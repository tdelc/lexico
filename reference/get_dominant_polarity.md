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
dplyr::count(df_polarity,polarity)
#> # A tibble: 3 × 2
#>   polarity     n
#>   <chr>    <int>
#> 1 negative     2
#> 2 neutral     36
#> 3 positive    12
```
