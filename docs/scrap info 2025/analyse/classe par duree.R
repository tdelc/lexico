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

df_segment <- readRDS(file.path(data_path,"df_segment_classe.rds"))

df_segment %>%
  filter(id_segment < 50,classe_local != "Autre") %>%
  # filter(channel == "CNEWS") %>%
  group_by(channel,classe_local,id_segment) %>%
  summarise(nb = n()) %>%
  group_by(channel,id_segment) %>%
  mutate(prop = nb/sum(nb)) %>%
  ungroup() %>%
  ggplot()+
  aes(x=id_segment,y=prop,col=classe_local)+
  geom_line()+
  facet_wrap(~channel)

df_info_text <- df_iramuteq_segments %>%
  select(channel,playlistDescription,video_id,classe=classe_text,date_video,
         year_video,month_video,day_video,duree,likeCount,viewCount,commentCount) %>%
  distinct()

df_info_segm <- df_iramuteq_segments %>%
  select(channel,playlistDescription,video_id,id_segment,classe,classe_text,
         date_video,year_video,month_video,day_video)

df_text <- df_iramuteq_segments %>%
  group_by(channel,playlistDescription,video_id,title,description,date_video) %>%
  summarise(text = paste(text, collapse = " ")) %>%
  distinct()

df_segm <- df_iramuteq_segments %>%
  select(channel,playlistDescription,video_id,id_segment,text)

classe_palette <- readRDS(file.path(data_path,"classe_palette.rds"))
classe_palette_soft <- readRDS(file.path(data_path,"classe_palette_soft.rds"))

df_info_text %>%
  # mutate(duree = round(duree/60/10)) %>%
  mutate(duree = cut(round(duree/60),10,1:10)) %>%
  group_by(channel,classe,duree) %>%
  summarise(nb = n()) %>%
  group_by(channel,duree) %>%
  mutate(prop = nb/sum(nb)) %>%
  ungroup() %>%
  ggplot()+
  aes(x=duree,y=prop,col=channel)+
  geom_line()
