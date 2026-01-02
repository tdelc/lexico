# Convert quanteda corpus to tokens

Convert quanteda corpus to tokens

## Usage

``` r
corpus_to_tokens(
  corpus,
  recode_words = get_recode_words(),
  stopwords = get_specific_stopwords(),
  multiwords = get_specific_multiwords()
)
```

## Arguments

- corpus:

  corpus from quanteda

- recode_words:

  names vector of words to recode

- stopwords:

  words to remove

- multiwords:

  words to collapse

## Value

tokens

## Examples

``` r
corpus_to_tokens(quanteda::data_corpus_inaugural)
#> Tokens consisting of 60 documents and 4 docvars.
#> 1789-Washington :
#>  [1] "fellow-citizens" "the"             "senate"          "and"            
#>  [5] "the"             "house"           "representatives" "among"          
#>  [9] "the"             "vicissitudes"    "incident"        "life"           
#> [ ... and 1,074 more ]
#> 
#> 1793-Washington :
#>  [1] "fellow"    "citizens"  "again"     "called"    "upon"      "the"      
#>  [7] "voice"     "country"   "execute"   "the"       "functions" "its"      
#> [ ... and 84 more ]
#> 
#> 1797-Adams :
#>  [1] "when"      "was"       "first"     "perceived" "early"     "times"    
#>  [7] "that"      "middle"    "course"    "for"       "america"   "remained" 
#> [ ... and 1,734 more ]
#> 
#> 1801-Jefferson :
#>  [1] "friends"   "and"       "fellow"    "citizens"  "called"    "upon"     
#>  [7] "undertake" "the"       "duties"    "the"       "first"     "executive"
#> [ ... and 1,354 more ]
#> 
#> 1805-Jefferson :
#>  [1] "proceeding"    "fellow"        "citizens"      "that"         
#>  [5] "qualification" "which"         "the"           "constitution" 
#>  [9] "requires"      "before"        "entrance"      "the"          
#> [ ... and 1,694 more ]
#> 
#> 1809-Madison :
#>  [1] "unwilling" "depart"    "from"      "examples"  "the"       "most"     
#>  [7] "revered"   "authority" "avail"     "myself"    "the"       "occasion" 
#> [ ... and 859 more ]
#> 
#> [ reached max_ndoc ... 54 more documents ]
```
