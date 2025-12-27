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

saveRDS(df_segment, file.path(paths$shiny, "df_segment.rds"))
saveRDS(palettes  , file.path(paths$shiny, "palettes.rds"))

# Réduire les infos
df_info_text <- df_iramuteq_segments %>%
  select(channel,playlistDescription,video_id,classe=classe_text,date_video,
         year_video,month_video,duree,likeCount,viewCount,commentCount) %>%
  distinct()

df_info_segm <- df_iramuteq_segments %>%
  select(channel,playlistDescription,video_id,id_segment,date_video,duree,
         classe,classe_text)

df_text <- df_iramuteq_segments %>%
  group_by(channel,playlistDescription,video_id,title,description,date_video) %>%
  summarise(text = paste(text, collapse = " ")) %>%

  distinct()

df_segm <- df_iramuteq_segments %>%
  select(channel,playlistDescription,video_id,id_segment,text)

saveRDS(df_info_text,file.path(shiny_path,"df_info_text.rds"))
saveRDS(df_info_segm,file.path(shiny_path,"df_info_segm.rds"))
arrow::write_parquet(df_text,file.path(shiny_path,"df_text.parquet"))
arrow::write_parquet(df_segm,file.path(shiny_path,"df_segm.parquet"))


saveRDS(classe_palette,file.path(shiny_path,"classe_palette.rds"))
saveRDS(classe_palette_soft,file.path(shiny_path,"classe_palette_soft.rds"))


# -------------------------------------------------------------------------
# 4) Sauvegarder df commune pour app shiny
# -------------------------------------------------------------------------




