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
df_full <- readRDS(file.path(data_path,"df_full.rds"))
chaine_info <- c("BFMTV","CNEWS","France Info","LCI")
df_sub <- df %>% filter(channel %in% chaine_info)


corpus_path <- "corpus_segment_corpus_7/corpus_segment_alceste_1"
# corpus_path <- "corpus_segment_corpus_7/corpus_segment_alceste_2"
corpus_name <- "export_corpus.txt"

df_iramuteq <- import_from_iramuteq(
  file.path(iramuted_path,corpus_path,corpus_name)
)

# df_iramuteq_class <- read_iramuteq_class(
#   file.path(iramuted_path,corpus_path,"RAPPORT.txt")
# )

class_col_5 <- c("white","red","green","cadetblue2","plum2")
class_col_6 <- c("white","red","gold","green","cadetblue2","plum2")
class_col_14 <- c("white","red","gold","green","cadetblue2","plum2","orange",
                  "yellow","cyan","pink","palegreen","khaki","peru","tomato")

vec_classe_lab <- c("Autre", "Géopolitique", "Faits divers",
                    "Politique", "Économie", "Médias")

vec_classe_lab <- c("Autre", "International", "Violence",
                    "Politique", "Clivage", "Économie")

vec_classe_lab <- c("Autre", "International", "Violence",
                    "Politique", "Clivage", "Économie")

# vec_classe_lab <- c("Autre", "Sport","Religion", "Santé","Justice","Police",
#                     "Famille","Journalisme","Ukraine","Israël","Budget",
#                     "Élection","Assemblée","Agriculture")

vec_classe_col <- switch(as.character(length(vec_classe_lab)),
                         "5" = class_col_5,
                         "6" = class_col_6,
                         "14" = class_col_14
)
vec_class_nbr <- as.character(0:(length(vec_classe_lab)-1))

vec_classe_col_soft <- sapply(vec_classe_col,function(x)
  colorRampPalette(c("white", x))(5)[3])

classe_palette <- setNames(vec_classe_col,vec_classe_lab)
classe_palette_soft <- setNames(vec_classe_col_soft,vec_classe_lab)



df_iramuteq <- df_iramuteq %>%
  mutate(classe = factor(classe,levels = vec_class_nbr,labels = vec_classe_lab))


df_iramuteq_segments <- df_iramuteq %>%
  rename(video_id = videoid) %>%
  mutate(channel = ifelse(channel == "FranceInfo","France Info",channel)) %>%
  left_join(df_sub %>% select(channel,video_id,year_video,month_video,day_video,
                              date_video,playlistDescription,duree,likeCount,
                              viewCount,commentCount,title,description)) %>%
  group_by(video_id) %>% mutate(id_segment = row_number()) %>% ungroup()

# Ajouter la classe du texte
df_classe_text <- df_iramuteq_segments %>%
  count(channel,video_id,classe) %>%
  group_by(channel,video_id) %>% slice_max(n,with_ties = F) %>% ungroup() %>%
  rename(classe_text = classe)

df_iramuteq_segments <- df_iramuteq_segments %>%
  left_join(df_classe_text %>% select(channel,video_id,classe_text))

df_iramuteq_segments %>% select(video_id) %>% distinct()

# Sauver les fichiers
saveRDS(df_iramuteq_segments,file.path(iramuted_path,corpus_path,"df_iramuteq_segments.rds"))
saveRDS(classe_palette      ,file.path(iramuted_path,corpus_path,"classe_palette.rds"))
saveRDS(classe_palette_soft ,file.path(iramuted_path,corpus_path,"classe_palette_soft.rds"))


