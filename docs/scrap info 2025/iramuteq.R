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

corpus_path <- "corpus_segment_corpus_1/corpus_segment_alceste_1"
corpus_name <- "export_corpus.txt"

df <- readRDS(file.path(data_path,"df.rds"))
df_full <- readRDS(file.path(data_path,"df_full.rds"))
chaine_info <- c("BFMTV","CNEWS","France Info","LCI")
df_sub <- df %>% filter(channel %in% chaine_info)

df_iramuteq <- import_from_iramuteq(
  file.path(iramuted_path,corpus_path,corpus_name)
)

df_iramuteq_class <- read_iramuteq_class(
  file.path(iramuted_path,corpus_path,"RAPPORT.txt")
)

class_col_5 <- c("white","red","green","blue","purple")
class_col_6 <- c("white","red","grey","green","blue","purple")

vec_classe_lab <- c("Autre", "Géopolitique", "Faits divers",
                    "Politique", "Économie", "Médias")

vec_classe_col <- switch(as.character(length(vec_classe_lab)),
  "5" = class_col_5,
  "6" = class_col_6
)
vec_class_nbr <- as.character(0:(length(vec_classe_lab)-1))

df_iramuteq <- df_iramuteq %>%
  mutate(classe = factor(classe,levels = vec_class_nbr,labels = vec_classe_lab))


# df_iramuteq <- df_iramuteq %>%
#   mutate(classe = factor(classe,levels = c("0","1","2","3","4","5"),
#                          labels = c("Autre", "Économie", "Politique",
#                                     "Géopolitique", "Justice", "Faits divers")))

# df_sub2 <- df_sub2 %>%
#   mutate(classe = factor(classe,levels = c("0","1","2","3","4"),
#                          labels = c("Autre", "Économie", "Géopolitique",
#                                     "Politique","Faits divers")))

df_iramuteq_full <- df_iramuteq %>%
  rename(video_id = videoid) %>%
  mutate(channel = ifelse(channel == "FranceInfo","France Info",channel)) %>%
  left_join(df_sub %>% select(channel,video_id,year_video,month_video,day_video,
                              date_video,playlistDescription,duree,likeCount,
                              viewCount,commentCount,title,description))

# Ajouter la classe du texte
df_classe_text <- df_iramuteq_full %>%
  count(channel,video_id,classe) %>%
  group_by(channel,video_id) %>% slice_max(n,with_ties = F) %>% ungroup() %>%
  rename(classe_text = classe)

df_iramuteq_full <- df_iramuteq_full %>%
  left_join(df_classe_text %>% select(channel,video_id,classe_text))


# Pour avoir le % de la vidéo
df_iramuteq_full <- df_iramuteq_full %>%
  group_by(channel,video_id) %>%
  mutate(id_morceau = row_number(),
         pc_morceau = (id_morceau-0.5)/n(),
         classe_morceau = cut(pc_morceau,seq(0,1,0.1),1:10)
         ) %>%
  ungroup()

# Sauver pour le dashboard
shiny_path <- "~/GitHub/lexico/docs/scrap info 2025/dashboard"

# Réduire les infos
df_info_text <- df_iramuteq_full %>%
  select(channel,playlistDescription,video_id,classe=classe_text,date_video,
         year_video,duree,likeCount,viewCount,commentCount) %>%
  distinct()

df_info_segm <- df_iramuteq_full %>%
  select(channel,playlistDescription,video_id,id_morceau,classe)

df_text <- df_iramuteq_full %>%
  group_by(channel,playlistDescription,video_id,title,description,date_video) %>%
  summarise(text = paste(text, collapse = " ")) %>%
  distinct()

df_segm <- df_iramuteq_full %>%
  select(channel,playlistDescription,video_id,id_morceau,text)

saveRDS(df_info_text,file.path(shiny_path,"df_info_text.rds"))
saveRDS(df_info_segm,file.path(shiny_path,"df_info_segm.rds"))
arrow::write_parquet(df_text,file.path(shiny_path,"df_text.parquet"))
arrow::write_parquet(df_segm,file.path(shiny_path,"df_segm.parquet"))

vec_classe_col_soft <- sapply(vec_classe_col,function(x)
  colorRampPalette(c("white", x))(5)[3])

classe_palette <- setNames(vec_classe_col,vec_classe_lab)
classe_palette_soft <- setNames(vec_classe_col_soft,vec_classe_lab)

saveRDS(classe_palette,file.path(shiny_path,"classe_palette.rds"))
saveRDS(classe_palette_soft,file.path(shiny_path,"classe_palette_soft.rds"))


