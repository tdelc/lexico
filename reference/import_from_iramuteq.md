# import df from iramuteq

import df from iramuteq

## Usage

``` r
import_from_iramuteq(file)
```

## Arguments

- file:

  path to file .txt from IRaMuTeQ

## Value

data.frame

## Examples

``` r
df <- janeaustenr::austen_books()[1:10,]
path_txt <- file.path(tempfile(fileext=".txt"))
export_to_iramuteq(df,"book","text",path_txt)
#> NULL
import_from_iramuteq(path_txt)
#>                     text              book
#> 1  SENSE AND SENSIBILITY Sense&Sensibility
#> 2                        Sense&Sensibility
#> 3         by Jane Austen Sense&Sensibility
#> 4                        Sense&Sensibility
#> 5                 (1811) Sense&Sensibility
#> 6                        Sense&Sensibility
#> 7                        Sense&Sensibility
#> 8                        Sense&Sensibility
#> 9                        Sense&Sensibility
#> 10             CHAPTER 1 Sense&Sensibility
```
