
col2hex <- function(x, alpha = FALSE) {
  args <- as.data.frame(t(col2rgb(x, alpha = alpha)))
  args <- c(args, list(names = x, maxColorValue = 255))
  do.call(rgb, args)
}

treemap_double_classe <- function(df,title = "Treemap",footer ="",
                                  palette){

  df_pre_treemap <- df %>%
    mutate(id_classe = as.numeric(id_classe)) %>%
    count(id_classe,classe,classe_local) %>%
    filter(n >= 30) %>%
    arrange(id_classe,classe,classe_local) %>%
    # group_by(classe) %>% mutate(id_classe = row_number()) %>% ungroup() %>%
    mutate(classe_local = paste0(classe_local," (",round(100*n/sum(n)),"%)"))

  print(df_pre_treemap)

  pal <- palettes$global$soft
  pal <- pal[order(names(pal), decreasing = FALSE)]

  treemap::treemap(df_pre_treemap,
          index = c("classe", "classe_local"), vSize = "n", type = "index",
          fontsize.labels = c(15, 12),
          fontcolor.labels = c("black", "grey30"),
          fontface.labels = c(2, 1),
          bg.labels = c("transparent"),
          align.labels = list(
            # c("center", "center"),
            c("left", "top"),
            c("right", "bottom")
          ),
          overlap.labels = 0.5,
          inflate.labels = F,
          palette=pal,
          # palette=c("#DEDEDE","#8AB2DF","#E29393","#B48DCC","#AFBEC4","#96BE98") ,
          sortID = "id_classe",
          title = title
  )

  if (footer == ""){
    nb_segments <- nrow(df_segment)
    nb_videos <- df_segment %>% summarise(n=n_distinct(video_id)) %>% pull(n)
    footer <- glue::glue("Classification basée sur {nb_segments} segments de texte d'une minute issus de {nb_videos} vidéos.")
  }

  footnote <-
  grid::grid.text(
    footer ,
    x = 0.9, y = 0.025,just="right",
    gp = gpar(fontsize = 10, col = "grey30")
  )
}
