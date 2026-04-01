make_exif_metadata <- function(n = 1L) {
  data.frame(
    SS = rep("250", n),
    A  = rep("5.6", n),
    FL = rep("50", n),
    EX = rep("0", n),
    Date_Time_Original = rep("2024:03:19 12:00:00", n)
  )
}

make_jpg_copy <- function(dir) {
  src <- system.file(
    "extdata", "service-pnp-fsac-1a35000-1a35300-1a35373r.jpg",
    package = "APMD"
  )
  dst <- file.path(dir, "test.jpg")
  file.copy(from = src, to = dst, overwrite = TRUE)
  dst
}

# Input validation ----

test_that("editing_exif errors when files count differs from metadata rows", {
  metadata <- make_exif_metadata(2L)
  expect_error(
    editing_exif(files = "one_file.jpg", metadata = metadata),
    "metadata must have as many rows as the length of files"
  )
})

# Class compatibility ----

test_that("editing_exif writes FocalLength and DateTimeOriginal from a data.frame", {
  tmp <- withr::local_tempdir()
  jpg <- make_jpg_copy(tmp)

  editing_exif(
    files = jpg,
    metadata = make_exif_metadata(),
    overwrite_original = TRUE,
    verbose = FALSE
  )
  result <- exiftoolr::exif_read(jpg)
  expect_equal(result[["FocalLength"]], 50)
  expect_equal(result[["DateTimeOriginal"]], "2024:03:19 12:00:00")
})

test_that("editing_exif writes FocalLength and DateTimeOriginal from a tibble", {
  tmp <- withr::local_tempdir()
  jpg <- make_jpg_copy(tmp)

  editing_exif(
    files = jpg,
    metadata = dplyr::as_tibble(make_exif_metadata()),
    overwrite_original = TRUE,
    verbose = FALSE
  )
  result <- exiftoolr::exif_read(jpg)
  expect_equal(result[["FocalLength"]], 50)
  expect_equal(result[["DateTimeOriginal"]], "2024:03:19 12:00:00")
})

test_that("editing_exif writes FocalLength and DateTimeOriginal from a data.table", {
  tmp <- withr::local_tempdir()
  jpg <- make_jpg_copy(tmp)

  editing_exif(
    files = jpg,
    metadata = data.table::as.data.table(make_exif_metadata()),
    overwrite_original = TRUE,
    verbose = FALSE
  )
  result <- exiftoolr::exif_read(jpg)
  expect_equal(result[["FocalLength"]], 50)
  expect_equal(result[["DateTimeOriginal"]], "2024:03:19 12:00:00")
})

# Aperture ----

test_that("editing_exif writes FNumber from A column", {
  tmp <- withr::local_tempdir()
  jpg <- make_jpg_copy(tmp)

  metadata <- data.frame(SS = "250", A = "2.8", FL = "50")
  editing_exif(files = jpg, metadata = metadata, overwrite_original = TRUE, verbose = FALSE)

  result <- exiftoolr::exif_read(jpg)
  expect_equal(result[["FNumber"]], 2.8)
})

# SS format handling ----

test_that("editing_exif writes ExposureTime=0.004 for SS fraction '1/250'", {
  tmp <- withr::local_tempdir()
  jpg <- make_jpg_copy(tmp)

  metadata <- data.frame(SS = "1/250", A = "5.6", FL = "50", EX = "0")
  editing_exif(files = jpg, metadata = metadata, overwrite_original = TRUE, verbose = FALSE)

  result <- exiftoolr::exif_read(jpg)
  expect_equal(result[["ExposureTime"]], 0.004)
})

test_that("editing_exif writes ExposureTime=2 for SS seconds '2s'", {
  tmp <- withr::local_tempdir()
  jpg <- make_jpg_copy(tmp)

  metadata <- data.frame(SS = "2s", A = "5.6", FL = "50", EX = "0")
  editing_exif(files = jpg, metadata = metadata, overwrite_original = TRUE, verbose = FALSE)

  result <- exiftoolr::exif_read(jpg)
  expect_equal(result[["ExposureTime"]], 2)
})

test_that("editing_exif writes ExposureTime=0.004 for SS numeric '250'", {
  tmp <- withr::local_tempdir()
  jpg <- make_jpg_copy(tmp)

  metadata <- data.frame(SS = "250", A = "5.6", FL = "50", EX = "0")
  editing_exif(files = jpg, metadata = metadata, overwrite_original = TRUE, verbose = FALSE)

  result <- exiftoolr::exif_read(jpg)
  expect_equal(result[["ExposureTime"]], 0.004)
})

