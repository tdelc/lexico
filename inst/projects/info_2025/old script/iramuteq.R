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

df_iramuteq_segments <- readRDS(file.path(data_path,"df_iramuteq_segments.rds"))

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


# Recharger les éléments issues de prepa_iramuteq.R

couleur_gt <- function(gt){
  gt %>%
    # data_color(columns = Économie, method = "numeric",palette = c("white", "red")) %>%
    # data_color(columns = Politique, method = "numeric",palette = c("white", "grey")) %>%
    # data_color(columns = Géopolitique, method = "numeric",palette = c("white", "green")) %>%
    # data_color(columns = Justice, method = "numeric",palette = c("white", "blue")) %>%
    # data_color(columns = `Faits divers`, method = "numeric",palette = c("white", "purple"))
    # data_color(columns = Géopolitique, method = "numeric",palette = c("white", "red")) %>%
    # data_color(columns = `Faits divers`, method = "numeric",palette = c("white", "grey")) %>%
    # data_color(columns = Politique, method = "numeric",palette = c("white", "green")) %>%
    # data_color(columns = Économie, method = "numeric",palette = c("white", "blue")) %>%
    # data_color(columns = Médias, method = "numeric",palette = c("white", "purple"))

    data_color(columns = International, method = "numeric",palette = c("white", "red")) %>%
    data_color(columns = Violence, method = "numeric",palette = c("white", "grey")) %>%
    data_color(columns = Politique, method = "numeric",palette = c("white", "green")) %>%
    data_color(columns = Clivage, method = "numeric",palette = c("white", "blue")) %>%
    data_color(columns = Économie, method = "numeric",palette = c("white", "purple"))
}

source_videos <- glue::glue(
  "Source : {nrow(df_info_segm %>% distinct(video_id))} vidéos extraites de Youtube ; Traitements, calculs et erreur : Thomas Delclite.")

# Simple % des segments par chaîne
df_info_segm %>%
  count(channel,classe) %>%
  group_by(channel) %>% mutate(n_all = sum(n),n = n/sum(n)) %>% ungroup() %>%
  arrange(classe) %>%
  pivot_wider(names_from = classe,values_from = n) %>%
  gt(rowname_col = "channel") %>%
  cols_label(n_all = "Nb segments") %>%
  fmt_percent(columns=-n_all,decimals = 1,sep_mark = ".",dec_mark = ",") %>%
  fmt_number(columns=n_all,decimals = 0,sep_mark = ".",dec_mark = ",") %>%
  couleur_gt(classe_palette) %>%
  gt::tab_header("Classification des segments de vidéos") %>%
  gt::tab_source_note(source_videos) %>%
  gt::tab_source_note(glue::glue(
    "Proportion calculée sur {nrow(df_iramuteq_full)} segments d'environ 40 mots."))


# Ici, c'est une stat sur les segments, comment faire pour avoir la même chose
# par vidéo, en imaginant prendre la classe dominante

df_info_text %>%
  count(channel,classe) %>%
  group_by(channel) %>% mutate(n_all = sum(n),n = n/sum(n)) %>% ungroup() %>%
  arrange(classe) %>%
  pivot_wider(names_from = classe,values_from = n) %>%
  arrange(channel) %>%
  gt(rowname_col = "channel") %>%
  cols_label(n_all = "Nb vidéos") %>%
  fmt_percent(columns=-n_all,decimals = 1,sep_mark = ".",dec_mark = ",") %>%
  fmt_number(columns=n_all,decimals = 0,sep_mark = ".",dec_mark = ",") %>%
  fmt_missing() %>%
  couleur_gt() %>%
  gt::tab_header("Classification des vidéos") %>%
  gt::tab_source_note(source_videos) %>%
  gt::tab_source_note(glue::glue(
    "Classification des vidéos sur base de la classe la plus fréquente"))

# Et si je calculais d'abord le pourcentage de classe dans chaque text, puis
# je faisais la somme, un peu du entre deux

df_info_segm %>%
  count(channel,video_id,classe) %>%
  group_by(channel,video_id) %>% mutate(n_all = sum(n),n = n/sum(n)) %>%
  group_by(channel) %>% mutate(n_all = n_distinct(video_id)) %>%
  group_by(channel,classe) %>% summarise(n_all=mean(n_all),n = mean(n)) %>% ungroup() %>%
  arrange(classe) %>%
  pivot_wider(names_from = classe,values_from = n) %>%
  arrange(channel) %>%
  gt(rowname_col = "channel") %>%
  cols_label(n_all = "Nb vidéos") %>%
  fmt_percent(columns=-n_all,decimals = 1,sep_mark = ".",dec_mark = ",") %>%
  fmt_number(columns=n_all,decimals = 0,sep_mark = ".",dec_mark = ",") %>%
  fmt_missing() %>%
  couleur_gt() %>%
  gt::tab_header("Classification des vidéos") %>%
  gt::tab_source_note(source_videos) %>%
  gt::tab_source_note(glue::glue(
    "Moyenne des proportions de classe par vidéo."))

