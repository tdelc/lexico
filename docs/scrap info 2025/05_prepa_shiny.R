cli::cli_alert_info("Début du 05_prepa_shiny.R")

# -------------------------------------------------------------------------
# 1) Import RDS
# -------------------------------------------------------------------------

df_segment <- readRDS(file.path(paths$data,"df_segment_classe.rds"))
palettes   <- readRDS(file.path(paths$data,"palettes.rds"))

df_video <- df_segment %>%
  count(channel, video_id, classe, name = "n_segments") %>%
  group_by(channel, video_id) %>%
  slice_max(n_segments, with_ties = FALSE) %>%
  ungroup() %>%
  rename(classe_text = classe)

df_segment <- df_segment %>%
  select(-classe_text,-n_segments) %>%
  left_join(df_video)

# -------------------------------------------------------------------------
# 2) Sauvegarder df commune pour app shiny
# -------------------------------------------------------------------------

saveRDS(df_segment, file.path(paths$shiny, "df_segment.rds"))
saveRDS(palettes  , file.path(paths$shiny, "palettes.rds"))

cli::cli_alert_success("Fin du 05_prepa_shiny.R")






