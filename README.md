
# lexico

Package R pour faciliter l’extraction et l’analyse lexicométrique de
contenus vidéo YouTube. Il combine des utilitaires de scraping (API
YouTube + sous-titres via `yt-dlp`) et des fonctions de
préparation/normalisation pour travailler ensuite avec *quanteda* ou
exporter/importer des corpus au format *IRaMuTeQ*.

## Installation

L’installation se fait directement via mon github. Aucune diffusion sur
CRAN n’est prévue à ce stade.

``` r
remotes::install_github("tdelc/lexico")
```

## Prérequis

- Une clé API YouTube Data (v3) pour interroger les playlists et vidéos.
- L’outil en ligne de commande
  [`yt-dlp`](https://github.com/yt-dlp/yt-dlp) disponible dans le `PATH`
  pour télécharger les sous-titres.
- R (avec les dépendances déclarées dans `DESCRIPTION`, notamment
  `quanteda`, `dplyr`, `httr`, `purrr`, `stringr`, `stopwords`).

Aucune donnée n’est distribuée avec le package : seules les fonctions
sont fournies, le téléchargement restant à la charge de
l’utilisateur·rice.

## Fonctionnalités principales

### Scraping YouTube

- `get_playlist_items(api_key, playlist_id, max_results = 100)`:
  récupère les métadonnées d’une playlist (titre, description, date de
  publication, position, etc.).
- `get_videos_details(api_key, video_ids)`: complète les informations
  des vidéos (statistiques, durée, langue, tags…).
- `download_subtitles(video_id, out_dir, yt_dlp = "yt-dlp", force_dl = FALSE)`:
  télécharge les sous-titres automatiques français d’une vidéo.
- `read_vtt_as_text(vtt_file)`: transforme un fichier `.vtt` en texte
  brut agrégé.
- `run_complete_extraction(api_key, path, suffix, playlist_id, max_videos)`:
  pipeline clé en main pour une playlist : récupération des infos/
  stats, téléchargement des sous-titres, consolidation en CSV.
- `parse_yt_duration(duration)`: convertit la durée YouTube (ex.
  `"PT25M31S"`) en secondes.

### Préparation et nettoyage

- `clean_df_text(vec_text, recode_words, stopwords, multiwords)`:
  normalise les textes (suppression de stopwords spécifiques, recodage,
  composition de multi-mots).
- Lexique et règles prêtes à l’emploi : `get_specific_stopwords()`,
  `get_specific_multiwords()`, `get_recode_words()`,
  `remove_apostrophe()`.

### Quanteda

- `corpus_to_tokens(corpus, recode_words, stopwords, multiwords)`:
  convertit un corpus `quanteda` en tokens propres (minuscules, retrait
  ponctuation, URLs, nombres, stopwords, recodage, multi-mots).
- `get_dictionary()`: dictionnaire thématique (immigration, sécurité,
  identité, etc.) prêt pour `quanteda::dfm_lookup`.

### IRaMuTeQ

- `export_to_iramuteq(df, meta_cols, text_col, output_file)`: crée un
  fichier texte structuré pour IRaMuTeQ à partir d’un data.frame
  (métadonnées en en-tête `****`).
- `import_from_iramuteq(file)`: lit un export IRaMuTeQ et reconstruit un
  data.frame (métadonnées + texte).

## Exemple de flux complet

``` r
api_key <- Sys.getenv("YOUTUBE_API_KEY")
playlist_id <- "PLxxxxxxxxxxxxxxxx"
base_dir <- "data"

# 1. Scraper les infos + sous-titres de la playlist
run_complete_extraction(
  api_key = api_key,
  path = base_dir,
  suffix = "ma_chaine",
  playlist_id = playlist_id,
  max_videos = 200
)

# 2. Charger les textes et nettoyer
subs_dir <- file.path(base_dir, "subs_ma_chaine")
vtt_files <- list.files(subs_dir, pattern = "\\.vtt$", full.names = TRUE)
text_df <- purrr::map_dfr(vtt_files, read_vtt_as_text)

# 3. Tokeniser puis créer une DFM avec dictionnaire thématique
corp <- quanteda::corpus(text_df, text_field = "text_clean")
toks <- corpus_to_tokens(corp)
dfm <- quanteda::dfm(toks)
quanteda::dfm_lookup(dfm, dictionary = get_dictionary())

# 4. Exporter vers IRaMuTeQ si besoin
export_to_iramuteq(text_df, meta_cols = "video_id", text_col = "text_clean", output_file = "iramuteq.txt")
```

## Bonnes pratiques

- Respectez les quotas de l’API YouTube et stockez votre clé dans une
  variable d’environnement.
- `download_subtitles()` accepte `force_dl = TRUE` pour forcer la mise à
  jour des sous-titres.
- Les multi-mots sont enregistrés avec `_` pour les conserver lors de
  l’analyse lexicométrique.

## Licence

Les codes sont publics sous licence gpl3; aucune donnée n’est distribuée
avec le package.
