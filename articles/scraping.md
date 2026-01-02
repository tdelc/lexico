# Scraper des playlists YouTube

Cette vignette décrit comment récupérer des vidéos et des sous-titres
YouTube avant de les transformer en tableaux exploitables avec le
package **lexico**.

## Pré-requis

- Une clé API YouTube (`YT_API_KEY`).
- L’outil en ligne de commande `yt-dlp`, indiqué via `yt_dlp_path`.
- Un dossier où stocker les CSV et les sous-titres téléchargés.

``` r
library(lexico)
library(dplyr)

yt_dlp_path  <- Sys.getenv("YT_DLP_PATH")
api_key <- Sys.getenv("YT_API_KEY")

workdir <- file.path(tempdir(),"data")
dir.create(workdir, showWarnings = FALSE)
```

## Récupérer les métadonnées d’une playlist

La fonction `get_videos_info` permet de récupérer la liste des vidéos.
Voici un exemple avec la playlist ’Face-à-Face” créée par la chaîne
d’information en continu BFMTV. En cliquant sur la playlist, on obtient
l’url suivante :
<https://www.youtube.com/watch?v=Ul5HWIJLxzs&list=PL-qBKb-rfbhhmFo0yCUq2KyhVKHpCX0aG>.
On extrait l’identifiant de la playlist après l’argument `list` de
l’url.

``` r
playlist_id <- "PL-qBKb-rfbhhmFo0yCUq2KyhVKHpCX0aG"

df_info <- get_videos_info(api_key, playlist_id, max_results = 20)
```

Cette première base de données nous donne la liste des vidéos avec leur
identifiant (`video_id`), ainsi que le titre, la description, le nom de
la chaîne YouTube et la date de publication.

``` r
head(df_info)
#>      video_id                        playlist_id          publishedAt
#> 1 6IOUEJN6GRI PL-qBKb-rfbhhmFo0yCUq2KyhVKHpCX0aG 2025-12-12T13:20:02Z
#> 2 Ab_5e7jEoag PL-qBKb-rfbhhmFo0yCUq2KyhVKHpCX0aG 2025-12-16T09:38:02Z
#> 3 QA84_nDOREk PL-qBKb-rfbhhmFo0yCUq2KyhVKHpCX0aG 2025-12-15T13:53:25Z
#> 4 p6Pzs3iGwNk PL-qBKb-rfbhhmFo0yCUq2KyhVKHpCX0aG 2025-12-10T10:44:11Z
#> 5 mjdbw7M0LRI PL-qBKb-rfbhhmFo0yCUq2KyhVKHpCX0aG 2025-12-10T10:44:11Z
#>                                                                                               title
#> 1               Narcotrafic, fouilles XXL en prison...L'interview en intégralité de Gérald Darmanin
#> 2 Mercosur, petits colis... L'interview en intégralité de Dominique Schelcher, PDG de Coopérative U
#> 3                Attaque à Sydney, colère agricole... L'interview en intégralité de Marion Maréchal
#> 4   Échanges avec Nicolas Sarkozy, budget, maisons closes… L'interview intégrale de Sébastien Chenu
#> 5         Budget, hôpitaux, propos de Brigitte Macron… L'interview intégrale d'Amélie de Montchalin
#>   channelTitle
#> 1        BFMTV
#> 2        BFMTV
#> 3        BFMTV
#> 4        BFMTV
#> 5        BFMTV
#>                                                                                                                                                                                                                                                                                                                                         description
#> 1                                                                                                                           Gérald Darmanin, ministre de la Justice, était l'invité du Face à Face sur RMC et BFMTV ce vendredi 12 décembre. Il est notamment revenu sur les fouilles XXL en prison, les remises de peine ou encore le narcotrafic.
#> 2                                                                                                                                                                                                                                   Dominique Schelcher, PDG de Coopérative U, était l'invité du Face à Face sur BFMTV et RMC ce mardi 16 décembre.
#> 3                                                                                                                                                                                                    Marion Maréchal, députée européenne et présidente d'Identité-Libertés, était l'invitée d'Apolline de Malherbe dans le "Face à Face" sur BFMTV.
#> 4 Sébastien Chenu, député RN du Nord et vice-président de l'Assemblée nationale, était l'invité du Face à face ce mercredi 10 décembre. Il est notamment revenu sur ses échanges avec Nicolas Sarkozy lors de sa détention, mais aussi sur le vote du budget à l'Assemblée nationale, ou encore la proposition du RN de rouvrir les maisons closes.
#> 5                                                                                                                                                                               Amélie de Montchalain, ministre des Comptes publics, était l'invitée du Face ce mardi 9 décembre avant le vote du budget à l'Assemblée nationale dans l'après-midi.
#>   position
#> 1       NA
#> 2       NA
#> 3       NA
#> 4       NA
#> 5       NA
```

A partir de cette liste d’identifiants, la fonction `get_videos_stat`
extrait l’ensemble des statistiques des vidéos.

``` r
df_stat <- get_videos_stat(api_key, df_info$video_id)
```

Cette seconde base de données inclue le nombre de vues, de likes et de
commentaires, mais aussi les tags, la description et la langue de la
vidéo.

