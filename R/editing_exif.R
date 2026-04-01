#' Batch editing of exif data
#' @inheritParams renaming_nossaflex
#' @param metadata a data.frame as provided by \code{\link{parsing_nossaflex}},
#' \code{\link{parsing_json}} or \code{\link{parsing_frames}}.
#' @param extra_tags A named character vector of additional exif tags to write
#'   for every file, e.g. `c(Artist = "Jane Smith", Copyright = "2024 Jane Smith")`.
#'   These are appended to the per-shot metadata tags.
#' @param overwrite_original logical, if TRUE, no copy is created by `exiftool`. See <https://exiftool.org/forum/index.php?topic=13191.msg71304#msg71304>
#' @param verbose passes `-v2` argument to `exiftool`
#' @details
#' Editing the `maker`, `model` and various `makerNotes` tags before or during darktable editing will most likely render the file unsuable for darktable since it uses these fields for parameterising the editing treatments.
#'
#' @returns Called for its side effect of writing EXIF tags to `files`.
#'   Returns `NULL` invisibly.
#' @importFrom dplyr select any_of mutate across if_else case_when
#' @export
#' @examples
#' \dontrun{
#' files <- tools::list_files_with_exts(
#'   dir = system.file("extdata", package = "APMD"),
#'   exts = "jpg", full.names = TRUE
#' )
#' metadata <- reading_nossaflex(
#'   path = system.file("extdata", "nossaflex_filenames.txt", package = "APMD")
#' ) |>
#'   parsing_nossaflex()
#' editing_exif(metadata = metadata, files = files)
#'
#' metadata <- data.frame(
#'   NO = c(1, 2), SS = c("2s", "4000"), A = c(1.4, 2.8),
#'   FL = c(50, 50), EX = c("+2", "-1"),
#'   Northing = c("N", "N"), Easting = c("E", "E"),
#'   Latitude = c(54.321, 54.321), Longitude = c(12.345, 12.345),
#'   Date_Time_Original = c("2024-03-19 21:40:40 +0000", "2024-04-20 12:20:10 +0000"),
#'   Camera_Brand = c("Nikon", "Nikon"), Camera_Model = c("FA", "FA"),
#'   Lens_Brand = c("Nikon", "Nikon"),
#'   Lens_Model = c("Nikkor AF 50mm d f/1.4", "Nikkor AF 50mm d f/1.4"),
#'   Lens_Focal_Length = c(50, 50), Lens_Maximum_Aperture = c(1.4, 1.4)
#' )
#' editing_exif(metadata = metadata, files = files, extra_tags = c(Artist = "Jane Smith"))
#' }
#'
#'

