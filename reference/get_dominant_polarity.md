# Get most frequent polarity of a sentiment score df

Get most frequent polarity of a sentiment score df

## Usage

``` r
get_dominant_polarity(df_sentiment, threshold = 5)
```

## Arguments

- df_sentiment:

  data.frame from get_nrc_sentiment

- threshold:

  minimum frequency to keep polarity

## Value

data.frame

## Examples

``` r
vec_text <- janeaustenr::austen_books()$text
df_sentiment <- syuzhet::get_nrc_sentiment(vec_text[1:50], lang="english")
df_polarity <- get_dominant_polarity(df_sentiment,2)
#> Error: 'rownames_to_column' is not an exported object from 'namespace:dplyr'
dplyr::count(df_polarity,polarity)
#> Error: object 'df_polarity' not found
```
