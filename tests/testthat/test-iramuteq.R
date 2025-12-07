df_to_export <- janeaustenr::austen_books()[1:10,]
df_to_export$book <- stringr::str_remove_all(df_to_export$book," ")
path_txt <- file.path(tempfile(fileext=".txt"))


test_that("export_to_iramuteq() works", {
  expect_null(export_to_iramuteq(df_to_export,"book","text",path_txt))
})

test_that("import_from_iramuteq() works", {
  df_to_import <- import_from_iramuteq(path_txt)
  df_to_import <- as.data.frame(import_from_iramuteq(path_txt))
  expect_equal(as.data.frame(df_to_export),df_to_import)
})