###################
# IDEA
# 1) taking advantage of exiftool ability to read tags in a csv directly
# import from CSV file https://exiftool.org/faq.html#Q26
# exiftool -csv="c:\Users\Phil\test.csv" "c:\Users\Phil\Images"
##############
# 2) taking advantage of exiftool batch execution abilities
editing_exif <- function(
  metadata,
  files,
  extra_tags = NULL,
  overwrite_original = FALSE,
  verbose = TRUE
) {
  base::stopifnot(
    "metadata must have as many rows as the length of files" = length(files) ==
      nrow(metadata)
  )

  # Deleting columns with unknown tags ----
  exif_tags <- c(
    # Shot
    "NO",
    "SS",
    #"ShutterSpeed", # not writable
    "ExposureTime",
    "A",
    "FNumber",
    "FL",
    "FocalLengthIn35mmFormat",
    #"FocalLength35efl", # not writable
    "EX",
    "Northing",
    "Easting",
    "Latitude",
    "Longitude",
    "Date_Time_Original",
    #Camera
    "Camera_Brand",
    "Camera_Model",
    # Lens
    "Lens",
    "Lens_Brand",
    "Lens_Model",
    "Lens_Focal_Length",
    "Lens_Max_Focal_Length",
    "Lens_Maximum_Aperture",
    "Lens_Serial_Number",
    # Nikon lens MakerNote — writable on D3000 (verified 2026-04-01)
    "Nikon:LensIDNumber",
    "Nikon:LensFStops",
    "Nikon:MinFocalLength",
    "Nikon:MaxFocalLength",
    "Nikon:MaxApertureAtMinFocal",
    "Nikon:MaxApertureAtMaxFocal",
    "Nikon:MCUVersion",
    "Nikon:LensType",
    #"Nikon:LensSpec", # composite
    #"Nikon:LensID",   # composite
    # "Lens_ID", # composite
    # Film stock
    "Stock",
    "ISO",
    # Flash
    "Flash"
  )

  exif_names <- c(
    # Shot
    "ImageNumber",
    "ShutterSpeedValue",
    #"ShutterSpeed", # not writable
    "ExposureTime",
    "FNumber",
    "FNumber",
    "FocalLength",
    "FocalLengthIn35mmFormat",
    # "FocalLength35efl", # not writable
    "ExposureCompensation",
    "GPSLatitudeRef",
    "GPSLongitudeRef",
    "GPSLatitude",
    "GPSLongitude",
    "DateTimeOriginal",
    # Camera
    "Make",
    "Model",
    # Lens
    "XMP:Lens",
    "LensMake",
    "LensModel",
    "MinFocalLength",
    "MaxFocalLength",
    "MaxApertureValue",
    "LensSerialNumber",
    # Nikon lens MakerNote (identity mapping — column name = tag name)
    "Nikon:LensIDNumber",
    "Nikon:LensFStops",
    "Nikon:MinFocalLength",
    "Nikon:MaxFocalLength",
    "Nikon:MaxApertureAtMinFocal",
    "Nikon:MaxApertureAtMaxFocal",
    "Nikon:MCUVersion",
    "Nikon:LensType",
    #"Nikon:LensSpec", # composite
    #"Nikon:LensID",   # composite
    # "LensID", # composite
    # Film stock
    "ImageDescription",
    "ISO",
    # Flash
    "Flash"
  )

  checkmate::assert_true(length(exif_tags) == length(exif_names))

  metadata <- as.data.frame(select(metadata, any_of(exif_tags)))

  # Converting values ----
  ## Excluding "auto" values ----
  variables <- c("SS", "FL", "A")
  if (any(unlist(select(metadata, any_of(variables))) == "auto")) {
    message('"auto" values in SS, A and FL are turned into "".')
    metadata <- mutate(
      metadata,
      across(
        any_of(variables),
        ~ if_else(grepl("auto", .x, fixed = TRUE), "", .x)
      )
    )
  }

  ## ShutterSpeedValue and ExposureTime ----
  # Capture original SS before transformation — ExposureTime needs it
  original_SS <- metadata[["SS"]]

  metadata <- mutate(
    metadata,
    SS = case_when(
      grepl("/", original_SS, fixed = TRUE) ~ original_SS,
      grepl("s", original_SS, fixed = TRUE) ~ sub(
        "s",
        "",
        original_SS,
        fixed = TRUE
      ),
      !is.na(suppressWarnings(as.numeric(original_SS))) ~ as.character(
        1 / suppressWarnings(as.numeric(original_SS))
      ),
      .default = ""
    ),
    # ExposureTime: decimal seconds derived from the original SS string
    ExposureTime = case_when(
      grepl("/", original_SS, fixed = TRUE) ~
        suppressWarnings(as.character(1 / as.integer(sub("1/", "", original_SS, fixed = TRUE)))),
      grepl("s", original_SS, fixed = TRUE) ~ sub(
        "s",
        "",
        original_SS,
        fixed = TRUE
      ),
      !is.na(suppressWarnings(as.numeric(original_SS))) ~ as.character(
        1 / suppressWarnings(as.numeric(original_SS))
      ),
      .default = ""
    )
  )

  ## ShutterSpeedValue APEX ----
  # APEX = log2(1 / ExposureTime); derived from ExposureTime (already in decimal seconds)
  exposure_time <- metadata[["ExposureTime"]]
  if ("SS" %in% names(metadata)) {
    metadata <- mutate(
      metadata,
      SS = if_else(
        !is.na(exposure_time) & exposure_time != "",
        as.character(log2(1 / as.numeric(exposure_time))),
        ""
      )
    )
  }

  # if aperture is auto and SS no, mode is S
  # if aperture and SS is auto, mode is P
  # if aperture is given and SS is auto, mode is A

  # Editing exif ----
  for (i in seq_along(files)) {
    arguments <- metadata[i, ]

    matched_idx <- match(
      x = names(arguments),
      table = exif_tags,
      nomatch = NA_integer_
    )
    arguments <- arguments[, !is.na(matched_idx), drop = FALSE]
    matched_idx <- matched_idx[!is.na(matched_idx)]

    arguments <- stats::setNames(object = arguments, exif_names[matched_idx])

    shot_args <- vapply(
      seq_along(arguments),
      function(j) {
        stringi::stri_join("-", names(arguments)[[j]], "=", arguments[[j]])
      },
      FUN.VALUE = character(1L)
    )

    extra_args <- if (!is.null(extra_tags)) {
      vapply(
        seq_along(extra_tags),
        function(j) {
          stringi::stri_join("-", names(extra_tags)[[j]], "=", extra_tags[[j]])
        },
        FUN.VALUE = character(1L)
      )
    }

    # LensInfo — canonical 4-element rational [MinFL MaxFL MinFN MaxFN] ----
    lens_info_arg <- NULL
    if (all(c("Lens_Focal_Length", "Lens_Max_Focal_Length", "Lens_Maximum_Aperture") %in% names(metadata))) {
      min_fl <- metadata[[i, "Lens_Focal_Length"]]
      max_fl <- metadata[[i, "Lens_Max_Focal_Length"]]
      max_ap <- metadata[[i, "Lens_Maximum_Aperture"]]
      if (!is.na(min_fl) && !is.na(max_fl) && !is.na(max_ap) &&
          min_fl != "" && max_fl != "" && max_ap != "") {
        lens_info_arg <- stringi::stri_join(
          "-LensInfo=", min_fl, " ", max_fl, " ", max_ap, " ", max_ap
        )
      }
    }

    all_args <- c(shot_args, lens_info_arg, extra_args)

    if (isTRUE(overwrite_original)) {
      all_args <- c("-overwrite_original", all_args)
    }

    if (isTRUE(verbose)) {
      all_args <- c("-v2", all_args)
    }

    if (isTRUE(verbose)) {
      print(all_args)
    }

    exiftoolr::exif_call(path = files[[i]], args = all_args, quiet = FALSE)
  }
}

