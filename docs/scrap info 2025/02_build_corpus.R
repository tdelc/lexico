cli::cli_alert_info("Début du 02_build_corpus.R")

# -------------------------------------------------------------------------
# 1) Import brut
# -------------------------------------------------------------------------

df_playlist <- read.csv(file.path(paths$raw, "df_playlist.csv"))

files_info <- list.files(paths$raw, "df_info_.*?\\.csv$", full.names = TRUE)
files_stat <- list.files(paths$raw, "df_stat_.*?\\.csv$", full.names = TRUE)
files_text <- list.files(paths$raw, "df_text_.*?\\.csv$", full.names = TRUE)

df_info <- purrr::map_dfr(files_info, read.csv)
df_stat <- purrr::map_dfr(files_stat, read.csv)
df_text <- purrr::map_dfr(files_text, read.csv)

# -------------------------------------------------------------------------
# 2)  Dédoublonnage stats (fusion des tags)
# -------------------------------------------------------------------------

# Attention, il y a des doublons qui n'ont pas les mêmes tags.
# C'est bizarre, car il n'y a pas de raison dès lors que l'id est le même
# Je vais simplement les fusionner

vars <- setdiff(names(df_stat), "tags")

df_stat <- df_stat %>%
  distinct() %>%
  group_by(across(all_of(vars))) %>%
  summarise(
    tags = paste(tags, collapse = "|"),
    .groups = "drop"
  )

# -------------------------------------------------------------------------
# 3) Enrichissement des stats vidéo
# -------------------------------------------------------------------------

df_stat <- df_stat %>%
  mutate(
    date_video  = as.Date(publishedAt),
    year_video  = lubridate::year(publishedAt),
    week_video  = lubridate::week(publishedAt),
    month_video = lubridate::month(publishedAt),
    day_video   = lubridate::day(publishedAt),
    duree       = parse_yt_duration(duration)
  )

# -------------------------------------------------------------------------
# 4) Réunion "vidéo" (stat + info + playlist) + normalisation channel
# -------------------------------------------------------------------------

# "df_long" car une ligne par petit segment (seulement quelques mots)

df_long <- df_stat %>%
  left_join(
    df_info %>% select(video_id, playlist_id) %>% distinct(),
    by = "video_id"
  ) %>%
  left_join(df_playlist,by = c("channelTitle", "playlist_id")) %>%
  rename(channel = channelTitle) %>%
  mutate(
    id = paste(channel, video_id, sep = "-"),
    channel = case_when(
      channel == "BLAST, Le souffle de l'info" ~ "BLAST",
      channel == "franceinfo"                  ~ "France Info",
      TRUE                                     ~ channel
    )
  )

# -------------------------------------------------------------------------
# 5) Doublons de playlist : garder 1 ligne par vidéo
# -------------------------------------------------------------------------


# Attention, à ce stade, il y a des doublons, mais c'est normal car les vidéos
# sont dans deux playlists.

df_long <- df_long %>%
  arrange(publishedAt) %>%
  group_by(video_id) %>%
  slice(1) %>%
  ungroup()


# -------------------------------------------------------------------------
# 6) Filtres sur les données
# -------------------------------------------------------------------------

# - durée, période, correction Europe 1 => CNEWS
# - chaînes d'info (au plus tôt)

df_long <- df_long %>%
  mutate(
    channel = if_else(suffix == "eur", "CNEWS", channel)  # Europe 1 => CNEWS
  ) %>%
  filter(duree >= params$min_duration) %>%
  filter(year_video %in% params$years_keep) %>%
  filter(channel %in% params$channels_info)

# -------------------------------------------------------------------------
# 7) Jointure avec textes par segment + nettoyage "vidéos sans texte"
# -------------------------------------------------------------------------

df_long <- df_long %>%
  left_join(df_text %>% distinct(), by = c("suffix", "video_id")) %>%
  mutate(id = paste0(id, "-", n_grp)) %>%
  filter(!is.na(text))

vars_keep <- c("video_id","publishedAt","title","description","channelId",
               "channel","duration","viewCount","likeCount","commentCount",
               "tags","date_video","year_video","week_video","month_video",
               "day_video","duree","playlist_id","suffix","playlistDescription",
               "id","n_grp","start","end","text")

df_long <- df_long %>%
  select(all_of(vars_keep))

# -------------------------------------------------------------------------
# 8) Nettoyage texte
# -------------------------------------------------------------------------

# Regrouper les mots qui vont ensemble
multiwords <- get_specific_multiwords()
multiwords_ <- stringr::str_replace_all(multiwords, "\\s+", "_")
names(multiwords_) <- multiwords

# (orthographe + multiwords + crochets)
df_long <- df_long %>%
  mutate(text = tolower(text),
         text = str_replace_all(text, get_recode_words()),
         text = str_replace_all(text, multiwords_),
         text = str_squish(text))

# Supprimer les []
df_long <- df_long %>%
  mutate(text = str_remove_all(text,"\\[[a-z]+?\\]"),
         text = str_squish(text))

# Ajout du nombre de mots
df_long <- df_long %>%
  mutate(wordsCount = str_count(text, "\\S+"))

# -------------------------------------------------------------------------
# 9) Créer les df de vidéo et de segments
# -------------------------------------------------------------------------

# df_video : une ligne par video
# df_segment : une ligne par segment de video (1 minute)
# df_long : une ligne par morceau de video (quelques secondes)

vars_keep <- c("video_id","publishedAt","title","description","channelId",
               "channel","duration","viewCount","likeCount","commentCount",
               "tags","date_video","year_video","week_video","month_video",
               "day_video","duree","playlist_id","suffix","playlistDescription")

