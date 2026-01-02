library(tidyverse)
library(gt)
library(devtools)
load_all()

paths <- list(
  raw      = "~/GitHub/lexico/docs/scrap info 2025/raw",
  data     = "~/GitHub/lexico/docs/scrap info 2025/data",
  dic      = "~/GitHub/lexico/docs/scrap info 2025/dictionary",
  shiny    = "~/GitHub/lexico/docs/scrap info 2025/dashboard"
)

df_segment      <- readRDS(file.path(paths$data,"df_segment_sentiment.rds"))
palettes      <- readRDS(file.path(paths$data,"palettes.rds"))

df_info_text <- df_segment %>%
  group_by(channel,title,playlistDescription,video_id,classe=classe_text,date_video,
         year_video,month_video,duree,likeCount,viewCount,commentCount,) %>%
  summarise(wordsCount = sum(wordsCount)) %>%
  ungroup()

df_info_text %>%
  filter(channel == "CNEWS") %>%
  summarise(min(date_video))

df_info_text %>%
  # filter(year_video == 2025) %>%
  group_by(channel,playlistDescription) %>%
  summarise(count = n(),
            duree = sum(duree),
            nb_words = sum(wordsCount)) %>%
  gt(rowname_col = "playlistDescription", groupname_col = "channel") %>%
  cols_label(
    count = "Nombre de vidéos",
    duree = "Durée totale des vidéos",
    nb_words = "Nombre de mots"
  ) %>%
  grand_summary_rows(
    fns = list(label = "Total Général", fn = "sum"),
    fmt = list(~ fmt_duration(.,column = duree, input_units="seconds",locale = "fr"),
               ~ fmt_number(.,column = nb_words,decimals = 0,
                            sep_mark = ".", dec_mark = ","))
  ) %>%
  # summary_rows(
  #   fns = list(label = "Total", fn = "sum"),
  #   fmt = list(~ fmt_duration(.,column = duree, input_units="seconds"),
  #              ~ fmt_number(.,column = nb_words,decimals = 0,
  #                           sep_mark = ".", dec_mark = ","))
  # ) %>%
  gt::fmt_duration(column = duree,input_units="seconds",locale = "fr") %>%
  gt::fmt_number(column = nb_words,decimals = 0, sep_mark = ".", dec_mark = ",") %>%
  gt::tab_header("Statistiques sur les vidéos extraites") %>%
  gt::tab_source_note(glue::glue("Source : {nrow(df)} vidéos extraites de Youtube"))


df_info_text %>%
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
  gt(rowname_col = "playlistDescription", groupname_col = "channel") %>%
  gt::fmt_duration(column = -count,input_units="seconds") %>%
  gt::tab_header("Statistiques sur la durée des vidéos") %>%
  gt::tab_source_note(glue::glue("Source : {nrow(df)} vidéos extraites de Youtube"))

df_info_text %>%
  # group_by(channel,playlistDescription) %>%
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

df_info_text %>%
  filter(duree == max(duree)) %>%
  select(channel,date_video,title)

df_text <- df_segment %>%
  group_by(channel,playlistDescription,video_id,id_segment,
           title,description,date_video,classe,classe_local) %>%
  summarise(text = paste(text, collapse = " ")) %>%
  ungroup() %>%
  distinct() %>%
  dplyr::mutate(text = remove_apostrophe(text)) %>%
  mutate(id = paste0(video_id,id_segment))

corpus_text  <- quanteda::corpus(df_text,docid_field="id",text_field="text")
tokens_text  <- corpus_to_tokens(corpus_text)
dfm_text  <- quanteda::dfm(tokens_text)
dfm_grp <- dfm_text %>%
  # dfm_subset(channel %in% c(input$key_group, input$key_ref)) %>%
  dfm_group(channel)

dfm_text %>%
  dfm_group(channel) %>%
  textplot_wordcloud(comparison = T,color = c("#0072CE","tomato",
                                              "#FFD200","#5B7DB1"))
title("Mots les plus discriminants de chaque chaîne", cex.main = 1.4, font.main = 2,outer =F,line=12)

dfm_text %>%
  dfm_group(classe) %>%
  textplot_wordcloud(comparison = T,color = c("#DFDFDF","#2E7D32",
                                              "#C62828","#1565C0",
                                              "#6A1B9A","#FF009C"))

dfm_text %>%
  dfm_subset(classe == "Économie") %>%
  dfm_group(classe_local) %>%
  textplot_wordcloud(comparison = T,color = c("#DFDFDF","#388E3C",
                                              "#1B5020","#607D8B"),
                     labelsize = 2.5)

