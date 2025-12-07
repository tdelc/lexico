#' import df from iramuteq
#'
#' @param file
#'
#' @returns data.frame
#' @export
#'
#' @examples
#' df <- janeaustenr::austen_books()
#' export_to_iramuteq(df,"book","text",tempfile())
#' import_from_iramuteq(tempfile())
import_from_iramuteq <- function(file) {
  # file : chemin vers le fichier .txt IRaMuTeQ

  # Lire toutes les lignes
  lines <- readLines(file, encoding = "UTF-8")  # adapte l'encodage si besoin

  # Indices de début de documents
  header_idx <- grep("^\\*\\*\\*\\*", lines)
  if (length(header_idx) == 0) {
    stop("Aucun en-tête '****' trouvé dans le fichier.")
  }

  # Ajouter un indice de fin pour boucler proprement
  header_idx <- c(header_idx, length(lines) + 1)

  docs <- vector("list", length(header_idx) - 1)

  for (k in seq_len(length(docs))) {
    h_line <- lines[header_idx[k]]

    # Lignes de texte du document (entre deux en-têtes)
    if (header_idx[k] + 1 <= header_idx[k + 1] - 1) {
      body_lines <- lines[(header_idx[k] + 1):(header_idx[k + 1] - 1)]
    } else {
      body_lines <- ""
    }

    text <- paste(body_lines, collapse = " ")
    text <- trimws(text)

    # Découper la ligne d'en-tête
    tokens <- strsplit(h_line, "\\s+")[[1]]
    meta_tokens <- tokens[-1]  # on enlève "****"

    meta_list <- list(text = text)

    for (mt in meta_tokens) {
      mt2 <- sub("^\\*", "", mt)  # enlever le *

      # 1) cas var=val (si tu l'utilises un jour)
      if (grepl("=", mt2)) {
        parts <- str_split(mt2, "=", n = 2)[[1]]
        # 2) cas var_val (ton exemple : yearvideo_2023)
      } else if (grepl("_", mt2)) {
        parts <- str_split(mt2, "_", n = 2)[[1]]
      } else {
        # si pas de séparateur, on met tout dans le nom, valeur NA
        parts <- c(mt2, NA_character_)
      }

      var <- parts[1]
      val <- parts[2]

      meta_list[[var]] <- val
    }

    docs[[k]] <- meta_list
  }

  # Convertir la liste de listes en data.frame (remplit les colonnes manquantes avec NA)
  # Si tu as dplyr à dispo :
  df <- dplyr::bind_rows(docs)

  # Version base R pour être 100% autonome :
  # all_names <- unique(unlist(lapply(docs, names)))
  # df <- do.call(
  #   rbind,
  #   lapply(docs, function(x) {
  #     x[setdiff(all_names, names(x))] <- NA
  #     x[all_names]
  #   })
  # )

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
#' export_to_iramuteq(df,"book","text",tempfile())
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
