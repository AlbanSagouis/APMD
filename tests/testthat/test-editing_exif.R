make_exif_metadata <- function(n = 2L) {
  data.table::data.table(
    NO = as.character(seq_len(n)),
    SS = rep("250", n),
    A  = rep("5.6", n),
    FL = rep("50", n),
    EX = rep("0", n)
  )
}

test_that("editing_exif errors when files count differs from metadata rows", {
  metadata <- make_exif_metadata(2L)
  expect_error(
    editing_exif(files = "one_file.jpg", metadata = metadata),
    "metadata must have as many rows as the length of files"
  )
})

test_that("editing_exif with mocked exif_call processes SS fraction format", {
  tmp <- withr::local_tempdir()
  jpg <- file.path(tmp, "test.jpg")
  file.create(jpg)

  metadata <- data.table::data.table(SS = "1/250", A = "5.6", FL = "50", EX = "0")

  local_mocked_bindings(
    exif_call = function(path, args, quiet) invisible(NULL),
    .package = "exiftoolr"
  )
  # Should run without error
  expect_no_error(
    editing_exif(files = jpg, metadata = metadata, verbose = FALSE)
  )
})

test_that("editing_exif with mocked exif_call processes SS seconds format", {
  tmp <- withr::local_tempdir()
  jpg <- file.path(tmp, "test.jpg")
  file.create(jpg)

  metadata <- data.table::data.table(SS = "2s", A = "5.6", FL = "50", EX = "0")

  local_mocked_bindings(
    exif_call = function(path, args, quiet) invisible(NULL),
    .package = "exiftoolr"
  )
  expect_no_error(
    editing_exif(files = jpg, metadata = metadata, verbose = FALSE)
  )
})

test_that("editing_exif with mocked exif_call processes SS numeric format", {
  tmp <- withr::local_tempdir()
  jpg <- file.path(tmp, "test.jpg")
  file.create(jpg)

  metadata <- data.table::data.table(SS = "250", A = "5.6", FL = "50", EX = "0")

  local_mocked_bindings(
    exif_call = function(path, args, quiet) invisible(NULL),
    .package = "exiftoolr"
  )
  expect_no_error(
    editing_exif(files = jpg, metadata = metadata, verbose = FALSE)
  )
})

test_that("editing_exif with mocked exif_call handles 'auto' SS values", {
  tmp <- withr::local_tempdir()
  jpg <- file.path(tmp, "test.jpg")
  file.create(jpg)

  metadata <- data.table::data.table(SS = "auto", A = "auto", FL = "50", EX = "0")

  local_mocked_bindings(
    exif_call = function(path, args, quiet) invisible(NULL),
    .package = "exiftoolr"
  )
  expect_no_error(
    editing_exif(files = jpg, metadata = metadata, verbose = FALSE)
  )
})

test_that("editing_exif with mocked exif_call handles extra_tags", {
  tmp <- withr::local_tempdir()
  jpg <- file.path(tmp, "test.jpg")
  file.create(jpg)

  metadata <- data.table::data.table(SS = "250", A = "5.6", FL = "50", EX = "0")

  local_mocked_bindings(
    exif_call = function(path, args, quiet) invisible(NULL),
    .package = "exiftoolr"
  )
  expect_no_error(
    editing_exif(
      files = jpg,
      metadata = metadata,
      extra_tags = c(Artist = "Jane Smith"),
      verbose = FALSE
    )
  )
})

test_that("editing_exif with mocked exif_call respects overwrite_original=TRUE", {
  tmp <- withr::local_tempdir()
  jpg <- file.path(tmp, "test.jpg")
  file.create(jpg)

  metadata <- data.table::data.table(SS = "250", A = "5.6", FL = "50", EX = "0")

  local_mocked_bindings(
    exif_call = function(path, args, quiet) invisible(NULL),
    .package = "exiftoolr"
  )
  expect_no_error(
    editing_exif(
      files = jpg,
      metadata = metadata,
      overwrite_original = TRUE,
      verbose = FALSE
    )
  )
})
