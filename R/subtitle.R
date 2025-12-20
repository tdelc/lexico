#' Convert subtitles file to minuted data.frame
#'
#' @param vtt_file name of a subtitles file
#'
#' @returns data.frame
#' @export
read_vtt_as_df <- function(vtt_file) {

  x <- readLines(vtt_file, warn = FALSE, encoding = "UTF-8")

  # repérer les lignes "timecode --> timecode"
  idx <- which(stringr::str_detect(x, "-->"))

  df <- purrr::map_dfr(idx, function(i) {

    # timecodes
    times <- stringr::str_extract_all(x[i], "\\d{2}:\\d{2}:\\d{2}\\.\\d{3}")[[1]]

    start <- hms_to_sec(times[1])
    end   <- hms_to_sec(times[2])

    # texte = lignes suivantes jusqu'à ligne vide
    text <- x[(i + 1):length(x)+10] |>
      (\(z) z[!stringr::str_detect(z, "-->")])() |>
      (\(z) z[seq_len(which(z == "")[1] - 1)])() |>
      paste(collapse = " ")

    # nettoyage balises <00:00:xx.xxx><c>
    text <- text |>
      stringr::str_remove_all("<[^>]+>") |>
      stringr::str_squish()

    dplyr::tibble(
      start = start,
      end   = end,
      text  = text
    )
  })

  # Récupérer l'ID vidéo à partir du nom de fichier (avant le premier point)
  file_name <- basename(vtt_file)
  video_id <- sub("\\..*$", "", file_name)

  df %>%
    dplyr::mutate(n_grp = floor((dplyr::row_number()-1)/3)) %>%
    dplyr::group_by(n_grp) %>%
    dplyr::summarise(start = min(start),end = max(end),
                     text = dplyr::last(text)) %>% dplyr::ungroup() %>%
    dplyr::select(-n_grp) %>%
    dplyr::mutate(video_id = video_id)
}

# docs/scrap info 2025/raw/subs_bfm/XuTN2ObRdUg.fr.vtt

read_vtt_as_df_fast <- function(vtt_file) {

  x <- readLines(vtt_file, warn = FALSE, encoding = "UTF-8")

  time_idx <- which(stringr::str_detect(x, "-->"))

  # timecodes
  times <- stringr::str_extract_all(x[time_idx], "\\d{2}:\\d{2}:\\d{2}\\.\\d{3}")

  start <- vapply(times, \(z) hms_to_sec(z[1]), numeric(1))
  end   <- vapply(times, \(z) hms_to_sec(z[2]), numeric(1))

  # fin de chaque bloc = ligne vide suivante ou prochain timecode
  next_idx <- c(time_idx[-1] - 1, length(x))
  empty_idx <- which(x == "")

  end_text_idx <- vapply(
    seq_along(time_idx),
    function(k) {
      candidates <- empty_idx[empty_idx > time_idx[k] & empty_idx <= next_idx[k]]
      if (length(candidates)) candidates[1] - 1 else next_idx[k]
    },
    numeric(1)
  )

  text <- vapply(
    seq_along(time_idx),
    function(k) {
      paste(x[(time_idx[k] + 1):end_text_idx[k]], collapse = " ")
    },
    character(1)
  ) |>
    stringr::str_remove_all("<[^>]+>") |>
    stringr::str_squish()

  video_id <- sub("\\..*$", "", basename(vtt_file))

  dplyr::tibble(
    start = start,
    end   = end,
    text  = text
  ) |>
    dplyr::mutate(n_grp = (dplyr::row_number() - 1) %/% 3) |>
    dplyr::group_by(n_grp) |>
    dplyr::summarise(
      start = min(start),
      end   = max(end),
      text  = dplyr::last(text),
      .groups = "drop"
    ) |>
    dplyr::mutate(video_id = video_id)
}

#' Regroup text by minutes
#'
#' @param df minuted data.frame from read_vtt_as_df()
#' @param minutes number of minutes to regroup
#' @param video_id name of id variable
#'
#' @returns data.frame
#' @export
#'
#' @examples
group_minuted_text <- function(df,minutes,video_id="video_id"){
  secondes <- minutes*60
  df %>%
    dplyr::mutate(minute = floor(start/secondes)) %>%
    dplyr::group_by(!!sym(video_id),minute) %>%
    dplyr::summarise(start = min(start),end = max(end),
              text = paste(text, collapse = " ")) %>%
    ungroup()
}


hms_to_sec <- function(x) {
  h <- as.numeric(stringr::str_sub(x, 1, 2))
  m <- as.numeric(stringr::str_sub(x, 4, 5))
  s <- as.numeric(stringr::str_sub(x, 7))
  h * 3600 + m * 60 + s
}

#' Convert subtitles file to text
#'
#' @param vtt_file name of a subtitles file
#'
#' @returns data.frame
#' @export
read_vtt_as_text <- function(vtt_file) {
  lines <- readLines(vtt_file, warn = FALSE, encoding = "UTF-8")

  # On enlève l'entête et les lignes vides
  lines <- lines[lines != "" & lines != "WEBVTT"]
  lines <- lines[lines != "Kind: captions" & lines != "Language: fr"]

  # On enlève les timecodes (lignes contenant -->)
  lines <- lines[!grepl("-->", lines)]

  # On enlève les lignes contenant des <c>
  text_lines <- lines[!grepl("<c>", lines)]
  text_lines <- unique(text_lines)

  # On colle tout en un seul texte
  full_text <- paste(text_lines, collapse = " ")

  # Récupérer l'ID vidéo à partir du nom de fichier (avant le premier point)
  file_name <- basename(vtt_file)
  video_id <- sub("\\..*$", "", file_name)

  dplyr::tibble(
    video_id = video_id,
    text = full_text
  )
}
