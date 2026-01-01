
#' Convert color to hexadecimal
#'
#' @param x name of color
#' @param alpha get transparent color
#'
#' @returns hex color
#' @export
#'
#' @examples
#' col2hex('red')
col2hex <- function(x, alpha = FALSE) {
  args <- as.data.frame(t(col2rgb(x, alpha = alpha)))
  args <- c(args, list(names = x, maxColorValue = 255))
  do.call(rgb, args)
}

#' Plot a treemap of thema and classe of segments
#'
#' @param df data.frame with theme and classe
#' @param id_theme id of theme (to order it)
#' @param theme name of theme variable
#' @param classe name of classe variable
#' @param title title of the treemap
#' @param footer (optional) footer of the treemap
#' @param palette (optional) palette to color theme
#' @param threshold minimum frequent of classe to show
#'
#' @returns plot
#' @export
#'
#' @examples
#' df_segment <- read.csv("inst/extdata/df_segment.csv")
#' treemap_double_classe(df_segment,"id_classe","classe","classe_local",0)
treemap_double_classe <- function(df,
                                  id_theme,
                                  theme,
                                  classe,
                                  threshold = 30,
                                  title  = "Treemap",
                                  footer = "",
                                  palette= NA){

  df_pre_treemap <- df %>%
    mutate(id_theme_ = as.numeric(!!sym(id_theme)),
           theme_ = !!sym(theme),
           classe_ = !!sym(classe)) %>%
    count(id_theme_,theme_,classe_) %>%
    filter(n >= threshold) %>%
    arrange(id_theme_,theme_,classe_) %>%
    # group_by(classe) %>% mutate(id_theme_ = row_number()) %>% ungroup() %>%
    mutate(classe_ = paste0(classe_," (",round(100*n/sum(n)),"%)")) %>%
    mutate(n_all = sum(n)) %>%
    group_by(theme_) %>%
    mutate(theme_ = paste0(theme_," (",round(100*sum(n)/n_all),"%)"))

  pal <- palettes$global$soft
  pal <- pal[order(names(pal), decreasing = FALSE)]

  treemap::treemap(df_pre_treemap,
          index = c("theme_", "classe_"), vSize = "n", type = "index",
          fontsize.labels = c(15, 14),
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
          sortID = "id_theme_",
          title = title
  )

  grid::grid.text(
    footer ,
    x = 0.9, y = 0.025,just="right",
    gp = grid::gpar(fontsize = 10, col = "grey30")
  )
}
