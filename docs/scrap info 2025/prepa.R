library(tidyverse)
library(gt)
library(devtools)
load_all()

raw_path      <- "~/GitHub/lexico/docs/scrap info 2025/raw"
data_path     <- "~/GitHub/lexico/docs/scrap info 2025/data"
iramuted_path <- "~/GitHub/lexico/docs/scrap info 2025/iramuteq"

df_playlist <- read.csv(file.path(raw_path,"df_playlist.csv"))

# raw_path      <- "~/GitHub/lexico/docs/scrap info 2025/raw/df OLD"

list_df_info <- list.files(raw_path,"df_info_.*?\\.csv$", full.names = TRUE)
list_df_stat <- list.files(raw_path,"df_stat_.*?\\.csv$", full.names = TRUE)
list_df_text <- list.files(raw_path,"df_text_.*?\\.csv$", full.names = TRUE)

df_info <- purrr::map_dfr(list_df_info, read.csv)
df_stat <- purrr::map_dfr(list_df_stat, read.csv)
df_text <- purrr::map_dfr(list_df_text, read.csv)

nrow(df_stat)
nrow(dplyr::distinct(df_stat))

# Attention, il y a des doublons qui n'ont pas les mêmes tags.
# C'est bizarre, car il n'y a pas de raison dès lors que l'id est le même
# Je vais simplement les fusionner

vars <- colnames(df_stat)[colnames(df_stat) != "tags"]
df_stat <- df_stat %>%
  distinct() %>%
  group_by(!!!syms(vars)) %>%
  summarise(tags = paste(tags,collapse="|")) %>%
  ungroup()

nrow(df_stat)
nrow(dplyr::distinct(df_stat))

# Nettoyer/ajouter des variables
df_stat <- df_stat %>%
  dplyr::mutate(date_video = as.Date(publishedAt),
                year_video = lubridate::year(publishedAt),
                week_video = lubridate::week(publishedAt),
                month_video = lubridate::month(publishedAt),
                day_video = lubridate::day(publishedAt),
                duree = parse_yt_duration(duration),
                tags = stringr::str_replace_all(tags,"\\|"," ")
  )


  # dplyr::group_by(channel,day_video) %>%
  # dplyr::arrange(publishedAt) %>%
  # dplyr::mutate(i = row_number(),
  #               id = paste(channel,day_video,i,sep="-")) %>%
  # ungroup()

# Réunion des statistiques
df <- df_stat %>%
  dplyr::distinct() %>%
  dplyr::left_join(df_info %>%
                     dplyr::select(video_id,playlist_id) %>%
                     dplyr::distinct()
                   ,by = "video_id") %>%
  dplyr::left_join(df_playlist,by = c("channelTitle","playlist_id")) %>%
  dplyr::rename(channel = channelTitle) %>%
  dplyr::mutate(id = paste(channel,video_id,sep="-"))

nrow(df)
nrow(dplyr::distinct(df))
df %>% dplyr::count(video_id) %>% filter(n>1) %>% nrow()

# Attention, à ce stade, il y a des doublons, mais c'est normal car les vidéos
# sont dans deux playlists.

# Pour éviter de garder cela, je vais quand même n'en garder qu'une seule,
# Après, ce n'est que 43 vidéos, donc ça fera qu'une vingtaine en moins

df <- df %>%
  arrange(publishedAt) %>%
  group_by(video_id) %>% filter(row_number() == 1) %>% ungroup()

nrow(df)
nrow(dplyr::distinct(df))
df %>% dplyr::count(video_id) %>% filter(n>1) %>% nrow()

# Nettoyage cosmétique
df[df$channel == "BLAST, Le souffle de l'info","channel"] <- "BLAST"
df[df$channel == "franceinfo","channel"] <- "France Info"

# On retombe bien sur les 8177 vidéos de départ

# Réunion avec les textes par segment
df_full <- df %>%
  dplyr::left_join(df_text %>% dplyr::distinct(),by = c("suffix","video_id"))

# Identifier chaque segment
df_full <- df_full %>%
  dplyr::mutate(id = paste0(id,"-",n_grp))

#### Nettoyage préliminaire ####

# Retirer certaines vidéos sans text (sans doute car vidéo privée)
df_full <- df_full %>% filter(!is.na(text))
df <- df %>% filter(video_id %in% unique(df_full$video_id))
# On perd seulement 139 vidéos


df %>%
  group_by(channel) %>%
  summarise(count = n(),
            min = min(duree),
            p10 = quantile(duree,0.10),
            q1 = quantile(duree,0.25),
            mean = mean(duree),
            median = median(duree),
            q3 = quantile(duree,0.75),
            p90 = quantile(duree,0.90),
            max = max(duree)) %>%
  gt() %>%
  gt::fmt_duration(column = -count,input_units="seconds") %>%
  gt::tab_header("Statistiques sur la durée des vidéos") %>%
  gt::tab_source_note(glue::glue("Source : {nrow(df)} vidéos extraites de Youtube"))

# Les vidéos de CNEWS sont en fait des capsules, très petite (150 secondes au max)
# Ce n'est pas du tout le même format que les autres chaînes
# Décision, virer les toutes petites vidéos, pour toutes les chaînes.

df <- df %>% filter(duree >= 120)

# Dans la même logique, les très grandes vidéos sont sans doute le fruit d'un
# autre processus

df %>%
  filter(duree > 60*60*2) %>%
  select(channel,title,duree) %>%
  gt()

# En fait, pour certaines vidéos, on est sur du replay d'un truc hors de la chaine
# donc à supprimer, mais pas toujours. Pour l'instant, on garde.

# Pour Europe 1, les playlists sont en fait que des vidéos avec CNEWS,
# donc on peut légitimement basculer cette playlist en CNEWS

df[df$suffix == "eur","channel"] <- "CNEWS"
df_full[df_full$suffix == "eur","channel"] <- "CNEWS"

# Se limiter seulement à 2025
df <- df %>% filter(year_video == 2025)

# limiter les textes aux IDs conservés
df_full <- df_full %>% filter(video_id %in% unique(df$video_id))

saveRDS(df     ,file = file.path(data_path,"df.rds"))
saveRDS(df_full,file = file.path(data_path,"df_full.rds"))

#### Export Iramuteq ####

chaine_info <- c("BFMTV","CNEWS","France Info","LCI")
df_sub <- df_full %>% filter(channel %in% chaine_info)

# Choisir un regroupement des segments
df_grp <- df_sub %>% group_minuted_text(1) %>%
  left_join(df %>% select(video_id,year_video,channel))

export_to_iramuteq(df          = df_grp,
                   meta_cols   = c("video_id","year_video","channel"),
                   text_col    = "text",
                   output_file = file.path(iramuted_path,"corpus_segment.txt")
)


