# Insert_missing_records
testthat::test_that("insert_missing_records works as expected with NOSSAFLEX", {
  testthat::skip_on_ci()
  testthat::skip_on_cran()

  metadata <- reading_nossaflex(path = testthat::test_path("testdata", "nossaflex_filenames.txt")) |>
    parsing_nossaflex()
  new_rows <- data.frame(T = "est roll", NO = "02", SS = "125",
                         A = "1.4", FL = "50", EX = "0")

  testthat::expect_snapshot({
    insert_missing_records(metadata = metadata, row_indices = 2L, new_rows = new_rows)
  })
})

testthat::test_that("insert_missing_records works as expected with JSON", {
  testthat::skip_on_ci()
  testthat::skip_on_cran()

  metadata <- parsing_json(path = testthat::test_path("testdata",
                                                      "nossaflex_Vito_70_test-week.txt"))
  new_rows <- data.frame(
    Roll_Name    = rep("Test-week", 3),
    Roll_Number  = rep("005", 3),
    Camera_Brand = rep("Voigtlaender", 3),
    Camera_Model = rep("Vito 70", 3),
    NO = 5:7,
    SS = rep("auto", 3),
    A  = rep("auto", 3)
  )
  testthat::expect_snapshot({
    insert_missing_records(metadata = metadata, row_indices = 5:7, new_rows = new_rows,
                           extrapolate_data = TRUE)
  })
})

testthat::test_that("insert_missing_records works as expected with JSON and extrapolation", {
  testthat::skip_on_ci()
  testthat::skip_on_cran()

  metadata <- parsing_json(path = testthat::test_path("testdata",
                                                      "nossaflex_Vito_70_test-week.txt"))
  new_rows <- data.frame(
    Roll_Name    = rep("Test-week", 3),
    Roll_Number  = rep("005", 3),
    Camera_Brand = rep("Voigtlaender", 3),
    Camera_Model = rep("Vito 70", 3),
    NO = 5:7,
    SS = rep("auto", 3),
    A  = rep("auto", 3)
  )
  testthat::expect_snapshot({
    insert_missing_records(metadata = metadata, row_indices = 5:7, new_rows = new_rows,
                           extrapolate_data = FALSE)
  })
})

# testthat::test_that("insert_missing_records works as expected when adding at the end of the roll", {
#   testthat::skip_on_ci()
#   testthat::skip_on_cran()
#
# })
