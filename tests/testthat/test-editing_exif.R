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
