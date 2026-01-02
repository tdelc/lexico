# Correct apostrophe

Correct apostrophe

## Usage

``` r
remove_apostrophe(
  text,
  patterns = c("l", "d", "qu", "j", "s", "m", "n", "c", "t")
)
```

## Arguments

- text:

  vector of strings to correct

- patterns:

  patterns

## Value

text

## Examples

``` r
remove_apostrophe("Aujourd'hui, j'ai pris l'avion")
#> [1] "Aujourhui, ai pris avion"
```
