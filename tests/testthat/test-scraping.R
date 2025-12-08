yt_dlp  <- Sys.getenv("YT_DLP_PATH")
api_key <- Sys.getenv("YT_API_KEY")
playlist_id <- "PL-qBKb-rfbhjZjW0RQr3Dm8iIvXFE0Gwy"


# Scrap
df_info <- get_playlist_items(api_key, playlist_id, max_results = 10)
df_stat <- get_videos_details(api_key, df_info[1:10,"video_id"])
temp_dir <- tempdir()
download_subtitles(df_info[1,"video_id"],temp_dir,yt_dlp)
file <- list.files(temp_dir,pattern = paste0(df_info[1,"video_id"],".*?.vtt"))
df_vtt <- read_vtt_as_text(file.path(temp_dir,file))

test_that("get_playlist_items() works", {
  skip_if(api_key == "", "No API key found")
  expect_equal(colnames(df_info),
               c("video_id","playlist_id","publishedAt",
                 "title","channelTitle","description","position"))
})

test_that("get_videos_details() works", {
  skip_if(api_key == "", "No API key found")

  expected_colnames <- c("video_id","publishedAt","title","description",
                         "channelId","channelTitle","categoryId","Language",
                         "AudioLanguage","tags","duration","caption",
                         "viewCount","likeCount","commentCount")
  expect_equal(colnames(df_stat),expected_colnames)
})

test_that("get_videos_details() works", {
  skip_if(api_key == "", "No API key found")
  size <- file.info(file.path(temp_dir,file))$size
  expect_equal(length(file),1)
  expect_gt(size,50000)
})

test_that("read_vtt_as_text() works", {
  skip_if(api_key == "", "No API key found")
  expect_equal(colnames(df_vtt),c("video_id","text"))
})

run_complete_extraction(api_key, yt_dlp,temp_dir,"test",playlist_id,10)

test_that("run_complete_extraction() works", {
  skip_if(api_key == "", "No API key found")
  expect_true(dir.exists(file.path(temp_dir,"subs_test")))
  expect_true(file.exists(file.path(temp_dir,"df_info_test.csv")))
  expect_true(file.exists(file.path(temp_dir,"df_stat_test.csv")))
  expect_true(file.exists(file.path(temp_dir,"df_text_test.csv")))
})

test_that("parse_yt_duration() works", {
  expect_equal(parse_yt_duration("PT25M31S"),1531)
})
