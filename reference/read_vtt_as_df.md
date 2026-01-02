# Convert subtitles file to minuted data.frame

Convert subtitles file to minuted data.frame

## Usage

``` r
read_vtt_as_df(vtt_file)
```

## Arguments

- vtt_file:

  name of a subtitles file

## Value

data.frame

## Examples

``` r
path_vtt <- lexico_example("6IOUEJN6GRI.fr.vtt")
read_vtt_as_df(path_vtt)
#> # A tibble: 584 × 5
#>    n_grp start   end text                                               video_id
#>    <dbl> <dbl> <dbl> <chr>                                              <chr>   
#>  1     0  3.40  6.31 Et c'est l'heure du face- à face, il est arrivé à… 6IOUEJN…
#>  2     1  6.31  7.6  d'Armanin. [rires]                                 6IOUEJN…
#>  3     2  7.6  11.8  Vous êtes le garde des SAAU, ministre de la justi… 6IOUEJN…
#>  4     3 11.8  13.2  à vous poser parce qu'en plus votre                6IOUEJN…
#>  5     4 13.2  16.3  parole est de plus en plus rare. Désormais vous v… 6IOUEJN…
#>  6     5 16.3  17.9  les questions politiques mais là il y a            6IOUEJN…
#>  7     6 17.9  23.1  vraiment du boulot et notamment sur le front de l… 6IOUEJN…
#>  8     7 23.1  26.9  notamment détailler votre projet de loi.           6IOUEJN…
#>  9     8 26.9  30.6  Je cite le titre de votre projet de loi. Un proje… 6IOUEJN…
#> 10     9 30.6  34.9  sanction utile, rapide et effective. en            6IOUEJN…
#> # ℹ 574 more rows
```