couleur_gt <- function(gt){
  gt %>%
    # data_color(columns = Économie, method = "numeric",palette = c("white", "red")) %>%
    # data_color(columns = Politique, method = "numeric",palette = c("white", "grey")) %>%
    # data_color(columns = Géopolitique, method = "numeric",palette = c("white", "green")) %>%
    # data_color(columns = Justice, method = "numeric",palette = c("white", "blue")) %>%
    # data_color(columns = `Faits divers`, method = "numeric",palette = c("white", "purple"))
    data_color(columns = Géopolitique, method = "numeric",palette = c("white", "red")) %>%
    data_color(columns = `Faits divers`, method = "numeric",palette = c("white", "grey")) %>%
    data_color(columns = Politique, method = "numeric",palette = c("white", "green")) %>%
    data_color(columns = Économie, method = "numeric",palette = c("white", "blue")) %>%
    data_color(columns = Médias, method = "numeric",palette = c("white", "purple"))
}

source_videos <- glue::glue(
  "Source : {nrow(df_iramuteq_full %>% distinct(video_id))} vidéos extraites de Youtube ; Traitements, calculs et erreur : Thomas Delclite.")

# Simple % des segments par chaîne
df_iramuteq_full %>%
  count(channel,classe) %>%
  group_by(channel) %>% mutate(n_all = sum(n),n = n/sum(n)) %>% ungroup() %>%
  arrange(classe) %>%
  pivot_wider(names_from = classe,values_from = n) %>%
  gt(rowname_col = "channel") %>%
  cols_label(n_all = "Nb segments") %>%
  fmt_percent(columns=-n_all,decimals = 1,sep_mark = ".",dec_mark = ",") %>%
  fmt_number(columns=n_all,decimals = 0,sep_mark = ".",dec_mark = ",") %>%
  couleur_gt() %>%
  gt::tab_header("Classification des segments de vidéos") %>%
  gt::tab_source_note(source_videos) %>%
  gt::tab_source_note(glue::glue(
    "Proportion calculée sur {nrow(df_iramuteq_full)} segments d'environ 40 mots."))


# Ici, c'est une stat sur les segments, comment faire pour avoir la même chose
# par vidéo, en imaginant prendre la classe dominante

df_iramuteq_full %>%
  select(channel,video_id,classe_text) %>% distinct() %>%
  count(channel,classe_text) %>%
  group_by(channel) %>% mutate(n_all = sum(n),n = n/sum(n)) %>% ungroup() %>%
  arrange(classe_text) %>%
  pivot_wider(names_from = classe_text,values_from = n) %>%
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

df_iramuteq_full %>%
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
df_iramuteq_full %>%
  select(channel,playlistDescription,video_id,classe_text) %>% distinct() %>%
  count(channel,playlistDescription,classe_text) %>%
  group_by(channel,playlistDescription) %>% mutate(n_all = sum(n),n = n/sum(n)) %>%
  arrange(classe_text) %>%
  pivot_wider(names_from = classe_text,values_from = n) %>%
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
df_iramuteq_full %>%
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


# Tiens, par playlist, quel est le % de tel classe par segment
df_iramuteq_full %>%
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

df_iramuteq_full %>%
  select(channel,video_id,classe_text) %>% distinct() %>%
  count(channel,classe_text) %>%
  ggplot()+
-  aes(x=channel,y=n,fill=classe_text)+
  geom_bar(stat = "identity")+
  scale_fill_manual(values = vec_classe_all)+
  coord_flip()

df_iramuteq_full %>%
  select(channel,video_id,classe_text) %>% distinct() %>%
  count(channel,classe_text) %>%
  ggplot()+
  aes(x=channel,y=n,fill=classe_text)+
  geom_bar(stat = "identity",position = "fill")+
  scale_fill_manual(values = vec_classe_all)+
  coord_flip()

# Je voudrais savoir le % de chaque classe selon le moment de la vidéo
syn <- df_iramuteq_full %>%
  filter(classe_text == "Politique") %>%
  count(channel,classe_morceau,classe) %>%
  group_by(channel,classe_morceau) %>% mutate(n = n/sum(n))

ggplot(syn)+
  aes(x=classe_morceau,y=n,fill=classe)+
  geom_bar(stat = "identity")+
  scale_fill_manual(values = vec_classe_all)+
  facet_wrap(~channel)

# Est ce que ces tendances ont évolué dans le temps
syn2 <- df_iramuteq_full %>%
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

syn3 <- df_iramuteq_full %>%
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
