library(tidyverse)
library(gt)
library(devtools)
load_all()

raw_path      <- "~/GitHub/lexico/docs/scrap info 2025/raw"
data_path     <- "~/GitHub/lexico/docs/scrap info 2025/data"
iramuted_path <- "~/GitHub/lexico/docs/scrap info 2025/iramuteq"

df      <- readRDS(file.path(data_path,"df.rds"))
df_full <- readRDS(file.path(data_path,"df_full.rds"))

df %>%
  group_by(channel,playlistDescription) %>%
  summarise(count = n(),
            duree = sum(duree)) %>%
  gt(rowname_col = "playlistDescription", groupname_col = "channel") %>%
  grand_summary_rows(
    fns = list(label = "Total Général", fn = "sum"),
    fmt = list(~ fmt_duration(.,column = -count, input_units="seconds"))
  ) %>%
  gt::fmt_duration(column = -count,input_units="seconds") %>%
  gt::tab_header("Statistiques sur la durée des vidéos") %>%
  gt::tab_source_note(glue::glue("Source : {nrow(df)} vidéos extraites de Youtube"))


# Nb mots
df_full %>%
  group_by(channel,playlistDescription) %>%
  summarise(count_videos = n(),
            count_words = sum(str_count(text))) %>%
  gt(rowname_col = "playlistDescription", groupname_col = "channel") %>%
  grand_summary_rows(
    fns = list(label = "Total Général", fn = "sum")
  ) %>%
  gt::tab_header("Statistiques sur le nombre de mots des vidéos") %>%
  gt::tab_source_note(glue::glue("Source : {nrow(df)} vidéos extraites de Youtube"))

df %>%
  group_by(channel,playlistDescription) %>%
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

