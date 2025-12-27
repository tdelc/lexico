
# -------------------------------------------------------------------------
# 1) Charger les données RDS (issues de l'étape précédente)
# -------------------------------------------------------------------------

iramuteq_dir_global <- file.path(paths$data,params$corpus_path_global)
iramuteq_dir_local  <- file.path(paths$data,params$corpus_path_local)

df_segment_global <- readRDS(file.path(iramuteq_dir_global, "df_segment.rds"))
palettes_global   <- readRDS(file.path(iramuteq_dir_global, "palettes.rds"))
df_segment_local  <- readRDS(file.path(iramuteq_dir_local,  "df_segment.rds"))
palettes_local    <- readRDS(file.path(iramuteq_dir_local,  "palettes.rds"))

# -------------------------------------------------------------------------
# 2) Fusionner les classes
# -------------------------------------------------------------------------

temp_local <- df_segment_local %>%
  select(video_id,id_segment,classe_local = classe)

df_segment_classe <- df_segment_global %>%
  left_join(temp_local)

stopifnot(nrow(df_segment_classe) == nrow(df_segment_global))
stopifnot(df_segment_classe %>% filter(is.na(classe)) %>% nrow() == 0)
stopifnot(df_segment_classe %>% filter(is.na(classe_local)) %>% nrow() == 0)

# -------------------------------------------------------------------------
# 3) Correction manuelle des classes
# -------------------------------------------------------------------------

df_segment_classe <- df_segment_classe %>%
  mutate(
    # classe = ifelse(classe == "Clivage","Société",classe),
    classe = case_when(
      classe_local == "Religion" ~ "Société",
      classe_local == "Sport" ~ "Société",
      classe_local == "Gauche" ~ "Politique",
      classe_local == "Droite" ~ "Politique",
      classe_local == "Industrie" ~ "Économie",
      classe_local == "Famille" ~ "Société",
      classe_local == "Journalisme" ~ "Société",
      TRUE ~ classe)
  )

df_segment_classe <- df_segment_classe %>%
  mutate(
    id_classe = match(classe, names(palettes$global$hard))
  )

# id_clivage <- which(names(palettes_global$hard) == "Clivage")
# names(palettes_global$hard)[id_clivage] <- "Société"
# names(palettes_global$soft)[id_clivage] <- "Société"

df_segment_classe %>%
  count(classe,classe_local) %>%
  filter(n < sum(n)/row_number()/10)

# Bug, le guerre / Autre est vraiment très court
# A voir pour les supprimer

# -------------------------------------------------------------------------
# 4) Sauvegarder df commune dans data
# -------------------------------------------------------------------------

palettes <- list(global = palettes_global,local = palettes_local)

saveRDS(df_segment_classe, file.path(paths$data, "df_segment_classe.rds"))
saveRDS(palettes,          file.path(paths$data, "palettes.rds"))
