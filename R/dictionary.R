#' Get quanteda dictionary with preset terms
#'
#' @returns quanteda dictionary
#' @export
#'
#' @examples
#' get_dictionary()
get_dictionary <- function(){
  quanteda::dictionary(list(
    # 1. Immigration / frontières
    immigration = c(
      "immigration", "immigré", "immigrés", "immigrée", "immigrées",
      "migrant", "migrants", "migration", "migrations",
      "clandestin", "clandestins", "sans_papiers", "réfugié", "réfugiés",
      "asile", "demandeur_d_asile", "demandeurs_d_asile", "quotas",
      "expulsion", "expulsions", "reconduite", "rémigration", "frontières",
      "frontalier", "frontaliers"
    ),

    # 2. Sécurité / ordre public
    securite = c(
      "sécurité", "insécurité", "ordre", "ordre_public",
      "délinquance", "délinquant", "délinquants",
      "violence", "violences", "agression", "agressions",
      "cambriolage", "cambriolages", "trafic", "trafics", "racket",
      "rodéos", "rodéo", "émeute", "émeutes",
      "maintien_de_l_ordre", "lbd", "flashball"
    ),

    # 3. Police / justice pénale
    police_justice = c(
      "police", "policier", "policiers", "gendarme", "gendarmes",
      "forces_de_l_ordre", "brigade", "commissariat",
      "justice", "tribunal", "prison", "prisons",
      "peine", "peines", "condamnation", "condamnations", "incarcération",
      "comparution", "garde_à_vue"
    ),

    # 4. Religion (général) + islam
    religion_islam = c(
      "religion", "religions", "croyant", "croyants",
      "laïcité", "laïque", "laïques",
      "islam", "islamisme", "islamiste", "islamistes",
      "musulman", "musulmans", "mosquée", "mosquées",
      "voile", "voiles", "hidjab", "burqa", "niqab",
      "charia"
    ),

    # 5. Identité nationale / nation
    identite_nationale = c(
      "identité", "identitaire", "identitaires",
      "nation", "national", "nationale", "nationaux",
      "patrie", "patriotisme", "patriote", "patriotes",
      "souveraineté", "souverainiste", "souverainistes",
      "grand_remplacement", "assimilation", "intégration",
      "français", "française", "françaises", "peuple", "peuple_francais",
      "racines", "civilisation"
    ),

    # 6. Valeurs culturelles / mœurs / “wokisme”
    valeurs_culturelles = c(
      "valeurs", "valeur", "culture", "culturel", "culturelle", "culturelles",
      "tradition", "traditions", "coutumes",
      "woke", "wokisme", "politiquement_correct",
      "cancel_culture", "censure", "censurer",
      "morale", "mœurs", "progressisme", "progressiste", "progressistes",
      "conservateur", "conservateurs", "conservatisme"
    ),

    # 7. Genre / sexualité / minorités
    genre_minorites = c(
      "genre", "identité_de_genre",
      "lgbt", "lgbtq", "lgbtqia",
      "homosexuel", "homosexuelle", "homosexuels", "homosexuelles",
      "gay", "gays", "lesbienne", "lesbiennes",
      "bisexuel", "bisexuelle", "trans", "transgenre", "transgenres",
      "non_binaire", "queer",
      "minorités", "minorité", "minorité_sexuelle",
      "orientation_sexuelle"
    ),

    # 8. Racisme / discriminations
    racisme_discriminations = c(
      "racisme", "raciste", "racistes",
      "antisémitisme", "antisémite", "antisémites",
      "islamophobie", "islamophobe", "islamophobes",
      "xénophobie", "xénophobe", "xénophobes",
      "discrimination", "discriminations", "discriminer",
      "égalité", "égalitaire", "égalitarisme"
    ),

    # 9. Politique française (général)
    politique_francaise = c(
      "politique", "politiques", "gouvernement", "gouvernements",
      "majorité", "opposition", "député", "députés", "sénat", "sénateur", "sénateurs",
      "assemblée_nationale", "assemblée",
      "président", "présidentielle", "présidentielles",
      "premier_ministre", "ministre", "ministres",
      "gouvernance", "exécutif", "législatif"
    ),

    # 10. Partis politiques (surtout structuration gauche/droite)
    partis_politiques = c(
      "parti", "partis",
      "rassemblement_national", "rn",
      "front_national",
      "la_france_insoumise", "insoumis", "insoumise",
      "parti_socialiste", "ps",
      "républicains", "les_républicains", "lr",
      "écologistes", "eelv", "verts",
      "modem", "horizons",
      "front_populaire", "nupes",
      "extrême_droite", "extrême_gauche", "populisme", "populiste", "populistes"
    ),

    # 11. Europe / institutions internationales
    europe_international = c(
      "europe", "européen", "européenne", "européennes", "européens",
      "union_européenne", "ue", "bruxelles",
      "commission_européenne", "parlement_européen",
      "otan", "onu", "unicef", "unesco", "oms"
    ),

    # 12. Conflits internationaux / terrorisme
    conflits_terrorisme = c(
      "guerre", "conflit", "conflits",
      "ukraine", "russie", "états_unis", "usa", "israël", "gaza", "palestine",
      "hamas", "daech", "al_qaida",
      "terrorisme", "terroriste", "terroristes",
      "attentat", "attentats", "attaque", "attaques",
      "djihad", "djihadiste", "djihadistes"
    ),

    # 13. Médias / débat public
    medias_debat = c(
      "médias", "média", "journalistes", "journaliste",
      "plateau", "débat", "débats", "polémique", "polémiques",
      "opinion", "éditorial", "éditorialiste", "éditorialistes",
      "audience", "audiences",
      "censure", "liberté_d_expression", "réseaux_sociaux"
    )
  ))
}

