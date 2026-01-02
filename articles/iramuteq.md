# Préparer et exploiter des corpus avec IRaMuTeQ

Cette vignette montre comment exporter un tableau de textes vers le
format attendu par IRaMuTeQ, puis comment réimporter les résultats de
classification.

Avant de faire l’export vers IRaMuTeQ, nous appliquons les corrections
sur le `df_text` (voir la vignette *Préparer les données textuelles*
pour le détail).

``` r
library(lexico)
library(dplyr)
library(stringr)

data(df_text_bfm)
df_text <- df_text_bfm

stopwords <- get_specific_stopwords()
stopwords_regex <- paste0("\\b(?:", paste(stopwords, collapse = "|"), ")\\b")

df_text <- df_text %>%
  mutate(text = tolower(text),
         text = str_remove_all(text,stopwords_regex),
         text = str_replace_all(text, get_recode_words()),
         text = str_remove_all(text,"\\[[a-z]+?\\]"),
         text = str_squish(text))

df_segment <- df_text %>%
  mutate(id_segment = 1+floor(start/(2*60))) %>%
  group_by(suffix,video_id,id_segment) %>%
  summarise(start = min(start),end = max(end),
            text = paste(text, collapse = " "),
            .groups = "drop")
```

## Construire le fichier .txt pour IRaMuTeQ

