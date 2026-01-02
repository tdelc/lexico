# Plot a treemap of thema and classe of segments

Plot a treemap of thema and classe of segments

## Usage

``` r
treemap_double_classe(
  df,
  id_theme,
  theme,
  classe,
  threshold = 30,
  title = "Treemap",
  footer = "",
  palette = NA
)
```

## Arguments

- df:

  data.frame with theme and classe

- id_theme:

  id of theme (to order it)

- theme:

  name of theme variable

- classe:

  name of classe variable

- threshold:

  minimum frequent of classe to show

- title:

  title of the treemap

- footer:

  (optional) footer of the treemap

- palette:

  (optional) palette to color theme

## Value

plot

## Examples

``` r
df_segment <- read.csv("inst/extdata/df_segment.csv")
#> Warning: cannot open file 'inst/extdata/df_segment.csv': No such file or directory
#> Error in file(file, "rt"): cannot open the connection
treemap_double_classe(df_segment,"id_classe","classe","classe_local",0)
#> Error in mutate(., theme_ = paste0(theme_, " (", round(100 * sum(n)/n_all),     "%)")): could not find function "mutate"
```
