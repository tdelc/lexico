#' Get youtube infos from a playlist
#'
#' @param api_key youtube api key
#' @param playlist_id id of the playlist
#' @param max_results maximum amount of results
#'
#' @returns data.frame
#' @export
#'
#' @examples
get_playlist_items <- function(api_key, playlist_id, max_results = 100) {

  base_url <- "https://www.googleapis.com/youtube/v3/playlistItems"

  all_items <- list()
  df <- data.frame()
  next_page_token <- NULL
  fetched <- 0

  repeat {
    # nombre de vidéos à demander cette fois-ci (max 50 par appel API)
    n_this <- min(50, max_results - fetched)
    if (n_this <= 0) break

    query <- list(
      part       = "contentDetails,snippet",
      playlistId = playlist_id,
      maxResults = n_this,
      key        = api_key
    )

    if (!is.null(next_page_token)) {
      query$pageToken <- next_page_token
    }

    resp <- httr::GET(base_url, query = query)
    httr::stop_for_status(resp)

    dat <- jsonlite::fromJSON(httr::content(
      resp, as = "text", encoding = "UTF-8"))

    if (length(dat$items) == 0) break

    df_temp <- data.frame(
      video_id      = dat$items$contentDetails$videoId,
      playlist_id   = playlist_id,
      publishedAt   = dat$items$snippet$publishedAt,
      title         = dat$items$snippet$title,
      channelTitle  = dat$items$snippet$channelTitle,
      description   = dat$items$snippet$description,
      position      = dat$items$snippet$position
    )

    df <- dplyr::bind_rows(df,df_temp)

    next_page_token <- dat$nextPageToken
    if (is.null(next_page_token)) break
  }

  df
}

#' Get details from youtube videos
#'
#' @param api_key youtube api key
#' @param video_ids vector of youtube id
#'
#' @returns data.frame
#' @export
#'
#' @examples
get_videos_details <- function(api_key, video_ids) {

  base_url <- "https://www.googleapis.com/youtube/v3/videos"

  id_chunks <- split(video_ids, ceiling(seq_along(video_ids) / 50))

  df <- purrr::map_dfr(id_chunks, function(ids_chunk) {

    query <- list(
      part = "snippet,contentDetails,statistics",
      id   = paste(ids_chunk, collapse = ","),
      key  = api_key
    )

    resp <- httr::GET(base_url, query = query)
    httr::stop_for_status(resp)

    dat <- jsonlite::fromJSON(httr::content(
      resp, as = "text", encoding = "UTF-8"),flatten = TRUE)

    if (length(dat$items) == 0) return(data.frame())

    data.frame(
      video_id      = dat$items$id,
      publishedAt   = dat$items$snippet.publishedAt,
      title         = dat$items$snippet.title,
      description   = dat$items$snippet.description,
      channelId     = dat$items$snippet.channelId,
      channelTitle  = dat$items$snippet.channelTitle,
      categoryId    = dat$items$snippet.categoryId,
      Language      = dat$items$snippet.defaultLanguage,
      AudioLanguage = dat$items$snippet.defaultAudioLanguage,
      tags          = paste(unlist(dat$items$snippet.tags),collapse = "|"),
      duration      = dat$items$contentDetails.duration,
      caption       = dat$items$contentDetails.caption,
      viewCount     = as.numeric(dat$items$statistics.viewCount),
      likeCount     = as.numeric(dat$items$statistics.likeCount),
      commentCount  = as.numeric(dat$items$statistics.commentCount)
    )
  })

  df
}

