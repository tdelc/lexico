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
path_vtt <- file.path("inst/extdata/subs_bfm/6IOUEJN6GRI.fr.vtt")
read_vtt_as_text(path_vtt)
#> Warning: cannot open file 'inst/extdata/subs_bfm/6IOUEJN6GRI.fr.vtt': No such file or directory
#> Error in file(con, "r"): cannot open the connection
```
