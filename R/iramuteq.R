#' import df from iramuteq
#'
#' @param file path to file .txt from IRaMuTeQ
#'
#' @returns data.frame
#' @export
#'
#' @examples
#' df <- janeaustenr::austen_books()[1:10,]
#' path_txt <- file.path(tempfile(fileext=".txt"))
#' export_to_iramuteq(df,"book","text",path_txt)
#' import_from_iramuteq(path_txt)
import_from_iramuteq <- function(file) {

  lines <- readLines(file, encoding = "UTF-8")  # adapte l'encodage si besoin

  # idx to begin document
  header_idx <- grep("^\\*\\*\\*\\*", lines)
  if (length(header_idx) == 0) {
    stop("No header '****' found in the file.")
  }

  # add end idx
  header_idx <- c(header_idx, length(lines) + 1)

  docs <- vector("list", length(header_idx) - 1)

  for (k in seq_len(length(docs))) {
    h_line <- lines[header_idx[k]]

    if (header_idx[k] + 1 <= header_idx[k + 1] - 1) {
      body_lines <- lines[(header_idx[k] + 1):(header_idx[k + 1] - 1)]
    } else {
      body_lines <- ""
    }

    text <- paste(body_lines, collapse = " ")
    text <- trimws(text)

    tokens <- strsplit(h_line, "\\s+")[[1]]
    meta_tokens <- tokens[-1]  # remove ****

    meta_list <- list(text = text)

    for (mt in meta_tokens) {
      mt2 <- sub("^\\*", "", mt)  # remove *

      if (grepl("=", mt2)) {
        parts <- stringr::str_split(mt2, "=", n = 2)[[1]]
      } else if (grepl("_", mt2)) {
        parts <- stringr::str_split(mt2, "_", n = 2)[[1]]
      } else {
        parts <- c(mt2, NA_character_)
      }

      var <- parts[1]
      val <- parts[2]

      meta_list[[var]] <- val
    }

    docs[[k]] <- meta_list
  }

  df <- dplyr::bind_rows(docs)

  df <- as.data.frame(df, stringsAsFactors = FALSE)
  rownames(df) <- NULL

  df
}

#' Export to iramuteq
#'
#' @param df df to export
#' @param meta_cols names of cols to export as meta
#' @param text_col name of col to export as text
#' @param output_file name of txt file
#'
#' @returns nothing (create file)
#' @export
#'
#' @examples
#' df <- janeaustenr::austen_books()[1:10,]
#' path_txt <- file.path(tempfile(fileext=".txt"))
#' export_to_iramuteq(df,"book","text",path_txt)
export_to_iramuteq <- function(df, meta_cols, text_col, output_file) {

  stopifnot("text" %in% names(df))

  df$meta <- apply(df[, meta_cols, drop = FALSE], 1, function(r) {
    paste0("*", stringr::str_remove_all(names(r),"_"),
           "_", stringr::str_remove_all(r," "), collapse = " ")
  })

  corpus <- paste0(
    "**** ", df$meta,
    "\n",
    gsub("\r|\n", " ", dplyr::pull(df[,text_col])),
    collapse = "\n\n"
  )

  writeLines(corpus, output_file, useBytes = TRUE)
  return(NULL)
}
