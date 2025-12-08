library(quanteda)
library(quanteda.textplots)
library(quanteda.textstats)
library(quanteda.textmodels)

#### Création des Corpus ####

# Suppression des apostrophe avant
df_ <- df %>%
  dplyr::mutate(title       = remove_apostrophe(title),
                text        = remove_apostrophe(text),
                tags        = remove_apostrophe(tags),
                description = remove_apostrophe(description))

corpus_title <- quanteda::corpus(df_,docid_field="id",text_field="title")
corpus_text  <- quanteda::corpus(df_,docid_field="id",text_field="text")
corpus_tags  <- quanteda::corpus(df_,docid_field="id",text_field="tags")
corpus_desc  <- quanteda::corpus(df_,docid_field="id",text_field="description")

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

write_rds(df,file=file.path(data_path,"df_full.rds"))
write_rds(df_clean,file=file.path(data_path,"df_clean.rds"))

write_rds(corpus_title,file=file.path(data_path,"corpus_title.rds"))
write_rds(corpus_text, file=file.path(data_path,"corpus_text.rds"))
write_rds(corpus_tags, file=file.path(data_path,"corpus_tags.rds"))
write_rds(corpus_desc, file=file.path(data_path,"corpus_desc.rds"))

write_rds(tokens_title,file=file.path(data_path,"tokens_title.rds"))
write_rds(tokens_text, file=file.path(data_path,"tokens_text.rds"))
write_rds(tokens_tags, file=file.path(data_path,"tokens_tags.rds"))
write_rds(tokens_desc, file=file.path(data_path,"tokens_desc.rds"))

write_rds(dfm_title,file=file.path(data_path,"dfm_desc.rds"))
write_rds(dfm_text, file=file.path(data_path,"dfm_desc.rds"))
write_rds(dfm_tags, file=file.path(data_path,"dfm_desc.rds"))
write_rds(dfm_desc, file=file.path(data_path,"dfm_desc.rds"))