# args = c("-Photographer=Alban",
#          "-ImageNumber=1",
#          "-ShutterSpeedValue=1", # APEX unit?? ShutterSpeedValue
#          "-iso=200",
#          "-FNumber=1.4",
#          "-FocalLength=50",
#          "-ExposureTime=1/250",
#          "-ExposureCompensation=+1",# better than ExposureBiasValue ?
#          "-model=Nikon FA",
#          "-LensMake=Nikon",
#          "-LensModel=50mm 1.4D"),
# Camera ----
# Model
# Lens ----
# MaxApertureValue rational64u displayed as an F number, but stored as an APEX value)
# FNumber
#Artist or Photographer	string
# 0xa432 	LensInfo 	rational64u[4] 	ExifIFD 	(4 rational values giving focal and aperture ranges, called LensSpecification by the EXIF spec.)
# Value 1 : = Minimum focal length (unit: mm)
# Value 2 : = Maximum focal length (unit: mm)
# Value 3 : = Minimum F number in the minimum focal length
# Value 4 : = Minimum F number in the maximum focal length
#
# So, just making up numbers, if you set
# exiftool -LensInfo="5 10 100 200" FILE.JPG
# 0xa433 	LensMake 	string 	ExifIFD
# 0xa434 	LensModel 	string 	ExifIFD
# 0xa435 	LensSerialNumber 	string 	ExifIFD
# Lens 	string/
# FocalLength
# 0x0083 	LensType 	int8u 	Bit 0 = MF
# Bit 1 = D
# Bit 2 = G
# Bit 3 = VR
# Bit 4 = 1
# Bit 5 = FT-1
# Bit 6 = E
# Bit 7 = AF-P

# CreateDate
# GPSLatitude 10.23456
# GPSLatitudeRef "N"
# GPSLongitude 10.23456
# GPSLongitudeRef "E"

# Film roll possible exif tags: ImageDescription, ImageHistory, UserComment,
# Title, CameraFirmware, ProfileName, CameraLabel, DocumentName

# 0xa300 	FileSource 	undef 	ExifIFD 	1 = Film Scanner
# 2 = Reflection Print Scanner
# 3 = Digital Camera
# "\x03\x00\x00\x00" = Sigma Digital Camera