``` r
head(df_stat)
#>      video_id          publishedAt
#> 1 Ab_5e7jEoag 2025-12-16T08:04:49Z
#> 2 QA84_nDOREk 2025-12-15T08:02:35Z
#> 3 6IOUEJN6GRI 2025-12-12T08:15:22Z
#> 4 p6Pzs3iGwNk 2025-12-10T07:59:02Z
#> 5 mjdbw7M0LRI 2025-12-09T08:05:01Z
#>                                                                                               title
#> 1 Mercosur, petits colis... L'interview en intégralité de Dominique Schelcher, PDG de Coopérative U
#> 2                Attaque à Sydney, colère agricole... L'interview en intégralité de Marion Maréchal
#> 3               Narcotrafic, fouilles XXL en prison...L'interview en intégralité de Gérald Darmanin
#> 4   Échanges avec Nicolas Sarkozy, budget, maisons closes… L'interview intégrale de Sébastien Chenu
#> 5         Budget, hôpitaux, propos de Brigitte Macron… L'interview intégrale d'Amélie de Montchalin
#>                                                                                                                                                                                                                                                                                                                                         description
#> 1                                                                                                                                                                                                                                   Dominique Schelcher, PDG de Coopérative U, était l'invité du Face à Face sur BFMTV et RMC ce mardi 16 décembre.
#> 2                                                                                                                                                                                                    Marion Maréchal, députée européenne et présidente d'Identité-Libertés, était l'invitée d'Apolline de Malherbe dans le "Face à Face" sur BFMTV.
#> 3                                                                                                                           Gérald Darmanin, ministre de la Justice, était l'invité du Face à Face sur RMC et BFMTV ce vendredi 12 décembre. Il est notamment revenu sur les fouilles XXL en prison, les remises de peine ou encore le narcotrafic.
#> 4 Sébastien Chenu, député RN du Nord et vice-président de l'Assemblée nationale, était l'invité du Face à face ce mercredi 10 décembre. Il est notamment revenu sur ses échanges avec Nicolas Sarkozy lors de sa détention, mais aussi sur le vote du budget à l'Assemblée nationale, ou encore la proposition du RN de rouvrir les maisons closes.
#> 5                                                                                                                                                                               Amélie de Montchalain, ministre des Comptes publics, était l'invitée du Face ce mardi 9 décembre avant le vote du budget à l'Assemblée nationale dans l'après-midi.
#>                  channelId channelTitle categoryId Language AudioLanguage
#> 1 UCXwDLMDV86ldKoFVc_g8P0g        BFMTV         25       fr            fr
#> 2 UCXwDLMDV86ldKoFVc_g8P0g        BFMTV         25       fr            fr
#> 3 UCXwDLMDV86ldKoFVc_g8P0g        BFMTV         25       fr            fr
#> 4 UCXwDLMDV86ldKoFVc_g8P0g        BFMTV         25       fr            fr
#> 5 UCXwDLMDV86ldKoFVc_g8P0g        BFMTV         25       fr            fr
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        tags
#> 1 Jean-Pierre Farandou|bfmactu|face à face|politique|Dominique Schelcher|bfmactu|faceàface|économie|bfmactu|marion maréchal|politique|Gérald Darmanin|Justice|bfmactu|peine|politique|prison|RN|assemblée nationale|bfmactu|budget|député|extrême droite|maisons closes|nicolas sarkozy|nord|politique|rassemblement national|sébastien chenu|Amélie de Montchalin|bfmactu|budget|hôpitaux|ministre des comptes publics|poltique|santé|ssemblée national|sécurité socialed|votea|éficit|49.3|assemblée nationale|baisse de la natalité|bfmactu|bruno retailleau|budget 2026|emmanuel macron|face-à-face|gouvernement|horizons|labellisation|maud bregeon|médias|politique|sébastien lecornu|édouard philippe|RN|agression jordan bardella|assemblée nationale|bfmactu|budget 2026|face-à-face|immigration|impôts|jordan bardella|marine le pen|politique|pouvoir d’achat|présidentielle 2027|retraites|sébastien lecornu|yaël braun-pivet|augmentation|bfmactu|cacao|carburant|chocolat|face-à-face|inflation|michel-édouard leclerc|négociations commerciales|pouvoir d'achat|prix|société|viande|économie|Face à Face|Flavie Rault|bfmactu|faceàface|syndicat national des directeurs pénitentiaires|Vincent Jeanbrun|bfmactu|faceàface|mehdi kessaci|ministre|violences conjugales|voile|bfmactu|chef d'état major des armées|emmanuel macron|guerre|lfi|manuel bompard|paix|politique|service militaire|armée|bfmactu|défense|face à face|guerre en ukraine|kiev|moscou|police-justice|russie|ukraine|vladimir poutine|volodymyr zelensky|amine kessaci|bfmactu|drogue|face à face|narcobanditisme|narcotrafic|police-justice|Medhi Kessaci|bfmactu|face à face|police-justice|Cannes|bfmactu|collectivités|congrès des maires|david lisnard|face-à-face|local|maire|politique|sécurité|élus|2027|bfmactu|budget 2026|europe|face-à-face|hôpitaux|impots|logement|patrick sébastien|people|politique|société|taxes|13-Novembre|Laurent Nunez|allemagne|alégrie|bfmactu|boualem sansal|face-à-face|gouvernement|libération|menace|police|politique|terrorisme|bfmactu|bruno lemaire|budget 2026|emmanuel macron|face-à-face|finances publiques|lettre|lfi|politique|prime de Noël|réforme des retraites|éric coquerel|bfmactu|centre ville|commerce|entreprises|made in france|ministre|serge papin|shein|économie|assemblée nationale|bfmactu|budget|droite|les républicains|lfi|lr|politique|primaire|rn|shein|xavier bertrand|bfmactu|bhv|frédéric merlin|magasin|mode|ouverture|prêt à porter|shein|ultra fast fashion|v^tement|bfmactu|entrisme|gilles kepel|islam|moyen oriant|municipales|radicalisation|spécialiste|sécurité|élections|assemblée nationale|bfmactu|budget|découverts bancaires|gestes|justice fiscale|mesures|ministre de l'économie|politique|polémique|roland lescure|shein|vote|bfmactu|faceàface|france algérie|olivier faure|taxe zucman|Bfmactu|face à face|gouvernement|maud bregeon|politique|2027|RN|Rassemblement national|bfmactu|budget 2026|face-à-face|gouvernement|immigration|marine le pen|politique|présidentielle|reconquête|union des droites|éric ciotti|éric zemmour|Face à Face|Peimane Ghaleh-Marzban|bfmactu|police-justice|bfmactu|budget|cambriolage|jean-philippe tanguy|louvre|marine le pen|musée du louvre|nicolas sarkozy|politique|rassemblement national|retraites|rn|réforme des retraites|bfmactu|budget|emmanuel macron|françois ruffin|politique|retraites|réforme des retraites|sébastien lecornu|bfmactu|face à face|nicolas sarkozy|police-justice|politique|prison de la santé|bfmactu|faceàface|françois-xavier bellamy|les républicains|politique|bfmactu|censure|eric ciotti|faceàface|gouvernement|politique|udr|bfmactu|censure|faceàface|olivier faure|politique|ps|sébastien lecornu|bfmactu|gouvernement|jean-louis borloo|lecornu|politique|udi|bfmsocial|emmanuel macron|face à face|gouvernement|lfi|mathilde panot|politique|sébastien lecornu|bfmactu|face à face|gouvernement|politique|rassemblement national|rn|sébastien lecornu|bfmactu|budget 2026|fabien roussel|nicolas sarkozy|politique|pouvoir d'achat|sébastien lecornu|bfmactu|budget|cgt|gouvernement|grèves|mobilisation|politique|sophie binet|syndicats|bfmactu|condamnation|face-à-face|jets de peinture|justice|laure beccuau|magistrate|magistrats|nicolas sarkozy|paris|politique|têtes de cochon|PS|bfmsocial|olivier faure|parti socialiste|politique|RN|bfmactu|condamnation|face-à-face|fiscalité|justice|marine le pen|nicolas sarkozy|politique|sébastien chenu|taxe zucman|bfmactu|budget 2026|dominique de villepin|drone|emmanuel macron|europe|face-à-face|gouvernement|guerre en ukraine|international|mouamman kadhafi|nicolas sarkozy|police-justice|politique|procès libyen|sébastien lecornu|taxe zucman|bfmactu|chine|entreprises|face-à-face|france|françois ruffin|industrie|picardie debout|politique|syndicats|sébastien lecornu|taxes sur les riches|benjamin netanyahu|bernard-henri lévy|bfmactu|face-à-face|gaza|international|israël|politique|reconnaissance de la Palestine|russie|société|valdimir poutine|Reconquête|bfmactu|israel|palestine|politique|sarah knafo|taxe|zucman|bfmactu|bruno retailleau|faceàface|gouvernement|grève|politique|sécurité|BFMTV|Croissance économique|FNSEA|Inflation|MEDEF|Michel-Édouard Leclerc|Pouvoir d'achat|Taxation|Transformation numérique|bfmactu|faceàface|Économie française|économie|argent|bfmsocial|dette|thomas picketty|économie|économiste|bfmactu|faceàface|gérard larcher|politique
#> 2 Jean-Pierre Farandou|bfmactu|face à face|politique|Dominique Schelcher|bfmactu|faceàface|économie|bfmactu|marion maréchal|politique|Gérald Darmanin|Justice|bfmactu|peine|politique|prison|RN|assemblée nationale|bfmactu|budget|député|extrême droite|maisons closes|nicolas sarkozy|nord|politique|rassemblement national|sébastien chenu|Amélie de Montchalin|bfmactu|budget|hôpitaux|ministre des comptes publics|poltique|santé|ssemblée national|sécurité socialed|votea|éficit|49.3|assemblée nationale|baisse de la natalité|bfmactu|bruno retailleau|budget 2026|emmanuel macron|face-à-face|gouvernement|horizons|labellisation|maud bregeon|médias|politique|sébastien lecornu|édouard philippe|RN|agression jordan bardella|assemblée nationale|bfmactu|budget 2026|face-à-face|immigration|impôts|jordan bardella|marine le pen|politique|pouvoir d’achat|présidentielle 2027|retraites|sébastien lecornu|yaël braun-pivet|augmentation|bfmactu|cacao|carburant|chocolat|face-à-face|inflation|michel-édouard leclerc|négociations commerciales|pouvoir d'achat|prix|société|viande|économie|Face à Face|Flavie Rault|bfmactu|faceàface|syndicat national des directeurs pénitentiaires|Vincent Jeanbrun|bfmactu|faceàface|mehdi kessaci|ministre|violences conjugales|voile|bfmactu|chef d'état major des armées|emmanuel macron|guerre|lfi|manuel bompard|paix|politique|service militaire|armée|bfmactu|défense|face à face|guerre en ukraine|kiev|moscou|police-justice|russie|ukraine|vladimir poutine|volodymyr zelensky|amine kessaci|bfmactu|drogue|face à face|narcobanditisme|narcotrafic|police-justice|Medhi Kessaci|bfmactu|face à face|police-justice|Cannes|bfmactu|collectivités|congrès des maires|david lisnard|face-à-face|local|maire|politique|sécurité|élus|2027|bfmactu|budget 2026|europe|face-à-face|hôpitaux|impots|logement|patrick sébastien|people|politique|société|taxes|13-Novembre|Laurent Nunez|allemagne|alégrie|bfmactu|boualem sansal|face-à-face|gouvernement|libération|menace|police|politique|terrorisme|bfmactu|bruno lemaire|budget 2026|emmanuel macron|face-à-face|finances publiques|lettre|lfi|politique|prime de Noël|réforme des retraites|éric coquerel|bfmactu|centre ville|commerce|entreprises|made in france|ministre|serge papin|shein|économie|assemblée nationale|bfmactu|budget|droite|les républicains|lfi|lr|politique|primaire|rn|shein|xavier bertrand|bfmactu|bhv|frédéric merlin|magasin|mode|ouverture|prêt à porter|shein|ultra fast fashion|v^tement|bfmactu|entrisme|gilles kepel|islam|moyen oriant|municipales|radicalisation|spécialiste|sécurité|élections|assemblée nationale|bfmactu|budget|découverts bancaires|gestes|justice fiscale|mesures|ministre de l'économie|politique|polémique|roland lescure|shein|vote|bfmactu|faceàface|france algérie|olivier faure|taxe zucman|Bfmactu|face à face|gouvernement|maud bregeon|politique|2027|RN|Rassemblement national|bfmactu|budget 2026|face-à-face|gouvernement|immigration|marine le pen|politique|présidentielle|reconquête|union des droites|éric ciotti|éric zemmour|Face à Face|Peimane Ghaleh-Marzban|bfmactu|police-justice|bfmactu|budget|cambriolage|jean-philippe tanguy|louvre|marine le pen|musée du louvre|nicolas sarkozy|politique|rassemblement national|retraites|rn|réforme des retraites|bfmactu|budget|emmanuel macron|françois ruffin|politique|retraites|réforme des retraites|sébastien lecornu|bfmactu|face à face|nicolas sarkozy|police-justice|politique|prison de la santé|bfmactu|faceàface|françois-xavier bellamy|les républicains|politique|bfmactu|censure|eric ciotti|faceàface|gouvernement|politique|udr|bfmactu|censure|faceàface|olivier faure|politique|ps|sébastien lecornu|bfmactu|gouvernement|jean-louis borloo|lecornu|politique|udi|bfmsocial|emmanuel macron|face à face|gouvernement|lfi|mathilde panot|politique|sébastien lecornu|bfmactu|face à face|gouvernement|politique|rassemblement national|rn|sébastien lecornu|bfmactu|budget 2026|fabien roussel|nicolas sarkozy|politique|pouvoir d'achat|sébastien lecornu|bfmactu|budget|cgt|gouvernement|grèves|mobilisation|politique|sophie binet|syndicats|bfmactu|condamnation|face-à-face|jets de peinture|justice|laure beccuau|magistrate|magistrats|nicolas sarkozy|paris|politique|têtes de cochon|PS|bfmsocial|olivier faure|parti socialiste|politique|RN|bfmactu|condamnation|face-à-face|fiscalité|justice|marine le pen|nicolas sarkozy|politique|sébastien chenu|taxe zucman|bfmactu|budget 2026|dominique de villepin|drone|emmanuel macron|europe|face-à-face|gouvernement|guerre en ukraine|international|mouamman kadhafi|nicolas sarkozy|police-justice|politique|procès libyen|sébastien lecornu|taxe zucman|bfmactu|chine|entreprises|face-à-face|france|françois ruffin|industrie|picardie debout|politique|syndicats|sébastien lecornu|taxes sur les riches|benjamin netanyahu|bernard-henri lévy|bfmactu|face-à-face|gaza|international|israël|politique|reconnaissance de la Palestine|russie|société|valdimir poutine|Reconquête|bfmactu|israel|palestine|politique|sarah knafo|taxe|zucman|bfmactu|bruno retailleau|faceàface|gouvernement|grève|politique|sécurité|BFMTV|Croissance économique|FNSEA|Inflation|MEDEF|Michel-Édouard Leclerc|Pouvoir d'achat|Taxation|Transformation numérique|bfmactu|faceàface|Économie française|économie|argent|bfmsocial|dette|thomas picketty|économie|économiste|bfmactu|faceàface|gérard larcher|politique
#> 3 Jean-Pierre Farandou|bfmactu|face à face|politique|Dominique Schelcher|bfmactu|faceàface|économie|bfmactu|marion maréchal|politique|Gérald Darmanin|Justice|bfmactu|peine|politique|prison|RN|assemblée nationale|bfmactu|budget|député|extrême droite|maisons closes|nicolas sarkozy|nord|politique|rassemblement national|sébastien chenu|Amélie de Montchalin|bfmactu|budget|hôpitaux|ministre des comptes publics|poltique|santé|ssemblée national|sécurité socialed|votea|éficit|49.3|assemblée nationale|baisse de la natalité|bfmactu|bruno retailleau|budget 2026|emmanuel macron|face-à-face|gouvernement|horizons|labellisation|maud bregeon|médias|politique|sébastien lecornu|édouard philippe|RN|agression jordan bardella|assemblée nationale|bfmactu|budget 2026|face-à-face|immigration|impôts|jordan bardella|marine le pen|politique|pouvoir d’achat|présidentielle 2027|retraites|sébastien lecornu|yaël braun-pivet|augmentation|bfmactu|cacao|carburant|chocolat|face-à-face|inflation|michel-édouard leclerc|négociations commerciales|pouvoir d'achat|prix|société|viande|économie|Face à Face|Flavie Rault|bfmactu|faceàface|syndicat national des directeurs pénitentiaires|Vincent Jeanbrun|bfmactu|faceàface|mehdi kessaci|ministre|violences conjugales|voile|bfmactu|chef d'état major des armées|emmanuel macron|guerre|lfi|manuel bompard|paix|politique|service militaire|armée|bfmactu|défense|face à face|guerre en ukraine|kiev|moscou|police-justice|russie|ukraine|vladimir poutine|volodymyr zelensky|amine kessaci|bfmactu|drogue|face à face|narcobanditisme|narcotrafic|police-justice|Medhi Kessaci|bfmactu|face à face|police-justice|Cannes|bfmactu|collectivités|congrès des maires|david lisnard|face-à-face|local|maire|politique|sécurité|élus|2027|bfmactu|budget 2026|europe|face-à-face|hôpitaux|impots|logement|patrick sébastien|people|politique|société|taxes|13-Novembre|Laurent Nunez|allemagne|alégrie|bfmactu|boualem sansal|face-à-face|gouvernement|libération|menace|police|politique|terrorisme|bfmactu|bruno lemaire|budget 2026|emmanuel macron|face-à-face|finances publiques|lettre|lfi|politique|prime de Noël|réforme des retraites|éric coquerel|bfmactu|centre ville|commerce|entreprises|made in france|ministre|serge papin|shein|économie|assemblée nationale|bfmactu|budget|droite|les républicains|lfi|lr|politique|primaire|rn|shein|xavier bertrand|bfmactu|bhv|frédéric merlin|magasin|mode|ouverture|prêt à porter|shein|ultra fast fashion|v^tement|bfmactu|entrisme|gilles kepel|islam|moyen oriant|municipales|radicalisation|spécialiste|sécurité|élections|assemblée nationale|bfmactu|budget|découverts bancaires|gestes|justice fiscale|mesures|ministre de l'économie|politique|polémique|roland lescure|shein|vote|bfmactu|faceàface|france algérie|olivier faure|taxe zucman|Bfmactu|face à face|gouvernement|maud bregeon|politique|2027|RN|Rassemblement national|bfmactu|budget 2026|face-à-face|gouvernement|immigration|marine le pen|politique|présidentielle|reconquête|union des droites|éric ciotti|éric zemmour|Face à Face|Peimane Ghaleh-Marzban|bfmactu|police-justice|bfmactu|budget|cambriolage|jean-philippe tanguy|louvre|marine le pen|musée du louvre|nicolas sarkozy|politique|rassemblement national|retraites|rn|réforme des retraites|bfmactu|budget|emmanuel macron|françois ruffin|politique|retraites|réforme des retraites|sébastien lecornu|bfmactu|face à face|nicolas sarkozy|police-justice|politique|prison de la santé|bfmactu|faceàface|françois-xavier bellamy|les républicains|politique|bfmactu|censure|eric ciotti|faceàface|gouvernement|politique|udr|bfmactu|censure|faceàface|olivier faure|politique|ps|sébastien lecornu|bfmactu|gouvernement|jean-louis borloo|lecornu|politique|udi|bfmsocial|emmanuel macron|face à face|gouvernement|lfi|mathilde panot|politique|sébastien lecornu|bfmactu|face à face|gouvernement|politique|rassemblement national|rn|sébastien lecornu|bfmactu|budget 2026|fabien roussel|nicolas sarkozy|politique|pouvoir d'achat|sébastien lecornu|bfmactu|budget|cgt|gouvernement|grèves|mobilisation|politique|sophie binet|syndicats|bfmactu|condamnation|face-à-face|jets de peinture|justice|laure beccuau|magistrate|magistrats|nicolas sarkozy|paris|politique|têtes de cochon|PS|bfmsocial|olivier faure|parti socialiste|politique|RN|bfmactu|condamnation|face-à-face|fiscalité|justice|marine le pen|nicolas sarkozy|politique|sébastien chenu|taxe zucman|bfmactu|budget 2026|dominique de villepin|drone|emmanuel macron|europe|face-à-face|gouvernement|guerre en ukraine|international|mouamman kadhafi|nicolas sarkozy|police-justice|politique|procès libyen|sébastien lecornu|taxe zucman|bfmactu|chine|entreprises|face-à-face|france|françois ruffin|industrie|picardie debout|politique|syndicats|sébastien lecornu|taxes sur les riches|benjamin netanyahu|bernard-henri lévy|bfmactu|face-à-face|gaza|international|israël|politique|reconnaissance de la Palestine|russie|société|valdimir poutine|Reconquête|bfmactu|israel|palestine|politique|sarah knafo|taxe|zucman|bfmactu|bruno retailleau|faceàface|gouvernement|grève|politique|sécurité|BFMTV|Croissance économique|FNSEA|Inflation|MEDEF|Michel-Édouard Leclerc|Pouvoir d'achat|Taxation|Transformation numérique|bfmactu|faceàface|Économie française|économie|argent|bfmsocial|dette|thomas picketty|économie|économiste|bfmactu|faceàface|gérard larcher|politique
#> 4 Jean-Pierre Farandou|bfmactu|face à face|politique|Dominique Schelcher|bfmactu|faceàface|économie|bfmactu|marion maréchal|politique|Gérald Darmanin|Justice|bfmactu|peine|politique|prison|RN|assemblée nationale|bfmactu|budget|député|extrême droite|maisons closes|nicolas sarkozy|nord|politique|rassemblement national|sébastien chenu|Amélie de Montchalin|bfmactu|budget|hôpitaux|ministre des comptes publics|poltique|santé|ssemblée national|sécurité socialed|votea|éficit|49.3|assemblée nationale|baisse de la natalité|bfmactu|bruno retailleau|budget 2026|emmanuel macron|face-à-face|gouvernement|horizons|labellisation|maud bregeon|médias|politique|sébastien lecornu|édouard philippe|RN|agression jordan bardella|assemblée nationale|bfmactu|budget 2026|face-à-face|immigration|impôts|jordan bardella|marine le pen|politique|pouvoir d’achat|présidentielle 2027|retraites|sébastien lecornu|yaël braun-pivet|augmentation|bfmactu|cacao|carburant|chocolat|face-à-face|inflation|michel-édouard leclerc|négociations commerciales|pouvoir d'achat|prix|société|viande|économie|Face à Face|Flavie Rault|bfmactu|faceàface|syndicat national des directeurs pénitentiaires|Vincent Jeanbrun|bfmactu|faceàface|mehdi kessaci|ministre|violences conjugales|voile|bfmactu|chef d'état major des armées|emmanuel macron|guerre|lfi|manuel bompard|paix|politique|service militaire|armée|bfmactu|défense|face à face|guerre en ukraine|kiev|moscou|police-justice|russie|ukraine|vladimir poutine|volodymyr zelensky|amine kessaci|bfmactu|drogue|face à face|narcobanditisme|narcotrafic|police-justice|Medhi Kessaci|bfmactu|face à face|police-justice|Cannes|bfmactu|collectivités|congrès des maires|david lisnard|face-à-face|local|maire|politique|sécurité|élus|2027|bfmactu|budget 2026|europe|face-à-face|hôpitaux|impots|logement|patrick sébastien|people|politique|société|taxes|13-Novembre|Laurent Nunez|allemagne|alégrie|bfmactu|boualem sansal|face-à-face|gouvernement|libération|menace|police|politique|terrorisme|bfmactu|bruno lemaire|budget 2026|emmanuel macron|face-à-face|finances publiques|lettre|lfi|politique|prime de Noël|réforme des retraites|éric coquerel|bfmactu|centre ville|commerce|entreprises|made in france|ministre|serge papin|shein|économie|assemblée nationale|bfmactu|budget|droite|les républicains|lfi|lr|politique|primaire|rn|shein|xavier bertrand|bfmactu|bhv|frédéric merlin|magasin|mode|ouverture|prêt à porter|shein|ultra fast fashion|v^tement|bfmactu|entrisme|gilles kepel|islam|moyen oriant|municipales|radicalisation|spécialiste|sécurité|élections|assemblée nationale|bfmactu|budget|découverts bancaires|gestes|justice fiscale|mesures|ministre de l'économie|politique|polémique|roland lescure|shein|vote|bfmactu|faceàface|france algérie|olivier faure|taxe zucman|Bfmactu|face à face|gouvernement|maud bregeon|politique|2027|RN|Rassemblement national|bfmactu|budget 2026|face-à-face|gouvernement|immigration|marine le pen|politique|présidentielle|reconquête|union des droites|éric ciotti|éric zemmour|Face à Face|Peimane Ghaleh-Marzban|bfmactu|police-justice|bfmactu|budget|cambriolage|jean-philippe tanguy|louvre|marine le pen|musée du louvre|nicolas sarkozy|politique|rassemblement national|retraites|rn|réforme des retraites|bfmactu|budget|emmanuel macron|françois ruffin|politique|retraites|réforme des retraites|sébastien lecornu|bfmactu|face à face|nicolas sarkozy|police-justice|politique|prison de la santé|bfmactu|faceàface|françois-xavier bellamy|les républicains|politique|bfmactu|censure|eric ciotti|faceàface|gouvernement|politique|udr|bfmactu|censure|faceàface|olivier faure|politique|ps|sébastien lecornu|bfmactu|gouvernement|jean-louis borloo|lecornu|politique|udi|bfmsocial|emmanuel macron|face à face|gouvernement|lfi|mathilde panot|politique|sébastien lecornu|bfmactu|face à face|gouvernement|politique|rassemblement national|rn|sébastien lecornu|bfmactu|budget 2026|fabien roussel|nicolas sarkozy|politique|pouvoir d'achat|sébastien lecornu|bfmactu|budget|cgt|gouvernement|grèves|mobilisation|politique|sophie binet|syndicats|bfmactu|condamnation|face-à-face|jets de peinture|justice|laure beccuau|magistrate|magistrats|nicolas sarkozy|paris|politique|têtes de cochon|PS|bfmsocial|olivier faure|parti socialiste|politique|RN|bfmactu|condamnation|face-à-face|fiscalité|justice|marine le pen|nicolas sarkozy|politique|sébastien chenu|taxe zucman|bfmactu|budget 2026|dominique de villepin|drone|emmanuel macron|europe|face-à-face|gouvernement|guerre en ukraine|international|mouamman kadhafi|nicolas sarkozy|police-justice|politique|procès libyen|sébastien lecornu|taxe zucman|bfmactu|chine|entreprises|face-à-face|france|françois ruffin|industrie|picardie debout|politique|syndicats|sébastien lecornu|taxes sur les riches|benjamin netanyahu|bernard-henri lévy|bfmactu|face-à-face|gaza|international|israël|politique|reconnaissance de la Palestine|russie|société|valdimir poutine|Reconquête|bfmactu|israel|palestine|politique|sarah knafo|taxe|zucman|bfmactu|bruno retailleau|faceàface|gouvernement|grève|politique|sécurité|BFMTV|Croissance économique|FNSEA|Inflation|MEDEF|Michel-Édouard Leclerc|Pouvoir d'achat|Taxation|Transformation numérique|bfmactu|faceàface|Économie française|économie|argent|bfmsocial|dette|thomas picketty|économie|économiste|bfmactu|faceàface|gérard larcher|politique
#> 5 Jean-Pierre Farandou|bfmactu|face à face|politique|Dominique Schelcher|bfmactu|faceàface|économie|bfmactu|marion maréchal|politique|Gérald Darmanin|Justice|bfmactu|peine|politique|prison|RN|assemblée nationale|bfmactu|budget|député|extrême droite|maisons closes|nicolas sarkozy|nord|politique|rassemblement national|sébastien chenu|Amélie de Montchalin|bfmactu|budget|hôpitaux|ministre des comptes publics|poltique|santé|ssemblée national|sécurité socialed|votea|éficit|49.3|assemblée nationale|baisse de la natalité|bfmactu|bruno retailleau|budget 2026|emmanuel macron|face-à-face|gouvernement|horizons|labellisation|maud bregeon|médias|politique|sébastien lecornu|édouard philippe|RN|agression jordan bardella|assemblée nationale|bfmactu|budget 2026|face-à-face|immigration|impôts|jordan bardella|marine le pen|politique|pouvoir d’achat|présidentielle 2027|retraites|sébastien lecornu|yaël braun-pivet|augmentation|bfmactu|cacao|carburant|chocolat|face-à-face|inflation|michel-édouard leclerc|négociations commerciales|pouvoir d'achat|prix|société|viande|économie|Face à Face|Flavie Rault|bfmactu|faceàface|syndicat national des directeurs pénitentiaires|Vincent Jeanbrun|bfmactu|faceàface|mehdi kessaci|ministre|violences conjugales|voile|bfmactu|chef d'état major des armées|emmanuel macron|guerre|lfi|manuel bompard|paix|politique|service militaire|armée|bfmactu|défense|face à face|guerre en ukraine|kiev|moscou|police-justice|russie|ukraine|vladimir poutine|volodymyr zelensky|amine kessaci|bfmactu|drogue|face à face|narcobanditisme|narcotrafic|police-justice|Medhi Kessaci|bfmactu|face à face|police-justice|Cannes|bfmactu|collectivités|congrès des maires|david lisnard|face-à-face|local|maire|politique|sécurité|élus|2027|bfmactu|budget 2026|europe|face-à-face|hôpitaux|impots|logement|patrick sébastien|people|politique|société|taxes|13-Novembre|Laurent Nunez|allemagne|alégrie|bfmactu|boualem sansal|face-à-face|gouvernement|libération|menace|police|politique|terrorisme|bfmactu|bruno lemaire|budget 2026|emmanuel macron|face-à-face|finances publiques|lettre|lfi|politique|prime de Noël|réforme des retraites|éric coquerel|bfmactu|centre ville|commerce|entreprises|made in france|ministre|serge papin|shein|économie|assemblée nationale|bfmactu|budget|droite|les républicains|lfi|lr|politique|primaire|rn|shein|xavier bertrand|bfmactu|bhv|frédéric merlin|magasin|mode|ouverture|prêt à porter|shein|ultra fast fashion|v^tement|bfmactu|entrisme|gilles kepel|islam|moyen oriant|municipales|radicalisation|spécialiste|sécurité|élections|assemblée nationale|bfmactu|budget|découverts bancaires|gestes|justice fiscale|mesures|ministre de l'économie|politique|polémique|roland lescure|shein|vote|bfmactu|faceàface|france algérie|olivier faure|taxe zucman|Bfmactu|face à face|gouvernement|maud bregeon|politique|2027|RN|Rassemblement national|bfmactu|budget 2026|face-à-face|gouvernement|immigration|marine le pen|politique|présidentielle|reconquête|union des droites|éric ciotti|éric zemmour|Face à Face|Peimane Ghaleh-Marzban|bfmactu|police-justice|bfmactu|budget|cambriolage|jean-philippe tanguy|louvre|marine le pen|musée du louvre|nicolas sarkozy|politique|rassemblement national|retraites|rn|réforme des retraites|bfmactu|budget|emmanuel macron|françois ruffin|politique|retraites|réforme des retraites|sébastien lecornu|bfmactu|face à face|nicolas sarkozy|police-justice|politique|prison de la santé|bfmactu|faceàface|françois-xavier bellamy|les républicains|politique|bfmactu|censure|eric ciotti|faceàface|gouvernement|politique|udr|bfmactu|censure|faceàface|olivier faure|politique|ps|sébastien lecornu|bfmactu|gouvernement|jean-louis borloo|lecornu|politique|udi|bfmsocial|emmanuel macron|face à face|gouvernement|lfi|mathilde panot|politique|sébastien lecornu|bfmactu|face à face|gouvernement|politique|rassemblement national|rn|sébastien lecornu|bfmactu|budget 2026|fabien roussel|nicolas sarkozy|politique|pouvoir d'achat|sébastien lecornu|bfmactu|budget|cgt|gouvernement|grèves|mobilisation|politique|sophie binet|syndicats|bfmactu|condamnation|face-à-face|jets de peinture|justice|laure beccuau|magistrate|magistrats|nicolas sarkozy|paris|politique|têtes de cochon|PS|bfmsocial|olivier faure|parti socialiste|politique|RN|bfmactu|condamnation|face-à-face|fiscalité|justice|marine le pen|nicolas sarkozy|politique|sébastien chenu|taxe zucman|bfmactu|budget 2026|dominique de villepin|drone|emmanuel macron|europe|face-à-face|gouvernement|guerre en ukraine|international|mouamman kadhafi|nicolas sarkozy|police-justice|politique|procès libyen|sébastien lecornu|taxe zucman|bfmactu|chine|entreprises|face-à-face|france|françois ruffin|industrie|picardie debout|politique|syndicats|sébastien lecornu|taxes sur les riches|benjamin netanyahu|bernard-henri lévy|bfmactu|face-à-face|gaza|international|israël|politique|reconnaissance de la Palestine|russie|société|valdimir poutine|Reconquête|bfmactu|israel|palestine|politique|sarah knafo|taxe|zucman|bfmactu|bruno retailleau|faceàface|gouvernement|grève|politique|sécurité|BFMTV|Croissance économique|FNSEA|Inflation|MEDEF|Michel-Édouard Leclerc|Pouvoir d'achat|Taxation|Transformation numérique|bfmactu|faceàface|Économie française|économie|argent|bfmsocial|dette|thomas picketty|économie|économiste|bfmactu|faceàface|gérard larcher|politique
#>   duration caption viewCount likeCount commentCount
#> 1 PT18M30S    true      5207        81           32
#> 2 PT18M44S    true     18220       258          224
#> 3 PT25M34S    true     11671       121          140
#> 4 PT17M58S    true     24287       215          192
#> 5 PT18M20S    true     10425        98          172
```

