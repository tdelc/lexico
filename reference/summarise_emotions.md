# Summarise emotions of a data.frame

Summarise emotions of a data.frame

## Usage

``` r
summarise_emotions(df)
```

## Arguments

- df:

  data.frame to summarise

## Value

data.frame

## Examples

``` r
vec_text <- janeaustenr::austen_books()$text
df_sentiment <- syuzhet::get_nrc_sentiment(vec_text[1:50], lang="english")
df_emotion <- get_dominant_emotion(df_sentiment,1)
summarise_emotions(df_emotion)
#> Joining with `by = join_by(emotion)`
#> # A tibble: 1 × 10
#>   n_all undiff   joy  fear sadness anger disgust surprise trust anticipation
#>   <int>  <dbl> <dbl> <dbl>   <dbl> <dbl>   <dbl>    <dbl> <dbl>        <dbl>
#> 1    50   0.46  0.02     0    0.02  0.08    0.02     0.02  0.16         0.22
```
