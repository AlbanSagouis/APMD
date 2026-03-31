lens_cols <- c(
  "Nikon:LensIDNumber", "Nikon:LensFStops",
  "Nikon:MinFocalLength", "Nikon:MaxFocalLength",
  "Nikon:MaxApertureAtMinFocal", "Nikon:MaxApertureAtMaxFocal",
  "Nikon:MCUVersion", "Nikon:LensType",
  "Nikon:LensSpec", "Nikon:LensID"
)

test_that("add_lens_data_nikon_AF_28_105_D returns one-row data.frame with expected columns", {
  result <- add_lens_data_nikon_AF_28_105_D()
  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 1L)
  expect_named(result, lens_cols)
})

test_that("add_lens_data_nikon_AF_28_105_D returns correct LensID", {
  expect_equal(
    add_lens_data_nikon_AF_28_105_D()[["Nikon:LensID"]],
    "AF Zoom-Nikkor 28-105mm f/3.5-4.5D IF"
  )
})

test_that("add_lens_data_nikon_AF_24_D returns one-row data.frame with expected columns", {
  result <- add_lens_data_nikon_AF_24_D()
  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 1L)
  expect_named(result, lens_cols)
})

test_that("add_lens_data_nikon_AF_24_D returns correct LensID", {
  expect_equal(
    add_lens_data_nikon_AF_24_D()[["Nikon:LensID"]],
    "AF Nikkor 24mm f/2.8D"
  )
})

test_that("add_lens_data_nikon_AF_50_D returns one-row data.frame with expected columns", {
  result <- add_lens_data_nikon_AF_50_D()
  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 1L)
  expect_named(result, lens_cols)
})

test_that("add_lens_data_nikon_AF_50_D returns correct LensID", {
  expect_equal(
    add_lens_data_nikon_AF_50_D()[["Nikon:LensID"]],
    "AF Nikkor 50mm f/1.4D"
  )
})

test_that("add_lens_data_nikon_AF_85 returns one-row data.frame with expected columns", {
  result <- add_lens_data_nikon_AF_85()
  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 1L)
  expect_named(result, lens_cols)
})

test_that("add_lens_data_nikon_AF_85 returns correct LensID and non-D LensType", {
  result <- add_lens_data_nikon_AF_85()
  expect_equal(result[["Nikon:LensID"]], "AF Nikkor 85mm f/1.8")
  expect_equal(result[["Nikon:LensType"]], 0)
})

test_that("add_lens_data_nikon_AF_105_D returns one-row data.frame with expected columns", {
  result <- add_lens_data_nikon_AF_105_D()
  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 1L)
  expect_named(result, lens_cols)
})

test_that("add_lens_data_nikon_AF_105_D returns correct LensID", {
  expect_equal(
    add_lens_data_nikon_AF_105_D()[["Nikon:LensID"]],
    "AF Micro-Nikkor 105mm f/2.8D"
  )
})

test_that("add_lens_data_sigma_AF_28_70_D returns one-row data.frame with expected columns", {
  result <- add_lens_data_sigma_AF_28_70_D()
  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 1L)
  expect_named(result, lens_cols)
})

test_that("add_lens_data_sigma_AF_28_70_D returns correct LensID", {
  expect_equal(
    add_lens_data_sigma_AF_28_70_D()[["Nikon:LensID"]],
    "Sigma 28-70mm F2.8"
  )
})

test_that("delete_lens_data returns one-row data.frame with expected columns", {
  result <- delete_lens_data()
  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 1L)
  expect_named(result, lens_cols)
})

test_that("delete_lens_data returns empty strings for all fields", {
  result <- delete_lens_data()
  expect_true(all(vapply(result, function(x) x == "", logical(1L))))
})
