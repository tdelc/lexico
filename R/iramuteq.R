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
#' df <- janeaustenr::austen_books()
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

#' Read report from iramuteq to extract words of each class
#'
#' @param file path to report file .txt from IRaMuTeQ
#' @param classe index of class to extract
#'
#' @returns data.frame
#' @export
#'
#' @examples
#' path_iramtueq <- "inst/extdata/corpus_janeausten/corpus_janeausten_alceste_1"
#' path_txt <- file.path(path_iramtueq,"RAPPORT.txt")
#' head(read_iramuteq_class(path_txt,1))
read_iramuteq_class <- function(file, classe = 1) {

  x <- readLines(file, encoding = "UTF-8", warn = FALSE)

  # repérer le début de la classe
  start <- which(str_detect(
    x,
    paste0("^classe\\s+", classe, "\\s+-")
  ))

  if (length(start) == 0) stop("Classe non trouvée")

  # lignes après le titre de classe
  x2 <- x[(start + 1):length(x)]

  # on garde uniquement les lignes commençant par un rang numérique
  rows <- x2[str_detect(x2, "^\\s*\\d+\\|")]

  # stop dès qu'on atteint une autre classe ou une ligne vide
  rows <- rows[!str_detect(rows, "^classe\\s+")]
  rows <- rows[rows != ""]

  # rows <- rows[!str_detect(rows,"NS \\(")]

  # parsing ligne par ligne
  # res <- lapply(rows, function(l) {
  res <- tibble(NULL)
  for (l in rows){

    parts <- str_split(l, "\\|", simplify = TRUE)
    parts <- trimws(parts)

    if (str_detect(l,"NS \\(")) break

    p.value <- str_extract(parts[7], "\\s+([0-9,.]+)")

    res_temp <- tibble(
      rang        = as.integer(parts[1]),
      freq_classe = as.integer(parts[2]),
      freq_totale = as.integer(parts[3]),
      pct         = as.numeric(parts[4]),
      chi2        = as.numeric(parts[5]),
      pos         = parts[6],
      forme       = parts[7],
      # CORRIGER ICI
      # p_value     = str_extract(l, "<\\s*[0-9,.]+")
      p_value     = p.value
    )
    res <- bind_rows(res,res_temp)
  }

  res %>%
    mutate(forme = str_squish(str_remove(str_remove(forme,p_value),"<")),
           p_value = as.numeric(str_replace(p_value,",",".")))
}


