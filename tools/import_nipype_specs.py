#!/usr/bin/env python3
"""Import Nipype interfaces into niflowr JSON specs.

This script inspects Nipype interface classes and writes niflowr-compatible
spec files to `inst/specs/`.

Examples
--------
python tools/import_nipype_specs.py \
  --manifest tools/nipype_manifest.json \
  --overwrite

python tools/import_nipype_specs.py \
  --interface nipype.interfaces.fsl.preprocess:BET \
  --interface nipype.interfaces.fsl.preprocess:FLIRT \
  --dry-run
"""

from __future__ import annotations

import argparse
import datetime as dt
import importlib
import inspect
import json
import pathlib
import pkgutil
import re
from dataclasses import dataclass
from typing import Any, Dict, List, Optional, Sequence, Tuple


SCHEMA_VERSION = "0.1.0"
SKIP_TRAITS = {"trait_added", "trait_modified"}


@dataclass
class InterfaceJob:
    interface: str
    spec_id: Optional[str] = None
    title: Optional[str] = None
    description: Optional[str] = None


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--interface",
        action="append",
        default=[],
        help="Interface spec in form 'module.path:ClassName' or 'module.path.ClassName'.",
    )
    parser.add_argument(
        "--manifest",
        type=pathlib.Path,
        help="Path to JSON manifest with an array of interface entries.",
    )
    parser.add_argument(
        "--discover-root",
        action="append",
        default=[],
        help=(
            "Discover interfaces by scanning a module root, e.g. "
            "'nipype.interfaces.fsl'. Can be passed multiple times."
        ),
    )
    parser.add_argument(
        "--discover-regex",
        help="Optional regex filter applied to fully-qualified class names during discovery.",
    )
    parser.add_argument(
        "--discover-max",
        type=int,
        help="Maximum number of discovered interfaces to include.",
    )
    parser.add_argument(
        "--output-dir",
        type=pathlib.Path,
        default=pathlib.Path("inst/specs"),
        help="Directory where generated niflowr JSON specs are written.",
    )
    parser.add_argument(
        "--schema",
        type=pathlib.Path,
        default=pathlib.Path("inst/schema/niflowr-spec-0.1.0.json"),
        help="Path to niflowr JSON schema for optional validation.",
    )
    parser.add_argument(
        "--overwrite",
        action="store_true",
        help="Overwrite existing output files.",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print what would be written without writing files.",
    )
    parser.add_argument(
        "--include-noncli-inputs",
        action="store_true",
        help="Include non-mandatory input traits that do not have argstr metadata.",
    )
    parser.add_argument(
        "--include-unresolved-outputs",
        action="store_true",
        help="Include output entries even when output path cannot be inferred.",
    )
    parser.add_argument(
        "--imported-at",
        help=(
            "Explicit ISO-8601 timestamp for origin.imported_at. "
            "Use with CI for reproducible outputs."
        ),
    )
    parser.add_argument(
        "--omit-imported-at",
        action="store_true",
        help="Do not write origin.imported_at (deterministic output).",
    )
    return parser.parse_args()


def parse_interface_ref(ref: str) -> Tuple[str, str]:
    if ":" in ref:
        module_name, class_name = ref.rsplit(":", 1)
        return module_name, class_name
    if "." not in ref:
        raise ValueError(
            f"Invalid interface reference '{ref}'. Use module:Class or module.Class."
        )
    module_name, class_name = ref.rsplit(".", 1)
    return module_name, class_name


def camel_to_snake(name: str) -> str:
    parts = []
    for chunk in name.split("_"):
        if not chunk:
            continue
        s1 = re.sub(r"(.)([A-Z][a-z]+)", r"\1_\2", chunk)
        s2 = re.sub(r"([a-z0-9])([A-Z])", r"\1_\2", s1)
        parts.append(s2.lower())
    return "_".join(parts)


def infer_provider(module_name: str) -> str:
    parts = module_name.split(".")
    if "interfaces" in parts:
        idx = parts.index("interfaces")
        if idx + 1 < len(parts):
            return parts[idx + 1].lower()
    if len(parts) > 1:
        return parts[-2].lower()
    return parts[0].lower()


def first_sentence(doc: Optional[str]) -> Optional[str]:
    if not doc:
        return None
    for raw_line in doc.splitlines():
        line = raw_line.strip()
        if line:
            return line
    return None


def is_undefined(value: Any) -> bool:
    if value is None:
        return False
    class_name = value.__class__.__name__.lower()
    if "undefined" in class_name:
        return True
    value_repr = repr(value).strip().lower()
    return value_repr in {"<undefined>", "undefined"}


