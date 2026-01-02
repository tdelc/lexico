# Format gt with emotions

Format gt with emotions

## Usage

``` r
format_emotions(gt)
```

## Arguments

- gt:

  gt to format : label, color, percent

## Value

gt

## Examples

``` r
vec_text <- janeaustenr::austen_books()$text
df_sentiment <- syuzhet::get_nrc_sentiment(vec_text[1:50], lang="english")
df_emotion <- get_dominant_emotion(df_sentiment,1)
format_emotions(gt::gt(summarise_emotions(df_emotion)))
#> Joining with `by = join_by(emotion)`


  

n_all
```

Indéterminé

Joie

Peur

Tristesse

Colère

Dégoût

Surprise

Confiance

Anticipation

50

46.0%

2.0%

0.0%

2.0%

8.0%

2.0%

2.0%

16.0%

22.0%
