# Analyser les textes avec Quanteda

Cette vignette montre comment passer d’un tableau de textes nettoyés à
des objets `quanteda` prêts pour l’analyse lexicométrique.

Avant de faire l’analyse quanteda, nous appliquons les corrections sur
le `df_text` (voir la vignette *Préparer les données textuelles* pour le
détail).

``` r
library(lexico)
library(dplyr)
library(stringr)
library(quanteda)

data(df_text_bfm)
df_text <- df_text_bfm

stopwords <- get_specific_stopwords()
stopwords_regex <- paste0("\\b(?:", paste(stopwords, collapse = "|"), ")\\b")

df_text <- df_text %>%
  mutate(text = tolower(text),
         text = str_remove_all(text,stopwords_regex),
         text = str_replace_all(text, get_recode_words()),
         text = str_remove_all(text,"\\[[a-z]+?\\]"),
         text = str_squish(text))

df_segment <- df_text %>%
  mutate(id_segment = 1+floor(start/(2*60))) %>%
  group_by(suffix,video_id,id_segment) %>%
  summarise(start = min(start),end = max(end),
            text = paste(text, collapse = " "),
            .groups = "drop")
```

## Du tableau au corpus

Pour créer un corpus quanteda, il faut un identifiant de document, une
variable de texte et d’éventuelles variables de métadonnées. Attention,
l’identifiant doit être unique, il nous faut donc créer une variable
couplant video_id et id_segment.

``` r
df_segment <- df_segment %>% mutate(doc_id = paste(video_id,id_segment))

corpus_segment <- corpus(df_segment, 
                         docid_field = "doc_id",
                         text_field  = "text")
```

## Tokenisation et nettoyage

Le corpus ainsi obtenu peut être retravaillé, nettoyé comme nous l’avons
fait durant l’étape de préparation des données. D’autres options
spécifiques au package quanteda peuvent être utilisées.

``` r
tokens_segment <- corpus_segment %>% 
  tokens(
    remove_punct = TRUE,
    remove_symbols = TRUE,
    remove_numbers = TRUE,
    remove_url = TRUE)  %>%
  tokens_tolower() %>%
  tokens_replace(names(get_recode_words()), unname(get_recode_words())) %>%
  tokens_remove(get_specific_stopwords()) %>%
  tokens_keep(pattern = "^.{3,}$",valuetype = "regex")

head(tokens_segment)
#> Tokens consisting of 6 documents and 5 docvars.
#> 6IOUEJN6GRI 1 :
#>  [1] "heure"      "face"       "face"       "arrivé"     "instant"   
#>  [6] "géralde"    "darmanin"   "garde"      "saau"       "ministre"  
#> [11] "justice"    "nombreuses"
#> [ ... and 137 more ]
#> 
#> 6IOUEJN6GRI 2 :
#>  [1] "pouvait"      "pendant"      "temps"        "relativement" "long"        
#>  [6] "agir"         "impunément"   "cas"          "sanctions"    "rapides"     
#> [11] "dissuasives"  "gens"        
#> [ ... and 171 more ]
#> 
#> 6IOUEJN6GRI 3 :
#>  [1] "carcéral"    "prisons"     "envoyer"     "gens"        "font"       
#>  [6] "mois"        "prison"      "maisons"     "arrêt"       "classiques" 
#> [11] "surpeuplées" "occasion"   
#> [ ... and 160 more ]
#> 
#> 6IOUEJN6GRI 4 :
#>  [1] "devrait"        "territoire"     "national"       "train"         
#>  [5] "appliquait"     "uqtf"           "loi"            "agents"        
#>  [9] "pénitentiaires" "agents"         "pénitentiaires" "magistrats"    
#> [ ... and 148 more ]
#> 
#> 6IOUEJN6GRI 5 :
#>  [1] "passe"     "intérieur" "prisons"   "prisons"   "états"     "droit"    
#>  [7] "voudrais"  "puissiez"  "document"  "commenter" "ceux"      "écoutent" 
#> [ ... and 128 more ]
#> 
#> 6IOUEJN6GRI 6 :
#>  [1] "prison"         "gardiens"       "mêmes"          "peuvent"       
#>  [5] "intervenir"     "surprennent"    "cocktail"       "affreux"       
#>  [9] "manque"         "agents"         "pénitentiaires" "rajoute"       
#> [ ... and 142 more ]
```

