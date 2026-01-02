# Format gt with emotions

Format gt with emotions

## Usage

``` r
format_emotions(gt)
```

## Arguments

- gt:

  gt to format : label, color, percent

## Value

gt

## Examples

``` r
vec_text <- janeaustenr::austen_books()$text
sentiment_scores <- syuzhet::get_nrc_sentiment(vec_text[1:50], lang="english")
df_emotion <- get_dominant_emotion(df_sentiment,1)
#> Error in get_dominant_emotion(df_sentiment, 1): object 'sentiment_scores' not found
format_emotions(gt(summarise_emotions(df_emotion)))
#> Error in loadNamespace(x): there is no package called ‘gt’
```
