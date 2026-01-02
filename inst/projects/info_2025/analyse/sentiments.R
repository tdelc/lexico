library(tidyverse)
library(rfeel)
library(quanteda)
library(gt)
library(devtools)
load_all()

paths <- list(
  raw      = "~/GitHub/lexico/inst/projects/info_2025/raw",
  data     = "~/GitHub/lexico/inst/projects/info_2025/data",
  dic      = "~/GitHub/lexico/inst/projects/info_2025/dictionary",
  shiny    = "~/GitHub/lexico/inst/projects/info_2025/dashboard"
)

## Préparation des dictionnaires
df_polarity <- rfeel::sentiments_polarity
df_score    <- rfeel::sentiments_score

list_polarity <- unique(df_polarity$polarity) %>% map(~{
  df_polarity %>% filter(polarity == .x) %>% pull(word)
})
names(list_polarity) <- unique(df_polarity$polarity)
dict_polarity <- dictionary(list_polarity)

list_score <- unique(df_score$sentiment) %>% map(~{
  df_score %>% filter(sentiment == .x) %>% pull(word)
})
names(list_score) <- unique(df_score$sentiment)
dict_score <- dictionary(list_score)

test <- df_segment %>%
  dplyr::mutate(text = remove_apostrophe(text)) %>%
  corpus(docid_field="id",text_field="text") %>%
  corpus_to_tokens() %>%
  quanteda::tokens_remove(stopwords("fr"))


df_segment     <- readRDS(file.path(paths$data, "df_segment_classe.rds"))
palettes       <- readRDS(file.path(paths$data, "palettes.rds"))

df_segment <- df_segment %>%
  mutate(id = paste0(video_id,id_segment))

tokens_segment <- df_segment %>%
  dplyr::mutate(text = remove_apostrophe(text)) %>%
  corpus(docid_field="id",text_field="text") %>%
  corpus_to_tokens() %>%
  quanteda::tokens_remove(stopwords("fr"))

df_polarity_segment <- tokens_segment %>%
  tokens_lookup(dictionary = dict_polarity) %>%
  dfm() %>%
  convert("data.frame") %>%
  rename(id = doc_id) %>%
  mutate(tokensCount = ntoken(tokens_text),
         polarity = case_when(
           # positive >= 1.5*negative ~ "positive",
           # negative >= 1.5*positive ~ "negative",
           positive >= negative & positive >= 0.2*tokensCount ~ "positive",
           negative >= positive & negative >= 0.2*tokensCount ~ "negative",
           TRUE~"neutral")
  )

df_polarity_segment %>%
  count(polarity)

df_score_segment <- tokens_segment %>%
  tokens_lookup(dictionary = dict_score) %>%
  dfm() %>%
  convert("data.frame") %>%
  rename(id = doc_id)

df_score_segment <- df_score_segment %>%
  left_join(df_score_segment %>%
              pivot_longer(cols = -id) %>%
              group_by(id) %>%
              slice_max(value,n=1,with_ties = FALSE) %>%
              ungroup() %>%
              rename(sentiment = name) %>%
              mutate(sentiment = ifelse(value < 5,"neutral",sentiment))
  )

df_segment2 <- df_segment %>%
  left_join(df_polarity_segment) %>%
  left_join(df_score_segment) %>%
  mutate(
         neutral = tokensCount - positive - negative,
         pc_positive = positive / tokensCount,
         pc_negative = negative / tokensCount,
         pc_neutral  = neutral / tokensCount,
         pc_joy      = joy / tokensCount,
         pc_fear     = fear / tokensCount,
         pc_sadness  = sadness / tokensCount,
         pc_anger    = anger / tokensCount,
         pc_disgust  = disgust / tokensCount,
         pc_surprise = surprise / tokensCount
         )

summarise_sentiments <- function(df){
  # df1 <- df %>%
  #   count(polarity) %>%
  #   mutate(n = n/sum(n)) %>% ungroup() %>%
  #   pivot_wider(names_from = polarity,values_from = n)

  df2 <- df %>%
    count(sentiment) %>%
    mutate(n = n/sum(n)) %>% ungroup() %>%
    pivot_wider(names_from = sentiment,values_from = n)

  # df1 %>% left_join(df2)
  df2
}

color_sentiments <- function(gt){
  gt %>%
    # data_color(columns = c(positive),method = "numeric",
    #            palette = c("white", "#2E7D32"),na_color = "white") %>%
    data_color(columns = c(neutral),method = "numeric",
               palette = c("white", "#9E9E9E"),na_color = "white") %>%
    # data_color(columns = c(negative),method = "numeric",
    #            palette = c("white", "#C62828"),na_color = "white") %>%
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
               palette = c("white", "#00838F"),na_color = "white")
}

label_sentiments <- function(gt){
  gt %>%
    cols_label(# positive = "Positif",
               # negative = "Négatif",
               neutral  = "Indéterminé",
               joy      = "Joie",
               fear     = "Peur",
               sadness  = "Tristesse",
               anger    = "Colère",
               disgust  = "Dégoût",
               surprise = "Surprise")
}

format_sentiments <- function(gt){
  gt %>%
    color_sentiments() %>%
    label_sentiments() %>%
    fmt_percent(decimals = 1)
}

df_segment2 %>%
  group_by(channel) %>%
  summarise_sentiments() %>%
  gt() %>%
  format_sentiments()


