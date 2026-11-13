"""Read actual image bytes independently of the R renderer and output resolver."""
import json,sys
from pathlib import Path
import nibabel as nib
import numpy as np
root=Path(sys.argv[1]); results=json.load(open(root/'results.json'))
checks=[]
failures=[]
for name, result in results.items():
    for key, paths in result['outputs'].items():
        for path in ([paths] if isinstance(paths,str) else paths):
            p=Path(path)
            assert p.exists(), (name,key,path)
            if p.is_file() and str(p).endswith(('.nii','.nii.gz')):
                img=nib.load(p); data=img.get_fdata()
                assert data.shape[:3] == (48,48,48), (name,key,data.shape)
                assert np.isfinite(data).all(), (name,key,'nonfinite')
                assert np.allclose(img.affine, nib.load(root/'in/t1.nii.gz').affine, atol=1e-4), (name,key,'affine')
                if name=='mcflirt' and key=='out_file': assert data.shape[3]==3
                if key in ('partial_volume_files','probability_maps'):
                    if not (data.min() >= -1e-5 and data.max() <= 1+1e-5):
                        failures.append({'tool':name,'output':key,'path':path,'minimum':float(data.min()),'maximum':float(data.max())})
                checks.append({'tool':name,'output':key,'shape':data.shape,'affine':img.affine.tolist()})
            elif p.suffix=='.h5' and p.is_file():
                assert p.stat().st_size > 0, (name,key,'empty composite transform')
            elif p.suffix=='.mat' and p.is_file():
                mat=np.loadtxt(p); assert mat.shape==(4,4) and np.isfinite(mat).all()
                assert abs(np.linalg.det(mat[:3,:3]))>1e-6
pves=results['fast']['outputs']['partial_volume_files']
assert len(pves)==3
corrected=nib.load(results['n4']['outputs']['output_image']).get_fdata()
bias=nib.load(results['n4']['outputs']['bias_image']).get_fdata()
original=nib.load(root/'in/t1.nii.gz').get_fdata()
mask=nib.load(root/'in/mask.nii.gz').get_fdata()>0
assert np.allclose(corrected[mask]*bias[mask], original[mask],rtol=2e-4,atol=1e-3)
# Compare the text products with image bytes, independently of the R wrapper.
bold=nib.load(results['mcflirt']['outputs']['out_file']).get_fdata()
expected_means=bold[mask].mean(axis=0)
meants_checks=[]
for ext in ('txt','tsv'):
    requested=root/'out'/f'requested_mean.{ext}'
    declared=Path(results[f'meants_{ext}']['outputs']['out_file'])
    assert declared == requested, (ext,'wrong declared text destination',str(declared))
    assert not requested.with_suffix('').exists(), (ext,'unexpected extensionless output')
    means=np.loadtxt(declared,ndmin=2)
    assert means.shape == (bold.shape[3],1), (ext,'wrong frame count or columns',means.shape)
    assert np.isfinite(means).all(), (ext,'nonfinite means')
    assert np.allclose(means[:,0],expected_means,rtol=1e-5,atol=1e-5), (ext,'incorrect masked means')
    meants_checks.append({'extension':ext,'rows':means.shape[0],
                          'max_absolute_error':float(np.max(np.abs(means[:,0]-expected_means)))})
json.dump({'status':'failed' if failures else 'passed','scope':'mechanical artifact contracts','checks':checks,'failures':failures,'n4_reconstruction':'passed','meants':meants_checks},open(root/'verification.json','w'),indent=2)
print(f'Checked {len(checks)} image artifacts, N4 multiplicative reconstruction, and both meants text outputs; {len(failures)} failures')
assert not failures, failures
