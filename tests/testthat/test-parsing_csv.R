test_that("parsing_csv returns a data.frame", {
  result <- parsing_csv(test_path("fixtures", "analog_plus_test.csv"))
  expect_s3_class(result, "data.frame")
})

test_that("parsing_csv has expected columns", {
  result <- parsing_csv(test_path("fixtures", "analog_plus_test.csv"))
  expected_cols <- c(
    "NO", "SS", "A", "FL", "EX", "ISO", "Flash",
    "Date_Time_Original", "Latitude", "Longitude", "Northing", "Easting",
    "Camera_Brand", "Camera_Model", "Lens_Brand", "Lens_Model", "Stock"
  )
  expect_true(all(is.element(expected_cols, names(result))))
})

test_that("parsing_csv rows are ordered by NO", {
  result <- parsing_csv(test_path("fixtures", "analog_plus_test.csv"))
  expect_equal(result$NO, sort(result$NO))
})

test_that("parsing_csv strips f/ prefix from Aperture", {
  result <- parsing_csv(test_path("fixtures", "analog_plus_test.csv"))
  expect_false(any(grepl("f/", result$A, fixed = TRUE)))
  expect_equal(result$A[[1]], "5.6")
})

test_that("parsing_csv strips mm suffix from Focal", {
  result <- parsing_csv(test_path("fixtures", "analog_plus_test.csv"))
  expect_false(any(grepl("mm", result$FL, fixed = TRUE)))
  expect_equal(result$FL[[1]], "50")
})

test_that("parsing_csv strips EV suffix from Compensation", {
  result <- parsing_csv(test_path("fixtures", "analog_plus_test.csv"))
  expect_false(any(grepl("EV", result$EX, fixed = TRUE)))
  expect_equal(result$EX, c("0", "+1", "-1"))
})

test_that("parsing_csv formats Date_Time_Original as YYYY:MM:DD HH:MM:SS", {
  result <- parsing_csv(test_path("fixtures", "analog_plus_test.csv"))
  expect_equal(result$Date_Time_Original[[1]], "2025:11:03 08:14:00")
})

test_that("parsing_csv splits Camera into Brand and Model", {
  result <- parsing_csv(test_path("fixtures", "analog_plus_test.csv"))
  expect_equal(result$Camera_Brand[[1]], "Nikon")
  expect_equal(result$Camera_Model[[1]], "FA")
})

test_that("parsing_csv splits Camera with multi-word model correctly", {
  result <- parsing_csv(test_path("fixtures", "analog_plus_test.csv"))
  expect_equal(result$Camera_Brand[[3]], "Voigtländer")
  expect_equal(result$Camera_Model[[3]], "Vito 145")
})

test_that("parsing_csv splits Lens into Brand and Model", {
  result <- parsing_csv(test_path("fixtures", "analog_plus_test.csv"))
  expect_equal(result$Lens_Brand[[2]], "Sigma")
  expect_equal(result$Lens_Model[[2]], "28-70 f/2.8")
})

test_that("parsing_csv sets Lens_Model to NA for single-word lens", {
  result <- parsing_csv(test_path("fixtures", "analog_plus_test.csv"))
  expect_true(is.na(result$Lens_Model[[3]]))
})

test_that("parsing_csv sets Northing to 'N' and Easting to 'E'", {
  result <- parsing_csv(test_path("fixtures", "analog_plus_test.csv"))
  expect_true(all(result$Northing == "N"))
  expect_true(all(result$Easting == "E"))
})

test_that("parsing_csv errors on non-existent file", {
  expect_error(parsing_csv("nonexistent.csv"))
})
