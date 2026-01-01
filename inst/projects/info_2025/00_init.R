library(tidyverse)
library(devtools)
library(syuzhet)
library(quanteda)
library(quanteda.textplots)
library(quanteda.textstats)
library(quanteda.textmodels)
library(gtExtras)
load_all()

# -------------------------------------------------------------------------
# 0) Paramètres
# -------------------------------------------------------------------------

paths <- list(
  raw      = "~/GitHub/lexico/inst/projects/info_2025/raw",
  data     = "~/GitHub/lexico/inst/projects/info_2025/data",
  dic      = "~/GitHub/lexico/inst/projects/info_2025/dictionary",
  shiny    = "~/GitHub/lexico/inst/projects/info_2025/dashboard"
)

params <- list(

  yt_dlp = Sys.getenv("YT_DLP_PATH"),
  api_key = Sys.getenv("YT_API_KEY"),
  max_videos = 1000,

  # Chaînes d'info
  channels_info = c("BFMTV", "CNEWS", "France Info", "LCI"),

  # Période d'analyse
  years_keep = 2024:2025,

  # Filtre durée (en secondes)
  min_duration = 120,

  # Regroupement Iramuteq : texte par minute
  group_minutes = 1,

  # Seuil pour repérer les segments très courts
  min_words_diag = 100,

  # Corpus à récupérer
  corpus_path = "corpus_segment_corpus_1/corpus_segment_alceste_4",
  corpus_file = "export_corpus.txt",

  # Dossier issu de l'étape manuelle Iramuteq
  corpus_path_global = "corpus_segment_corpus_3/corpus_segment_alceste_5",
  corpus_path_local  = "corpus_segment_corpus_3/corpus_segment_alceste_4",

  # Fichier de mapping classes (à créer/éditer manuellement une fois)
  class_map_file = "class_map.csv"
)
