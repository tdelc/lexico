library(shiny)
library(dplyr)
library(stringr)
library(glue)

df_segment <- readRDS(file="df_segment.rds")
palettes <- readRDS(file="palettes.rds")

# ---- Helpers ----
yt_url <- function(video_id,id_segment)
  glue("https://www.youtube.com/watch?v={video_id}&t={(id_segment-1)*60}")

safe_one <- function(x, default = "") {
  if (length(x) == 0 || is.na(x[1])) default else as.character(x[1])
}

trim_quote <- function(x, max_chars = 3800) {
  x <- str_squish(x)
  ifelse(nchar(x) > max_chars, paste0(substr(x, 1, max_chars), "…"), x)
}

# ---- Validate input data ----
stopifnot(exists("df_segment"))
stopifnot(all(c("classe_local","text","channel","video_id","date_video","title","description") %in% names(df_segment)))

df_base <- df_segment %>%
  filter(!is.na(classe_local), !is.na(text), !is.na(channel)) %>%
  mutate(
    classe_local = as.character(classe_local),
    channel = as.character(channel),
    text = str_squish(as.character(text))
  ) %>%
  filter(nchar(text) >= 80) %>%             # évite les micro-segments trop faciles/bizarres
  filter(!is.na(video_id) & nzchar(video_id))

all_categories <- sort(unique(df_base$classe_local))
all_channels   <- sort(unique(df_base$channel))

# ---- UI sparkle CSS (paillettes) ----
sparkle_css <- "
@keyframes pop {
  0% { transform: scale(0.95); opacity: 0.0; }
  20% { transform: scale(1.02); opacity: 1.0; }
  100% { transform: scale(1.0); opacity: 1.0; }
}
@keyframes confetti {
  0% { transform: translateY(-10px) rotate(0deg); opacity: 0; }
  10% { opacity: 1; }
  100% { transform: translateY(280px) rotate(720deg); opacity: 0; }
}
.sparkle-card { animation: pop 220ms ease-out; }
.confetti {
  position: fixed; top: -20px; left: 0; right: 0;
  pointer-events: none; z-index: 9999;
}
.confetti i{
  position: absolute; top: 0;
  width: 10px; height: 16px;
  border-radius: 3px;
  animation: confetti 900ms ease-in forwards;
  opacity: 0;
}
.badge-cat{
  display:inline-block; padding: 6px 10px; border-radius: 999px;
  font-weight: 600; font-size: 12px;
  border: 1px solid rgba(0,0,0,0.08);
}
.small-muted{ color: rgba(0,0,0,0.55); font-size: 12px; }
.quote{
  font-size: 16px; line-height: 1.35;
  padding: 12px 14px; border-radius: 14px;
  background: rgba(0,0,0,0.03);
  border: 1px solid rgba(0,0,0,0.06);
  white-space: pre-wrap;
}
.kpi{
  padding: 12px 14px; border-radius: 16px;
  background: rgba(0,0,0,0.03);
  border: 1px solid rgba(0,0,0,0.06);
}
.kpi .label{ font-size: 12px; opacity: 0.75; }
.kpi .value{ font-size: 22px; font-weight: 800; }
"

ui <- fluidPage(
  tags$head(tags$style(HTML(sparkle_css))),
  div(
    style = "max-width: 1200px; margin: 18px auto 40px auto;",
    fluidRow(
      column(4,
             h2("Qui a dit ça ?"),
             column(6,actionButton("new_round", "Nouveaux extraits", class = "btn-primary")),
             column(6,div(class="kpi",
                          div(class="value", textOutput("kpi_score", inline = TRUE))))
      ),
      column(8,
             radioButtons("cat", "Catégorie", choices = all_categories, selected = all_categories[sample(1:length(all_categories),1)],inline = T),
             checkboxInput("hard_mode", "Mode difficile : options = toutes les chaînes", value = FALSE),
             checkboxInput("avoid_repeat", "Éviter de revoir les mêmes vidéos", value = TRUE)
      )
    ),
    fluidRow(
      uiOutput("confetti"),
      uiOutput("round_badge_ui"),
      column(6,uiOutput("round_A_ui")),
      column(6,uiOutput("round_B_ui"))
    ),
    fluidRow(
      column(6,uiOutput("result_A_ui")),
      column(6,uiOutput("result_B_ui"))
    )
  )
)

