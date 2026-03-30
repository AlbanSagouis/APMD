# parsing_json
testthat::test_that("parsing works as expected", {
  testthat::skip_on_ci()
  testthat::skip_on_cran()

  test_object <- parsing_json(
    path = testthat::test_path("fixtures", "test roll FA Berlin.json")
  )

  testthat::expect_snapshot(test_object)
})
