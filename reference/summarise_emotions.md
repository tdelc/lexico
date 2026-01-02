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
#> Error in get_dominant_emotion(df_sentiment, 1): object 'sentiment_scores' not found
summarise_emotions(df_emotion)
#> Error in ungroup(.): could not find function "ungroup"
```
