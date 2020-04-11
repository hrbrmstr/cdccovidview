#' Retrieve NCHS Mortality Surveillance Data
#'
#' @return data frame
#' @references <https://www.cdc.gov/coronavirus/2019-ncov/covid-data/covidview/04102020/nchs-data.html>
#' @export
mortality_surveillance_data <- function() {

  pg <- xml2::read_html("https://www.cdc.gov/coronavirus/2019-ncov/covid-data/covidview/04102020/nchs-data.html")

  nat_tbl <- rvest::html_nodes(pg, xpath=".//table[contains(., 'Total Deaths')]")
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

  cov <- set_names(nat_tbl[, 1:5], c("year", "week", "total_deaths", "deaths", "pct_deaths"))
  cov$cause <- "COVID-19"

  pnu <- set_names(nat_tbl[, c(1:3, 6:7)], c("year", "week", "total_deaths", "deaths", "pct_deaths"))
  pnu$cause <- "Pneumonia"

  flu <- set_names(nat_tbl[, c(1:3, 8:9)], c("year", "week", "total_deaths", "deaths", "pct_deaths"))
  flu$cause <- "Influenza"

  nat_tbl <- rbind(cov, pnu, flu, stringsAsFactors = FALSE)
  nat_tbl$region <- "National"
  nat_tbl$source <- "NCHS"
  nat_tbl$year <- clean_int(nat_tbl$year)
  nat_tbl$week <- clean_int(nat_tbl$week)
  nat_tbl$total_deaths <- clean_int(nat_tbl$total_deaths)
  nat_tbl$deaths <- clean_int(nat_tbl$deaths)
  nat_tbl$pct_deaths <- clean_num(nat_tbl$pct_deaths)/100

  as_tibble(nat_tbl[!is.na(nat_tbl$week),])

}