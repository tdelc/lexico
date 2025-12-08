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

df <- readRDS(file.path(data_path,"df.rds"))
chaine_info <- c("BFMTV","CNEWS","France Info","LCI")
df_sub <- df %>% filter(channel %in% chaine_info)

corpus_path <- file.path(iramuted_path,"corpus_text_corpus_1/corpus_text_alceste_4")

df_sub2 <- import_from_iramuteq(file.path(corpus_path,"export_corpus.txt"))

df_sub2 <- df_sub2 %>%
  mutate(classe = factor(classe,levels = c("0","1","2","3","4","5"),
                         labels = c("Autre", "Économie", "Politique",
                                    "Géopolitique", "Justice", "Faits divers")))

df_sub2_full <- df_sub2 %>%
  rename(video_id = videoid) %>%
  mutate(channel = ifelse(channel == "FranceInfo","France Info",channel)) %>%
  left_join(df_sub %>% select(channel,video_id,year_video,month_video,day_video,
                              playlistDescription,duree,likeCount,title,
                              description,text_full = text))

# Ajouter la classe du texte
df_classe_text <- df_sub2_full %>%
  count(channel,video_id,classe) %>%
  group_by(channel,video_id) %>% slice_max(n,with_ties = F) %>% ungroup() %>%
  rename(classe_text = classe)

df_sub2_full <- df_sub2_full %>%
  left_join(df_classe_text %>% select(channel,video_id,classe_text))


# Pour avoir le % de la vidéo
df_sub2_full <- df_sub2_full %>%
  group_by(channel,video_id) %>%
  mutate(id_morceau = row_number(),
         pc_morceau = (id_morceau-0.5)/n(),
         classe_morceau = cut(pc_morceau,seq(0,1,0.1),1:10)
         ) %>%
  ungroup()

couleur_gt <- function(gt){
  gt %>%
    data_color(columns = Économie, method = "numeric",palette = c("white", "red")) %>%
    data_color(columns = Politique, method = "numeric",palette = c("white", "grey")) %>%
    data_color(columns = Géopolitique, method = "numeric",palette = c("white", "green")) %>%
    data_color(columns = Justice, method = "numeric",palette = c("white", "blue")) %>%
    data_color(columns = `Faits divers`, method = "numeric",palette = c("white", "purple"))
}

# Simple % des segments par chaîne
df_sub2_full %>%
  count(channel,classe) %>%
  group_by(channel) %>% mutate(n = n/sum(n)) %>% ungroup() %>%
  arrange(classe) %>%
  pivot_wider(names_from = classe,values_from = n) %>%
  mutate(All = 1) %>%
  gt(rowname_col = "channel") %>%
  fmt_percent(decimals = 1) %>%
  couleur_gt() %>%
  gt::tab_header("Classification des vidéos") %>%
  gt::tab_source_note(glue::glue("Source : 2213 vidéos extraites de Youtube"))

# Ici, c'est une stat sur les segments, comment faire pour avoir la même chose
# par vidéo, en imaginant prendre la classe dominante

df_sub2_full %>%
  select(channel,video_id,classe_text) %>% distinct() %>%
  count(channel,classe_text) %>%
  group_by(channel) %>% mutate(n = n/sum(n)) %>% ungroup() %>%
  arrange(classe_text) %>%
  pivot_wider(names_from = classe_text,values_from = n) %>%
  arrange(channel) %>%
  mutate(All = 1) %>%
  gt(rowname_col = "channel") %>%
  fmt_percent(decimals = 1) %>%
  fmt_missing() %>%
  couleur_gt() %>%
  gt::tab_header("Classification des vidéos") %>%
  gt::tab_source_note(glue::glue("Source : 2213 vidéos extraites de Youtube"))

# Et si je calculais d'abord le pourcentage de classe dans chaque text, puis
# je faisais la somme, un peu du entre deux

df_sub2_full %>%
  count(channel,video_id,classe) %>%
  group_by(channel,video_id) %>% mutate(n = n/sum(n)) %>% ungroup() %>%
  group_by(channel,classe) %>% summarise(n = mean(n)) %>% ungroup() %>%
  arrange(classe) %>%
  pivot_wider(names_from = classe,values_from = n) %>%
  arrange(channel) %>%
  mutate(All = 1) %>%
  gt(rowname_col = "channel") %>%
  fmt_percent(decimals = 1) %>%
  couleur_gt() %>%
  gt::tab_header("Classification des vidéos") %>%
  gt::tab_source_note(glue::glue("Source : 2213 vidéos extraites de Youtube"))


# Tiens, quels sont les % de classe des segments, lorsque le classe text est ceci
df_sub2_full %>%
  # filter(classe_text == "Faits divers") %>%
  filter(classe_text == "Justice") %>%
  count(channel,classe) %>%
  group_by(channel) %>% mutate(n = n/sum(n)) %>% ungroup() %>%
  arrange(classe) %>%
  pivot_wider(names_from = classe,values_from = n) %>%
  arrange(channel) %>%
  gt(rowname_col = "channel") %>%
  fmt_percent(decimals = 1) %>%
  couleur_gt()

