test_that("renaming_nossaflex errors when files have no extension", {
  expect_error(
    renaming_nossaflex(files = "photo_without_extension", filenames = "new_name"),
    "files must have an extension"
  )
})

test_that("renaming_nossaflex errors when files have mixed extensions", {
  expect_error(
    renaming_nossaflex(
      files = c("photo1.jpg", "photo2.png"),
      filenames = c("new1", "new2")
    ),
    "files must all have the same extension"
  )
})

test_that("renaming_nossaflex renames files and returns named logical vector", {
  tmp <- withr::local_tempdir()
  src_files <- file.path(tmp, c("img001.jpg", "img002.jpg"))
  file.create(src_files)

  result <- renaming_nossaflex(
    files     = src_files,
    filenames = c("NO01_SS250_A5.6_FL50_EX0", "NO02_SS125_A5.6_FL50_EX0"),
    copy      = FALSE
  )

  expect_type(result, "logical")
  expect_true(all(result))
  expect_true(file.exists(file.path(tmp, "NO01_SS250_A5.6_FL50_EX0.jpg")))
  expect_true(file.exists(file.path(tmp, "NO02_SS125_A5.6_FL50_EX0.jpg")))
})

test_that("renaming_nossaflex with copy=TRUE creates backup files", {
  tmp <- withr::local_tempdir()
  src_files <- file.path(tmp, c("img001.jpg", "img002.jpg"))
  file.create(src_files)

  renaming_nossaflex(
    files     = src_files,
    filenames = c("NO01_SS250_A5.6_FL50_EX0", "NO02_SS125_A5.6_FL50_EX0"),
    copy      = TRUE
  )

  expect_true(file.exists(file.path(tmp, "img001_copy.jpg")))
  expect_true(file.exists(file.path(tmp, "img002_copy.jpg")))
})

test_that("renaming_nossaflex result is named by new file paths", {
  tmp <- withr::local_tempdir()
  src_files <- file.path(tmp, c("img001.jpg", "img002.jpg"))
  file.create(src_files)

  result <- renaming_nossaflex(
    files     = src_files,
    filenames = c("NO01_SS250_A5.6_FL50_EX0", "NO02_SS125_A5.6_FL50_EX0"),
    copy      = FALSE
  )

  expect_named(result)
  expect_match(names(result)[[1L]], "NO01_SS250_A5\\.6_FL50_EX0\\.jpg")
})
