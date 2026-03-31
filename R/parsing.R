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
    dplyr::bind_rows() |>
    as.data.frame()
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
#' @noRd

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
#' path <- "/path/to/exported_analog_data.json"
#' parsing_json(path = path)
#' }

parsing_json <- function(path, apply_corrections = TRUE) {
  checkmate::assert_access(path, access = "r")
  checkmate::assert_logical(apply_corrections, len = 1L, null.ok = FALSE)

  json <- jsonlite::read_json(path = path, simplifyVector = TRUE)

  res <- data.frame(
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
    Lens_Brand = vapply(
      json$Shots,
      function(shot) {
        val <- shot$Lens$`Lens Brand`
        if (is.null(val) || length(val) == 0L) NA_character_ else as.character(val)
      },
      character(1L)
    ),
    Lens_Maximum_Aperture = vapply(
      json$Shots,
      function(shot) {
        val <- shot$Lens$`Lens Maximum Aperture`
        if (is.null(val) || length(val) == 0L) NA_character_ else as.character(val)
      },
      character(1L)
    ),
    Lens_Focal_Length = vapply(
      json$Shots,
      function(shot) {
        val <- shot$Lens$`Lens Focal Length`
        if (is.null(val) || length(val) == 0L) NA_character_ else as.character(val)
      },
      character(1L)
    ),
    EX = sapply(json$Shots, function(shot) shot$`Exposure`),
    Date_Time_Original = sapply(
      json$Shots,
      function(shot) shot$`Created Date`
    ),
    stringsAsFactors = FALSE
  )

  if (is.element("NO", colnames(res))) {
    res <- res[order(res$NO), ]
  }

  # Coordinates
  coords_raw <- sapply(
    X   = json$Shots,
    FUN = function(shot) shot$`Location Coordinates`
  ) |>
    gsub(pattern = "[\\[\\]]", replacement = "", perl = TRUE)

  coords_split <- stringi::stri_split_fixed(
    str     = coords_raw,
    pattern = ", ",
    n       = 2L
  )
  res$Latitude  <- vapply(
    coords_split,
    function(x) if (length(x) >= 1L) x[[1L]] else NA_character_,
    character(1L)
  )
  res$Longitude <- vapply(
    coords_split,
    function(x) if (length(x) >= 2L) x[[2L]] else NA_character_,
    character(1L)
  )
  res$Northing <- "N"
  res$Easting  <- "E"

  if (apply_corrections) {
    if (
      json$Camera$`Camera Brand` == "Voigtlaender" &&
        json$Camera$`Camera Model` == "Vito 70"
    ) {
      res$Lens_Focal_Length <- 70L
      res$SS <- "auto"
      res$A  <- "auto"
    }
  }

  return(res)
}


#' Parsing the JSON data sent by the `Frames` app
#' @param path Complete path to the .frames / JSON data
#' @inherit parsing_nossaflex return
#' @importFrom jsonlite read_json
#' @export
#' @examples
#' \dontrun{
#' path <- "/path/to/exported_frames_data.frames"
#' parsing_frames(path = path)
#' }

parsing_frames <- function(path) {
  checkmate::assert_access(path, access = "r")

  json <- jsonlite::read_json(path = path, simplifyVector = TRUE)

  n_shots <- length(json$frames$number)
  null_chr <- function(x) if (is.null(x) || length(x) == 0L) rep(NA_character_, n_shots) else x

  res <- data.frame(
    Roll_Name = json$name,

    Camera_Brand = json$camera$make,
    Camera_Model = json$camera$model,

    NO = json$frames$number,
    SS = json$frames$shutterSpeed,
    A = json$frames$aperture,
    # FL (shot focal length) not available in Frames format
    Lens_Brand = null_chr(json$frames$lens.make),
    Lens_Model = null_chr(json$frames$lens.model),
    Lens_Maximum_Aperture = null_chr(json$frames$lens.maxAperture),
    # Note: Frames exports the lens maximum focal length, not the shot focal
    # length. For prime lenses these are the same; for zooms they differ.
    Lens_Max_Focal_Length = null_chr(json$frames$lens.maxFocalLength),
    EX = json$frames$exposure,
    Date_Time_Original = json$frames$createdAt,
    Latitude = json$frames$latitude,
    Longitude = json$frames$longitude,
    Northing = "N",
    Easting = "E",
    stringsAsFactors = FALSE
  )

  if (is.element("NO", colnames(res))) {
    res <- res[order(res$NO), ]
  }

  return(res)
}


