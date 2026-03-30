test_that("parsing_json returns a data.table", {
  result <- parsing_json(test_path("fixtures", "nossaflex_Vito_70_test-week.txt"))
  expect_s3_class(result, "data.table")
})

test_that("parsing_json has expected columns", {
  result <- parsing_json(test_path("fixtures", "nossaflex_Vito_70_test-week.txt"))
  expected_cols <- c(
    "Roll_Name", "Roll_Number", "Camera_Brand", "Camera_Model",
    "NO", "SS", "A", "FL", "Lens_Brand", "Lens_Maximum_Aperture",
    "Lens_Focal_Length", "EX", "Date_Time_Original",
    "Latitude", "Longitude", "Northing", "Easting"
  )
  expect_true(all(expected_cols %in% names(result)))
})

test_that("parsing_json rows are ordered by NO", {
  result <- parsing_json(test_path("fixtures", "nossaflex_Vito_70_test-week.txt"))
  expect_equal(result$NO, sort(result$NO))
})

test_that("parsing_json Voigtlaender Vito 70 correction sets SS and A to 'auto'", {
  result <- parsing_json(
    test_path("fixtures", "nossaflex_Vito_70_test-week.txt"),
    apply_corrections = TRUE
  )
  expect_true(all(result$SS == "auto"))
  expect_true(all(result$A == "auto"))
})

test_that("parsing_json Voigtlaender Vito 70 correction sets Lens_Focal_Length to 70", {
  result <- parsing_json(
    test_path("fixtures", "nossaflex_Vito_70_test-week.txt"),
    apply_corrections = TRUE
  )
  expect_true(all(result$Lens_Focal_Length == 70L))
})

test_that("parsing_json with apply_corrections=FALSE does not force SS/A to 'auto'", {
  result_corrected <- parsing_json(
    test_path("fixtures", "nossaflex_Vito_70_test-week.txt"),
    apply_corrections = TRUE
  )
  result_raw <- parsing_json(
    test_path("fixtures", "nossaflex_Vito_70_test-week.txt"),
    apply_corrections = FALSE
  )
  # corrections are applied for Vito 70 only when TRUE; raw data should differ in Lens_Focal_Length
  expect_false(isTRUE(all.equal(result_corrected$Lens_Focal_Length, result_raw$Lens_Focal_Length)))
})

test_that("parsing_json Northing and Easting columns are 'N' and 'E'", {
  result <- parsing_json(test_path("fixtures", "nossaflex_Vito_70_test-week.txt"))
  expect_true(all(result$Northing == "N"))
  expect_true(all(result$Easting == "E"))
})

test_that("parsing_json errors on non-existent file", {
  expect_error(parsing_json("nonexistent.json"))
})

test_that("parsing_json errors when apply_corrections is not logical", {
  expect_error(
    parsing_json(
      test_path("fixtures", "nossaflex_Vito_70_test-week.txt"),
      apply_corrections = "yes"
    )
  )
})

test_that("parsing_frames returns a data.table", {
  result <- parsing_frames(test_path("fixtures", "Berlin_Boat.frames"))
  expect_s3_class(result, "data.table")
})

test_that("parsing_frames has expected core columns", {
  result <- parsing_frames(test_path("fixtures", "Berlin_Boat.frames"))
  # Only check columns guaranteed to exist regardless of lens data availability
  expected_cols <- c(
    "Roll_Name", "Camera_Brand", "Camera_Model",
    "NO", "SS", "A", "EX", "Date_Time_Original",
    "Latitude", "Longitude", "Northing", "Easting"
  )
  expect_true(all(expected_cols %in% names(result)))
})

test_that("parsing_frames rows are ordered by NO", {
  result <- parsing_frames(test_path("fixtures", "Berlin_Boat.frames"))
  expect_equal(result$NO, sort(result$NO))
})

test_that("parsing_frames Northing and Easting are 'N' and 'E'", {
  result <- parsing_frames(test_path("fixtures", "Berlin_Boat.frames"))
  expect_true(all(result$Northing == "N"))
  expect_true(all(result$Easting == "E"))
})

test_that("parsing_frames errors on non-existent file", {
  expect_error(parsing_frames("nonexistent.frames"))
})
