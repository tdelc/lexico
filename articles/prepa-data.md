# Préparer les données textuelles

Cette vignette détaille les étapes de préparation des textes issus des
sous-titres : structuration des segments, nettoyage lexical et
regroupements.

``` r
library(lexico)
library(dplyr)
library(stringr)

data(df_text_bfm)
df_text <- df_text_bfm
```

## Nettoyer et normaliser le vocabulaire

Les textes extraits sont issus de sous-titre générés automatiquement par
YouTube. Il y a beaucoup d’erreurs dans ces textes, et un enjeu
important pour l’analyse et de bien nettoyer le fichier avant analyse.
Je propose ici plusieurs étapes de nettoyage

### Passage du texte en minuscule

Pour faciliter le nettoyage puis l’analyse, je commence par passer le
texte en minuscule :

``` r
df_text <- df_text %>%
  mutate(text = tolower(text))
```

### Suppression de mots spécifiques

Un texte issu de l’oral contient beaucoup d’oralité impropres pour
l’analyse textuelle. Aussi, dans le cas précis de l’analyse sur les
chaînes d’information en continu, le nom des chaînes revient souvient et
il est préférable de les retirer en avance. Une fonction
`get_specific_stopwords` permet de regrouper les mots que j’ai jugé
utile à retirer, vous pouvez créer votre propre liste.

``` r
stopwords <- get_specific_stopwords()
head(stopwords)
#> [1] "au"   "aux"  "avec" "ce"   "ces"  "dans"
stopwords_regex <- paste0("\\b(?:", paste(stopwords, collapse = "|"), ")\\b")

df_text <- df_text %>%
  mutate(text = str_remove_all(text,stopwords_regex))
```

### Correction de mots spécifiques

En analysant les mots les plus fréquents, il est possible de remarquer
des mots systématiquement mal orthographié. Il est possible donc de
prévoir un vecteur de mots avec leur correction et de corriger le texte
en une fois. Une fonction `get_recode_words` prévoit les corrections que
j’ai remarqué, vous pouvez créer votre propre vecteur.

``` r
recode_words <- get_recode_words()

head(recode_words)
#> (^|[^a-z])(sarkozi)([^a-z]|$)    (^|[^a-z])(atal)([^a-z]|$) 
#>               "\\1sarkozy\\3"                 "\\1attal\\3" 
#>   (^|[^a-z])(hatal)([^a-z]|$) (^|[^a-z])(baayrou)([^a-z]|$) 
#>                 "\\1attal\\3"                "\\1bayrou\\3" 
#>  (^|[^a-z])(baayou)([^a-z]|$)   (^|[^a-z])(berou)([^a-z]|$) 
#>                "\\1bayrou\\3"                "\\1bayrou\\3"

df_text <- df_text %>%
  mutate(text = str_replace_all(text, recode_words))
```

### Retrait des crochets

YouTube ajoute des crochets pour indiquer des rires, des
applaudissements ou de la musique, voici comment retirer ces passages.

``` r
unlist(str_extract_all(df_text$text,"\\[[a-z]+?\\]"))
#> [1] "[rires]"

df_text <- df_text %>%
  mutate(text = str_remove_all(text,"\\[[a-z]+?\\]"),
         text = str_squish(text))
```

### Ajout du nombre de mots

Il est possible d’ajouter le nombre de mots du bloc de texte pour les
analyses futures.

``` r
df_text <- df_text %>%
  mutate(wordsCount = str_count(text, "\\S+"))
```

## Créer des corpus selon une taille de segments

Initialement, la base de données `df_text` contient une ligne par bloc
de quelques mots.

Voici comment regrouper pour obtenir une ligne par vidéo :

``` r
df_video <- df_text %>%
  group_by(suffix,video_id) %>% 
  summarise(text = paste(text,collapse = " "),
            wordsCount = sum(wordsCount,na.rm = T),
            .groups = 'drop')

head(df_video)
#> # A tibble: 5 × 4
#>   suffix video_id    text                                             wordsCount
#>   <chr>  <chr>       <chr>                                                 <int>
#> 1 bfm    6IOUEJN6GRI "' 'heure face- face, arrivé 'instant. géralde …       2506
#> 2 bfm    Ab_5e7jEoag "29 . dominique chelcher. apoline ' studio répo…       1672
#> 3 bfm    QA84_nDOREk "8h29 . marian maréchal, présidente parti ident…       1800
#> 4 bfm    mjdbw7M0LRI "' ' saura passe casse -midi, vote solennel bud…       1778
#> 5 bfm    p6Pzs3iGwNk "8h28 . sébastien chenu. . député rn nord, vice…       1699
```

Vous pouvez aussi décider de la durée (en minutes) de chaque segment de
vidéo. Ceci permet de contrôler différemment la division en segment de
texte réalisé par IRaMuTeQ ou par Quanteda.

``` r
duree_segment <- 2

df_segment <- df_text %>%
  mutate(id_segment = 1+floor(start/(duree_segment*60))) %>%
  group_by(suffix,video_id,id_segment) %>%
  summarise(start = min(start),end = max(end),
            text = paste(text, collapse = " "),
            wordsCount = sum(wordsCount,na.rm = T),
            .groups = "drop")

head(df_segment)
#> # A tibble: 6 × 7
#>   suffix video_id    id_segment  start   end text                     wordsCount
#>   <chr>  <chr>            <dbl>  <dbl> <dbl> <chr>                         <int>
#> 1 bfm    6IOUEJN6GRI          1   3.40  120. "' 'heure face- face, a…        185
#> 2 bfm    6IOUEJN6GRI          2 120.    240. "pouvait pendant temps …        229
#> 3 bfm    6IOUEJN6GRI          3 240.    363. "carcéral, prisons . en…        214
#> 4 bfm    6IOUEJN6GRI          4 363.    481. "devrait territoire nat…        191
#> 5 bfm    6IOUEJN6GRI          5 481.    600. "passe 'intérieur priso…        176
#> 6 bfm    6IOUEJN6GRI          6 600.    721. "prison gardiens -mêmes…        188
```

Les tableaux obtenus sont prêts pour l’export IRaMuTeQ ou l’analyse
Quanteda.
