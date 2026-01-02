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
path_txt <- lexico_example("RAPPORT.txt")
head(read_iramuteq_class(path_txt,1))
#> # A tibble: 6 × 8
#>    rang freq_classe freq_totale   pct  chi2 pos   forme     p_value
#>   <int>       <int>       <int> <dbl> <dbl> <chr> <chr>       <dbl>
#> 1     0           4           5  80    23.8 adj   pire       0.0001
#> 2     1           3           3 100    22.7 ver   payer      0.0001
#> 3     2           4           6  66.7  18.9 nom   milliard   0.0001
#> 4     3           4           6  66.7  18.9 nr    lecornu    0.0001
#> 5     4           5          10  50    17.1 nr    sébastien  0.0001
#> 6     5           3           4  75    15.9 nom   économie   0.0001
```
