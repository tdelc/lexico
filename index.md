# lexico

Lexico est un package R facilitant l’extraction et l’analyse
lexicométrique de contenus vidéo YouTube. Il combine des utilitaires de
scraping (API YouTube + sous-titres via `yt-dlp`) et des fonctions de
préparation/normalisation pour travailler ensuite avec *quanteda* ou
exporter/importer des corpus au format *IRaMuTeQ*.

## Installation

L’installation se fait directement via mon github. Aucune diffusion sur
CRAN n’est prévue à ce stade. Les fonctionnalités et noms des fonctions
pourront subir des modifications majeures au fil des utilisations.

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
- IRaMuTeQ, pour créer les classes de segments de texte.

Aucune donnée n’est distribuée avec le package : seules les fonctions
sont fournies, le téléchargement restant à la charge de
l’utilisateur·rice.

## Fonctionnalités principales

### Scraping YouTube

- `get_videos_info(api_key, playlist_id, max_results = 100)`: récupère
  les métadonnées d’une playlist (titre, description, date de
  publication, position, etc.).
- `get_videos_stats(api_key, video_ids)`: complète les informations des
  vidéos (statistiques, durée, langue, tags…).
- ``` get_videos_text``(``video_ids``, out_dir, yt_dlp = "yt-dlp", force_dl = FALSE) ```:
  télécharge les sous-titres automatiques français d’une vidéo et les
  prépare en base de données minutée.
- `run_complete_extraction(api_key, path, suffix, playlist_id, max_videos)`:
  pipeline clé en main pour une playlist : récupération des infos/
  stats/text, sauvegarde en CSV.

### IRaMuTeQ

- `export_to_iramuteq(df, meta_cols, text_col, output_file)`: crée un
  fichier texte structuré pour IRaMuTeQ à partir d’un data.frame
  (métadonnées en en-tête `****`).
- `import_from_iramuteq(file)`: lit un export IRaMuTeQ et reconstruit un
  data.frame (métadonnées + texte).

## Usage

Plusieurs vignettes sont rédigées pour aider à l’utilisation

- [Scraper des playlists
  YouTube](https://tdelc.github.io/lexico/articles/scraping.html) pour
  apprendre à extraire les vidéos, leurs sous-titres et mettre en format
  base de données les informations.

- [Préparer les données
  textuelles](https://tdelc.github.io/lexico/articles/prepa-data.html)
  où j’explique comment j’ai nettoyé le corpus.

- [Préparer et exploiter des corpus avec
  IRaMuTeQ](https://tdelc.github.io/lexico/articles/iramuteq.html) pour
  comprendre comment exploiter ce corpus avec IRaMuTeQ.

- [Analyser les textes avec
  Quanteda](https://tdelc.github.io/lexico/articles/quanteda.html) pour
  l’analyse du corpus avec le package R Quanteda

## Remarques

- Respectez les quotas de l’API YouTube et stockez votre clé dans une
  variable d’environnement.
- [`download_subtitles()`](https://tdelc.github.io/lexico/reference/download_subtitles.md)
  accepte `force_dl = TRUE` pour forcer la mise à jour des sous-titres.
- Les multi-mots sont enregistrés avec `_` pour les conserver lors de
  l’analyse lexicométrique.

## Licence

Les codes sont publics sous licence gpl3. Aucune donnée n’est distribuée
avec le package.
