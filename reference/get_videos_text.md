# Get YouTube subtitles of videos

Get YouTube subtitles of videos

## Usage

``` r
get_videos_text(
  video_ids,
  path,
  suffix,
  yt_dlp_path = "yt-dlp",
  force_dl = FALSE
)
```

## Arguments

- video_ids:

  vector of youtube id

- path:

  path to save subtitles

- suffix:

  suffix to identify the playlist

- yt_dlp_path:

  path to yt_dlp

- force_dl:

  force the download of subtitles

## Value

data.frame
