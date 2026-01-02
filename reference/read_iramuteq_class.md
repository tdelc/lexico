# Read report from iramuteq to extract words of each class

Read report from iramuteq to extract words of each class

## Usage

``` r
read_iramuteq_class(file, classe = 1)
```

## Arguments

- file:

  path to report file .txt from IRaMuTeQ

- classe:

  index of class to extract

## Value

data.frame

## Examples

``` r
path_iramtueq <- "inst/extdata/corpus_janeausten/corpus_janeausten_alceste_1"
path_txt <- file.path(path_iramtueq,"RAPPORT.txt")
head(read_iramuteq_class(path_txt,1))
#> Warning: cannot open file 'inst/extdata/corpus_janeausten/corpus_janeausten_alceste_1/RAPPORT.txt': No such file or directory
#> Error in file(con, "r"): cannot open the connection
```
