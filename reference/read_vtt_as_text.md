# Convert subtitles file to text (OLD)

Convert subtitles file to text (OLD)

## Usage

``` r
read_vtt_as_text(vtt_file)
```

## Arguments

- vtt_file:

  name of a subtitles file

## Value

data.frame

## Examples

``` r
path_vtt <- lexico_example("6IOUEJN6GRI.fr.vtt")
read_vtt_as_text(path_vtt)
#> # A tibble: 1 × 2
#>   video_id    text                                                              
#>   <chr>       <chr>                                                             
#> 1 6IOUEJN6GRI "  Et c'est l'heure du face- à face, il est arrivé à l'instant. B…
```
