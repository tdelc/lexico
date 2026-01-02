# Regroup text by minutes

Regroup text by minutes

## Usage

``` r
group_minuted_text(df, minutes, video_id = "video_id")
```

## Arguments

- df:

  minuted data.frame from read_vtt_as_df()

- minutes:

  number of minutes to regroup

- video_id:

  name of id variable

## Value

data.frame

## Examples

``` r
df_text <- read.csv("inst/extdata/df_text_bfm.csv")
#> Warning: cannot open file 'inst/extdata/df_text_bfm.csv': No such file or directory
#> Error in file(file, "rt"): cannot open the connection
head(group_minuted_text(df_text,2))
#> Error in ungroup(.): could not find function "ungroup"
```
