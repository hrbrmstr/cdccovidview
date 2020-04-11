#' Retrieve National Syndromic Surveillance Program (NSSP): Emergency Department Visits Percentage of Visits for COVID-19-Like Illness (CLI) or Influenza-like Illness (ILI)
#'
#' @references <https://www.cdc.gov/coronavirus/2019-ncov/covid-data/covidview/04102020/nssp-regions.html>
#' @return data frame
#' @export
nssp_er_visits_national <- function() {

  pg <- xml2::read_html("https://www.cdc.gov/coronavirus/2019-ncov/covid-data/covidview/04102020/nssp-regions.html")

  nat_tbl <- rvest::html_nodes(pg, xpath=".//table[contains(., 'National')]")
  nat_rows <- rvest::html_nodes(nat_tbl, "tbody > tr")
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
  nat_tbl <- do.call(rbind.data.frame, nat_rows)

  cli <- set_names(nat_tbl[, 1:5], c("week", "num_fac", "total_ed_visits", "visits", "pct_visits"))
  cli$visit_type <- "cli"

  ili <- set_names(nat_tbl[, c(1:3, 6:7)], c("week", "num_fac", "total_ed_visits", "visits", "pct_visits"))
  ili$visit_type <- "ili"

  nat_tbl <- rbind(ili, cli, stringsAsFactors = FALSE)
  nat_tbl$region <- "National"
  nat_tbl$source <- "Emergency Departments"
  nat_tbl$year <- clean_int(substr(nat_tbl$week, 1, 4))
  nat_tbl$week <- clean_int(substr(nat_tbl$week, 5, 6))
  nat_tbl$num_fac <- clean_int(nat_tbl$num_fac)
  nat_tbl$visits <- clean_int(nat_tbl$visits)
  nat_tbl$pct_visits <- clean_num(nat_tbl$pct_visits)/100

  as_tibble(nat_tbl[!is.na(nat_tbl$week),])

}
