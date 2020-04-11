#' Retrieve National Surveillance of U.S. State and Local Public Health Laboratories Reporting to CDC
#'
#' @return data frame
#' @references <https://www.cdc.gov/coronavirus/2019-ncov/covid-data/covidview/04102020/labs-regions.html>
#' @export
public_health_labs_national <- function() {

  xml2::read_html(
    "https://www.cdc.gov/coronavirus/2019-ncov/covid-data/covidview/04102020/labs-regions.html"
  ) -> pg

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

  total <- set_names(nat_tbl[, 1:5], c("week", "num_labs", "tested", "tested_pos", "pct_pos"))
  total$age_group <- "Overall"

  a1 <- set_names(nat_tbl[, c(1:2, 6:8)], c("week", "num_labs", "tested", "tested_pos", "pct_pos"))
  a1$age_group <- "0-4 yr"

  a2 <- set_names(nat_tbl[, c(1:2, 9:11)], c("week", "num_labs", "tested", "tested_pos", "pct_pos"))
  a2$age_group <- "5-17 yr"

  a3 <- set_names(nat_tbl[, c(1:2, 12:14)], c("week", "num_labs", "tested", "tested_pos", "pct_pos"))
  a3$age_group <- "18-49 yr"

  a4 <- set_names(nat_tbl[, c(1:2, 15:17)], c("week", "num_labs", "tested", "tested_pos", "pct_pos"))
  a4$age_group <- "50-64 yr"

  a5 <- set_names(nat_tbl[, c(1:2, 18:20)], c("week", "num_labs", "tested", "tested_pos", "pct_pos"))
  a5$age_group <- "65+ yr"

  nat_tbl <- rbind(total, a1, a2, a3, a4, a5, stringsAsFactors = FALSE)
  nat_tbl$region <- "National"
  nat_tbl$source <- "Public Health Labs"
  nat_tbl$week <- clean_int(nat_tbl$week)
  nat_tbl$num_labs <- clean_int(nat_tbl$num_labs)
  nat_tbl$tested <- clean_int(nat_tbl$tested)
  nat_tbl$tested_pos <- clean_int(nat_tbl$tested_pos)
  nat_tbl$pct_pos <- clean_num(nat_tbl$pct_pos)/100

  nat_tbl[!is.na(nat_tbl$week),]

}