test_that("editing_exif handles 'auto' SS and A values without error", {
  tmp <- withr::local_tempdir()
  jpg <- make_jpg_copy(tmp)

  metadata <- data.frame(SS = "auto", A = "auto", FL = "50", EX = "0")
  expect_no_error(
    editing_exif(files = jpg, metadata = metadata, overwrite_original = TRUE, verbose = FALSE)
  )
})

# Extra options ----

test_that("editing_exif writes extra_tags to file", {
  tmp <- withr::local_tempdir()
  jpg <- make_jpg_copy(tmp)

  editing_exif(
    files = jpg,
    metadata = make_exif_metadata(),
    extra_tags = c(Artist = "Jane Smith"),
    overwrite_original = TRUE,
    verbose = FALSE
  )
  result <- exiftoolr::exif_read(jpg)
  expect_equal(result[["Artist"]], "Jane Smith")
})

# Lens fields ----

test_that("editing_exif writes LensModel and LensMake", {
  tmp <- withr::local_tempdir()
  jpg <- make_jpg_copy(tmp)

  metadata <- data.frame(
    SS = "250", A = "2.8", FL = "24",
    Lens_Brand = "Nikon",
    Lens_Model = "AF Nikkor 24mm f/2.8D"
  )
  editing_exif(files = jpg, metadata = metadata, overwrite_original = TRUE, verbose = FALSE)

  result <- exiftoolr::exif_read(jpg)
  expect_equal(result[["LensModel"]], "AF Nikkor 24mm f/2.8D")
  expect_equal(result[["LensMake"]], "Nikon")
})

test_that("editing_exif writes LensInfo from focal length and aperture columns", {
  tmp <- withr::local_tempdir()
  jpg <- make_jpg_copy(tmp)

  metadata <- data.frame(
    SS = "250", A = "2.8", FL = "28",
    Lens_Model = "AF Zoom-Nikkor 28-105mm f/3.5-4.5D IF",
    Lens_Focal_Length = 28,
    Lens_Max_Focal_Length = 105,
    Lens_Maximum_Aperture = 3.6
  )
  editing_exif(files = jpg, metadata = metadata, overwrite_original = TRUE, verbose = FALSE)

  result <- exiftoolr::exif_read(jpg)
  expect_equal(result[["LensModel"]], "AF Zoom-Nikkor 28-105mm f/3.5-4.5D IF")
  expect_false(is.null(result[["LensInfo"]]))
})

# verbose ----

test_that("editing_exif with verbose=FALSE does not print args", {
  tmp <- withr::local_tempdir()
  jpg <- make_jpg_copy(tmp)

  expect_no_message(
    expect_output(
      editing_exif(
        files = jpg,
        metadata = make_exif_metadata(),
        overwrite_original = TRUE,
        verbose = FALSE
      ),
      NA  # no output expected
    )
  )
})

test_that("editing_exif with overwrite_original=FALSE creates a backup", {
  tmp <- withr::local_tempdir()
  jpg <- make_jpg_copy(tmp)

  editing_exif(
    files = jpg,
    metadata = make_exif_metadata(),
    overwrite_original = FALSE,
    verbose = FALSE
  )
  expect_true(file.exists(paste0(jpg, "_original")))
})

# add_lens_data_*() integration ----

test_that("add_lens_data_nikon_AF_24_D integrates with editing_exif to write LensModel", {
  tmp <- withr::local_tempdir()
  jpg <- make_jpg_copy(tmp)

  metadata <- cbind(
    data.frame(SS = "125", A = "2.8", FL = "24", Lens_Model = "AF Nikkor 24mm f/2.8D"),
    add_lens_data_nikon_AF_24_D()
  )
  editing_exif(files = jpg, metadata = metadata, overwrite_original = TRUE, verbose = FALSE)

  result <- exiftoolr::exif_read(jpg)
  expect_equal(result[["LensModel"]], "AF Nikkor 24mm f/2.8D")
})

test_that("delete_lens_data integrates with editing_exif without error", {
  tmp <- withr::local_tempdir()
  jpg <- make_jpg_copy(tmp)

  metadata <- cbind(
    data.frame(SS = "125", A = "2.8", FL = "24"),
    delete_lens_data()
  )
  expect_no_error(
    editing_exif(files = jpg, metadata = metadata, overwrite_original = TRUE, verbose = FALSE)
  )
})