#' Specific stopwords for this study
#'
#' @returns vector of terms
#' @export
#'
#' @examples
#' get_specific_stopwords()
get_specific_stopwords <- function(){
  c(stopwords::stopwords('fr'),
    "c'est","ça","qu'on","a","ya","news","lci","bfm","tv","blast",
    "le média","cnews","new","europe1","europe 1","bfmactu","tf1","rmc","bfmtv",
    "grande_interview","france_info","europin",
    "donc","plus","fait","tout","euh","qu'il","parce","dire",
    "bien","quand","faut","si","très","faire","france","aussi",
    "va","dit","là","est-ce","comme","non","aujourd'hui","alors",
    "peut","être","j'ai","oui","pense","tous","question",
    "beaucoup","peu","n'est","où","voilà","évidemment","encore",
    "d'une","veut","peut-être","puis","déjà","depuis","aujourhui",
    "monsieur","madame","effectivement","qu'à","là-dessus",
    "regardez","dès","ah","pu","jusà","toujours","hein","bah",
    "attendez","dites","hier","estimez","pardonnez-moi","gros",
    "punchline","matin","bienvenue","également",
    "lundi","mardi","mercredi","jeudi","vendredi","samedi","dimanche",
    "10h30","9h30","comment","chose","veux","quoi",
    "quelque","beaucoup","merci","ben","ouais",
    "bonjour","bonsoir","écoutez","etc","au-delà","désormais",
    "enfin","justement","finalement","est-à-dire","cetera",
    "puisque","abord","surtout","simplement","exactement",
    "forcément","clairement","complètement","fort","totalement",
    "tellement","sauf","tel","met","quelun",
    "dis", "crois", "juste", "vais", "savez", "vois", "disant",
    "peux", "donne", "essayer", "faites", "regarder", "entendre",
    "regarde", "expliquer", "cours", "laisser", "attention",
    "demander", "fais", "laisse", "importe", "vite","lors","mis",
    "avoir","deux","entre",
    "intégralité","interview","matinale","édito","adobe","retrouvez-nous",
    "direct","site","abonnez-vous","facebook","twitter","instagram",
    "retrouvez","grands","meilleur","afp","google","sonia","affirmé",
    "après","ans","selon","voici","vraiment","assez","bon")
}

