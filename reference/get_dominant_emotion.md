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
#> Error in get_dominant_emotion(df_sentiment, 2): object 'sentiment_scores' not found
dplyr::count(df_emotion,sentiment)
#> Error: object 'df_emotion' not found
```