df_segment2 %>%
  group_by(channel,playlistDescription) %>%
  summarise_sentiments() %>%
  gt(rowname_col = "playlistDescription",groupname_col = "channel") %>%
  format_sentiments()

df_segment2 %>%
  group_by(classe_local) %>%
  summarise_sentiments() %>%
  gt(rowname_col = "classe_local") %>%
  format_sentiments()

df_segment2 %>%
  group_by(classe_local,channel) %>%
  summarise_sentiments() %>%
  gt(rowname_col = "channel",groupname_col = "classe_local") %>%
  format_sentiments()

df_segment2 %>%
  group_by(year_video,channel) %>%
  summarise_sentiments() %>%
  gt(rowname_col = "channel",groupname_col = "year_video") %>%
  format_sentiments()




?syuzhet::rescale_x_2()

get_sentiment_dictionary(lang = "french")
get_sentiment(test[1:10], method = "nrc", lang = "french")
get_nrc_sentiment(test[1:10], lang = "french")


test <- unlist(lapply(tokens_segment, paste, collapse = " "))
sentiment_scores <- get_nrc_sentiment(test, lang="french")

df_score_segment <- cbind(df_segment[,"id"],sentiment_scores)
df_score_segment <- df_score_segment %>%
  left_join(df_score_segment %>%
              select(-negative,-positive) %>%
              pivot_longer(cols = -id) %>%
              group_by(id) %>%
              slice_max(value,n=1,with_ties = FALSE) %>%
              ungroup() %>%
              rename(sentiment = name) %>%
              mutate(sentiment = ifelse(value < 5,"neutral",sentiment))
  ) %>%
  left_join(df_score_segment %>%
              select(id,negative,positive) %>%
              pivot_longer(cols = -id) %>%
              group_by(id) %>%
              slice_max(value,n=1,with_ties = FALSE) %>%
              ungroup() %>%
              rename(polarity = name) %>%
              mutate(polarity = ifelse(value < 5,"neutral",polarity)) %>%
              select(-value)
  )

df_segment2 <- df_segment %>%
  left_join(df_score_segment)

summarise_sentiments <- function(df){
  df %>%
    count(sentiment) %>%
    mutate(n_all = sum(n), n = n/sum(n)) %>% ungroup() %>%
    pivot_wider(names_from = sentiment,values_from = n)
}

color_sentiments <- function(gt){
  gt %>%
    # data_color(columns = c(positive),method = "numeric",
    #            palette = c("white", "#2E7D32"),na_color = "white") %>%
    data_color(columns = c(neutral),method = "numeric",
               palette = c("white", "#9E9E9E"),na_color = "white") %>%
    # data_color(columns = c(negative),method = "numeric",
    #            palette = c("white", "#C62828"),na_color = "white") %>%
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
    cols_label(# positive = "Positif",
      # negative = "Négatif",
      neutral  = "Indéterminé",
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

df_segment2 %>%
  group_by(channel) %>%
  summarise_polarity() %>%
  gt(rowname_col = "channel") %>%
  cols_label(channel = "Chaîne") %>%
  format_polarity() %>%
  gt::tab_header("Statistiques des polarités dans les segments de vidéos") %>%
  gt::tab_source_note(glue::glue("Source : {nrow(df_segment2)} segments issus de {length(unique(df_segment2$video_id))} vidéos extraites de Youtube")) %>%
  gt::tab_source_note(glue::glue("Classification des polarités avec le package syuzhet"))

df_segment2 %>%
  group_by(channel,playlistDescription) %>%
  summarise_sentiments() %>%
  select(channel,playlistDescription,n_all,
         joy,trust,surprise,anticipation,neutral,sadness,anger,disgust,fear) %>%
  gt(rowname_col = "playlistDescription",groupname_col = "channel") %>%
  cols_label(channel = "Chaîne",
             playlistDescription = "Playlist",
             n_all = "Nombre de segments") %>%
  # summary_rows(
  #   fns = list(label = "Total", fn = "mean"),
  #   fmt = list(~ fmt_percent(.,decimals = 1),
  #              ~ fmt_number(.,columns = n_all,decimals = 0))
  # ) %>%
  format_sentiments() %>%
  fmt_number(columns = n_all,decimals = 0,sep_mark = " ")



df_time <- df_segment2 %>%
  filter(year_video == 2024) %>%
  count(channel, month_video, sentiment, name = "n") %>%
  group_by(channel, month_video) %>%
  mutate(p = n / sum(n)) %>%
  ungroup()

ggplot(df_time, aes(x = month_video, y = p, fill = sentiment)) +
  geom_area() +
  facet_wrap(~ channel) +
  scale_y_continuous(labels = scales::percent)


df_share <- df_segment2 %>%
  mutate(day_video = yday(date_video)) %>%
  filter(year_video == 2025) %>%
  count(day_video, sentiment, name = "n") %>%
  group_by(day_video) %>%
  mutate(p = n / sum(n)) %>%
  ungroup()

df_share %>%
  mutate(sentiment = factor(sentiment, levels = unique(df_segment2$sentiment))) %>%
  ggplot(aes(x = sentiment, y = day_video, fill = p)) +
  geom_tile() +
  scale_fill_continuous(labels = scales::percent) +
  theme_minimal()