[`export_to_iramuteq()`](https://tdelc.github.io/lexico/reference/export_to_iramuteq.md)
attend un `data.frame` contenant au moins une colonne texte et des
colonnes de métadonnées. Chaque ligne devient un document.

``` r
export_to_iramuteq(
  df = df_segment,
  meta_cols = c("video_id","id_segment"),
  text_col = "text",
  output_file = "inst/extdata/corpus_bfm.txt"
)
```

Le fichier généré contient un en-tête `****` suivi des variables
métadonnées préfixées par `*` et du texte nettoyé des retours à la
ligne.

Vous pouvez maintenant utiliser IRaMuTeQ pour traiter le corpus. Pour
l’exemple donné ci-dessus, j’ouvre IRaMuTeQ, charge le corpus en
désactivant l’option ‘faire des segments de texte’ car les segments ont
été fait par le minutage. Je choisis ensuite la classification par
méthode Reinert simple sur texte, pour obtenir la classification
suivante :

![](images/dendrogramme_1.png)

Ensuite, j’exporte le corpus afin de récupérer la classe attribuée à
chaque segment, ainsi que le rapport pour obtenir les mots de chaque
classe.

## Lire un corpus IRaMuTeQ existant

Pour récupérer le corpus IRaMuTeQ en tableau R, utilisez la fonction
[`import_from_iramuteq()`](https://tdelc.github.io/lexico/reference/import_from_iramuteq.md).
Chaque métadonnée devient une colonne ; le texte est stocké dans `text`
et la classe dans `classe` avec une classe 0 pour les segments non
attribués. Attention, les tirets bas des métadonnées sont supprimés.

``` r
df_segment <- import_from_iramuteq(lexico_example("export_corpus.txt"))
head(df_segment)
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     text
#> 1                                                                                                                                                                                                                                              heure face face arriver instant géralde darmanin garder saau ministre justice nombreux question poser parole rare discret question politique boulot notamment front justice pénal venir notamment détailler projet loi citer titre projet loi projet loi viser assurer sanction utile rapide effectif justice fermer creux reconnaître sanction ni utile ni rapide ni effectif justice lent grand injustice pays temps trop important victime accuser attendre société attendre sanction sûr lenteur justice valoir justice pénal valoir justice civil attendre trop souvent divorce garder enfant tutelle problème immobilier devoir régler justice efficace partie moitié peine prison prononcer tribunal gens aller seul journée prison efficace prononcer peine prison jamais autant prononcer celle prononcer utile 70 récidive pays détenu sortir prison récidivent 7 fois 10 montrer système efficace écouter constat terrible constat terrible justice important égalité femme homme cimenter démocratie nourrir populisme voir justice inefficace constater malheureusement pays européen mêmes difficulté baser système justice falloir récidiviste pouvoir sanctionner lourdement fond laisser
#> 2                  pouvoir pendant temps relativement long agir impunément cas sanction ni rapide ni dissuasives gens aller prison immense majorité gens aller prison gens commettre acte policier gendarme dire arrêter personne aller jamais prison connaître formule mettre intérieur constater voir juge magistrat dire quelqu récidiviste addictions drogue alcool désocialisé servir mettre prison arranger socialisation maladie psychiatrique devoir aller prison devoir aller ailleurs juge autocensure magistrat malheureusement six code pénal aider exemple code pénal écrire peine égal 6 mois prison autant amende code pénal article 6 mois prison prison aménagement peine obligatoire contradictoire absurde disposition législatif rajouter fil temps absurde quasi personne condamner moins an prison faire prison projet loi porte changer fin aménagement peine obligatoire juge pouvoir prononcer court peine cas autres pays notamment pays bas angleterre court peine peine mois 2 mois 3 mois 4 mois prison compte grandeur peine compte certitude peine certain premier deuxième cas carton jaune devoir carton rouge pouvoir sanction clair rapide montrer victime accuser société justice création court peine voire ultra court peine estd prendre exemple hollande hollande aller quelques jour prison laisser juge libre fixer peine devoir fixer effet peine mois elles interdire code pénal possible adapter immobilier
#> 3 carcéral prison envoyer gens faire 2 mois prison maison arrêt classique surpeuplé occasion parler court peine possible prononcer juge peine obligatoire chaque condamnation chaque condamnation peine parfois condamner peine proprement parler raison quelques centaine cas an croire français aucune peine parfois peine proportionné difficulté connaître notamment texte loi proposer nouveau peine minimal peine planchée peine planchée peine appliquer récidive peine minimal comprendre premier occurrence premier peine minimal proposer ceux attaquer policier gendarme ceux dépositaire autorité public agent pénitentiaire magistrat ceux représenter autorité exemple peine minimal proposition texte loi an an prison peine maximal peine minimal juge fixer peine minimal maximal aménagement aménagement certain nombre profil personne condamner notamment oqtf aujourd h demain spécifique dessus expérience premier expérience fois pendant longtemps ministreère intérieur justice problème régler 25 étranger prison partie étranger devoir partir prison purger peine pays origine augmenter début année augmenter quasiment 100 expulsion étranger prison partie européen 3 4 européen ensuite code effet chose bizarre exemple aménagement peine sortie prison possible réinsertion comprendre détenu trouver travail retrouver famille projet vie devoir sortir prison réinsérer faire réinsertion important quelqu sous eqtf
#> 4                                                                                    devoir territoire national train appliquer uqtf loi agent pénitentiaire agent pénitentiaire magistrat obliger appliquer loi mal écrire changer faute faire aménagement peine eqtf aménagement peine seul aménagement peine possible eqtf expulser accord eqtf sortir prison expulser pays origine retrouver travail retrouver famille devoir retrouver puisqu étranger situation irrégulier condamner venir géral darmanin 25 étranger prison dont trois 4 étranger extraint européen certains relation immigration délinquance partie relation immigration délinquance étranger délinquant immense majorité respecter pays travailler envoyer enfant école vouloir mieux vivre étranger surreprésentés délinquance français seulement ministre intérieur maire maire commun citoyen citoyen voir mauvais intégration difficulté extrêmement fort lier parfois pauvreté parfois trafic drogue parfois trafic être humain étranger auteur autres acte délinquance victime autres acte délinquance exemple femme étranger victime violence femme français femme français victime violence certain lien combattre notamment immigration mieux contrôler mieux intégrer justice fermer étranger commettre acte délinquance justice fermer revenir narcotrafic vouloir régime contre narcotrafic proche celui terroriste évoquer lieu lesquels gens incarcérer récemment
#> 5                                                                                                                                                                                                                                                                                                    passer intérieur prison prison état droit vouloir pouvoir document commenter ceux écouter vidéo procurer tournée 9 novembre dernier scène violence inouie passer sein prison nantes voir détenu entièrement nu ensanglanté traîner bitume cour intérieur prison réalité groupe détenu battre promenade pourtant aucun gardien intervenir considérer trop dangereux gardien mêmes pouvoir intervenir sein lieu lieu normalement lequel régner loi rétablir ordre prison incontestable 11 mois ministre justice essayer certaine réussite prison haut sécurité construire 5 mois 5 mois savoir prison ailleurs étranger venir visiter montrer téléphone portable drogue clé usb gens dangereux ceux capable évader commander assassinat notamment grand partie narcotrafiquant suite affaire amra victime feramra oeil chose sécurité agent pénitenciiaires français rester toutes autres prison savoir téléphone portable cheat couteau drone parloir corruption rentrer faire fouille moment jamais ampleur prison 80 fouille centaine prison fouiller fameux fouille xl revenir instant image découverte imaginer avant elles saisissant fond sein
#> 6                                                prison gardien mêmes pouvoir intervenir surprendre cocktail affreux manquer agent pénitentiaire rajouter 1000 prochain budget manquer 4000 agent pénitentiaire prison gens courageux nombreux comprendre parfois peur soutenir année prochain 1000 agence supplémentaire voter revenir voir devant difficulté pays priver policier gendarme agent péniteniaires magistrat année prochain 1000 agent supplémentaire construire 3000 place prison an reconstruction place prison partie arrêter manquer compte place prison 86000 détenu 65000 place grosso_modo troisièmement prison gens devoir gens atteindre psychiatriquement 25 détenu maladie psychiatrique avant rentrer développ fois prison cellule 9 arranger pathologie 25 gens emprisonner toucher maladie psychiatrique devoir devoir hôpital psychiatrique agent pénitentiaire prison gérer toutes difficulté empire inalphabétisation addictions drogue alcool important maladie psychiatrique mauvais intégration étranger venir parler fouille ailleurs assister dernier jour certain nombre fouille fouiller objectif zéro portable durer nuit premier bilan trouver cellule grand fouille organiser centaine agent police gendarmerie douane remercier chien venir trouver téléphone portable argent drogue 80 premier prison fouilli près 200 trouver 1100 portable quasiment 10 kg drogue près 1500 objet interdire couteau exemple
#>       videoid idsegment classe
#> 1 6IOUEJN6GRI         1      4
#> 2 6IOUEJN6GRI         2      3
#> 3 6IOUEJN6GRI         3      3
#> 4 6IOUEJN6GRI         4      4
#> 5 6IOUEJN6GRI         5      4
#> 6 6IOUEJN6GRI         6      4
```

À partir du fichier `rapport.txt`, on peut récupérer la liste des mots
constitutifs de chaque classe.

``` r
nb_classes <- length(unique(df_segment$classe))-1

df_mots <- 1:nb_classes %>% purrr:::map_df(~{
  read_iramuteq_class(lexico_example("RAPPORT.txt"),.x) %>%
    mutate(classe = .x)
})

head(df_mots)
#> # A tibble: 6 × 9
#>    rang freq_classe freq_totale   pct  chi2 pos   forme     p_value classe
#>   <int>       <int>       <int> <dbl> <dbl> <chr> <chr>       <dbl>  <int>
#> 1     0           4           5  80    23.8 adj   pire       0.0001      1
#> 2     1           3           3 100    22.7 ver   payer      0.0001      1
#> 3     2           4           6  66.7  18.9 nom   milliard   0.0001      1
#> 4     3           4           6  66.7  18.9 nr    lecornu    0.0001      1
#> 5     4           5          10  50    17.1 nr    sébastien  0.0001      1
#> 6     5           3           4  75    15.9 nom   économie   0.0001      1
```

La base de données `df_segment` peut maintenant être couplée aux bases
de données `df_stat` et `df_info` pour analyser les classes selon la
date de publication, la playlist, le titre de la vidéo, etc.
