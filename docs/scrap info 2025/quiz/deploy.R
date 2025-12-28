library(rsconnect)

rsconnect::setAccountInfo(
  name='tdelc',
  token='1EFE34508C75C402EB3B515E1E09803E',
  secret='m1XP43+aKdbqc54WlRQaQcybH03N1W2ka5NvQc66')

# setwd("C:/Users/tdelc/Pictures/médiapart bfm/dashboard")
# file.copy("../obj/df_full.rds","df_full.rds")
# file.copy("../obj/tokens_text_brut.rds","tokens_text_brut.rds")
# file.copy("../obj/dfm_text.rds","dfm_text.rds")

rsconnect::deployApp(account='tdelc',appName="quiz_info_continu",
                     server = "shinyapps.io",launch.browser = FALSE)
