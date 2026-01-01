summarise_sentiments <- function(df){
  df %>%
    count(sentiment) %>%
    mutate(n_all = sum(n), n = n/sum(n)) %>% ungroup() %>%
    pivot_wider(names_from = sentiment,values_from = n)
}

color_sentiments <- function(gt){
  gt %>%
    data_color(columns = c(undiff),method = "numeric",
               palette = c("white", "#9E9E9E"),na_color = "white") %>%
    data_color(columns = c(joy),method = "numeric",
               palette = c("white", "#FBC02D"),na_color = "white") %>%
    data_color(columns = c(fear),method = "numeric",
               palette = c("white", "#6A1B9A"),na_color = "white") %>%
    data_color(columns = c(sadness),method = "numeric",
               palette = c("white", "#1565C0"),na_color = "white") %>%
    data_color(columns = c(anger),method = "numeric",
               palette = c("white", "#D84315"),na_color = "white") %>%
    data_color(columns = c(disgust),method = "numeric",
               palette = c("white", "#558B2F"),na_color = "white") %>%
    data_color(columns = c(surprise),method = "numeric",
               palette = c("white", "#00838F"),na_color = "white") %>%
    data_color(columns = c(anticipation),method = "numeric",
               palette = c("white", "#FB8C00"),na_color = "white") %>%
    data_color(columns = c(trust),method = "numeric",
               palette = c("white", "#26A69A"),na_color = "white")
}

label_sentiments <- function(gt){
  gt %>%
    cols_label(undiff  = "Indéterminé",
      joy      = "Joie",
      fear     = "Peur",
      sadness  = "Tristesse",
      anger    = "Colère",
      disgust  = "Dégoût",
      surprise = "Surprise",
      trust    = "Confiance",
      anticipation = "Anticipation"
    )
}

format_sentiments <- function(gt){
  gt %>%
    color_sentiments() %>%
    label_sentiments() %>%
    fmt_percent(decimals = 1)
}

summarise_polarity <- function(df){
  df %>%
    count(polarity) %>%
    mutate(n = n/sum(n)) %>% ungroup() %>%
    pivot_wider(names_from = polarity,values_from = n)
}

color_polarity <- function(gt){
  gt %>%
    data_color(columns = c(positive),method = "numeric",
               palette = c("white", "#2E7D32"),na_color = "white") %>%
    data_color(columns = c(neutral),method = "numeric",
               palette = c("white", "#9E9E9E"),na_color = "white") %>%
    data_color(columns = c(negative),method = "numeric",
               palette = c("white", "#C62828"),na_color = "white")
}

label_polarity <- function(gt){
  gt %>%
    cols_label(
      positive = "Positif",
      neutral = "Neutre",
      negative = "Négatif"
    )
}

format_polarity <- function(gt){
  gt %>%
    color_polarity() %>%
    label_polarity() %>%
    fmt_percent(decimals = 1)
}