df_segment %>%
  filter(classe_local == "Santé") %>%
  mutate(fl_immigration = str_detect(text,"immigration")) %>%
  group_by(channel) %>%
  summarise(mean(fl_immigration))

dfm_text %>%
  dfm_subset(classe == "Société") %>%
  dfm_group(classe_local) %>%
  # topfeatures(groups = classe_local,n=20)
  textplot_wordcloud(comparison = T,color = c("#DFDFDF","#FFBEC5",
                                              "#FF6E7A","#FF009C"),
                     labelsize = 2.5)
dfm_text %>%
  dfm_subset(classe == "Politique") %>%
  dfm_group(classe_local) %>%
  # topfeatures(groups = classe_local,n=20)
  textplot_wordcloud(comparison = T,color = c("#7B1FA2","#DFDFDF","#1E35B1",
                                              "#AA2455","#FFA400","#000050"),
                     labelsize = 2)

dfm_text %>%
  dfm_subset(classe == "Justice") %>%
  dfm_group(classe_local) %>%
  # topfeatures(groups = classe_local,n=20)
  textplot_wordcloud(comparison = T,color = c("#DFDFDF","#1565C0","#0D47A1"),
                     labelsize = 2)

dfm_text %>%
  dfm_subset(classe == "Guerre") %>%
  dfm_group(classe_local) %>%
  # topfeatures(groups = classe_local,n=20)
  textplot_wordcloud(comparison = T,color = c("#A31F2F","#E71C1C"),
                     labelsize = 2)



df_segment %>%
  mutate(fl_immigration = str_detect(text,"immigration")) %>%
  group_by(classe,classe_local,channel) %>%
  summarise(pc_immigration = mean(fl_immigration)) %>% ungroup() %>%
  pivot_wider(names_from = channel,values_from = pc_immigration) %>%
  gt(
    rowname_col = "classe_local",
    groupname_col = "classe",
    caption="Fréquence des segments comportant le terme 'immigration' selon la catégorie du segment et la chaîne") %>%
  cols_label(classe_local = md("Catégorie")) %>%
  fmt_percent(decimals = 1) %>%
  sub_missing() %>%
  data_color(method = "numeric",
             palette = c("white", "red"),
             na_color = "white")




wordcloud_channel <- function(dfm_text,channel_){
  color <- switch(channel_,
                  "CNEWS" = "tomato",
                  "France Info" = "#FFD200",
                  "LCI" = "#5B7DB1",
                  "BFMTV" = "#0072CE",
  )
  dfm_text %>%
    dfm_subset(channel == channel_) %>%
    textplot_wordcloud(color = color)
}

topfeatures_channel <- function(dfm_text){
  unique(docvars(dfm_text)$channel) %>% map_df(~{
    topfeatures(dfm_text %>% dfm_subset(channel == .x)) %>%
      as.data.frame() %>%
      rownames_to_column("feature") %>% select(feature) %>%
      mutate(id = paste0("M",row_number())) %>%
      pivot_wider(names_from = id,values_from = feature) %>%
      mutate(channel = .x,.before=M1)
  })
}

topfeatures_channel(dfm_text) %>%
  gt()

wordcloud_channel(dfm_text,"CNEWS")
wordcloud_channel(dfm_text,"France Info")
wordcloud_channel(dfm_text,"BFMTV")
wordcloud_channel(dfm_text,"LCI")

dfm_grp %>%
  textplot_wordcloud(comparison = T,color = c("#0072CE","tomato",
                                              "#FFD200","#5B7DB1"))

keyness_channel <- function(dfm_grp,channel,n=20){
  color <- switch(channel,
                  "CNEWS" = "tomato",
                  "France Info" = "#FFD200",
                  "LCI" = "#5B7DB1",
                  "BFMTV" = "#0072CE",
                  )
  dfm_grp %>%
    textstat_keyness(target = channel) %>%
    textplot_keyness(n = 20,color = c(color, "gray"))
}

keyness_channel(dfm_grp,"CNEWS")
keyness_channel(dfm_grp,"France Info")
keyness_channel(dfm_grp,"LCI")
keyness_channel(dfm_grp,"BFMTV")

kwic(tokens_text, pattern = "abnous",window = 5)
kwic(tokens_text, pattern = "écouter",window = 3)

df_text %>%
  filter(str_detect(text,"écoute")) %>%
  count(playlistDescription)
  kwic(pattern = "écouter",window = 3)


treemap_double_classe(df_segment,
                      "Répartition des propos prononcés par les chaînes d'information en continu")


