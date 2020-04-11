#' Retrieve Regional Syndromic Surveillance Program (NSSP): Emergency Department Visits Percentage of Visits for COVID-19-Like Illness (CLI) or Influenza-like Illness (ILI)
#'
#' @return data frame
#' @references <https://www.cdc.gov/coronavirus/2019-ncov/covid-data/covidview/04102020/nssp-regions.html>
#' @export
nssp_er_visits_regional <- function() {

  xml2::read_html(
    "https://www.cdc.gov/coronavirus/2019-ncov/covid-data/covidview/04102020/nssp-regions.html"
  ) -> pg

  regions <- sprintf("Region %d", 1:10)

  lapply(regions, function(region){

    reg_tbl <- rvest::html_nodes(pg, xpath=".//table[contains(., 'National')]")
    nat_rows <- rvest::html_nodes(reg_tbl, "tbody > tr")
    lapply(nat_rows, function(.x) {
      nat_tds <- rvest::html_nodes(.x, "td")
      nat_tds <- gsub(",", "", rvest::html_text(nat_tds))
      as_tibble(as.data.frame(
        as.list(
          set_names(
            nat_tds, sprintf("X%02d", 1:length(nat_tds))
          )
        ),
        stringsAsFactors = FALSE
      ))
    }) -> nat_rows
    reg_tbl <- do.call(rbind.data.frame, nat_rows)

    cli <- set_names(reg_tbl[, 1:5], c("week", "num_fac", "total_ed_visits", "visits", "pct_visits"))
    cli$visit_type <- "cli"

    ili <- set_names(reg_tbl[, c(1:3, 6:7)], c("week", "num_fac", "total_ed_visits", "visits", "pct_visits"))
    ili$visit_type <- "ili"

    reg_tbl <- rbind(ili, cli, stringsAsFactors = FALSE)
    reg_tbl$region <- region
    reg_tbl$source <- "Emergency Departments"
    reg_tbl$week <- as.character(clean_int(reg_tbl$week))
    reg_tbl$year <- clean_int(substr(reg_tbl$week, 1, 4))
    reg_tbl$week <- clean_int(substr(reg_tbl$week, 5, 6))
    reg_tbl$num_fac <- clean_int(reg_tbl$num_fac)
    reg_tbl$visits <- clean_int(reg_tbl$visits)
    reg_tbl$pct_visits <- clean_num(reg_tbl$pct_visits)/100

    reg_tbl[!is.na(reg_tbl$week),]


  }) -> regs

  out <- do.call(rbind.data.frame, regs)

  as_tibble(out)

}
