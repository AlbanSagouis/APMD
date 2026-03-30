#' Batch renaming picture files with the names provided by the `analog` app
#' @param files a character vector of paths with complete file names like what
#'     \code{\link{list.files}} when used with `full.names = TRUE` or
#'     \code{\link[tools:fileutils]{tools::list_files_with_exts}} gives
#' @param filenames a character vector of target file names provided by
#'     \code{\link{reading_nossaflex}}. With or without file extensions.
#' @param copy logical, FALSE by default. If TRUE, a `_copy` backup of each
#'   file is made before renaming.
#' @returns A named logical vector (from \code{\link[base]{file.rename}}),
#'   named by the new file paths.
#' @description
#'    By default, the `filenames` provided by `analog` do not have file extensions.
#'    If the `filenames` do not have an extension, the extension of `files` is
#'    used. If `files` do not have an extension, an error is thrown.
#'
#'    By default, the `filenames` provided by `analog` do not have path.
#'    If the `filenames` do not have a complete path, the path of `files` is
#'    used. If `files` do not have a path, an error is thrown as they cannot be found.
#' @export
#' @examples
#' \dontrun{
#' files <- tools::list_files_with_exts(
#'   dir = system.file("extdata", package = "APMD"),
#'   exts = "jpg", full.names = TRUE
#' )
#' filenames <- c("NO01_SS1s_A5.6_FL35_EX-2", "NO02_SS125_A5.6_FL35_EX+1")
#' renaming_nossaflex(files = files, filenames = filenames, copy = TRUE)
#' }

renaming_nossaflex <- function(files, filenames, copy = FALSE) {
  base::stopifnot("files must have an extension" = grepl(
    x = files, pattern = "\\.[A-Za-z0-9]{1,4}$"))
  base::stopifnot("files must all have the same extension" =
                    length(unique(tools::file_ext(files))) == 1L)
  checkmate::assert_access(files, access = "r")
  checkmate::assert_logical(copy, len = 1L, null.ok = FALSE)

  if (is.element(el = ".", set = dirname(filenames))) {
    filenames <- paste0(dirname(files), "/", filenames)
  }
  checkmate::assert_access(dirname(filenames), access = "w")

  if (all(grepl(x = filenames, pattern = "\\.[A-Za-z0-9]{1,4}$"))) {
    base::stopifnot("filenames must all have the same extension" =
                      length(unique(tools::file_ext(filenames))) == 1L)
    base::stopifnot("filenames must have the same extension as files" =
                      unique(tools::file_ext(filenames)) ==
                      unique(tools::file_ext(files))
    )
  } else { # if `filenames` don't have extensions, inherit from files
    file_extension <- paste0(".", unique(tools::file_ext(files)))
    filenames <- paste0(filenames, file_extension)
  }

  if (isTRUE(copy)) {
    checkmate::assert_access(files, access = "w")

    file_extension <- paste0(".", unique(tools::file_ext(files)))
    base::file.copy(
      from = files,
      to = paste0(tools::file_path_sans_ext(files), "_copy", file_extension),
      copy.date = TRUE, recursive = FALSE)
  }

  return(stats::setNames(
    base::file.rename(from = files, to = filenames),
    filenames))
}