df_video <- df_long %>%
  group_by(across(all_of(vars_keep))) %>%
  summarise(text = paste(text,collapse = " "),
            wordsCount = sum(wordsCount,na.rm = T)) %>%
  ungroup()

stopifnot(df_video %>% group_by(video_id) %>% filter(n()>1) == 0)

df_segment <- df_long %>%
  mutate(id_segment = 1+floor(start/(params$group_minutes*60))) %>%
  group_by(across(all_of(c(vars_keep,"id_segment")))) %>%
  summarise(start = min(start),end = max(end),
                   text = paste(text, collapse = " "),
                   wordsCount = sum(wordsCount,na.rm = T)) %>%
  ungroup()

stopifnot(df_segment %>% select(video_id) %>% distinct() %>% nrow() == nrow(df_video))

# On filtrer les segments trop petits
# On garde le reste des infos (video et long)
# Puis on recode les id_segment

df_segment <- df_segment %>%
  filter(wordsCount >= params$min_words_diag) %>%
  group_by(video_id) %>% mutate(id_segment = row_number()) %>% ungroup()

# On retire les vidéos retiré par cette étape
df_video <- df_video %>%
  filter(video_id %in% df_segment$video_id)

stopifnot(df_segment %>% select(video_id) %>% distinct() %>% nrow() == nrow(df_video))

# -------------------------------------------------------------------------
# 8) Supprimer les textes en anglais
# -------------------------------------------------------------------------

# Il y a des segments (surtout classé en guerre) en anglais, je préfère les
# identifier pour les retirer directement

# Transformation des textes des segments en tokens
tokens_segment <- tokens(
  df_segment$text,
  remove_punct = TRUE,
  remove_numbers = TRUE) %>%
  tokens_tolower()

# Obtenir un dictionnaire de mots en français
dic_path <- "C:\\Users\\tdelc\\AppData\\Roaming\\RStudio\\dictionaries\\languages-system\\fr_FR.dic"
words_fr <- readLines(dic_path, encoding = "UTF-8")[-1]
words_fr <- sub("/.*$", "", words_fr)
dict_fr <- dictionary(list(fr = words_fr))

# Première méthode : si le nombre de mots non reconnu par un dictionnaire
# français est trop haut

nb_mots_fr <- dfm(tokens_segment) %>%
  dfm_lookup(dict_fr) %>%
  as.numeric()

# Deuxième méthode : si la proportion de éèà est trop faible

ratio_chars_fr <- function(text) {
  chars <- strsplit(text, "")[[1]]
  if (length(chars) < 20) return(NA_real_)
  mean(chars %in% c("é","è","ê","à","ù","ç","ô","î"))
}

# Troisième méthode : présence de mots en anglais

stop_en <- stopwords("en")

ratio_stop_en <- tokens_segment %>% lapply(function(x){
  if (length(x) < 5) return(NA_real_) else mean(x %in% stop_en)
}) %>% unlist()

df_segment$score_fr       <- nb_mots_fr / ntoken(tokens_segment)
df_segment$score_chars_fr <- map_dbl(df_segment$text, ratio_chars_fr)
df_segment$score_stop_en  <- ratio_stop_en

hist(df_segment$score_fr)
hist(df_segment$score_chars_fr)
hist(df_segment$score_stop_en)

df_segment %>%
  filter(ratio_stop_en > 0.1) %>%
  select(video_id,id_segment,channel,text) %>%
  gt()

# Check manuel (retrait manuel des segments incriminés)
df_segment <- df_segment %>%
  filter(!(video_id == "-YrIOidIFcA" & id_segment == 19),
         !(video_id == "0_NnzKFrUdw" & id_segment == 13),
         !(video_id == "LnaoaQFzOl4" & id_segment == 1),
         !(video_id == "cyPbuZfzW_4" & id_segment == 2),
         !(video_id == "B27yaz-EXXQ" & id_segment == 3),
         !(video_id == "HZ0bns5VRfc" & id_segment == 33),
         !(video_id == "KCpogKuoDTQ" & id_segment == 19),
         !(video_id == "8kErHKSd-HY" & id_segment == 11),
         !(video_id == "_LAV5G3mZs4" & id_segment == 16),
         !(video_id == "yHEsYVXZntU" & id_segment == 18),
         !(video_id == "Q3lPHTl62gA" & id_segment == 12),
         !(video_id == "0_NnzKFrUdw" & id_segment == 14),
         !(video_id == "Q3lPHTl62gA" & id_segment == 11),
         !(video_id == "IMvINKVbqYg" & id_segment == 30),
         !(video_id == "cyPbuZfzW_4" & id_segment == 2),
         !(video_id == "VqStUqdJoAY" & id_segment == 3)
  ) %>%
  group_by(video_id) %>% mutate(id_segment = row_number()) %>% ungroup()

stopifnot(df_segment %>% select(video_id) %>% distinct() %>% nrow() == nrow(df_video))

# -------------------------------------------------------------------------
# 10) Sauvegardes RDS et Iramuteq
# -------------------------------------------------------------------------

saveRDS(df_segment, file = file.path(paths$data, "df_segment.rds"))
saveRDS(df_video  , file = file.path(paths$data, "df_video.rds"))
saveRDS(df_long   , file = file.path(paths$data, "df_long.rds"))

export_to_iramuteq(
  df          = df_segment,
  meta_cols   = c("video_id", "year_video", "channel"),
  text_col    = "text",
  output_file = file.path(paths$data, "corpus_segment.txt")
)

cli::cli_alert_success("Fin du 02_build_corpus.R")