#' Download subtitles from a youtube video
#'
#' @param video_id video id
#' @param out_dir directory to save file
#' @param yt_dlp name of program to launch
#'
#' @returns NULL
#' @export
#'
#' @examples
download_subtitles <- function(video_id,
                               out_dir,
                               yt_dlp = "yt-dlp",
                               force_dl = FALSE) {
  url <- paste0("https://www.youtube.com/watch?v=", video_id)

  out_template <- file.path(out_dir, "%(id)s.%(ext)s")

  file_path <- file.path(out_dir,paste0(video_id,".fr.vtt"))
  if (file.exists(file_path) & !force_dl) {
    return(NULL)
  }

  args <- c(
    "--write-auto-subs",      # sous-titres automatiques
    "--sub-lang", "fr",       # langue FR
    "--skip-download",        # ne pas télécharger la vidéo
    "--output", shQuote(out_template),
    url
  )

  cli::cli_alert_info("Downloading video {video_id}.")
  res <- system2(yt_dlp, args = args, stdout = TRUE, stderr = TRUE)
  invisible(res)
}

#' Convert subtitles file to text
#'
#' @param vtt_file name of a subtitles file
#'
#' @returns data.frame
#' @export
#'
#' @examples
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

  tibble(
    video_id = video_id,
    text = full_text
  )
}

#' Run a complete extraction for a playlist id
#'
#' @param api_key youtube api key
#' @param path path to save subtitles
#' @param suffix suffix to identify the playlist
#' @param playlist_id id of the playlist
#' @param max_videos maximum amont of videos to extract
#'
#' @returns
#' @export
#'
#' @examples
run_complete_extraction <- function(api_key,
                                    path,
                                    suffix,
                                    playlist_id,
                                    max_videos){

  # Path and dirs
  path_info <- file.path(path,paste0("df_info_",suffix,".csv"))
  path_stat <- file.path(path,paste0("df_stat_",suffix,".csv"))
  path_text <- file.path(path,paste0("df_text_",suffix,".csv"))

  dir_path <- file.path(path,paste0("subs_",suffix))
  dir.create(dir_path, showWarnings = FALSE)

  # Previous df
  df_info_prev <- NULL
  if (file.exists(path_info)) df_info_prev <- read.csv(path_info)

  df_stat_prev <- NULL
  if (file.exists(path_stat)){
    df_stat_prev <- read.csv(path_stat) %>%
      dplyr::mutate(categoryId = as.character(categoryId))
  }

  # Download info et stat
  df_info <- get_playlist_items(api_key, playlist_id, max_results = max_videos)
  df_stat <- get_videos_details(api_key,df_info$video_id)

  df_info <- dplyr::bind_rows(df_info,df_info_prev)
  df_stat <- dplyr::bind_rows(df_stat,df_stat_prev)

  cli::cli_alert_info("Save files df_info_{suffix}",suffix," and df_stat_{suffix}")
  write.csv(df_info,file=file.path(path,paste0("df_info_",suffix,".csv")),row.names = F)
  write.csv(df_stat,file=file.path(path,paste0("df_stat_",suffix,".csv")),row.names = F)

  vec_ids <- df_info %>% dplyr::pull(video_id)
  cli::cli_alert_info("Number of subtitles to download: {length(vec_ids)}")

  purrr::walk(vec_ids, download_subtitles,
              out_dir = dir_path, yt_dlp = yt_dlp_path)

  list_files <- list.files(dir_path, pattern = "\\.vtt$", full.names = TRUE)

  df_text <- purrr::map_dfr(list_files, read_vtt_as_text) %>%
    dplyr::mutate(chaine = suffix)

  write.csv(df_text,file=path_text,row.names = F)
  return(NULL)
}

#' Get duration of a youtube video
#'
#' @param duration duration in youtube format
#'
#' @returns number
#' @export
#'
#' @examples
#' parse_yt_duration("PT25M31S")
parse_yt_duration <- function(duration) {

  hours   <- stringr::str_extract(duration, "\\d+(?=H)")
  minutes <- stringr::str_extract(duration, "\\d+(?=M)")
  seconds <- stringr::str_extract(duration, "\\d+(?=S)")

  hours  [is.na(hours)]   <- 0
  minutes[is.na(minutes)] <- 0
  seconds[is.na(seconds)] <- 0

  hours   <- as.numeric(hours)
  minutes <- as.numeric(minutes)
  seconds <- as.numeric(seconds)

  total_seconds <- hours * 3600 + minutes * 60 + seconds
  return(total_seconds)
}

