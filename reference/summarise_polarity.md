# Summarise polarity of a data.frame

Summarise polarity of a data.frame

## Usage

``` r
summarise_polarity(df)
```

## Arguments

- df:

  data.frame to summarise

## Value

data.frame

## Examples

``` r
vec_text <- janeaustenr::austen_books()$text
sentiment_scores <- syuzhet::get_nrc_sentiment(vec_text[1:50], lang="english")
df_polarity <- get_dominant_polarity(df_polarity,1)
#> Error: 'rownames_to_column' is not an exported object from 'namespace:dplyr'
summarise_polarity(df_polarity)
#> Error in ungroup(.): could not find function "ungroup"
```
