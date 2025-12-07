test_that("get_dictionary() works", {
  expect_true(quanteda::is.dictionary(get_dictionary()))
})

test_that("get_specific_stopwords() works", {
  expect_true(is.vector(get_specific_stopwords()))
  expect_true(is.character(get_specific_stopwords()))
})

test_that("get_recode_words() works", {
  expect_true(is.vector(get_recode_words()))
  expect_true(is.character(names(get_recode_words())))
  expect_equal(length(names(get_recode_words())), length(get_recode_words()))
})

test_that("remove_apostrophe() works", {
  sentence <- remove_apostrophe("Aujourd'hui, j'ai pris l'avion")
  expect_equal(sentence,"Aujourhui, ai pris avion")
})
