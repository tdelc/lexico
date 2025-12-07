sentence <- "Retrouvez l'interview en intégralité du premier ministre François berou"

test_that("clean_df_text() works", {
  expect_equal(clean_df_text(sentence),"premier_ministre françois_bayrou")
})
