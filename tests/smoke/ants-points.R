# Two noncommuting affines distinguish inversion, transform order and identity.
verify_ants_points <- function(root, run) {
  input <- function(name) file.path(root, "in", name)
  landmarks <- data.frame(x = c(0, 2, -1), y = c(0, -4, 3), z = c(0, 6, 5),
    t = 0, label = 1:3)
  utils::write.csv(landmarks, input("landmarks.csv"), row.names = FALSE, quote = FALSE)

  write_affine <- function(name, parameters) {
    writeLines(c("#Insight Transform File V1.0", "#Transform 0", "Transform: AffineTransform_double_3_3",
      paste("Parameters:", parameters), "FixedParameters: 0 0 0"), input(name))
  }
  write_affine("shift.tfm", "1 0 0 0 1 0 0 0 1 8 4 -2")
  write_affine("scale.tfm", "2 0 0 0 2 0 0 0 2 0 0 0")
  output <- file.path(root, "out", "mapped.csv")
  result <- run("ants_points", "ants.apply_transforms_to_points", dimension = 3L,
    input_file = input("landmarks.csv"), output_file = output,
    transforms = c(input("shift.tfm"), sprintf("[%s,1]", input("scale.tfm"))))

  # In this ANTs point command the translation is applied first, followed by
  # the inverse scale. All expected coordinates are exactly representable.
  expected <- transform(landmarks, x = (x + 8) / 2, y = (y + 4) / 2, z = (z - 2) / 2)
  observed <- utils::read.csv(output)
  stopifnot(identical(result$outputs$output_file, output),
    identical(names(observed), names(expected)), nrow(observed) == nrow(expected),
    all(as.matrix(observed) == as.matrix(expected)))
}
