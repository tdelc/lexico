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

params <- list(
  corpus_path_global = "corpus_segment_corpus_3/corpus_segment_alceste_5",
  corpus_path_local  = "corpus_segment_corpus_3/corpus_segment_alceste_4"
)

raw_path      <- "~/GitHub/lexico/docs/scrap info 2025/raw"
data_path     <- "~/GitHub/lexico/docs/scrap info 2025/data"
iramuteq_dir <- file.path(paths$data,params$corpus_path_local)

df_segment     <- readRDS(file.path(iramuteq_dir, "df_segment.rds"))
df_video       <- readRDS(file.path(iramuteq_dir, "df_video.rds"))
df_mots_classe <- readRDS(file.path(iramuteq_dir, "df_mots_classe.rds"))
palettes       <- readRDS(file.path(iramuteq_dir, "palettes.rds"))

df_mots_classe %>%
  filter(
    classe == "Religion",
    forme %in% c(
      "musulman","contraire","manière","république","laïcité","exercer",
      "pleinement","culte","religion","france","ramadan","mosquées","frères",
      "salafistes","islam","haine","juif","juifs","culte","églises","islamisme",
      "protéger","ville","escamoter","exercer","laïque","emprise"
    )
  ) %>% arrange(desc(chi2)) %>%
  summarise(sum(chi2))

df_mots_classe %>%
  filter(classe == "Religion") %>%
  arrange(desc(chi2))
