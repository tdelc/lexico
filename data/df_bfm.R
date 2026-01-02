#' Sample of df_info
#'
#' A dataset containing informations for 5 YouTube videos extracted
#'   from YouTube with get_playlist_items. The variables are as follows:
#'
#' \itemize{
#'   \item video_id. Identifier of the video from YouTube
#'   \item playlist_id. Identifier of the playlist from Youtube
#'   \item publishedAt. Date of video publication
#'   \item title. Title of the video
#'   \item channelTitle. Title of the channel
#'   \item description. Description of the video
#'   \item position. Position of the video in the playlist. Here all NA
#' }
#'
#' @docType data
#' @keywords datasets
#' @name df_info_bfm
#' @usage data(df_info_bfm)
#' @format A data frame with 5 rows and 7 variables
NULL

#' Sample of df_stat
#'
#' A dataset containing statistics for 5 YouTube videos extracted
#'   from YouTube with get_videos_details. The variables are as follows:
#'
#' \itemize{
#'   \item video_id. Identifier of the video from YouTube
#'   \item publishedAt. Date of video publication
#'   \item title. Title of the video
#'   \item description. Description of the video
#'   \item channelId. Identifier of the channel
#'   \item channelTitle. Title of the channel
#'   \item categoryId. Category of the video (see https://gist.github.com/dgp/1b24bf2961521bd75d6c?permalink_comment_id=2978499)
#'   \item Language. Language
#'   \item AudioLanguage. Audio language
#'   \item tags. tags separated by |
#'   \item duration. duration in text format (format = PT18M30S for 18m30s)
#'   \item caption. logical, is the video has caption
#'   \item viewCount. Number of views
#'   \item likeCount. Number of likes
#'   \item commentCount. Number of comments
#' }
#'
#' @docType data
#' @keywords datasets
#' @name df_stat_bfm
#' @usage data(df_stat_bfm)
#' @format A data frame with 5 rows and 15 variables
NULL

#' Sample of df_text
#'
#' A dataset containing subtitle text for 5 YouTube videos extracted
#'   from YouTube with get_playlist_items. The variables are as follows:
#'
#' \itemize{
#'   \item video_id. Identifier of the video from YouTube
#'   \item suffix. Identifier of the playlist from user
#'   \item n_grp. Identifier of text blocks
#'   \item start. timestamp of start
#'   \item end. timestamp of end
#'   \item text. text of the block
#' }
#'
#' @docType data
#' @keywords datasets
#' @name df_text_bfm
#' @usage data(df_text_bfm)
#' @format A data frame with 2240 rows and 6 variables
NULL
