library(quanteda)
library(quanteda.textplots)
library(quanteda.textstats)
library(quanteda.textmodels)
library(tidyverse)
library(gt)
library(devtools)
load_all()

raw_path      <- "~/GitHub/lexico/docs/scrap info 2025/raw"
data_path     <- "~/GitHub/lexico/docs/scrap info 2025/data"
iramuted_path <- "~/GitHub/lexico/docs/scrap info 2025/iramuteq"
shiny_path <- "~/GitHub/lexico/docs/scrap info 2025/dashboard"

df      <- readRDS(file.path(data_path,"df.rds"))
df_full <- readRDS(file.path(data_path,"df_full.rds"))

chaine_info <- c("BFMTV","CNEWS","France Info","LCI")
df_sub <- df_full %>% filter(channel %in% chaine_info)

df_text <- df_sub %>%
  filter(channel %in% chaine_info) %>%
  group_by(video_id,year_video,channel,title,tags,description) %>%
  summarise(text = paste(text, collapse = " ")) %>%
  ungroup()

#### Création des Corpus ####

# Suppression des apostrophe avant
df_text <- df_text %>%
  dplyr::mutate(title       = remove_apostrophe(title),
                text        = remove_apostrophe(text),
                tags        = remove_apostrophe(tags),
                description = remove_apostrophe(description))

corpus_title <- quanteda::corpus(df_text,docid_field="video_id",text_field="title")
corpus_text  <- quanteda::corpus(df_text,docid_field="video_id",text_field="text")
corpus_tags  <- quanteda::corpus(df_text,docid_field="video_id",text_field="tags")
corpus_desc  <- quanteda::corpus(df_text,docid_field="video_id",text_field="description")

#### Création des tokens ####

tokens_title <- corpus_to_tokens(corpus_title)
tokens_text  <- corpus_to_tokens(corpus_text)
tokens_tags  <- corpus_to_tokens(corpus_tags)
tokens_desc  <- corpus_to_tokens(corpus_desc)

#### Création des dfm (documents*features matrix) ####

dfm_title <- quanteda::dfm(tokens_title)
dfm_text  <- quanteda::dfm(tokens_text)
dfm_tags  <- quanteda::dfm(tokens_tags)
dfm_desc  <- quanteda::dfm(tokens_desc)

# dfm_prop <- dfm_brut %>% dfm_weight(scheme = "prop")

#### Sauver les fichiers ####

# write_rds(df,file=file.path(data_path,"df_full.rds"))
# write_rds(df_clean,file=file.path(data_path,"df_clean.rds"))

write_rds(corpus_title,file=file.path(data_path,"corpus_title.rds"))
write_rds(corpus_text, file=file.path(data_path,"corpus_text.rds"))
write_rds(corpus_tags, file=file.path(data_path,"corpus_tags.rds"))
write_rds(corpus_desc, file=file.path(data_path,"corpus_desc.rds"))

write_rds(tokens_title,file=file.path(data_path,"tokens_title.rds"))
write_rds(tokens_text, file=file.path(data_path,"tokens_text.rds"))
write_rds(tokens_tags, file=file.path(data_path,"tokens_tags.rds"))
write_rds(tokens_desc, file=file.path(data_path,"tokens_desc.rds"))

write_rds(dfm_title,file=file.path(data_path,"dfm_title.rds"))
write_rds(dfm_text, file=file.path(data_path,"dfm_text.rds"))
write_rds(dfm_tags, file=file.path(data_path,"dfm_tags.rds"))
write_rds(dfm_desc, file=file.path(data_path,"dfm_desc.rds"))

#### Export pour app ####
write_rds(tokens_text, file=file.path(shiny_path,"tokens_text.rds"))
write_rds(dfm_text   , file=file.path(shiny_path,"dfm_text.rds"))
