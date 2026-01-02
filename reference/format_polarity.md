# Format gt with polarity

Format gt with polarity

## Usage

``` r
format_polarity(gt)
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
df_polarity <- get_dominant_polarity(df_sentiment,1)
#> Error: 'rownames_to_column' is not an exported object from 'namespace:dplyr'
format_polarity(gt(summarise_polarity(df_polarity)))
#> Error in loadNamespace(x): there is no package called ‘gt’
```
