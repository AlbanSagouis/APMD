#' Insert rows in metadata data.frames
#' @inheritParams editing_exif
#' @param row_indices An integer or integer vector of row numbers where new
#'   rows should be inserted (before the row at that position).
#' @param new_rows A data.frame with column names matching names
#'   in `metadata` and values to insert, e.g. Roll_Name and Camera_Brand.
#'   Must have the same number of rows as `row_indices`.
#' @param extrapolate_data Logical, FALSE by default. If TRUE, the function
#' computes average Date_Time_Original, Latitude and Longitude values. Hence
#' works only with JSON data.
#' @export
#' @examples
#' metadata <- reading_nossaflex(
#'   path = system.file("extdata", "nossaflex_example.txt", package = "APMD")
#' ) |>
#'   parsing_nossaflex()
#' new_rows <- data.frame(NO = "02", SS = "125", A = "1.4", FL = "50", EX = "0")
#' insert_missing_records(metadata = metadata, row_indices = 2L, new_rows = new_rows)


insert_missing_records <- function(metadata, row_indices, new_rows,
                                   extrapolate_data = FALSE) {
  checkmate::assert_data_frame(metadata)
  checkmate::assert_integerish(row_indices, lower = 1L)
  checkmate::assert_data_frame(new_rows)
  checkmate::assert_true(length(row_indices) == nrow(new_rows))

  new_rows <- as.data.frame(new_rows)

  # Insert bottom-up so earlier insertions don't shift later indices
  insertion_order <- order(row_indices, decreasing = TRUE)
  row_indices_sorted <- row_indices[insertion_order]
  new_rows_sorted <- new_rows[insertion_order, , drop = FALSE]

  for (k in seq_along(row_indices_sorted)) {
    I <- row_indices_sorted[[k]]
    new_row <- new_rows_sorted[k, , drop = FALSE]

    if (isTRUE(extrapolate_data)) {
      # fails if inserting at the end of the roll — row I+1 must exist
      dt_col      <- metadata[c(I, I + 1L), "Date_Time_Original"]
      lat_lon_rows <- metadata[c(I, I + 1L), c("Latitude", "Longitude"), drop = FALSE]
      ne_rows      <- metadata[c(I, I + 1L), c("Northing", "Easting"),   drop = FALSE]

      same_or_na <- function(x) if (identical(x[[1L]], x[[2L]])) x[[1L]] else NA_character_

      dt_posix <- as.POSIXct(dt_col, format = "%Y-%m-%d %H:%M:%S", tz = "UTC")
      mean_dt  <- format(mean(dt_posix), format = "%Y-%m-%d %H:%M:%S")

      new_row[["Date_Time_Original"]] <- mean_dt
      new_row[["Latitude"]]           <- as.character(mean(as.numeric(lat_lon_rows[["Latitude"]])))
      new_row[["Longitude"]]          <- as.character(mean(as.numeric(lat_lon_rows[["Longitude"]])))
      new_row[["Northing"]]           <- same_or_na(ne_rows[["Northing"]])
      new_row[["Easting"]]            <- same_or_na(ne_rows[["Easting"]])
    }

    metadata <- dplyr::bind_rows(
      metadata[seq_len(I - 1L), , drop = FALSE],
      new_row,
      metadata[seq(from = I, to = nrow(metadata)), , drop = FALSE]
    )
  }

  # Renumber NO sequentially
  metadata$NO <- stringi::stri_pad_left(
    str   = seq_len(nrow(metadata)),
    width = 2L,
    pad   = "0"
  )

  return(metadata)
}
