# Get most frequent emotion of a sentiment score df

Get most frequent emotion of a sentiment score df

## Usage

``` r
get_dominant_emotion(df_sentiment, threshold = 5)
```

## Arguments

- df_sentiment:

  data.frame from get_nrc_sentiment

- threshold:

  minimum frequency to keep emotion

## Value

data.frame

## Examples

``` r
vec_text <- janeaustenr::austen_books()$text
df_sentiment <- syuzhet::get_nrc_sentiment(vec_text[1:50], lang="english")
df_emotion <- get_dominant_emotion(df_sentiment,2)
dplyr::count(df_emotion,emotion)
#> # A tibble: 5 × 2
#>   emotion          n
#>   <chr>        <int>
#> 1 anger            1
#> 2 anticipation     3
#> 3 surprise         1
#> 4 trust            3
#> 5 undiff          42
```