treemap_double_classe(df_segment %>%
                        # filter(year_video == 2025) %>%
                        filter(channel ==  "CNEWS"),
                      "Répartition des propos prononcés par CNEWS",
                      palette = palettes$global$soft)

treemap_double_classe(df_segment_classe %>%
                        filter(channel ==  "France Info"),
                      "Répartition des propos prononcés par France Info")

treemap_double_classe(df_segment_classe %>%
                        filter(channel ==  "BFMTV"),
                      "Répartition des propos prononcés par BFMTV")

treemap_double_classe(df_segment_classe %>%
                        filter(channel ==  "LCI"),
                      "Répartition des propos prononcés par LCI")



df_segment %>%
  mutate(test = classe_local == "Journalisme") %>%
  group_by(channel,playlistDescription) %>%
  summarise(test = mean(test))

df_segment %>%
  mutate(fl_mot = str_detect(text,"cohen")) %>%
  group_by(classe,classe_local,channel) %>%
  summarise(pc_mot = mean(fl_mot)) %>% ungroup() %>%
  pivot_wider(names_from = channel,values_from = pc_mot) %>%
  gt(
    rowname_col = "classe_local",
    groupname_col = "classe",
    caption="Fréquence des segments comportant le terme 'cohen' selon la catégorie du segment et la chaîne") %>%
  cols_label(classe_local = md("Catégorie")) %>%
  fmt_percent(decimals = 1) %>%
  sub_missing() %>%
  data_color(method = "numeric",
             palette = c("white", "red"),
             na_color = "white")

df_segment %>%
  mutate(fl_mot = str_detect(text,"cohen")) %>%
  group_by(channel) %>%
  summarise(pc_mot = sum(fl_mot))

df_segment %>%
  filter(playlistDescription == "Pascal Praud") %>%
  mutate(fl = classe_local=="Journalisme") %>%
  group_by(year_video,month_video) %>%
  summarise(fl = sum(fl)) %>% ungroup() %>%
  mutate(date = paste0(year_video,"-",str_pad(month_video,2,pad = "0"))) %>%
  ggplot()+
  aes(x=date,y=fl,group=1)+
  geom_line()




df_segment %>%
  mutate(fl_climat = str_detect(text,"environnement")) %>%
  group_by(channel,classe_local) %>%
  summarise(pc_climat = mean(fl_climat)) %>% ungroup() %>%
  pivot_wider(names_from = classe_local,values_from = pc_climat) %>%
  gt(rowname_col = "channel",
     caption = md("**Présence du mot 'environnement' dans les segments**")) %>%
  fmt_percent(decimals = 1) %>%
  data_color(method = "numeric",
             palette = c("white", "green3"),
             na_color = "white",
             direction = "row")

df_climat <- df_segment %>%
  filter(str_detect(text,"climat")) %>%
  dplyr::mutate(text = remove_apostrophe(text)) %>%
  mutate(id = paste0(video_id,id_segment))


dfm_text  <- df_climat %>%
  corpus(docid_field="id",text_field="text") %>%
  corpus_to_tokens() %>%
  dfm()

dfm_text %>% textplot_wordcloud()

dfm_grp <- dfm_text %>%
  dfm_group(channel)

dfm_text %>%
  dfm_group(channel) %>%
  textplot_wordcloud(comparison = T,labelsize = 2)

dfm_text %>%
  dfm_group(classe) %>%
  textplot_wordcloud(comparison = T,labelsize = 2)

df_segment %>%
  group_by(channel) %>%
  summarise_polarity() %>%
  gt(rowname_col = "channel") %>%
  cols_label(channel = "Chaîne") %>%
  format_polarity() %>%
  gt::tab_header("Statistiques des polarités dans les segments de vidéos") %>%
  gt::tab_source_note(glue::glue("Source : {nrow(df_segment)} segments issus de {length(unique(df_segment$video_id))} vidéos extraites de Youtube")) %>%
  gt::tab_source_note(glue::glue("Classification des polarités avec le package syuzhet"))

df_segment %>%
  group_by(classe) %>%
  summarise_emotions() %>%
  gt(rowname_col = "classe") %>%
  cols_label(classe = "Catégorie") %>%
  format_emotions() %>%
  gt::tab_header("Statistiques des émotions dans les segments de vidéos") %>%
  gt::tab_source_note(glue::glue("Source : {nrow(df_segment)} segments issus de {length(unique(df_segment$video_id))} vidéos extraites de Youtube")) %>%
  gt::tab_source_note(glue::glue("Classification des polarités avec le package syuzhet"))


