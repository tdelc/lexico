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

saveRDS(df_info_text,file.path(shiny_path,"df_info_text.rds"))
saveRDS(df_info_segm,file.path(shiny_path,"df_info_segm.rds"))
arrow::write_parquet(df_text,file.path(shiny_path,"df_text.parquet"))
arrow::write_parquet(df_segm,file.path(shiny_path,"df_segm.parquet"))


saveRDS(classe_palette,file.path(shiny_path,"classe_palette.rds"))
saveRDS(classe_palette_soft,file.path(shiny_path,"classe_palette_soft.rds"))
