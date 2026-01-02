#' Obtain extdata for the lexico package
#'
#' @param path name of file
#'
#' @returns link of path or (if path is null) list of paths
#' @export
#'
#' @examples
#' lexico_example()
#' lexico_example("df_info_bfm.csv")
lexico_example <- function(path = NULL) {
  if (is.null(path)) {
    dir(system.file("extdata", package = "lexico"))
  } else {
    system.file("extdata", path, package = "lexico", mustWork = TRUE)
  }
}
