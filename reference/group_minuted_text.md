# Regroup text by minutes

Regroup text by minutes

## Usage

``` r
group_minuted_text(df, minutes, video_id = video_id)
```

## Arguments

- df:

  minuted data.frame from read_vtt_as_df()

- minutes:

  number of minutes to regroup

- video_id:

  name of id variable

## Value

data.frame

## Examples

``` r
df_text <- read.csv(lexico_example("df_text_bfm.csv"))
head(group_minuted_text(df_text,2))
#> # A tibble: 6 × 5
#>   video_id    minute  start   end text                                          
#>   <chr>        <dbl>  <dbl> <dbl> <chr>                                         
#> 1 6IOUEJN6GRI      0   3.40  120. "Et c'est l'heure du face- à face, il est arr…
#> 2 6IOUEJN6GRI      1 120.    240. "pouvait pendant un temps relativement long a…
#> 3 6IOUEJN6GRI      2 240.    363. "carcéral, nos prisons à ça. On va pas envoye…
#> 4 6IOUEJN6GRI      3 363.    481. "qui devrait pas être sur notre territoire na…
#> 5 6IOUEJN6GRI      4 481.    600. "passe à l'intérieur des prisons. Est-ce que …
#> 6 6IOUEJN6GRI      5 600.    721. "prison si les gardiens eux-mêmes ne peuvent …
```
