test_that("parsing_nossaflex returns a data.frame", {
  result <- parsing_nossaflex(c("NO01_SS125_A5.6_FL50_EX0"))
  expect_s3_class(result, "data.frame")
})

test_that("parsing_nossaflex extracts correct column names from standard format", {
  result <- parsing_nossaflex(c("NO01_SS125_A5.6_FL50_EX0"))
  expect_named(result, c("NO", "SS", "A", "FL", "EX"))
})

test_that("parsing_nossaflex extracts correct values", {
  result <- parsing_nossaflex(c("NO01_SS125_A5.6_FL50_EX0"))
  expect_equal(result$NO, "01")
  expect_equal(result$SS, "125")
  expect_equal(result$A, "5.6")
  expect_equal(result$FL, "50")
  expect_equal(result$EX, "0")
})

test_that("parsing_nossaflex handles multiple filenames", {
  result <- parsing_nossaflex(c("NO01_SS1s_A5.6_FL50_EX-2", "NO02_SS125_A5.6_FL50_EX+1"))
  expect_equal(nrow(result), 2L)
  expect_equal(result$NO, c("01", "02"))
  expect_equal(result$SS, c("1s", "125"))
  expect_equal(result$EX, c("-2", "+1"))
})

test_that("parsing_nossaflex handles filenames with roll name prefix", {
  result <- parsing_nossaflex(c("Test roll_NO01_SS250_A2.8_FL50_EX+2"))
  expect_true("T" %in% names(result))
  expect_equal(result$T, "est roll")
  expect_equal(result$NO, "01")
})

test_that("parsing_nossaflex handles aperture with decimal", {
  result <- parsing_nossaflex(c("NO01_SS500_A2.8_FL35_EX0"))
  expect_equal(result$A, "2.8")
})

test_that("parsing_nossaflex handles shutter speed in seconds format", {
  result <- parsing_nossaflex(c("NO01_SS2s_A5.6_FL50_EX0"))
  expect_equal(result$SS, "2s")
})

test_that("parsing_nossaflex handles negative exposure compensation", {
  result <- parsing_nossaflex(c("NO03_SS250_A8_FL50_EX-1"))
  expect_equal(result$EX, "-1")
})

test_that("parsing_custom throws not-implemented error", {
  expect_error(parsing_custom(c("NO01_SS125_A5.6_FL50_EX0")), "Not yet implemented")
})
