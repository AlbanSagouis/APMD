# Parsing
#' Parsing NOSSAFLEX names
#' Parsing NOSSAFLEX names from a text file to a data.frame
#' @param filenames a character vector of file names following the structure:
#'     NO01_SS125_A5.6_FL35_EX0
#'     where
#'     NO = Number
#'     SS = Shutter Speed
#'     A = Aperture
#'     FL = Focal Length
#'     EX = Exposure (Over/under)
#' @returns A data.frame with standard columns from nossaflex convention.
#' @export
#' @examples
#' filenames = c("NO01_SS1s_A5.6_FL50_EX-2", "NO02_SS125_A5.6_FL50_EX+1")
#' parsing_nossaflex(filenames)

parsing_nossaflex <- function(filenames) {
  stringi::stri_split_regex(str = filenames, pattern = "_") |>
    lapply(function(split_filename) {
      stringi::stri_replace_all_regex(
        split_filename,
        pattern = "[A-Z]",
        replacement = ""
      ) |>
        stats::setNames(stringi::stri_extract_all_regex(
          split_filename,
          pattern = "[A-Z]{1,2}"
        )) |>
        as.list()
    }) |>
    data.table::rbindlist(fill = TRUE)
}

#' Parsing a custom NOSSAFLEX format
#' Parsing `filenames` with a consistent structure different from the classic
#' `NOSSAFLEX` structure into a data.frame
#' @inheritParams parsing_nossaflex
#' @param format A character string. Used to extract the desired parts of the
#'    NOSSAFLEX file names. default is "NO%NO_SS%SS_A%A_FL%FL_EX%EX" which
#'    corresponds to the standard NOSSAFLEX structure as in
#'    `NO01_SS125_A5.6_FL35_EX+1`.
#' @details
#' Inspired by \code{\link[base]{strptime}}
#' @keywords internal

parsing_custom <- function(filenames, format = "NO%NO_SS%SS_A%A_FL%FL_EX%EX") {
  stop("Not yet implemented", call. = FALSE)
}

#' Parsing the JSON data sent by the `Analog` app
#' @param path Complete path to the JSON data saved in a text file.
#' @param apply_corrections Correct known impossible values:
#'
#'  * If Camera Brand is Voigtlaender and Camera Model is Vito 70
#'    * Aperture or Shutter Speed different from "auto" will be turned into "auto".
#'    * Lens Focal Length will be changed to 70mm
#'  * If Lens has a Maximum Aperture of 1.4, a wider aperture such as 1 will be
#'  changed into 1.4
#'  * If Aperture uses "," as decimal separator, a "." is written instead.
#' @inherit parsing_nossaflex return
#' @importFrom jsonlite read_json
#' @export
#' @examples
#' \dontrun{
#' path = "tests/testthat/testdata/test1.json"
#' parsing_json(path)
#' }

parsing_json <- function(path, apply_corrections = TRUE) {
  checkmate::assert_access(path, access = "r")
  checkmate::assert_logical(apply_corrections, len = 1L, null.ok = FALSE)

  json <- jsonlite::read_json(path = path, simplifyVector = TRUE)

  res <- data.table::data.table(
    Roll_Name = json$`Roll Name`,
    Roll_Number = json$`Roll Number`,

    Camera_Brand = json$Camera$`Camera Brand`,
    Camera_Model = json$Camera$`Camera Model`,

    NO = names(json$Shots) |>
      gsub(pattern = "Shot ", replacement = "") |>
      as.integer(),
    SS = sapply(json$Shots, function(shot) shot$`Shutter Speed`),
    A = sapply(json$Shots, function(shot) shot$`Aperture`),
    FL = sapply(json$Shots, function(shot) shot$`Focal Length`),
    Lens_Brand = sapply(json$Shots, function(shot) shot$Lens$`Lens Brand`),
    Lens_Maximum_Aperture = sapply(
      json$Shots,
      function(shot) shot$Lens$`Lens Maximum Aperture`
    ),
    Lens_Focal_Length = sapply(
      json$Shots,
      function(shot) shot$Lens$`Lens Focal Length`
    ),
    EX = sapply(json$Shots, function(shot) shot$`Exposure`),
    Date_Time_Original = sapply(
      json$Shots,
      function(shot) shot$`Created Date`
    )
  )
  if (is.element("NO", colnames(res))) {
    data.table::setorder(x = res, "NO")
  }

  # Coordinates
  res[
    j = c("Latitude", "Longitude") := data.table::tstrsplit(
      x = sapply(
        X = json$Shots,
        FUN = function(shot) shot$`Location Coordinates`
      ) |>
        gsub(pattern = "[\\[\\]]", replacement = "", perl = TRUE),
      ", "
    )
  ][
    j = ":="(
      Northing = "N",
      Easting = "E"
    )
  ]

  if (apply_corrections) {
    if (
      json$Camera$`Camera Brand` == "Voigtlaender" &&
        json$Camera$`Camera Model` == "Vito 70"
    ) {
      data.table::set(res, j = "Lens_Focal_Length", value = 70L)
      res[j = c("SS", "A") := "auto"]
    }
  }

  return(res[])
}


#' Parsing the JSON data sent by the `Frames` app
#' @param path Complete path to the .frames / JSON data
#' @inherit parsing_nossaflex return
#' @importFrom jsonlite read_json
#' @export
#' @examples
#' \dontrun{
#' path = 'tests/testthat/testdata/Berlin_Boat.frames'
#' parsing_frames(path)
#' }

parsing_frames <- function(path) {
  checkmate::assert_access(path, access = "r")

  json <- jsonlite::read_json(path = path, simplifyVector = TRUE)

  res <- data.table::data.table(
    Roll_Name = json$name,

    Camera_Brand = json$camera$make,
    Camera_Model = json$camera$model,

    NO = json$frames$number,
    SS = json$frames$shutterSpeed,
    A = json$frames$aperture,
    # FL (shot focal length) not available in Frames format
    Lens_Brand = json$frames$lens.make,
    Lens_Model = json$frames$lens.model,
    Lens_Maximum_Aperture = json$frames$lens.maxAperture,
    # Note: Frames exports the lens maximum focal length, not the shot focal
    # length. For prime lenses these are the same; for zooms they differ.
    Lens_Max_Focal_Length = json$frames$lens.maxFocalLength,
    EX = json$frames$exposure,
    Date_Time_Original = json$frames$createdAt,
    Latitude = json$frames$latitude,
    Longitude = json$frames$longitude,
    Northing = "N",
    Easting = "E"
  )
  if (is.element("NO", colnames(res))) {
    data.table::setorder(x = res, "NO")
  }

  return(res)
}
