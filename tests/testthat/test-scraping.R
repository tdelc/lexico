yt_dlp  <- Sys.getenv("YT_DLP_PATH")
api_key <- Sys.getenv("YT_API_KEY")
playlist_id <- "PL-qBKb-rfbhjZjW0RQr3Dm8iIvXFE0Gwy"

test_that("get_playlist_items() works", {
  skip_if(api_key == "", "No API key found")
  df_info <- get_playlist_items(api_key, playlist_id, max_results = 10)

  expect_equal(colnames(df_info),
               c("video_id","playlist_id","publishedAt",
                 "title","channelTitle","description","position"))
})

test_that("get_videos_details() works", {
  skip_if(api_key == "", "No API key found")

  df_info <- get_playlist_items(api_key, playlist_id, max_results = 10)
  df_stat <- get_videos_details(api_key, df_info[1:10,"video_id"])

  expected_colnames <- c("video_id","publishedAt","title","description",
                         "channelId","channelTitle","categoryId","Language",
                         "AudioLanguage","tags","duration","caption",
                         "viewCount","likeCount","commentCount")

  expect_equal(colnames(df_stat),expected_colnames)
})

test_that("get_videos_details() works", {
  skip_if(api_key == "", "No API key found")

  temp_dir <- tempdir()

  df_info <- get_playlist_items(api_key, playlist_id, max_results = 10)
  download_subtitles(df_info[1,"video_id"],temp_dir,yt_dlp)

  file <- list.files(temp_dir,pattern = paste0(df_info[1,"video_id"],".*?.vtt"))
  size <- file.info(file.path(temp_dir,file))$size
  expect_equal(length(file),1)
  expect_gt(size,50000)
})
