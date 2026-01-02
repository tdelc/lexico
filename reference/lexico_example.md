# Obtain extdata for the lexico package

Obtain extdata for the lexico package

## Usage

``` r
lexico_example(path = NULL)
```

## Arguments

- path:

  name of file

## Value

link of path or (if path is null) list of paths

## Examples

``` r
lexico_example()
#>  [1] "6IOUEJN6GRI.fr.vtt" "Ab_5e7jEoag.fr.vtt" "QA84_nDOREk.fr.vtt"
#>  [4] "RAPPORT.txt"        "corpus_bfm.txt"     "dendrogramme_1.png"
#>  [7] "df_info_bfm.csv"    "df_segment.csv"     "df_stat_bfm.csv"   
#> [10] "df_text_bfm.csv"    "export_corpus.txt"  "mjdbw7M0LRI.fr.vtt"
#> [13] "p6Pzs3iGwNk.fr.vtt"
lexico_example("df_info_bfm.csv")
#> [1] "/home/runner/work/_temp/Library/lexico/extdata/df_info_bfm.csv"
```