# Tiens, par playlist, quel est le % de tel classe
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
  couleur_gt() %>%
  gt::tab_header("Classification des vidéos") %>%
  gt::tab_source_note(source_videos) %>%
  gt::tab_source_note(glue::glue(
    "Classification des vidéos sur base de la classe la plus fréquente"))



# Tiens, quels sont les % de classe des segments, lorsque le classe text est ceci
df_info_segm %>%
  filter(classe_text == "Faits divers") %>%
  # filter(classe_text == "Médias") %>%
  count(channel,classe) %>%
  group_by(channel) %>% mutate(n = n/sum(n)) %>% ungroup() %>%
  arrange(classe) %>%
  pivot_wider(names_from = classe,values_from = n) %>%
  arrange(channel) %>%
  gt(rowname_col = "channel") %>%
  fmt_percent(decimals = 1) %>%
  couleur_gt()


df_info_segm %>%
  select(channel,video_id,classe_text) %>% distinct() %>%
  count(channel,classe_text) %>%
  ggplot()+
  aes(x=channel,y=n,fill=classe_text)+
  geom_bar(stat = "identity")+
  scale_fill_manual(values = classe_palette_soft)+
  coord_flip()

df_info_segm %>%
  select(channel,video_id,classe_text) %>% distinct() %>%
  count(channel,classe_text) %>%
  ggplot()+
  aes(x=channel,y=n,fill=classe_text)+
  geom_bar(stat = "identity",position = "fill")+
  scale_fill_manual(values = classe_palette_soft)+
  coord_flip()

# Je voudrais savoir le % de chaque classe selon le moment de la vidéo
syn <- df_info_segm %>%
  filter(id_segment < 60) %>%
  filter(classe_text == "Politique") %>%
  count(channel,id_segment,classe) %>%
  group_by(channel,id_segment) %>% mutate(pc = n/sum(n))

ggplot(syn)+
  aes(x=id_segment,y=pc,fill=classe)+
  geom_bar(stat = "identity")+
  scale_fill_manual(values = classe_palette_soft)+
  facet_wrap(~channel)

syn <- df_info_segm %>%
  filter(id_segment <= 30) %>%
  filter(channel == "CNEWS") %>%
  count(playlistDescription,id_segment,classe) %>%
  group_by(playlistDescription,id_segment) %>% mutate(pc = n/sum(n))

ggplot(syn)+
  aes(x=id_segment,y=pc,fill=classe)+
  geom_bar(stat = "identity")+
  scale_fill_manual(values = classe_palette_soft)+
  facet_wrap(~playlistDescription)




# Est ce que ces tendances ont évolué dans le temps
syn2 <- df_info_segm %>%
  filter(year_video == 2025) %>%
  count(channel,month_video,classe) %>%
  group_by(channel,month_video) %>% mutate(n = n/sum(n))

ggplot(syn2)+
  aes(x=month_video,y=n,fill=classe)+
  geom_bar(stat = "identity")+
  scale_fill_manual(values = classe_palette_soft)+
  facet_wrap(~channel)


syn2 <- df_info_segm %>%
  filter(year_video == 2025) %>%
  count(channel,week_video = week(date_video),classe) %>%
  group_by(channel,week_video) %>% mutate(n = n/sum(n))

ggplot(syn2)+
  aes(x=week_video,y=n,fill=classe)+
  geom_bar(stat = "identity")+
  scale_fill_manual(values = classe_palette_soft)+
  facet_wrap(~channel)


# Ici, c'est une stat sur les segments, comment faire pour avoir la même chose
# par vidéo, en imaginant prendre la classe dominante

syn3 <- df_info_text %>%
  count(channel,month_video,classe) %>%
  group_by(channel,month_video) %>% mutate(n = n/sum(n))

ggplot(syn3)+
  aes(x=month_video,y=n,fill=classe)+
  geom_bar(stat = "identity")+
  scale_fill_manual(values = classe_palette_soft)+
  facet_wrap(~channel)

syn3 <- df_info_text %>%
  count(channel,week_video = week(date_video),classe) %>%
  group_by(channel,week_video) %>% mutate(n = n/sum(n))

ggplot(syn3)+
  aes(x=week_video,y=n,fill=classe)+
  geom_bar(stat = "identity")+
  scale_fill_manual(values = classe_palette_soft)+
  facet_wrap(~channel)




#### Se servir de Iramuteq en Quanteda ####

df_ <- df_iramuteq_full %>%
  group_by(channel,video_id,year_video,month_video,day_video,
           playlistDescription,duree,likeCount,title,
           classe_text,description) %>%
  summarise(text = paste(text,collapse = " "))

corpus_text  <- quanteda::corpus(df_,docid_field="video_id",text_field="text")
tokens_text  <- corpus_to_tokens(corpus_text)
dfm_text  <- quanteda::dfm(tokens_text)

dfm_group  <- dfm_text %>% quanteda::dfm_group(groups=classe_text)

dfm_group %>%
  dfm_subset(classe_text != "Autre") %>%
  textplot_wordcloud(comparison = T, color = vec_classe)

dfm_group %>% textstat_keyness(target = "Faits divers") %>% textplot_keyness()

quanteda::topfeatures(dfm_group)