#' Parsing CSV data from the Analog+ app
#' @param path Complete path to the CSV file saved by the Analog+ app.
#' @inherit parsing_nossaflex return
#' @details
#' Reads the CSV format exported by the Analog+ iOS app. The following column
#' mappings are applied:
#'
#' | CSV column      | Output column        | Transformation                       |
#' |-----------------|----------------------|--------------------------------------|
#' | `Frame`         | `NO`                 | none                                 |
#' | `Shutter Speed` | `SS`                 | none (e.g. `"1/125"`)                |
#' | `Aperture`      | `A`                  | `"f/"` prefix stripped               |
#' | `Focal`         | `FL`                 | `"mm"` suffix stripped               |
#' | `Compensation`  | `EX`                 | `" EV"` suffix stripped              |
#' | `ISO`           | `ISO`                | none                                 |
#' | `Flash`         | `Flash`              | none                                 |
#' | `Date`          | `Date_Time_Original` | `DD/MM/YYYY, H:MM` → `YYYY:MM:DD HH:MM:SS` |
#' | `Latitude`      | `Latitude`           | none                                 |
#' | `Longitude`     | `Longitude`          | none                                 |
#' | ` Camera`       | `Camera_Brand`       | first word; leading space in header trimmed |
#' |                 | `Camera_Model`       | remainder                            |
#' | `Lens`          | `Lens_Brand`         | first word                           |
#' |                 | `Lens_Model`         | remainder; `NA` for single-word lens |
#' | `Stock`         | `Stock`              | none                                 |
#'
#' `Northing` and `Easting` are set to `"N"` and `"E"` respectively.
#' Dates are parsed assuming UTC. The Analog+ app exports dates without
#' timezone information.
#' @export
#' @examples
#' \dontrun{
#' path <- "~/Pictures/D39 Chemnitz/Chemnitz 2025.csv"
#' parsing_csv(path = path)
#' }

parsing_csv <- function(path) {
  checkmate::assert_access(path, access = "r")

  csv <- utils::read.csv(
    file            = path,
    fileEncoding    = "UTF-8",
    check.names     = FALSE,
    stringsAsFactors = FALSE
  )
  names(csv) <- trimws(names(csv))

  camera_parts <- stringi::stri_split_fixed(str = csv[["Camera"]], pattern = " ", n = 2L)
  lens_parts   <- stringi::stri_split_fixed(str = csv[["Lens"]],   pattern = " ", n = 2L)

  res <- data.frame(
    NO    = csv[["Frame"]],
    SS    = csv[["Shutter Speed"]],
    A     = stringi::stri_replace_first_fixed(str = csv[["Aperture"]],     pattern = "f/",  replacement = ""),
    FL    = stringi::stri_replace_first_fixed(str = csv[["Focal"]],        pattern = "mm",  replacement = ""),
    EX    = stringi::stri_replace_first_fixed(str = csv[["Compensation"]], pattern = " EV", replacement = ""),
    ISO   = csv[["ISO"]],
    Flash = csv[["Flash"]],
    Date_Time_Original = format(
      x      = as.POSIXct(x = csv[["Date"]], format = "%d/%m/%Y, %H:%M", tz = "UTC"),
      format = "%Y:%m:%d %H:%M:%S"
    ),
    Latitude  = csv[["Latitude"]],
    Longitude = csv[["Longitude"]],
    Northing  = "N",
    Easting   = "E",
    Camera_Brand = vapply(X = camera_parts, FUN = `[[`, FUN.VALUE = character(1L), 1L),
    Camera_Model = vapply(
      X         = camera_parts,
      FUN       = function(x) if (length(x) >= 2L) x[[2L]] else NA_character_,
      FUN.VALUE = character(1L)
    ),
    Lens_Brand = vapply(X = lens_parts, FUN = `[[`, FUN.VALUE = character(1L), 1L),
    Lens_Model = vapply(
      X         = lens_parts,
      FUN       = function(x) if (length(x) >= 2L) x[[2L]] else NA_character_,
      FUN.VALUE = character(1L)
    ),
    Stock = csv[["Stock"]],
    stringsAsFactors = FALSE
  )

  if (is.element("NO", colnames(res))) {
    res <- res[order(res$NO), ]
  }

  return(res)
}