def to_json_value(value: Any) -> Any:
    if is_undefined(value):
        return None
    if isinstance(value, (str, int, float, bool)) or value is None:
        return value
    if isinstance(value, (list, tuple)):
        return [to_json_value(v) for v in value]
    if isinstance(value, dict):
        return {str(k): to_json_value(v) for k, v in value.items()}
    return str(value)


def trait_attr(trait: Any, key: str, default: Any = None) -> Any:
    if hasattr(trait, key):
        return getattr(trait, key)
    trait_type = getattr(trait, "trait_type", None)
    if trait_type is not None and hasattr(trait_type, key):
        return getattr(trait_type, key)
    return default


def infer_param_type(trait: Any, argstr: Optional[str]) -> str:
    trait_type = getattr(trait, "trait_type", None)
    type_name = type(trait_type).__name__.lower() if trait_type is not None else ""

    if "file" == type_name:
        return "file"
    if "directory" in type_name or type_name == "dir":
        return "dir"
    if "enum" in type_name:
        return "enum"
    if "bool" in type_name:
        if isinstance(argstr, str) and "%" not in argstr:
            return "flag"
        return "bool"
    if type_name in {"int", "cint", "long"}:
        return "int"
    if "float" in type_name or type_name in {"double", "cfloat"}:
        return "double"
    if type_name in {"list", "tuple", "set", "inputmultiobject", "outputmultiobject"}:
        return "list"
    if "compound" in type_name or "either" in type_name:
        return "list" if isinstance(argstr, str) and "%s" in argstr else "string"
    if type_name in {"str", "string", "unicode"}:
        return "string"
    return "string"


def enum_choices(trait: Any) -> Optional[List[Any]]:
    trait_type = getattr(trait, "trait_type", None)
    values = None
    if trait_type is not None:
        values = getattr(trait_type, "values", None)
    if values is None:
        values = getattr(trait, "values", None)
    if values is None:
        return None
    as_list = [to_json_value(v) for v in list(values)]
    return as_list if as_list else None


def normalize_name_list(values: Any) -> Optional[List[str]]:
    if values is None:
        return None
    if isinstance(values, str):
        return [values]
    if isinstance(values, (list, tuple)):
        out = [str(v) for v in values if v is not None]
        return out if out else None
    return [str(values)]


def convert_name_template(name_template: str, source_name: str) -> str:
    # Nipype templates are often old-style `%s` strings.
    template = name_template.replace("%s", "{" + source_name + "}")
    return template


def infer_output_path(
    output_name: str,
    output_trait: Any,
    input_names: Sequence[str],
) -> Optional[Dict[str, str]]:
    if output_name in input_names:
        return {"from_input": output_name}

    name_source = trait_attr(output_trait, "name_source")
    name_source_list = normalize_name_list(name_source)
    if name_source_list:
        source = name_source_list[0]
        if source in input_names:
            name_template = trait_attr(output_trait, "name_template")
            if isinstance(name_template, str) and name_template:
                return {"template": convert_name_template(name_template, source)}
            return {"from_input": source}

    return None


def infer_output_type(output_trait: Any) -> str:
    trait_type = getattr(output_trait, "trait_type", None)
    type_name = type(trait_type).__name__.lower() if trait_type is not None else ""
    if type_name == "file":
        return "file"
    if "directory" in type_name:
        return "dir"
    return "text"


def load_interface_class(ref: str) -> Tuple[str, str, Any]:
    module_name, class_name = parse_interface_ref(ref)
    module = importlib.import_module(module_name)
    cls = getattr(module, class_name)
    if not inspect.isclass(cls):
        raise TypeError(f"Reference {ref} resolved to non-class object: {cls!r}")
    return module_name, class_name, cls


