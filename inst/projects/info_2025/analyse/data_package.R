library(tidyverse)
library(rfeel)
library(quanteda)
library(gt)
library(devtools)
load_all()

path_examples <- "~/GitHub/lexico/inst/extdata"
path_data <- "~/GitHub/lexico/inst/projects/info_2025/data"


df_info_bfm <- read.csv(file.path(path_examples,"df_info_bfm.csv"))
df_stat_bfm <- read.csv(file.path(path_examples,"df_stat_bfm.csv"))
df_text_bfm <- read.csv(file.path(path_examples,"df_text_bfm.csv"))

df_segment_bfm <- readRDS(file.path(path_data, "df_segment_classe.rds")) %>%
  filter(video_id %in% df_info_bfm$video_id)

use_data(df_info_bfm,overwrite = TRUE)
use_data(df_stat_bfm)
use_data(df_text_bfm)
use_data(df_segment_bfm)

