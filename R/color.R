init_class_map_if_missing <- function(dir, filename, n_classes) {
  path <- file.path(dir, filename)
  if (!file.exists(path)) {
    message("class_map.csv absent -> création d'un squelette : ", path)
    tibble(
      class_id = 0:(n_classes - 1),
      label    = paste("Classe", 0:(n_classes - 1)),
      color    = NA_character_
    ) %>%
      write_csv(path)
  }
  path
}

read_class_map <- function(path) {
  readr::read_csv(path, show_col_types = FALSE) %>%
    mutate(
      class_id = as.character(class_id),
      label = as.character(label)
    ) %>%
    arrange(as.integer(class_id))
}

cols <- c("white","tomato","gold","green","cadetblue2","plum2",
          "orange","yellow","cyan","pink","palegreen","khaki",
          "peru","red","slateblue","lemonchiffon","firebrick1")

make_soft_colors <- function(cols) {
  sapply(cols, \(x) colorRampPalette(c("white", x))(5)[3])
}

build_palettes_from_map <- function(class_map,default_palette = cols) {
  # si l'utilisateur a mis des couleurs dans class_map.csv, on les utilise,
  # sinon on utilise la palette cols par défaut
  n <- nrow(class_map)

  if (all(is.na(class_map$color))) {
    cols <- default_palette[1:n]
    if (is.null(cols)) {
      cols <- c("white",rainbow(n-1))
    }
  } else {
    cols <- class_map$color
  }

  names(cols) <- class_map$label
  cols_soft <- make_soft_colors(cols)
  names(cols_soft) <- class_map$label

  list(hard = cols, soft = cols_soft)
}

