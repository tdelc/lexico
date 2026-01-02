# Export to iramuteq

Export to iramuteq

## Usage

``` r
export_to_iramuteq(df, meta_cols, text_col, output_file)
```

## Arguments

- df:

  df to export

- meta_cols:

  names of cols to export as meta

- text_col:

  name of col to export as text

- output_file:

  name of txt file

## Value

nothing (create file)

## Examples

``` r
df <- janeaustenr::austen_books()
path_txt <- file.path(tempfile(fileext=".txt"))
export_to_iramuteq(df,"book","text",path_txt)
#> NULL
```
