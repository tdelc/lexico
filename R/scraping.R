#' Get YouTube informations of videos from a playlist
#'
#' @param api_key youtube api key
#' @param playlist_id id of the playlist
#' @param max_results maximum amount of results
#'
#' @returns data.frame
#' @export
get_videos_info <- function(api_key, playlist_id, max_results = 100) {

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

  df[1:max_results,] %>%
    dplyr::filter(!is.na(video_id))
}

#' Get YouTube statistics informations of videos
#'
#' @param api_key youtube api key
#' @param video_ids vector of youtube id
#'
#' @returns data.frame
#' @export
get_videos_stat <- function(api_key, video_ids) {

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

  return(df)
}

#' Get YouTube subtitles of videos
#'
#' @param video_ids vector of youtube id
#' @param yt_dlp_path path to yt_dlp
#' @param path path to save subtitles
#' @param suffix suffix to identify the playlist
#' @param force_dl force the download of subtitles
#'
#' @returns data.frame
#' @export
get_videos_text <- function(video_ids,
                            path,
                            suffix,
                            yt_dlp_path = "yt-dlp",
                            force_dl = FALSE) {

  dir_path <- file.path(path,paste0("subs_",suffix))
  dir.create(dir_path, showWarnings = FALSE)

  cli::cli_alert_info("Number of subtitles to download: {length(video_ids)}")
  purrr::walk(video_ids, download_subtitles,
              out_dir = dir_path, yt_dlp_path = yt_dlp_path)

  list_files <- list.files(dir_path, pattern = "\\.vtt$", full.names = TRUE)

  return(vtt_files_to_df(path,suffix))
}

#' Download subtitles from a youtube video
#'
#' @param video_id video id
#' @param out_dir directory to save file
#' @param yt_dlp_path path to yt_dlp
#' @param force_dl overide existed vtt file
#'
#' @returns NULL
#' @export
download_subtitles <- function(video_id,
                               out_dir,
                               yt_dlp_path = "yt-dlp",
                               force_dl = FALSE) {
  url <- paste0("https://www.youtube.com/watch?v=", video_id)

  out_template <- file.path(out_dir, "%(id)s.%(ext)s")

  file_path <- file.path(out_dir,paste0(video_id,".fr.vtt"))
  if (file.exists(file_path) & !force_dl) {
    return(NULL)
  }

  # Créer un faux fichier (pour contourner à forcer les sous-titres vides)
  file.create(file_path)

  args <- c(
    "--write-auto-subs",      # sous-titres automatiques
    "--sub-lang", "fr",       # langue FR
    "--skip-download",        # ne pas télécharger la vidéo
    "--output", shQuote(out_template),
    url
  )

  cli::cli_alert_info("Downloading video {video_id}.")
  res <- system2(yt_dlp_path, args = args, stdout = TRUE, stderr = TRUE)
  invisible(res)
}

#' Run a complete extraction for a playlist id
#'
#' @param api_key youtube api key
#' @param yt_dlp_path path to yt_dlp
#' @param path path to save subtitles
#' @param suffix suffix to identify the playlist
#' @param playlist_id id of the playlist
#' @param max_videos maximum amont of videos to extract
#'
#' @returns NULL
#' @export
run_complete_extraction <- function(api_key,
                                    yt_dlp_path,
                                    path,
                                    suffix,
                                    playlist_id,
                                    max_videos){

  # Path and dirs
  path_info <- file.path(path,paste0("df_info_",suffix,".csv"))
  path_stat <- file.path(path,paste0("df_stat_",suffix,".csv"))
  path_text <- file.path(path,paste0("df_text_",suffix,".csv"))

  # Previous df
  df_info_prev <- NULL
  if (file.exists(path_info)){
    df_info_prev <- utils::read.csv(path_info) %>%
      dplyr::filter(!is.na(video_id)) %>%
      dplyr::select(-position) %>% dplyr::distinct()
  }

  df_stat_prev <- NULL
  if (file.exists(path_stat)){
    df_stat_prev <- utils::read.csv(path_stat)
    # %>% dplyr::mutate(categoryId = as.character(categoryId))
  }

  # Download info et stat
  df_info <- get_videos_info(api_key, playlist_id, max_results = max_videos)
  df_stat <- get_videos_stat(api_key,df_info$video_id)
  df_text <- get_videos_text(df_info$video_id,path,suffix,yt_dlp_path)

  df_info <- dplyr::bind_rows(df_info,df_info_prev)
  df_stat <- dplyr::bind_rows(df_stat,df_stat_prev)

  # Add info to df_text
  df_text <- df_text %>% dplyr::mutate(playlist_id = playlist_id)

  cli::cli_alert_info("Save files df_info_{suffix}, df_stat_{suffix}, df_text_{suffix}")
  utils::write.csv(df_info,file=path_info,row.names = F)
  utils::write.csv(df_info,file=path_stat,row.names = F)
  utils::write.csv(df_info,file=path_text,row.names = F)

  return(invisible(NULL))
}

#' Convert vtt files to minuted data.frame
#'
#' @param path path of vtt files
#' @param suffix suffix to identify the playlist
#'
#' @returns data.frame
#' @export
vtt_files_to_df <- function(path,
                            suffix){

  path_text <- file.path(path,paste0("df_text_",suffix,".csv"))
  dir_path <- file.path(path,paste0("subs_",suffix))

  list_files <- list.files(dir_path, pattern = "\\.vtt$", full.names = TRUE)

  cli::cli_process_start("Extraction du folder {suffix}")
  df_text <- list_files %>% purrr::map_dfr(read_vtt_as_df,.progress = TRUE)
  df_text$suffix <- suffix
  cli::cli_process_done()
  return(df_text)
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