Enfin, la fonction `get_videos_text` s’appuie sur `yt-dlp` pour
récupérer les sous-titres automatiques en français puis en faire une
base de données.

``` r
df_text <- get_videos_text(df_info$video_id,workdir,"suffix",yt_dlp_path)
```

Cette troisième base de données contient une ligne par bloc de
sous-titre d’environ quelques secondes, avec le minutage et le texte.

``` r
head(df_text)
#>   n_grp  start    end
#> 1     0  3.399  6.309
#> 2     1  6.309  7.600
#> 3     2  7.600 11.789
#> 4     3 11.789 13.160
#> 5     4 13.160 16.349
#> 6     5 16.349 17.920
#>                                                                                text
#> 1      Et c'est l'heure du face- à face, il est arrivé à l'instant. Bonjour Géralde
#> 2                                                                d'Armanin. [rires]
#> 3 Vous êtes le garde des SAAU, ministre de la justice. De très nombreuses questions
#> 4                                               à vous poser parce qu'en plus votre
#> 5           parole est de plus en plus rare. Désormais vous vous faites discret sur
#> 6                                           les questions politiques mais là il y a
#>      video_id suffix
#> 1 6IOUEJN6GRI    bfm
#> 2 6IOUEJN6GRI    bfm
#> 3 6IOUEJN6GRI    bfm
#> 4 6IOUEJN6GRI    bfm
#> 5 6IOUEJN6GRI    bfm
#> 6 6IOUEJN6GRI    bfm
```

