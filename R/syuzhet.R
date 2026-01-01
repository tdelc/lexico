
#' Get most frequent emotion of a sentiment score df
#'
#' @param df_sentiment data.frame from get_nrc_sentiment
#' @param threshold minimum frequency to keep emotion
#'
#' @returns data.frame
#' @export
#'
#' @examples
#' vec_text <- janeaustenr::austen_books()$text
#' df_sentiment <- get_nrc_sentiment(vec_text[1:50], lang="english")
#' df_emotion <- get_dominant_emotion(df_sentiment,2)
#' count(df_emotion,sentiment)
get_dominant_emotion <- function(df_sentiment,threshold = 5){
  sentiment_scores %>%
    rownames_to_column("id") %>%
    select(-negative,-positive) %>%
    pivot_longer(cols = -id) %>%
    group_by(id) %>%
    slice_max(value,n=1,with_ties = FALSE) %>%
    ungroup() %>%
    rename(sentiment = name) %>%
    mutate(sentiment = ifelse(value < threshold,"undiff",sentiment))
}

#' Get most frequent polarity of a sentiment score df
#'
#' @param df_sentiment data.frame from get_nrc_sentiment
#' @param threshold minimum frequency to keep polarity
#'
#' @returns data.frame
#' @export
#'
#' @examples
#' vec_text <- janeaustenr::austen_books()$text
#' df_sentiment <- get_nrc_sentiment(vec_text[1:50], lang="english")
#' df_polarity <- get_dominant_polarity(df_sentiment,2)
#' count(df_polarity,polarity)
get_dominant_polarity <- function(df_sentiment,threshold = 5){
  df_sentiment %>%
    rownames_to_column("id") %>%
    select(id,negative,positive) %>%
    pivot_longer(cols = -id) %>%
    group_by(id) %>%
    slice_max(value,n=1,with_ties = FALSE) %>%
    ungroup() %>%
    rename(polarity = name) %>%
    mutate(polarity = ifelse(value < threshold,"neutral",polarity))
}

#' Summarise emotions of a data.frame
#'
#' @param df data.frame to summarise
#'
#' @returns data.frame
#' @export
#'
#' @examples
#' vec_text <- janeaustenr::austen_books()$text
#' df_sentiment <- get_nrc_sentiment(vec_text[1:50], lang="english")
#' df_emotion <- get_dominant_emotion(df_sentiment,1)
#' summarise_emotions(df_emotion)
summarise_emotions <- function(df){

  vec_emotions <- c("undiff","joy","fear","sadness","anger","disgust",
                    "surprise","trust","anticipation")

  tibble(emotion= vec_emotions) %>%
    left_join(df %>% count(emotion)) %>%
    replace_na(list(n = 0)) %>%
    mutate(n_all = sum(n), n = n/sum(n)) %>% ungroup() %>%
    pivot_wider(names_from = emotion,values_from = n)
}

#' Color gt with emotions
#'
#' @param gt gt to color
#'
#' @returns gt
color_emotions <- function(gt){
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

#' Label gt with emotions
#'
#' @param gt gt to label
#'
#' @returns gt
label_emotions <- function(gt){
  gt %>%
    cols_label(
      undiff   = "Indéterminé",
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

#' Format gt with emotions
#'
#' @param gt gt to format : label, color, percent
#'
#' @returns gt
#' @export
#'
#' @examples
#' vec_text <- janeaustenr::austen_books()$text
#' sentiment_scores <- get_nrc_sentiment(vec_text[1:50], lang="english")
#' df_emotion <- get_dominant_emotion(df_sentiment,1)
#' format_emotions(gt(summarise_emotions(df_emotion)))
format_emotions <- function(gt){
  gt %>%
    color_emotions() %>%
    label_emotions() %>%
    fmt_percent(column = c("undiff","joy","fear","sadness","anger","disgust",
                           "surprise","trust","anticipation"),decimals = 1)
}

#' Summarise polarity of a data.frame
#'
#' @param df data.frame to summarise
#'
#' @returns data.frame
#' @export
#'
#' @examples
#' vec_text <- janeaustenr::austen_books()$text
#' sentiment_scores <- get_nrc_sentiment(vec_text[1:50], lang="english")
#' df_polarity <- get_dominant_polarity(df_polarity,1)
#' summarise_polarity(df_polarity)
summarise_polarity <- function(df){

  vec_polarity <- c("negative","neutral","positive")

  tibble(polarity = vec_polarity) %>%
    left_join(df %>% count(polarity)) %>%
    mutate(n = n/sum(n)) %>% ungroup() %>%
    pivot_wider(names_from = polarity,values_from = n)
}

#' Color gt with polarity
#'
#' @param gt gt to color
#'
#' @returns gt
color_polarity <- function(gt){
  gt %>%
    data_color(columns = c(positive),method = "numeric",
               palette = c("white", "#2E7D32"),na_color = "white") %>%
    data_color(columns = c(neutral),method = "numeric",
               palette = c("white", "#9E9E9E"),na_color = "white") %>%
    data_color(columns = c(negative),method = "numeric",
               palette = c("white", "#C62828"),na_color = "white")
}

#' Label gt with polarity
#'
#' @param gt gt to label
#'
#' @returns gt
label_polarity <- function(gt){
  gt %>%
    cols_label(
      positive = "Positif",
      neutral = "Neutre",
      negative = "Négatif"
    )
}

#' Format gt with polarity
#'
#' @param gt gt to format : label, color, percent
#'
#' @returns gt
#' @export
#'
#' @examples
#' vec_text <- janeaustenr::austen_books()$text
#' sentiment_scores <- get_nrc_sentiment(vec_text[1:50], lang="english")
#' df_polarity <- get_dominant_polarity(df_sentiment,1)
#' format_polarity(gt(summarise_polarity(df_polarity)))
format_polarity <- function(gt){
  gt %>%
    color_polarity() %>%
    label_polarity() %>%
    fmt_percent(column = c("positive","neutral","negative"),decimals = 1)
}
