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
df_sentiment <- syuzhet::get_nrc_sentiment(vec_text[1:50], lang="english")
df_polarity <- get_dominant_polarity(df_sentiment,1)
format_polarity(gt::gt(summarise_polarity(df_polarity)))
#> Joining with `by = join_by(polarity)`


  

Négatif
```

Neutre

Positif

16.0%

44.0%

40.0%
