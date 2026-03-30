# renaming_nossaflex
testthat::test_that("renaming works as expected", {
  testthat::skip_on_ci()
  testthat::skip_on_cran()

  files <- list.files(path = testthat::test_path("fixtures"),
                      pattern = "jpg",
                      full.names = TRUE)
  test_directory <- withr::local_tempdir()
  test_files <- paste0(test_directory, "/", basename(files))
  file.copy(from = files,
            to = test_files)
  filenames <- reading_nossaflex(path = testthat::test_path("fixtures", "nossaflex_filenames.txt"))

  renaming_nossaflex(files = test_files, filenames = filenames, copy = FALSE)

  checkmate::expect_file_exists(x = paste0(dirname(test_files), "/",
                                           filenames,
                                           extension = unique(
                                             sub(pattern = ".*(?=\\.[A-Za-z0-9]{1,3}$)",
                                                 replacement = "",
                                                 x = files, perl = TRUE))
  ))
})