# Tiens, par playlist, quel est le % de tel classe
df_sub2_full %>%
  select(channel,playlistDescription,video_id,classe_text) %>% distinct() %>%
  count(channel,playlistDescription,classe_text) %>%
  group_by(channel,playlistDescription) %>% mutate(n = n/sum(n)) %>%
  arrange(classe_text) %>%
  pivot_wider(names_from = classe_text,values_from = n) %>%
  arrange(channel) %>% mutate(All = 1) %>%
  gt(rowname_col = "playlistDescription",groupname_col = "channel") %>%
  fmt_missing() %>%
  fmt_percent(decimals = 1) %>%
  couleur_gt() %>%
  gt::tab_header("Classification des vidéos") %>%
  gt::tab_source_note(glue::glue("Source : 2213 vidéos extraites de Youtube"))


# Tiens, par playlist, quel est le % de tel classe par segment
df_sub2_full %>%
  count(channel,playlistDescription,classe) %>%
  group_by(channel,playlistDescription) %>% mutate(n = n/sum(n)) %>%
  pivot_wider(names_from = classe,values_from = n) %>%
  gt(rowname_col = "playlistDescription",groupname_col = "channel") %>%
  fmt_missing(missing_text = "0%") %>%
  fmt_percent(decimals = 1) %>%
  couleur_gt() %>%
  gt::tab_header("Classification des vidéos") %>%
  gt::tab_source_note(glue::glue("Source : 2213 vidéos extraites de Youtube"))


vec_classe_all <- c("black","red","grey","green","blue","purple")
vec_classe <- c("red","grey","green","blue","purple")

df_sub2_full %>%
  select(channel,video_id,classe_text) %>% distinct() %>%
  count(channel,classe_text) %>%
  ggplot()+
-  aes(x=channel,y=n,fill=classe_text)+
  geom_bar(stat = "identity")+
  scale_fill_manual(values = vec_classe_all)+
  coord_flip()

df_sub2_full %>%
  select(channel,video_id,classe_text) %>% distinct() %>%
  count(channel,classe_text) %>%
  ggplot()+
  aes(x=channel,y=n,fill=classe_text)+
  geom_bar(stat = "identity",position = "fill")+
  scale_fill_manual(values = vec_classe_all)+
  coord_flip()

# Je voudrais savoir le % de chaque classe selon le moment de la vidéo
syn <- df_sub2_full %>%
  filter(classe_text == "Politique") %>%
  count(channel,classe_morceau,classe) %>%
  group_by(channel,classe_morceau) %>% mutate(n = n/sum(n))

ggplot(syn)+
  aes(x=classe_morceau,y=n,fill=classe)+
  geom_bar(stat = "identity")+
  scale_fill_manual(values = vec_classe_all)+
  facet_wrap(~channel)

# Est ce que ces tendances ont évolué dans le temps
syn2 <- df_sub2_full %>%
  filter(year_video == 2025) %>%
  count(channel,month_video,classe) %>%
  group_by(channel,month_video) %>% mutate(n = n/sum(n))

ggplot(syn2)+
  aes(x=month_video,y=n,fill=classe)+
  geom_bar(stat = "identity")+
  scale_fill_manual(values = vec_classe_all)+
  facet_wrap(~channel)

# Ici, c'est une stat sur les segments, comment faire pour avoir la même chose
# par vidéo, en imaginant prendre la classe dominante

syn3 <- df_sub2_full %>%
  count(channel,month_video,classe_text) %>%
  group_by(channel,month_video) %>% mutate(n = n/sum(n))

ggplot(syn3)+
  aes(x=month_video,y=n,fill=classe_text)+
  geom_bar(stat = "identity")+
  scale_fill_manual(values = vec_classe_all)+
  facet_wrap(~channel)


df_sub2 %>%
  count(channel,classe) %>%
  group_by(channel) %>% mutate(n = n/sum(n)) %>%
  pivot_wider(names_from = channel,values_from = n)

df_sub2 %>%
  filter(channel == "franceinfo") %>%
  count(yearvideo,classe) %>%
  group_by(yearvideo) %>% mutate(n = n/sum(n)) %>%
  pivot_wider(names_from = yearvideo,values_from = n)

df_sub2 %>%
  filter(channel == "CNEWS") %>%
  count(yearvideo,classe) %>%
  group_by(yearvideo) %>% mutate(n = n/sum(n)) %>%
  pivot_wider(names_from = yearvideo,values_from = n)

df_sub2 %>%
  filter(channel == "LCI") %>%
  count(yearvideo,classe) %>%
  group_by(yearvideo) %>% mutate(n = n/sum(n)) %>%
  pivot_wider(names_from = yearvideo,values_from = n)



#### Se servir de Iramuteq en Quanteda ####

df_ <- df_sub2_full %>%
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
