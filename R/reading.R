#' Reading nossaflex file names
#' @param path if null, reading from clipboard
#' @returns a character vector of file names without extension
#' @examples
#' path <- system.file("extdata", "nossaflex_example.txt", package = "APMD")
#' reading_nossaflex(path = path)
#' @export

reading_nossaflex <- function(path) {
  checkmate::assert_access(path, access = "r")

  stringi::stri_read_lines(con = path)
}
