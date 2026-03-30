# parsing_nossaflex
testthat::test_that("parsing works as expected", {
  testthat::skip_on_ci()
  testthat::skip_on_cran()

  testthat::expect_snapshot({
    reading_nossaflex(path = testthat::test_path("fixtures", "nossaflex_filenames.txt")) |>
      parsing_nossaflex()
  })
})
