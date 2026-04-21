#' @keywords internal
#' @description
#' The APMD package is developed in GitHub
#' (https://github.com/albansagouis/APMD). To see the preferable citation of
#' the package, type citation("APMD").
#'
"_PACKAGE"
.datatable.aware <- TRUE

.onAttach <- function(libname, pkgname) {
  packageStartupMessage(
    "APMD v",
    utils::packageVersion("APMD"),
    " - Analog Photography MetaData"
  )
}

NULL
