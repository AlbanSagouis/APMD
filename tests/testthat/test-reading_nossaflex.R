test_that("reading_nossaflex returns a character vector", {
  result <- reading_nossaflex(test_path("testdata", "nossaflex_filenames.txt"))
  expect_type(result, "character")
})

test_that("reading_nossaflex reads correct number of lines", {
  result <- reading_nossaflex(test_path("testdata", "nossaflex_filenames.txt"))
  expect_length(result, 2L)
})

test_that("reading_nossaflex reads correct content", {
  result <- reading_nossaflex(test_path("testdata", "nossaflex_filenames.txt"))
  expect_match(result[[1L]], "NO01")
  expect_match(result[[2L]], "NO02")
})

test_that("reading_nossaflex errors on non-existent file", {
  expect_error(reading_nossaflex("nonexistent_file.txt"))
})
