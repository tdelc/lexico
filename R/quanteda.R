#' Convert quanteda corpus to tokens
#'
#' @param corpus corpus from quanteda
#' @param recode_words names vector of words to recode
#' @param stopwords words to remove
#' @param multiwords words to collapse
#'
#' @returns tokens
#' @export
#'
#' @examples
#' corpus_to_tokens(quanteda::data_corpus_inaugural)
corpus_to_tokens <- function(corpus,
                             recode_words = get_recode_words(),
                             stopwords = get_specific_stopwords(),
                             multiwords = get_specific_multiwords()){
  quanteda::tokens(corpus) %>%
    quanteda::tokens(
      remove_punct = TRUE,
      remove_symbols = TRUE,
      remove_numbers = TRUE,
      remove_url = TRUE)  %>%
    quanteda::tokens_tolower() %>%
    quanteda::tokens_replace(names(recode_words), unname(recode_words)) %>%
    quanteda::tokens_remove(stopwords) %>%
    quanteda::tokens_compound(quanteda::phrase(multiwords)) %>%
    quanteda::tokens_keep(pattern = "^.{3,}$",valuetype = "regex")
}
