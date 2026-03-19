make_metadata <- function() {
  data.table::data.table(
    NO = c("01", "02", "03"),
    SS = c("250", "125", "60"),
    A  = c("5.6", "8", "11")
  )
}

test_that("insert_missing_records rejects non-data.table metadata", {
  metadata <- as.data.frame(make_metadata())
  new_row <- data.frame(NO = "02", SS = "250", A = "5.6")
  expect_error(insert_missing_records(metadata, 2L, new_row))
})

test_that("insert_missing_records rejects row_indices below 1", {
  new_row <- data.frame(NO = "00", SS = "250", A = "5.6")
  expect_error(insert_missing_records(make_metadata(), 0L, new_row))
})

test_that("insert_missing_records rejects non-integer row_indices", {
  new_row <- data.frame(NO = "02", SS = "250", A = "5.6")
  expect_error(insert_missing_records(make_metadata(), "a", new_row))
})

test_that("insert_missing_records rejects mismatched row_indices and new_rows lengths", {
  new_rows <- data.frame(NO = c("02", "03"), SS = c("250", "125"), A = c("5.6", "8"))
  expect_error(insert_missing_records(make_metadata(), 2L, new_rows))
})

test_that("insert_missing_records inserts one row and returns correct row count", {
  new_row <- data.frame(NO = "02", SS = "500", A = "4")
  result <- insert_missing_records(make_metadata(), 2L, new_row)
  expect_equal(nrow(result), 4L)
})

test_that("insert_missing_records renumbers NO sequentially after insertion", {
  new_row <- data.frame(NO = "02", SS = "500", A = "4")
  result <- insert_missing_records(make_metadata(), 2L, new_row)
  expect_equal(result$NO, c("01", "02", "03", "04"))
})

test_that("insert_missing_records pads NO to 2 digits", {
  new_row <- data.frame(NO = "02", SS = "500", A = "4")
  result <- insert_missing_records(make_metadata(), 2L, new_row)
  expect_true(all(nchar(result$NO) == 2L))
})

test_that("insert_missing_records inserts row at correct position", {
  new_row <- data.frame(NO = "02", SS = "500", A = "4")
  result <- insert_missing_records(make_metadata(), 2L, new_row)
  # inserted row is at position 2 (before original row 2)
  expect_equal(result$SS[[2L]], "500")
  expect_equal(result$SS[[3L]], "125")
})

test_that("insert_missing_records inserts multiple rows in correct order", {
  new_rows <- data.frame(
    NO = c("02", "03"),
    SS = c("500", "1000"),
    A  = c("4",   "2.8")
  )
  result <- insert_missing_records(make_metadata(), c(2L, 3L), new_rows)
  expect_equal(nrow(result), 5L)
  expect_equal(result$NO, c("01", "02", "03", "04", "05"))
})

test_that("insert_missing_records preserves unaffected rows", {
  new_row <- data.frame(NO = "02", SS = "500", A = "4")
  result <- insert_missing_records(make_metadata(), 2L, new_row)
  expect_equal(result$SS[[1L]], "250")  # original row 1 unchanged
  expect_equal(result$SS[[4L]], "60")   # original row 3 unchanged
})

make_geo_metadata <- function() {
  data.table::data.table(
    NO                = c("01", "02", "03"),
    SS                = c("250", "125", "60"),
    Date_Time_Original = c("2024-01-01 10:00:00", "2024-01-02 12:00:00", "2024-01-03 14:00:00"),
    Latitude          = c("52.0", "52.5", "53.0"),
    Longitude         = c("13.0", "13.5", "14.0"),
    Northing          = c("N", "N", "N"),
    Easting           = c("E", "E", "E")
  )
}

test_that("insert_missing_records with extrapolate_data=TRUE fills Date_Time_Original", {
  new_row <- data.frame(NO = "02")
  result <- insert_missing_records(make_geo_metadata(), 2L, new_row, extrapolate_data = TRUE)
  expect_false(is.na(result$Date_Time_Original[[2L]]))
})

test_that("insert_missing_records with extrapolate_data=TRUE averages Latitude", {
  new_row <- data.frame(NO = "02")
  result <- insert_missing_records(make_geo_metadata(), 2L, new_row, extrapolate_data = TRUE)
  # Averages rows I=2 and I+1=3 from original: (52.5 + 53.0) / 2 = 52.75
  expect_equal(as.numeric(result$Latitude[[2L]]), 52.75)
})

test_that("insert_missing_records with extrapolate_data=TRUE averages Longitude", {
  new_row <- data.frame(NO = "02")
  result <- insert_missing_records(make_geo_metadata(), 2L, new_row, extrapolate_data = TRUE)
  # Averages rows I=2 and I+1=3 from original: (13.5 + 14.0) / 2 = 13.75
  expect_equal(as.numeric(result$Longitude[[2L]]), 13.75)
})

test_that("insert_missing_records with extrapolate_data=TRUE preserves matching Northing/Easting", {
  new_row <- data.frame(NO = "02")
  result <- insert_missing_records(make_geo_metadata(), 2L, new_row, extrapolate_data = TRUE)
  expect_equal(result$Northing[[2L]], "N")
  expect_equal(result$Easting[[2L]], "E")
})

test_that("insert_missing_records with extrapolate_data=FALSE leaves geo columns as NA", {
  metadata <- data.table::data.table(
    NO = c("01", "02", "03"),
    Date_Time_Original = c("2024-01-01 10:00:00", "2024-01-01 12:00:00", "2024-01-01 14:00:00"),
    Latitude  = c("52.0", "52.5", "53.0"),
    Longitude = c("13.0", "13.5", "14.0"),
    Northing  = c("N", "N", "N"),
    Easting   = c("E", "E", "E")
  )
  new_row <- data.frame(NO = "02")
  result <- insert_missing_records(metadata, 2L, new_row, extrapolate_data = FALSE)
  expect_true(is.na(result$Latitude[[2L]]))
  expect_true(is.na(result$Longitude[[2L]]))
})
