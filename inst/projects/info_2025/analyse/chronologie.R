library(tidyverse)
library(quanteda)
library(quanteda.textplots)
library(quanteda.textstats)
library(quanteda.textmodels)

library(gtExtras)

library(devtools)
load_all()

raw_path      <- "~/GitHub/lexico/docs/scrap info 2025/raw"
data_path     <- "~/GitHub/lexico/docs/scrap info 2025/data"
iramuted_path <- "~/GitHub/lexico/docs/scrap info 2025/iramuteq"

# Sauver pour le dashboard
corpus_path <- "corpus_segment_corpus_7/corpus_segment_alceste_1"
corpus_path <- "corpus_segment_corpus_7/corpus_segment_alceste_2"
shiny_path <- "~/GitHub/lexico/docs/scrap info 2025/dashboard"

df_iramuteq_segments <- readRDS(file.path(iramuted_path,corpus_path,"df_iramuteq_segments.rds"))

classe_palette <- readRDS(file.path(iramuted_path,corpus_path,"classe_palette.rds"))
classe_palette_soft <- readRDS(file.path(iramuted_path,corpus_path,"classe_palette_soft.rds"))


couleur_gt <- function(gt,classe_palette){
  for (k in 2:length(classe_palette)){
    color <- classe_palette[k]
    gt <- gt %>%
      data_color(columns = names(color), method = "numeric",palette = c("white", color),na_color="white")
  }
  gt
}

source_videos <- glue::glue(
  "Source : {nrow(df_info_segm %>% distinct(video_id))} vidéos extraites de Youtube ; Traitements, calculs et erreur : Thomas Delclite.")


# Réduire les infos
df_info_text <- df_iramuteq_segments %>%
  select(channel,playlistDescription,video_id,classe=classe_text,date_video,
         year_video,month_video,duree,likeCount,viewCount,commentCount) %>%
  distinct()

df_info_segm <- df_iramuteq_segments %>%
  select(channel,playlistDescription,video_id,id_segment,date_video,duree,
         classe,classe_text)

df_text <- df_iramuteq_segments %>%
  group_by(channel,playlistDescription,video_id,title,description,date_video) %>%
  summarise(text = paste(text, collapse = " ")) %>%

  distinct()

df_segm <- df_iramuteq_segments %>%
  select(channel,playlistDescription,video_id,id_segment,text)


df_info_text %>%
  count(channel,playlistDescription,classe) %>%
  group_by(channel,playlistDescription) %>% mutate(n_all = sum(n),n = n/sum(n)) %>%
  arrange(classe) %>%
  pivot_wider(names_from = classe,values_from = n) %>%
  arrange(channel) %>%
  gt(rowname_col = "playlistDescription",groupname_col = "channel") %>%
  cols_label(n_all = "Nb vidéos") %>%
  fmt_percent(columns=-n_all,decimals = 1,sep_mark = ".",dec_mark = ",") %>%
  fmt_number(columns=n_all,decimals = 0,sep_mark = ".",dec_mark = ",") %>%
  fmt_missing() %>%
  couleur_gt(classe_palette) %>%
  gt::tab_header("Classification des vidéos") %>%
  gt::tab_source_note(source_videos) %>%
  gt::tab_source_note(glue::glue(
    "Classification des vidéos sur base de la classe la plus fréquente"))


df_info_text %>%
  filter(channel == "LCI") %>%
  count(channel,year_video,month_video,classe) %>%
  group_by(channel,year_video,month_video) %>% mutate(n_all = sum(n),n = n/sum(n)) %>%
  arrange(classe) %>%
  pivot_wider(names_from = classe,values_from = n) %>%
  arrange(channel,year_video,month_video) %>%
  gt(rowname_col = c("month_video"),groupname_col = "year_video") %>%
  cols_label(n_all = "Nb vidéos") %>%
  fmt_percent(columns=-c(year_video,month_video,n_all),decimals = 1,sep_mark = ".",dec_mark = ",") %>%
  fmt_number(columns=c(year_video,month_video,n_all),decimals = 0,sep_mark = ".",dec_mark = ",") %>%
  fmt_missing() %>%
  couleur_gt(classe_palette) %>%
  gt::tab_header("Classification des vidéos") %>%
  gt::tab_source_note(source_videos) %>%
  gt::tab_source_note(glue::glue(
    "Classification des vidéos sur base de la classe la plus fréquente"))

