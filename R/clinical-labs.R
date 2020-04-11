#' Retrieve U.S. Clinical Laboratories Reporting SARS-CoV-2 Test Results to CDC
#'
#' @references <https://www.cdc.gov/coronavirus/2019-ncov/covid-data/covidview/04102020/reporting-cov2-results.html>
#' @return data frame
#' @export
clinical_labs <- function() {

  pg <- xml2::read_html("https://www.cdc.gov/coronavirus/2019-ncov/covid-data/covidview/04102020/reporting-cov2-results.html")

  clab_tbl <- rvest::html_table(pg, header = TRUE, trim = TRUE)[[1]]
  colnames(clab_tbl) <- c("week", "num_labs", "tested", "tested_pos", "pct_pos")

  clab_tbl$region <- "National"
  clab_tbl$source <- "Clinical Labs"

  clab_tbl$week <- clean_int(clab_tbl$week)
  clab_tbl$num_labs <- clean_int(clab_tbl$num_labs)
  clab_tbl$tested <- clean_int(clab_tbl$tested)
  clab_tbl$tested_pos <- clean_int(clab_tbl$tested_pos)
  clab_tbl$pct_pos <- clean_num(clab_tbl$pct_pos)/100

  as_tibble(clab_tbl[!is.na(clab_tbl$week),])

}