def collect_input_params(
    iface: Any,
    include_noncli_inputs: bool,
) -> Dict[str, Dict[str, Any]]:
    params: Dict[str, Dict[str, Any]] = {}
    traits_map = iface.inputs.traits()
    input_values = iface.inputs.get()

    for name, trait in sorted(traits_map.items()):
        if name in SKIP_TRAITS or name.startswith("_"):
            continue

        argstr = trait_attr(trait, "argstr")
        mandatory = bool(trait_attr(trait, "mandatory", False))

        if not include_noncli_inputs and argstr in (None, "") and not mandatory:
            continue

        param_type = infer_param_type(trait, argstr)
        entry: Dict[str, Any] = {"type": param_type}

        desc = trait_attr(trait, "desc")
        if isinstance(desc, str) and desc.strip():
            entry["desc"] = desc.strip()

        if mandatory:
            entry["required"] = True

        default = input_values.get(name)
        if not is_undefined(default):
            json_default = to_json_value(default)
            if json_default not in (None, ""):
                entry["default"] = json_default

        if param_type == "enum":
            choices = enum_choices(trait)
            if choices:
                entry["choices"] = choices

        cli_block: Dict[str, Any] = {}
        if isinstance(argstr, str) and argstr.strip():
            cli_block["argstr"] = argstr.strip()

        position = trait_attr(trait, "position")
        if isinstance(position, int):
            cli_block["position"] = position

        sep = trait_attr(trait, "sep")
        if isinstance(sep, str) and sep:
            cli_block["sep"] = sep

        repeat = trait_attr(trait, "repeat")
        if isinstance(repeat, bool) and repeat:
            cli_block["repeat"] = True

        if cli_block:
            entry["cli"] = cli_block

        validate_block: Dict[str, Any] = {}
        exists = trait_attr(trait, "exists")
        if param_type in {"file", "dir"} and isinstance(exists, bool) and exists:
            validate_block["exists"] = True

        low = trait_attr(trait, "low")
        if isinstance(low, (int, float)):
            validate_block["min"] = low

        high = trait_attr(trait, "high")
        if isinstance(high, (int, float)):
            validate_block["max"] = high

        if validate_block:
            entry["validate"] = validate_block

        constraints: Dict[str, List[str]] = {}
        xor_vals = normalize_name_list(trait_attr(trait, "xor"))
        if xor_vals:
            constraints["xor"] = xor_vals

        req_vals = normalize_name_list(trait_attr(trait, "requires"))
        if req_vals:
            constraints["requires"] = req_vals

        if constraints:
            entry["constraints"] = constraints

        params[name] = entry

    return params


def collect_outputs(
    iface: Any,
    input_names: Sequence[str],
    include_unresolved_outputs: bool,
) -> Dict[str, Dict[str, Any]]:
    outputs: Dict[str, Dict[str, Any]] = {}
    output_spec = getattr(iface, "output_spec", None)
    if output_spec is None:
        return outputs

    output_traits = output_spec().traits()
    for name, trait in sorted(output_traits.items()):
        if name in SKIP_TRAITS or name.startswith("_"):
            continue

        path_block = infer_output_path(name, trait, input_names)
        if path_block is None and not include_unresolved_outputs:
            continue
        if path_block is None:
            path_block = {"template": f"{{{name}}}"}

        outputs[name] = {
            "type": infer_output_type(trait),
            "path": path_block,
            "must_exist": False,
        }
    return outputs


def build_spec(
    job: InterfaceJob,
    nipype_version: str,
    include_noncli_inputs: bool,
    include_unresolved_outputs: bool,
    imported_at: Optional[str],
) -> Tuple[str, Dict[str, Any]]:
    module_name, class_name, cls = load_interface_class(job.interface)
    iface = cls()
    provider = infer_provider(module_name)

    spec_id = job.spec_id or f"{provider}.{camel_to_snake(class_name)}"
    title = job.title or f"{provider.upper()} {class_name}"
    description = job.description or first_sentence(inspect.getdoc(cls))

    command = getattr(iface, "_cmd", None)
    if not isinstance(command, str) or not command.strip():
        command = camel_to_snake(class_name)

    inputs = collect_input_params(iface, include_noncli_inputs)
    outputs = collect_outputs(
        iface,
        input_names=list(inputs.keys()),
        include_unresolved_outputs=include_unresolved_outputs,
    )

    origin: Dict[str, Any] = {
        "source": "nipype",
        "nipype_class": f"{module_name}.{class_name}",
        "nipype_version": nipype_version,
    }
    if imported_at is not None:
        origin["imported_at"] = imported_at

    spec: Dict[str, Any] = {
        "spec_version": SCHEMA_VERSION,
        "id": spec_id,
        "title": title,
        "command": command.strip(),
        "inputs": inputs,
        "outputs": outputs,
        "runtime": {"container": {"type": "none"}},
        "origin": origin,
    }
    if description:
        spec["description"] = description
    return spec_id, spec


def load_manifest(path: pathlib.Path) -> List[InterfaceJob]:
    payload = json.loads(path.read_text())
    if not isinstance(payload, list):
        raise ValueError("Manifest JSON must be an array.")

    jobs: List[InterfaceJob] = []
    for item in payload:
        if not isinstance(item, dict):
            raise ValueError("Manifest entries must be objects.")
        interface = item.get("interface")
        if not interface:
            raise ValueError("Manifest entry missing required key: interface")
        jobs.append(
            InterfaceJob(
                interface=str(interface),
                spec_id=item.get("id"),
                title=item.get("title"),
                description=item.get("description"),
            )
        )
    return jobs


