library(tidyverse)
library(quanteda)
library(quanteda.textplots)
library(quanteda.textstats)
library(quanteda.textmodels)
library(rainette)

library(gtExtras)

library(devtools)
load_all()

raw_path      <- "~/GitHub/lexico/docs/scrap info 2025/raw"
data_path     <- "~/GitHub/lexico/docs/scrap info 2025/data"
iramuted_path <- "~/GitHub/lexico/docs/scrap info 2025/iramuteq"

df <- readRDS(file.path(data_path,"df.rds"))
chaine_info <- c("BFMTV","CNEWS","France Info","LCI")
df_sub <- df %>% filter(channel %in% chaine_info)

corpus <- quanteda::corpus(df_sub,docid_field="id",text_field="text")
corpus <- split_segments(corpus, segment_size = 40)

tok <- corpus_to_tokens(corpus)
dtm <- dfm(tok, tolower = TRUE)
dtm <- dfm_trim(dtm, min_docfreq = 10)

res <- rainette(dtm, k = 6, min_segment_size = 15)
rainette_explor(res, dtm, corpus)