On peut ensuite construire une matrice document-terme :

``` r
dfm_segment <- dfm(tokens_segment)
dfm_segment
#> Document-feature matrix of: 52 documents, 2,835 features (96.08% sparse) and 5 docvars.
#>                features
#> docs            heure face arrivé instant géralde darmanin garde saau ministre
#>   6IOUEJN6GRI 1     1    2      1       1       1        1     2    1        1
#>   6IOUEJN6GRI 2     0    0      0       0       0        0     0    0        0
#>   6IOUEJN6GRI 3     0    0      0       0       0        0     0    0        0
#>   6IOUEJN6GRI 4     0    0      0       0       0        1     0    0        1
#>   6IOUEJN6GRI 5     0    0      0       1       0        0     0    0        1
#>   6IOUEJN6GRI 6     0    0      0       0       0        0     0    0        0
#>                features
#> docs            justice
#>   6IOUEJN6GRI 1      11
#>   6IOUEJN6GRI 2       1
#>   6IOUEJN6GRI 3       1
#>   6IOUEJN6GRI 4       2
#>   6IOUEJN6GRI 5       1
#>   6IOUEJN6GRI 6       0
#> [ reached max_ndoc ... 46 more documents, reached max_nfeat ... 2,825 more features ]
```

## Utiliser le dictionnaire fourni

Le package inclut un dictionnaire thématique prêt à l’emploi via
[`get_dictionary()`](https://tdelc.github.io/lexico/reference/get_dictionary.md).
Il s’utilise directement avec
[`tokens_lookup()`](https://quanteda.io/reference/tokens_lookup.html) ou
[`dfm_lookup()`](https://quanteda.io/reference/dfm_lookup.html).

``` r
dico <- get_dictionary()
dfm_thematic <- dfm_lookup(dfm_segment, dictionary = dico)
dfm_thematic
#> Document-feature matrix of: 52 documents, 13 features (73.08% sparse) and 5 docvars.
#>                features
#> docs            immigration securite police_justice religion_islam
#>   6IOUEJN6GRI 1           0        0             17              0
#>   6IOUEJN6GRI 2           0        0             27              0
#>   6IOUEJN6GRI 3           1        0             31              0
#>   6IOUEJN6GRI 4           3       11              7              0
#>   6IOUEJN6GRI 5           0        4             11              0
#>   6IOUEJN6GRI 6           0        0             12              0
#>                features
#> docs            identite_nationale valeurs_culturelles genre_minorites
#>   6IOUEJN6GRI 1                  0                   0               0
#>   6IOUEJN6GRI 2                  0                   0               0
#>   6IOUEJN6GRI 3                  1                   0               0
#>   6IOUEJN6GRI 4                  5                   0               0
#>   6IOUEJN6GRI 5                  1                   0               0
#>   6IOUEJN6GRI 6                  1                   0               0
#>                features
#> docs            racisme_discriminations politique_francaise partis_politiques
#>   6IOUEJN6GRI 1                       1                   2                 1
#>   6IOUEJN6GRI 2                       0                   1                 0
#>   6IOUEJN6GRI 3                       0                   0                 0
#>   6IOUEJN6GRI 4                       0                   2                 0
#>   6IOUEJN6GRI 5                       0                   1                 0
#>   6IOUEJN6GRI 6                       0                   0                 0
#> [ reached max_ndoc ... 46 more documents, reached max_nfeat ... 3 more features ]
```

`dfm_thematic` permet de suivre l’évolution de thèmes (immigration,
sécurité, etc.) sur les vidéos analysées. Il peut être agrégé par chaîne
ou par période avec
[`dfm_group()`](https://quanteda.io/reference/dfm_group.html) ou
`textstat_keyness()` pour comparer plusieurs sous-corpus.
