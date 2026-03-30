#' Insert rows in metadata data.tables
#' @inheritParams editing_exif
#' @param row_indices An integer or integer vector of row numbers where new
#'   rows should be inserted (before the row at that position).
#' @param new_rows A data.frame or data.table with column names matching names
#'   in `metadata` and values to insert, e.g. Roll_Name and Camera_Brand.
#'   Must have the same number of rows as `row_indices`.
#' @param extrapolate_data Logical, FALSE by default. If TRUE, the function
#' computes average Date_Time_Original, Latitude and Longitude values. Hence
#' works only with JSON data.
#' @importFrom data.table :=
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
  checkmate::assert_class(metadata, "data.table")
  checkmate::assert_integerish(row_indices, lower = 1L)
  checkmate::assert_data_frame(new_rows)
  checkmate::assert_true(length(row_indices) == nrow(new_rows))

  new_rows <- data.table::as.data.table(new_rows)

  # Insert bottom-up so earlier insertions don't shift later indices
  insertion_order <- order(row_indices, decreasing = TRUE)
  row_indices_sorted <- row_indices[insertion_order]
  new_rows_sorted <- new_rows[insertion_order, ]

  for (k in seq_along(row_indices_sorted)) {
    I <- row_indices_sorted[[k]]
    new_row <- new_rows_sorted[k, ]

    if (isTRUE(extrapolate_data)) {
      # fails if inserting at the end of the roll — row I+1 must exist
      dt_col <- metadata[c(I, I + 1L), "Date_Time_Original"][[1L]]
      lat_lon_rows <- metadata[c(I, I + 1L), c("Latitude", "Longitude")]
      ne_rows <- metadata[c(I, I + 1L), c("Northing", "Easting")]
      same_or_na <- function(x) if (identical(x[[1L]], x[[2L]])) x[[1L]] else NA_character_
      mean_values <- data.table::data.table(
        Date_Time_Original = paste(
          mean(data.table::as.IDate(dt_col)),
          mean(data.table::as.ITime(dt_col))
        ),
        Latitude = mean(as.numeric(lat_lon_rows[["Latitude"]])),
        Longitude = mean(as.numeric(lat_lon_rows[["Longitude"]])),
        Northing = same_or_na(ne_rows[["Northing"]]),
        Easting = same_or_na(ne_rows[["Easting"]])
      )

      data.table::set(
        x = new_row,
        j = c("Date_Time_Original", "Latitude", "Longitude", "Northing", "Easting"),
        value = mean_values
      )
    }

    metadata <- data.table::rbindlist(
      list(
        metadata[seq(from = 1L, to = I - 1L)],
        new_row,
        metadata[seq(from = I, to = nrow(metadata))]
      ),
      fill = TRUE
    )
  }

  # Renumber NO sequentially
  data.table::set(
    x = metadata,
    j = "NO",
    value = stringi::stri_pad_left(seq_len(nrow(metadata)), width = 2, pad = "0")
  )

  return(metadata[])
}
