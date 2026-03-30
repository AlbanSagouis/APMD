# parsing_frames
testthat::test_that("parsing works as expected", {
  testthat::skip_on_ci()
  testthat::skip_on_cran()

  test_object <- parsing_frames(
    path = testthat::test_path("fixtures", "Berlin_Boat.frames")
  )

  testthat::expect_snapshot(test_object)
})
