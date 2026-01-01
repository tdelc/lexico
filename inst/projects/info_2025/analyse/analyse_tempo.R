library(tidyverse)
library(gt)
library(devtools)
load_all()

raw_path      <- "~/GitHub/lexico/docs/scrap info 2025/raw"
data_path     <- "~/GitHub/lexico/docs/scrap info 2025/data"
iramuted_path <- "~/GitHub/lexico/docs/scrap info 2025/iramuteq"

df_playlist <- read.csv(file.path(raw_path,"df_playlist.csv"))

df <- readRDS(file.path(data_path,"df.rds"))

syn <- df %>%
  mutate(
    iso_str = sprintf("%d-W%02d-1", year_video, week_video),
    date_video = ISOweek::ISOweek2date(iso_str)
  ) %>%
  group_by(channel,date_video) %>%
  summarise(duree = sum(duree))

ggplot(syn) +
  aes(x = date_video, y = duree, col = channel) +
  geom_line()

syn <- df %>%
  filter(year_video >= 2025) %>%
  group_by(channel,month_video) %>%
  summarise(duree = sum(duree)/60/60)

ggplot(syn) +
  aes(x = month_video, y = duree, col = channel) +
  geom_line(size=1)

df %>%
  filter(year_video >= 2025) %>%
  group_by(channel,month_video) %>%
  summarise(duree = sum(duree)/60/60)

df %>%
  mutate(mois = month(month_video, label = TRUE, locale = "fr_FR.utf8")) %>%
  group_by(channel,mois) %>%
  summarise(duree = sum(duree)) %>%
  pivot_wider(names_from = channel, values_from = duree) %>%
  gt(rowname_col = "mois") %>%
  gt::fmt_duration(input_units="seconds") %>%
  grand_summary_rows(
    fns = list(label = "Total Général", fn = "sum"),
    fmt = list(~ fmt_duration(.,input_units="seconds"))
  ) %>%
  gt::tab_header("Statistiques sur le nombre de mots des vidéos") %>%
  gt::tab_source_note(glue::glue("Source : {nrow(df)} vidéos extraites de Youtube"))


df %>%
  mutate(mois = month(month_video, label = TRUE, locale = "fr_FR.utf8")) %>%
  group_by(channel,mois) %>%
  summarise(duree = sum(duree)) %>%
  group_by(channel) %>% mutate(duree =  duree / sum(duree)) %>% ungroup() %>%
  pivot_wider(names_from = mois, values_from = duree) %>%
  gt(rowname_col = "channel") %>%
  gt::fmt_percent(decimals = 0) %>%
  data_color(direction = "row",
             method = "numeric",palette = c("red", "green")) %>%
  gt::tab_header("Répartition des vidéos (selon la somme de leur durée)") %>%
  gt::tab_source_note(glue::glue("Source : {nrow(df)} vidéos extraites de Youtube"))

