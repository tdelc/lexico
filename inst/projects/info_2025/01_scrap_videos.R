# -------------------------------------------------------------------------
# 1) Définir les playlists à récupérer
# -------------------------------------------------------------------------

df_playlist <- dplyr::tibble(
                 suffix = "bfm",
                 channelTitle = "BFMTV",
                 playlist_id = "PL-qBKb-rfbhjZjW0RQr3Dm8iIvXFE0Gwy",
                 playlistDescription = "Politique") %>%
  dplyr::add_row(suffix = "bfm",
                 channelTitle = "BFMTV",
                 playlist_id = "PL-qBKb-rfbhhmFo0yCUq2KyhVKHpCX0aG",
                 playlistDescription = "Face-à-Face") %>%
  dplyr::add_row(suffix = "fra",
                 channelTitle = "franceinfo",
                 playlist_id = "PLg6GanYvTasW3tTMej4dqF65OBYud7vpr",
                 playlistDescription = "Politique") %>%
  dplyr::add_row(suffix = "fra",
                 channelTitle = "franceinfo",
                 playlist_id = "PLg6GanYvTasWQv6EPyPInaYhtyFRcht3r",
                 playlistDescription = "Interview de 8:30") %>%
  dplyr::add_row(suffix = "fra",
                 channelTitle = "franceinfo",
                 playlist_id = "PLg6GanYvTasUlJYuk2RWi38V0iEyeeyQ4",
                 playlistDescription = "Les sujets du 20h") %>%
  dplyr::add_row(suffix = "lci",
                 channelTitle = "LCI",
                 playlist_id = "PLdzIP_iC3tqs5NAMpAw8SXV94OE_BmmI0",
                 playlistDescription = "Actu Politique en France") %>%
  dplyr::add_row(suffix = "lci",
                 channelTitle = "LCI",
                 playlist_id = "PLdzIP_iC3tqumT7Db86uVGzuQJ_cFLwVb",
                 playlistDescription = "Interview matinale") %>%
  dplyr::add_row(suffix = "lci",
                 channelTitle = "LCI",
                 playlist_id = "PLdzIP_iC3tqvQsAmjGuMs-YZlT2kDqhCU",
                 playlistDescription = "Partis Pris Pujadas") %>%
  dplyr::add_row(suffix = "eur",
                 channelTitle = "Europe 1",
                 playlist_id = "PLohg8tfh_cS42wTeOZwo32Hn6GACM1g23",
                 playlistDescription = "Grande Interview") %>%
  dplyr::add_row(suffix = "eur",
                 channelTitle = "Europe 1",
                 playlist_id = "PLohg8tfh_cS5mZeg3tpn5M8bF8F7Apfj5",
                 playlistDescription = "Grand Rendez vous") %>%
  dplyr::add_row(suffix = "eur",
                 channelTitle = "Europe 1",
                 playlist_id = "PLohg8tfh_cS71OJvp1cRX7evXGFweG2qu",
                 playlistDescription = "Pascal Praud") %>%
  dplyr::add_row(suffix = "eur",
                 channelTitle = "Europe 1",
                 playlist_id = "PLohg8tfh_cS5NOYUSl0qxPa6KwkaRaMR8",
                 playlistDescription = "Punchline avec Laurence Ferrari") %>%
  dplyr::add_row(suffix = "med",
                 channelTitle = "Le Média",
                 playlist_id = "PLXJa1eyN_t2m13fapeE1DCvxxUL1rl8u0",
                 playlistDescription = "Politique") %>%
  dplyr::add_row(suffix = "cne",
                 channelTitle = "CNEWS",
                 playlist_id = "PLheywt34DW0NKn6EJc0v2W_wI_BY7ffYa",
                 playlistDescription = "Actu") %>%
  dplyr::add_row(suffix = "bla",
                 channelTitle = "BLAST, Le souffle de l'info",
                 playlist_id = "PLv1KZC6gJTFkYNI08mU_OvAH8Z2mpRW2C",
                 playlistDescription = "Actu") %>%
  dplyr::add_row(suffix = "int",
                 channelTitle = "France Inter",
                 playlist_id = "PL43OynbWaTMIw5ZnukRdGVNKF5g7uakaD",
                 playlistDescription = "8h20 Grand Entretien") %>%
  dplyr::add_row(suffix = "int",
                 channelTitle = "France Inter",
                 playlist_id = "PL43OynbWaTMIMtr7RFamX30vEt_C9sSnT",
                 playlistDescription = "Questions politiques") %>%
  dplyr::add_row(suffix = "int",
                 channelTitle = "France Inter",
                 playlist_id = "PL43OynbWaTMK5iS5F--GDXzk0gH2XxdRX",
                 playlistDescription = "Débat de la grande matinale") %>%
  dplyr::add_row(suffix = "int",
                 channelTitle = "France Inter",
                 playlist_id = "PL43OynbWaTMIMtr7RFamX30vEt_C9sSnT",
                 playlistDescription = "Questions politiques") %>%
  dplyr::add_row(suffix = "int",
                 channelTitle = "France Inter",
                 playlist_id = "PL43OynbWaTMLFi_Oj872nxqDeUGBNNRp4",
                 playlistDescription = "Édito politique")


write.csv(df_playlist,file.path(paths$raw,"df_playlist.csv"),row.names = F)

df_playlist_info <- df_playlist %>%
  dplyr::filter(suffix %in% params$channels_info)

1:nrow(df_playlist_info) %>% purrr::map(~{
  row <- df_playlist_info[.x,]
  cli::cli_alert_info("Extraction {row$playlistDescription}")
  run_complete_extraction(params$api_key,params$yt_dlp,paths$raw,
                          row$suffix,row$playlist_id,params$max_videos)
})




# vtt_path    <- "~/GitHub/lexico/inst/extdata/subs_bfm/"
#
# vtt_files_to_df("~/GitHub/lexico/inst/extdata","bfm")
#
#
# vtt_files_to_df(raw_path,"bfm")
