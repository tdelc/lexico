df <- data.frame(ID = 1,text = "Retrouvez l'interview en intégralité du premier ministre François berou")
expected_tokens <- c("l'interview","premier_ministre","françois_bayrou")
corpus_ <- quanteda::corpus(df)

test_that("corpus_to_tokens() works", {
  tokens_ <- corpus_to_tokens(corpus_)
  expect_equal(as.list(tokens_)$text1,expected_tokens)
  expect_equal(as.numeric(quanteda::ntoken(tokens_)),3)
})