#' Get specific multiwords for the study
#'
#' @returns vector of terms
#' @export
#'
#' @examples
#' get_specific_multiwords()
get_specific_multiwords <- function(){
  c("grande interview",
    "rassemblement national",
    "front national",
    "les républicains",
    "front populaire",
    # "bruno retailleau",
    # "alain duamel",
    "intelligence artificielle",
    # "donald trump",
    "france info",
    # "emmanuel macron",
    # "nicolas sarkozy",
    # "gabriel attal",
    # "jordan bardella",
    # "marine le pen",
    "le pen",
    "los angeles",
    # "françois hollande",
    # "françois bayrou",
    # "jean michel aphatie",
    "jean michel",
    # "jean luc mélenchon",
    # "jean-luc mélenchon",
    "premier ministre")
}

#' get recoding words
#'
#' @returns named vector of words
#' @export
#'
#' @examples
#' get_recode_words()
get_recode_words <- function(){
  recoded <- c(
    "sarkozi" = "sarkozy",
    "atal" = "attal",
    "hatal" = "attal",
    "baayrou" = "bayrou",
    "baayou" = "bayrou",
    "berou" = "bayrou",
    "berrou" = "bayrou",
    "baou" = "bayrou",
    "baïou" = "bayrou",
    # "rn" = "rassemblement national",
    # "lia" = "intelligence artificielle",
    # "lr" = "les républicains",
    "c'està" = "c'est à",
    "c'estàd" = "c'est à d",
    "c'estàdire" = "c'est à dire",
    "c'està-dire" = "c'est à dire",
    "rotillot" = "retailleau",
    "rotaillot" = "retailleau",
    "rotillo" = "retailleau",
    "weekend" = "week-end",
    "délinquence" = "délinquance",
    "zelenski" = "zelensky",
    "jordane" = "jordan",
    "lecnu" = "lecornu",
    "gluxman" = "glucksmann",
    "gluxman" = "glucksmann",
    "Lucy" = "Lucie",
    "queil" = "que il",
    "troisème" = "troisième",
    "cétait" = "c'était",
    "europin" = "europe 1",
    "voquier" = "Vauquier",
    "vquier" = "Vauquier",
    "voquet" = "Vauquier",
    "netaniaou" = "netanyahou",
    "netanahou" = "netanyahou",
    "netaniaahou" = "netanyahou",
    "matigon" = "matignon",
    "bonpard" = "bompard",
    "fériers" = "février",
    "férier" = "février",
    "lebret" = "le bret",
    "quinquena" = "quinquennat",
    "bardellaa" = "bardella",
    "mayot" = "mayotte",
    "jeis" = "je suis",
    "surcis" = "sursis",
    "làdessus" = "là-dessus",
    "hzbollah" = "hezbollah",
    "panau" = "panot",
    "ellisabeth" = "elisabeth",
    "armanin" = "darmanin",
    "mitteran" = "mitterand",
    "narrive" = "n'arrive",
    "évidment" = "évidemment",
    "d'étatmajor" = "d'état major",
    "puisquil" = "puis qu'il",
    "banlieux" = "banlieu",
    "d'obtempéré" = "d'obtempérer",
    "mélanchon" = "mélenchon",
    "politiqu" = "politique",
    "minist" = "ministre",
    "puisquon" = "puisqu'on",
    "politiquee" = "politique",
    "ministrere" = "ministère",
    "franceise " = "france insoumise",
    "jean luc" = "jean-luc",
    "anouna" = "hanouna"
  )

  # patterns (regex) : on match le mot fautif entouré de non-lettres
  patterns <- paste0("(^|[^a-z])(", names(recoded), ")([^a-z]|$)")

  # replacements : on remet le préfixe/suffixe + la correction
  replacements <- paste0("\\1", recoded, "\\3")

  out <- replacements
  names(out) <- patterns
  out
}

#' Correct apostrophe
#'
#' @param text vector of strings to correct
#' @param patterns patterns
#'
#' @returns text
#' @export
#'
#' @examples
#' remove_apostrophe("Aujourd'hui, j'ai pris l'avion")
remove_apostrophe <- function(
    text,
    patterns = c("l","d","qu","j","s","m","n","c","t")
)
{
  patterns <- c(paste0(patterns,"'"),paste0(patterns,"’"))
  patterns <- c(patterns,toupper(patterns))

  stringr::str_remove_all(text,paste(patterns,collapse = "|"))
}




