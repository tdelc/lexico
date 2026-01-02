# get recoding words

get recoding words

## Usage

``` r
get_recode_words()
```

## Value

named vector of words

## Examples

``` r
get_recode_words()
#>     (^|[^a-z])(sarkozi)([^a-z]|$)        (^|[^a-z])(atal)([^a-z]|$) 
#>                   "\\1sarkozy\\3"                     "\\1attal\\3" 
#>       (^|[^a-z])(hatal)([^a-z]|$)     (^|[^a-z])(baayrou)([^a-z]|$) 
#>                     "\\1attal\\3"                    "\\1bayrou\\3" 
#>      (^|[^a-z])(baayou)([^a-z]|$)       (^|[^a-z])(berou)([^a-z]|$) 
#>                    "\\1bayrou\\3"                    "\\1bayrou\\3" 
#>      (^|[^a-z])(berrou)([^a-z]|$)        (^|[^a-z])(baou)([^a-z]|$) 
#>                    "\\1bayrou\\3"                    "\\1bayrou\\3" 
#>       (^|[^a-z])(baïou)([^a-z]|$)      (^|[^a-z])(c'està)([^a-z]|$) 
#>                    "\\1bayrou\\3"                   "\\1c'est à\\3" 
#>     (^|[^a-z])(c'estàd)([^a-z]|$)  (^|[^a-z])(c'estàdire)([^a-z]|$) 
#>                 "\\1c'est à d\\3"              "\\1c'est à dire\\3" 
#> (^|[^a-z])(c'està-dire)([^a-z]|$)    (^|[^a-z])(rotillot)([^a-z]|$) 
#>              "\\1c'est à dire\\3"                "\\1retailleau\\3" 
#>   (^|[^a-z])(rotaillot)([^a-z]|$)     (^|[^a-z])(rotillo)([^a-z]|$) 
#>                "\\1retailleau\\3"                "\\1retailleau\\3" 
#>     (^|[^a-z])(weekend)([^a-z]|$) (^|[^a-z])(délinquence)([^a-z]|$) 
#>                  "\\1week-end\\3"               "\\1délinquance\\3" 
#>    (^|[^a-z])(zelenski)([^a-z]|$)     (^|[^a-z])(jordane)([^a-z]|$) 
#>                  "\\1zelensky\\3"                    "\\1jordan\\3" 
#>       (^|[^a-z])(lecnu)([^a-z]|$)     (^|[^a-z])(gluxman)([^a-z]|$) 
#>                   "\\1lecornu\\3"                "\\1glucksmann\\3" 
#>     (^|[^a-z])(gluxman)([^a-z]|$)        (^|[^a-z])(Lucy)([^a-z]|$) 
#>                "\\1glucksmann\\3"                     "\\1Lucie\\3" 
#>       (^|[^a-z])(queil)([^a-z]|$)    (^|[^a-z])(troisème)([^a-z]|$) 
#>                    "\\1que il\\3"                 "\\1troisième\\3" 
#>      (^|[^a-z])(cétait)([^a-z]|$)     (^|[^a-z])(europin)([^a-z]|$) 
#>                   "\\1c'était\\3"                  "\\1europe 1\\3" 
#>     (^|[^a-z])(voquier)([^a-z]|$)      (^|[^a-z])(vquier)([^a-z]|$) 
#>                  "\\1Vauquier\\3"                  "\\1Vauquier\\3" 
#>      (^|[^a-z])(voquet)([^a-z]|$)   (^|[^a-z])(netaniaou)([^a-z]|$) 
#>                  "\\1Vauquier\\3"                "\\1netanyahou\\3" 
#>   (^|[^a-z])(netanahou)([^a-z]|$) (^|[^a-z])(netaniaahou)([^a-z]|$) 
#>                "\\1netanyahou\\3"                "\\1netanyahou\\3" 
#>     (^|[^a-z])(matigon)([^a-z]|$)     (^|[^a-z])(bonpard)([^a-z]|$) 
#>                  "\\1matignon\\3"                   "\\1bompard\\3" 
#>     (^|[^a-z])(fériers)([^a-z]|$)      (^|[^a-z])(férier)([^a-z]|$) 
#>                   "\\1février\\3"                   "\\1février\\3" 
#>      (^|[^a-z])(lebret)([^a-z]|$)   (^|[^a-z])(quinquena)([^a-z]|$) 
#>                   "\\1le bret\\3"               "\\1quinquennat\\3" 
#>   (^|[^a-z])(bardellaa)([^a-z]|$)       (^|[^a-z])(mayot)([^a-z]|$) 
#>                  "\\1bardella\\3"                   "\\1mayotte\\3" 
#>        (^|[^a-z])(jeis)([^a-z]|$)      (^|[^a-z])(surcis)([^a-z]|$) 
#>                   "\\1je suis\\3"                    "\\1sursis\\3" 
#>    (^|[^a-z])(làdessus)([^a-z]|$)    (^|[^a-z])(hzbollah)([^a-z]|$) 
#>                 "\\1là-dessus\\3"                 "\\1hezbollah\\3" 
#>       (^|[^a-z])(panau)([^a-z]|$)  (^|[^a-z])(ellisabeth)([^a-z]|$) 
#>                     "\\1panot\\3"                 "\\1elisabeth\\3" 
#>     (^|[^a-z])(armanin)([^a-z]|$)    (^|[^a-z])(mitteran)([^a-z]|$) 
#>                  "\\1darmanin\\3"                 "\\1mitterand\\3" 
#>     (^|[^a-z])(narrive)([^a-z]|$)    (^|[^a-z])(évidment)([^a-z]|$) 
#>                  "\\1n'arrive\\3"                "\\1évidemment\\3" 
#> (^|[^a-z])(d'étatmajor)([^a-z]|$)    (^|[^a-z])(puisquil)([^a-z]|$) 
#>              "\\1d'état major\\3"                "\\1puis qu'il\\3" 
#>    (^|[^a-z])(banlieux)([^a-z]|$) (^|[^a-z])(d'obtempéré)([^a-z]|$) 
#>                   "\\1banlieu\\3"              "\\1d'obtempérer\\3" 
#>   (^|[^a-z])(mélanchon)([^a-z]|$)    (^|[^a-z])(politiqu)([^a-z]|$) 
#>                 "\\1mélenchon\\3"                 "\\1politique\\3" 
#>      (^|[^a-z])(minist)([^a-z]|$)    (^|[^a-z])(puisquon)([^a-z]|$) 
#>                  "\\1ministre\\3"                 "\\1puisqu'on\\3" 
#>  (^|[^a-z])(politiquee)([^a-z]|$)  (^|[^a-z])(ministrere)([^a-z]|$) 
#>                 "\\1politique\\3"                 "\\1ministère\\3" 
#>  (^|[^a-z])(franceise )([^a-z]|$)    (^|[^a-z])(jean luc)([^a-z]|$) 
#>          "\\1france insoumise\\3"                  "\\1jean-luc\\3" 
#>      (^|[^a-z])(anouna)([^a-z]|$) 
#>                   "\\1hanouna\\3" 
```
