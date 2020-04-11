#' Retrieve Regional Surveillance of U.S. State and Local Public Health Laboratories Reporting to CDC
#'
#' @return data frame
#' @references <https://www.cdc.gov/coronavirus/2019-ncov/covid-data/covidview/04102020/labs-regions.html>
#' @export
public_health_labs_regional <- function() {

  xml2::read_html(
    "https://www.cdc.gov/coronavirus/2019-ncov/covid-data/covidview/04102020/labs-regions.html"
  ) -> pg

  regions <- sprintf("Region %d", 1:10)

  lapply(regions, function(region){

    rvest::html_node(
      pg,
      xpath=sprintf(".//table[contains(., '%s (')]", region)
    ) -> reg_tbl

    reg_tbl <- rvest::html_table(reg_tbl, header = TRUE, trim = TRUE)

    colnames(reg_tbl) <- c("week", "num_labs", "tested", "tested_pos", "pct_pos")

    reg_tbl$region <- region
    reg_tbl$source <- "Public Health Labs"

    reg_tbl$week <- clean_int(reg_tbl$week)
    reg_tbl$num_labs <- clean_int(reg_tbl$num_labs)
    reg_tbl$tested <- clean_int(reg_tbl$tested)
    reg_tbl$tested_pos <- clean_int(reg_tbl$tested_pos)
    reg_tbl$pct_pos <- clean_num(reg_tbl$pct_pos)/100

    as_tibble(reg_tbl[!is.na(reg_tbl$week),])

  }) -> regs

  out <- do.call(rbind.data.frame, regs)

  as_tibble(out)

}
