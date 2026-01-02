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
df_sentiment <- syuzhet::get_nrc_sentiment(vec_text[1:50], lang="english")
df_polarity <- get_dominant_polarity(df_sentiment,1)
summarise_polarity(df_polarity)
#> Joining with `by = join_by(polarity)`
#> # A tibble: 1 × 3
#>   negative neutral positive
#>      <dbl>   <dbl>    <dbl>
#> 1     0.16    0.44      0.4
```