La fonction `run_complete_extraction` combine toutes les étapes
précédentes pour obtenir les trois bases de données à partir d’une seule
playlist.

``` r
# Dossier de travail où seront créés df_info_*, df_stat_* et df_text_*
workdir <- file.path(tempdir(),"data")
dir.create(workdir, showWarnings = FALSE)

run_complete_extraction(
  api_key = api_key,
  yt_dlp_path = yt_dlp_path,
  path = workdir,
  suffix = "playlist_demo",
  playlist_id = playlist_id,
  max_videos = 5
)
```

Pour extraire plusieurs playlist YouTube, le plus simple reste de créer
une base de données df_playlist avec une ligne par playlist, puis
d’appliquer la fonction `run_complete_extraction` à chaque ligne.

``` r
library(lexico)
yt_dlp  <- Sys.getenv("YT_DLP_PATH")
api_key <- Sys.getenv("YT_API_KEY")

max_videos  <- 5
workdir <- file.path(tempdir(),"data")

df_playlist <- dplyr::tibble(
                 suffix = "bfm",
                 channelTitle = "BFMTV",
                 playlist_id = "PL-qBKb-rfbhjZjW0RQr3Dm8iIvXFE0Gwy",
                 playlistDescription = "Politique") %>%
  dplyr::add_row(suffix = "fra",
                 channelTitle = "franceinfo",
                 playlist_id = "PLg6GanYvTasWQv6EPyPInaYhtyFRcht3r",
                 playlistDescription = "Interview de 8:30")

1:nrow(df_playlist) %>% purrr::map(~{
  row <- df_playlist[.x,]
  cli::cli_alert_info("Extraction {row$playlistDescription}")
  run_complete_extraction(api_key,yt_dlp,workdir,
                          row$suffix,row$playlist_id,max_videos)
})
```

La fonction `run_complete_extraction` crée trois fichiers pour chaque
playlist : `df_info`, `df_stat`, `df_text`. Dans le même répertoire se
trouve également un répertoire avec tous les fichiers vtt de
sous-titres.

Ces bases de données peuvent ensuite être nettoyées et enrichies avant
d’être utilisées dans les autres vignettes (préparation, IRaMuTeQ,
Quanteda).