def discover_interface_jobs(
    roots: Sequence[str],
    regex: Optional[str] = None,
    max_items: Optional[int] = None,
) -> List[InterfaceJob]:
    pattern = re.compile(regex) if regex else None
    discovered: List[InterfaceJob] = []
    seen: set[str] = set()

    for root in roots:
        pkg = importlib.import_module(root)
        if not hasattr(pkg, "__path__"):
            continue

        for mod_info in pkgutil.walk_packages(pkg.__path__, prefix=pkg.__name__ + "."):
            try:
                module = importlib.import_module(mod_info.name)
            except Exception:
                # Some Nipype submodules require optional dependencies.
                continue

            for _, cls in inspect.getmembers(module, inspect.isclass):
                if cls.__module__ != module.__name__:
                    continue
                fqcn = f"{cls.__module__}.{cls.__name__}"
                if fqcn in seen:
                    continue
                seen.add(fqcn)

                if pattern and not pattern.search(fqcn):
                    continue
                if not hasattr(cls, "input_spec") or not hasattr(cls, "_cmd"):
                    continue
                cmd = getattr(cls, "_cmd", None)
                if not isinstance(cmd, str) or not cmd.strip():
                    continue

                discovered.append(InterfaceJob(interface=fqcn))
                if max_items is not None and len(discovered) >= max_items:
                    return discovered

    return discovered


def collect_jobs(args: argparse.Namespace) -> List[InterfaceJob]:
    jobs: List[InterfaceJob] = []
    for ref in args.interface:
        jobs.append(InterfaceJob(interface=ref))
    if args.manifest:
        jobs.extend(load_manifest(args.manifest))
    if args.discover_root:
        jobs.extend(
            discover_interface_jobs(
                roots=args.discover_root,
                regex=args.discover_regex,
                max_items=args.discover_max,
            )
        )
    if not jobs:
        raise ValueError(
            "No interfaces requested. Use --interface, --manifest, or --discover-root."
        )

    deduped: List[InterfaceJob] = []
    seen: set[str] = set()
    for job in jobs:
        if job.interface in seen:
            continue
        seen.add(job.interface)
        deduped.append(job)
    return deduped


def validate_specs(schema_path: pathlib.Path, specs: Sequence[Dict[str, Any]]) -> None:
    if not schema_path.exists():
        print(f"[warn] Schema not found: {schema_path} (skipping validation)")
        return
    try:
        import jsonschema  # type: ignore
    except Exception:
        print("[warn] jsonschema is not installed; skipping schema validation")
        return

    schema = json.loads(schema_path.read_text())
    validator = jsonschema.Draft202012Validator(schema)
    for spec in specs:
        errors = sorted(validator.iter_errors(spec), key=lambda e: list(e.path))
        if errors:
            messages = "; ".join(err.message for err in errors)
            raise ValueError(f"Schema validation failed for {spec['id']}: {messages}")


def main() -> int:
    args = parse_args()
    try:
        jobs = collect_jobs(args)
    except Exception as exc:
        print(f"[error] {exc}")
        return 2

    try:
        nipype = importlib.import_module("nipype")
    except Exception as exc:
        print("[error] Could not import 'nipype'.")
        print(f"        {exc}")
        return 2

    nipype_version = str(getattr(nipype, "__version__", "unknown"))
    imported_at: Optional[str]
    if args.omit_imported_at:
        imported_at = None
    elif args.imported_at:
        imported_at = args.imported_at
    else:
        imported_at = dt.datetime.now(dt.timezone.utc).isoformat()

    generated: List[Tuple[pathlib.Path, Dict[str, Any]]] = []

    for job in jobs:
        try:
            spec_id, spec = build_spec(
                job=job,
                nipype_version=nipype_version,
                include_noncli_inputs=args.include_noncli_inputs,
                include_unresolved_outputs=args.include_unresolved_outputs,
                imported_at=imported_at,
            )
        except Exception as exc:
            print(f"[error] Failed to build {job.interface}: {exc}")
            return 1

        out_path = args.output_dir / f"{spec_id}.json"
        generated.append((out_path, spec))

    try:
        validate_specs(args.schema, [spec for _, spec in generated])
    except Exception as exc:
        print(f"[error] {exc}")
        return 1

    for out_path, spec in generated:
        rel = str(out_path)
        if out_path.exists() and not args.overwrite:
            print(f"[skip] {rel} exists (use --overwrite)")
            continue
        if args.dry_run:
            print(f"[dry-run] would write {rel}")
            continue
        out_path.parent.mkdir(parents=True, exist_ok=True)
        out_path.write_text(json.dumps(spec, indent=2) + "\n")
        print(f"[write] {rel}")

    print(f"[done] processed {len(generated)} interface(s)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
