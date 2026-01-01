cli::cli_alert_info("Début du 04_get_sentiments.R")

# -------------------------------------------------------------------------
# 1) Charger les données RDS (issues de l'étape précédente)
# -------------------------------------------------------------------------

df_segment     <- readRDS(file.path(paths$data, "df_segment_classe.rds"))
palettes       <- readRDS(file.path(paths$data, "palettes.rds"))

# -------------------------------------------------------------------------
# 2) Passer des tokens au score de sentiments
# -------------------------------------------------------------------------

df_segment <- df_segment %>%
  mutate(id = paste0(video_id,id_segment))

tokens_segment <- df_segment %>%
  dplyr::mutate(text = remove_apostrophe(text)) %>%
  corpus(docid_field="id",text_field="text") %>%
  corpus_to_tokens() %>%
  quanteda::tokens_remove(stopwords("fr"))

vec_segment <- unlist(lapply(tokens_segment, paste, collapse = " "))
sentiment_scores <- get_nrc_sentiment(vec_segment, lang="french")

# -------------------------------------------------------------------------
# 3) Coupler les sentiments à la df_segment
# -------------------------------------------------------------------------

df_score_segment <- cbind(df_segment[,"id"],sentiment_scores)
df_score_segment <- df_score_segment %>%
  left_join(df_score_segment %>%
              select(-negative,-positive) %>%
              pivot_longer(cols = -id) %>%
              group_by(id) %>%
              slice_max(value,n=1,with_ties = FALSE) %>%
              ungroup() %>%
              rename(sentiment = name) %>%
              mutate(sentiment = ifelse(value < 5,"undiff",sentiment))
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

df_segment <- df_segment %>%
  left_join(df_score_segment)

# -------------------------------------------------------------------------
# 4) Sauvegarder df commune dans data
# -------------------------------------------------------------------------

saveRDS(df_segment, file.path(paths$data, "df_segment_sentiment.rds"))

cli::cli_alert_success("Fin du 04_get_sentiments.R")