server <- function(input, output, session) {

  rv <- reactiveValues(
    round = NULL,
    used_video_ids = character(),
    score = 0,
    total = 0,
    streak = 0,
    last_result = NULL,
    show_confetti = FALSE
  )

  # options proposées (soit toutes, soit restreint aux chaînes présentes dans la catégorie)
  choice_channels <- reactive({
    # d <- df_base %>% filter(classe_local == input$cat)
    # ch <- sort(unique(d$channel))
    ch <- sort(unique(rv$round$channel))
    if (isTRUE(input$hard_mode)) all_channels else ch
  })

  pick_round <- function() {
    d <- df_base %>% filter(classe_local == input$cat)

    # éviter répétitions (vidéos) si demandé
    if (isTRUE(input$avoid_repeat) && length(rv$used_video_ids) > 0) {
      d2 <- d %>% filter(!video_id %in% rv$used_video_ids)
      # si trop restrictif, on relâche
      if (nrow(d2) >= 200) d <- d2
    }

    # on veut 2 extraits, idéalement de 2 chaînes différentes
    # on fait quelques essais, puis fallback
    for (attempt in 1:20) {
      s <- d %>% slice_sample(n = 2, replace = FALSE)
      if (nrow(s) == 2 && length(unique(s$channel)) == 2) return(s)
    }
    d %>% slice_sample(n = 2, replace = FALSE)
  }

  new_round <- function() {
    s <- pick_round()
    rv$round <- s
    if (isTRUE(input$avoid_repeat)) {
      rv$used_video_ids <- union(rv$used_video_ids, s$video_id)
    }
    rv$last_result <- NULL
    rv$show_confetti <- FALSE
  }

  observeEvent(input$new_round, {
    new_round()
  }, ignoreInit = FALSE)  # lance une 1re manche automatiquement

  observeEvent(input$cat, {
    new_round()
  }, ignoreInit = FALSE)  # lance une 1re manche automatiquement

  observeEvent(input$reset, {
    rv$score <- 0
    rv$total <- 0
    rv$streak <- 0
    rv$used_video_ids <- character()
    rv$last_result <- NULL
    rv$show_confetti <- FALSE
    new_round()
  })

  output$kpi_score <- renderText({
    paste0(rv$score, " / ", rv$total)
  })

  output$kpi_more <- renderText({
    if (rv$total == 0) {
      "Streak : 0"
    } else {
      pct <- round(100 * rv$score / rv$total)
      glue("Réussite : {pct}% • Streak : {rv$streak}")
    }
  })

  # Badge catégorie coloré (palette)
  cat_badge <- reactive({
    col <- palettes$local$soft[[input$cat]]
    if (is.null(col)) col <- "#EFEFEF"
    # Si blanc, on ajoute un petit contour visible
    border <- if (toupper(col) == "#FFFFFF") "rgba(0,0,0,0.18)" else "rgba(0,0,0,0.08)"
    tags$span(
      class = "badge-cat",
      style = glue("background:{col}; border-color:{border};"),
      input$cat
    )
  })

  output$round_badge_ui <- renderUI({
    tagList(
      div(
        style = "display:flex; align-items:center; gap:10px; margin-bottom:10px;",
        cat_badge(),
        tags$span(class="small-muted", glue("{nrow(df_base %>% filter(classe_local == input$cat))} segments éligibles pour {length(unique(df_base %>% filter(classe_local == input$cat) %>% pull(video_id)))} vidéos."))
      )
    )
  })

  output$round_A_ui <- renderUI({
    req(rv$round)
    s <- rv$round
    ch_choices <- choice_channels()

    # Sélecteurs "réponse" pour 2 extraits
    tagList(
      div(class="sparkle-card",
          style = "padding: 14px 16px; border-radius: 18px; border: 1px solid rgba(0,0,0,0.08);",
          h4("Extrait A", style="margin-top:0;"),
          div(class="quote", trim_quote(s$text[1])),
          br(),
          radioButtons("guess_a", "Quelle chaîne ?", choices = ch_choices, selected = character(0), inline = TRUE)
      )
    )
  })

  output$round_B_ui <- renderUI({
    req(rv$round)
    s <- rv$round
    ch_choices <- choice_channels()

    # Sélecteurs "réponse" pour 2 extraits
    tagList(
      div(class="sparkle-card",
          style = "padding: 14px 16px; border-radius: 18px; border: 1px solid rgba(0,0,0,0.08);",
          h4("Extrait B", style="margin-top:0;"),
          div(class="quote", trim_quote(s$text[2])),
          br(),
          fluidRow(
            column(10,radioButtons("guess_b", "Quelle chaîne ?", choices = ch_choices, selected = character(0), inline = TRUE)),
            column(2,actionButton("submit", "Valider", class = "btn-success"))
          )
      )
    )
  })

  # Confetti UI (simple)
  output$confetti <- renderUI({
    if (!isTRUE(rv$show_confetti)) return(NULL)

    # 18 confettis placés aléatoirement
    xs <- sample(5:95, 18, replace = TRUE)
    cols <- sample(unname(palettes$local$soft), 18, replace = TRUE)

    tags$div(
      class = "confetti",
      lapply(seq_along(xs), function(i) {
        tags$i(style = glue("left:{xs[i]}%; background:{cols[i]}; animation-delay:{runif(1,0,0.15)}s;"))
      })
    )
  })

  observeEvent(input$submit, {
    req(rv$round)
    # Si l'utilisateur n'a pas répondu aux 2, on ne fait rien (conservateur)
    if (is.null(input$guess_a) || is.null(input$guess_b) || input$guess_a == "" || input$guess_b == "") {
      rv$last_result <- list(
        ok = FALSE, msg = "Choisis une chaîne pour A ET pour B 🙂",
        details = NULL, bonus = FALSE
      )
      rv$show_confetti <- FALSE
      return()
    }

    s <- rv$round
    truth_a <- s$channel[1]
    truth_b <- s$channel[2]

    ok_a <- identical(input$guess_a, truth_a)
    ok_b <- identical(input$guess_b, truth_b)

    gained <- sum(ok_a, ok_b)
    rv$score <- rv$score + gained
    rv$total <- rv$total + 2

    bonus <- (gained == 2)
    if (bonus) {
      rv$streak <- rv$streak + 1
      rv$show_confetti <- TRUE
    } else {
      rv$streak <- 0
      rv$show_confetti <- FALSE
    }

    msg <- if (bonus) "💥 Perfect ! 2/2 — paillettes activées ✨"
    else if (gained == 1) "👍 Pas mal : 1/2 — tu chauffes."
    else "🥶 0/2 — c’est plus dur qu’on croit."

    details <- tibble::tibble(
      Extrait = c("A", "B"),
      Proposition = c(input$guess_a, input$guess_b),
      Réponse = c(truth_a, truth_b),
      Date = as.character(c(s$date_video[1], s$date_video[2])),
      Titre = c(s$title[1], s$title[2]),
      Description = c(s$description[1], s$description[2]),
      Lien = c(yt_url(s$video_id[1],s$id_segment[1]),
               yt_url(s$video_id[2],s$id_segment[2]))
    )

    rv$last_result <- list(ok = TRUE, msg = msg, details = details, bonus = bonus)
  })

  output$result_A_ui <- renderUI({
    if (is.null(rv$last_result)) return(NULL)

    res <- rv$last_result
    if (!isTRUE(res$ok)) {
      return(div(
        style="padding:12px 14px; border-radius: 16px; border: 1px solid rgba(0,0,0,0.08); background: rgba(255,200,0,0.12);",
        res$msg
      ))
    }

    det <- res$details
    i <- 1
    ok <- det$Proposition[i] == det$Réponse[i]

    # table maison, plus lisible qu'un DT ici
    tagList(
      div(
        class="sparkle-card",
        style = glue("padding: 14px 16px; border-radius: 18px; border: 1px solid rgba(0,0,0,0.08); margin-bottom:10px; background: {if (ok) 'rgba(0,255,150,0.08)' else 'rgba(255,80,80,0.08)'};"),
        h4(glue("Solution {det$Extrait[i]} : {det$Réponse[i]} {if (ok) '✅' else '❌'}"), style="margin-top:0;"),
        div(class="small-muted", glue("Date : {safe_one(det$Date[i])}")),
        div(style="margin-top:6px; font-weight:700;", safe_one(det$Titre[i], "(sans titre)")),
        div(class="small-muted", style="margin-top:4px;", safe_one(det$Description[i], "(sans description)")),
        div(style="margin-top:8px;",
            tags$a("🔗 Ouvrir sur YouTube", href = det$Lien[i], target = "_blank")
        )
      )
    )
  })

  output$result_B_ui <- renderUI({
    if (is.null(rv$last_result)) return(NULL)

    res <- rv$last_result
    # if (!isTRUE(res$ok)) {
    #   return(div(
    #     style="padding:12px 14px; border-radius: 16px; border: 1px solid rgba(0,0,0,0.08); background: rgba(255,200,0,0.12);",
    #     res$msg
    #   ))
    # }

    det <- res$details
    i <- 2
    ok <- det$Proposition[i] == det$Réponse[i]

    # table maison, plus lisible qu'un DT ici
    tagList(
      div(
        class="sparkle-card",
        style = glue("padding: 14px 16px; border-radius: 18px; border: 1px solid rgba(0,0,0,0.08); margin-bottom:10px; background: {if (ok) 'rgba(0,255,150,0.08)' else 'rgba(255,80,80,0.08)'};"),
        h4(glue("Solution {det$Extrait[i]} : {det$Réponse[i]} {if (ok) '✅' else '❌'}"), style="margin-top:0;"),
        div(class="small-muted", glue("Date : {safe_one(det$Date[i])}")),
        div(style="margin-top:6px; font-weight:700;", safe_one(det$Titre[i], "(sans titre)")),
        div(class="small-muted", style="margin-top:4px;", safe_one(det$Description[i], "(sans description)")),
        div(style="margin-top:8px;",
            tags$a("🔗 Ouvrir sur YouTube", href = det$Lien[i], target = "_blank")
        )
      )
    )
  })

}

shinyApp(ui, server)
