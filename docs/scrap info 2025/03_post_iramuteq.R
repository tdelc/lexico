cli::cli_alert_info("Début du 03_post_iramuteq.R")

# Faire tourner deux fois, un pour le local, un pour le global

path_iramuteq <- c(params$corpus_path_global,params$corpus_path_local)

path_iramuteq %>% map(~{

  cli::cli_alert_info("Début du corpus {.x}")

  # -------------------------------------------------------------------------
  # 1) Charger les données RDS (issues de l'étape précédente)
  # -------------------------------------------------------------------------

  df_segment <- readRDS(file = file.path(paths$data, "df_segment.rds"))
  df_video   <- readRDS(file = file.path(paths$data, "df_video.rds"))

  stopifnot(df_segment %>% select(video_id) %>% distinct() %>% nrow() == nrow(df_video))

  # -------------------------------------------------------------------------
  # 2) Import Iramuteq (post étape manuelle)
  # -------------------------------------------------------------------------

  iramuteq_dir  <- file.path(paths$data, .x)
  iramuteq_file <- file.path(iramuteq_dir, params$corpus_file)

  df_iramuteq <- import_from_iramuteq(iramuteq_file) %>%
    rename(video_id = videoid) %>%
    mutate(channel = case_when(
      channel == "FranceInfo" ~ "France Info",
      TRUE ~ channel
    ))

  stopifnot(df_iramuteq %>% select(video_id) %>% distinct() %>% nrow() == nrow(df_video))
  stopifnot(nrow(df_iramuteq) == nrow(df_segment))

  # -------------------------------------------------------------------------
  # 3) Mapping classes : fichier class_map.csv dans le dossier Iramuteq
  # -------------------------------------------------------------------------

  n_classes <- df_iramuteq %>% distinct(classe) %>% nrow()

  class_map_path <- init_class_map_if_missing(
    dir       = iramuteq_dir,
    filename  = params$class_map_file,
    n_classes = n_classes
  )

  class_map <- read_class_map(class_map_path)

  palettes <- build_palettes_from_map(class_map)

  # Appliquer les labels
  df_iramuteq <- df_iramuteq %>%
    mutate(
      id_classe = classe,
      classe = factor(
        as.character(classe),
        levels = class_map$class_id,
        labels = class_map$label
      )
    )

  stopifnot(nrow(df_iramuteq %>% filter(is.na(classe))) == 0)

  # -------------------------------------------------------------------------
  # 4) Créer les classes par vidéo
  # -------------------------------------------------------------------------

  df_iramuteq <- df_iramuteq %>%
    group_by(video_id) %>%
    mutate(id_segment = row_number()) %>%
    ungroup()

  df_iramuteq_video <- df_iramuteq %>%
    count(channel, video_id, classe, id_classe, name = "n_segments") %>%
    group_by(channel, video_id) %>%
    slice_max(n_segments, with_ties = FALSE) %>%
    ungroup() %>%
    rename(classe_text = classe, id_classe_text = id_classe)

  df_iramuteq <- df_iramuteq %>%
    left_join(df_iramuteq_video)

  stopifnot(nrow(df_iramuteq %>% filter(is.na(classe_text))) == 0)

  # -------------------------------------------------------------------------
  # 5) Joindre les classes aux fichiers initiaux
  # -------------------------------------------------------------------------

  # Sur les df_segment et df_video
  # classe_segment et classe_video

  test <- df_segment %>%
    select(video_id,id_segment,text) %>%
    left_join(df_iramuteq %>% select(video_id,id_segment,text2 = text)) %>%
    mutate(check = substr(text,1,5) == substr(text2,1,5))

  stopifnot(nrow(test %>% filter(!check)) < nrow(df_segment)/2)

  df_segment <- df_segment %>%
    left_join(df_iramuteq %>% select(video_id,id_segment,classe,id_classe,
                                     classe_text,id_classe_text,n_segments))

  stopifnot(nrow(df_segment %>% filter(is.na(classe))) == 0)

  df_segment <- df_segment %>%
    mutate(
      classe = case_when(
      is.na(classe) ~ class_map$label[1],
      TRUE ~ classe
      )
    )

  stopifnot(nrow(df_segment %>% filter(is.na(classe))) == 0)

  df_video <- df_video %>%
    left_join(df_iramuteq_video)

  stopifnot(nrow(df_video %>% filter(is.na(classe_text))) == 0)

  # Attention, certaines vidéos (3) disparaissent dans iramuteq. On leur attribue
  # Autre comme catégorie pour garantir la continuité des stats

  df_video <- df_video %>%
    mutate(classe_text = case_when(
      is.na(classe_text) ~ class_map$label[1],
      TRUE ~ classe_text
    ))

  # -------------------------------------------------------------------------
  # 5) Obtenir les mots caractéristiques
  # -------------------------------------------------------------------------

  file_classe <- file.path(paths$data,.x,"RAPPORT.txt")

  df_mots_classe <- c(1:(n_classes-1)) %>% map_df(~{
    read_iramuteq_class(file_classe,.x) %>%
      mutate(
        id_classe = .x,
        classe = class_map$label[.x+1])
  })

  # -------------------------------------------------------------------------
  # 6) Sauvegarder df spécifique au corpus
  # -------------------------------------------------------------------------

  saveRDS(df_segment,     file.path(iramuteq_dir, "df_segment.rds"))
  saveRDS(df_video,       file.path(iramuteq_dir, "df_video.rds"))
  saveRDS(df_mots_classe, file.path(iramuteq_dir, "df_mots_classe.rds"))
  saveRDS(palettes,       file.path(iramuteq_dir, "palettes.rds"))

})

cli::cli_alert_success("Fin du 03_post_iramuteq.R")
