#' Clean a text variable of a df
#'
#' @param vec_text vector of texts
#' @param recode_words names vector of words to recode
#' @param stopwords words to remove
#' @param multiwords words to collapse
#'
#' @returns vector of character
#' @export
#'
#' @examples
#' clean_df_text(janeaustenr::austen_books(),"text")
clean_df_text <- function(vec_text,
                          recode_words = get_recode_words(),
                          stopwords = get_specific_stopwords(),
                          multiwords = get_specific_multiwords()){

  stopwords_regex <- paste0("\\b(?:", paste(stopwords, collapse = "|"), ")\\b")

  multiwords <- stringr::str_replace_all(multiwords, "\\s+", "_")
  names(multiwords) <- multiwords

  vec_text <- stringr::str_remove_all (vec_text, stopwords_regex)
  vec_text <- stringr::str_replace_all(vec_text, multiwords)
  vec_text <- stringr::str_replace_all(vec_text, recode_words)

  vec_text
}


