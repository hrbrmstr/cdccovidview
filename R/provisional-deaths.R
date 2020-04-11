#' Retrieve Provisional Death Counts for Coronavirus Disease (COVID-19)
#'
#' @note Please see the indicated reference for all the caveats and precise meanings for each field. Also,
#'       this function used the JSON API (<https://data.cdc.gov/resource/hc4f-j6nb.json>)
#' @return a list with 4 named elements: `by_week`, `by_age`, `by_state`, `by_sex`
#' @references <https://data.cdc.gov/api/views/hc4f-j6nb/rows.csv?accessType=DOWNLOAD&bom=true&format=true>
#' @export
provisional_death_counts <- function() {

  res <- jsonlite::fromJSON("https://data.cdc.gov/resource/hc4f-j6nb.json")
  res <- as_tibble(res)

  res$covid_deaths <- clean_int(res$covid_deaths)
  res$total_deaths <- clean_int(res$total_deaths)
  res$pneumonia_deaths <- clean_int(res$pneumonia_deaths)
  res$pneumonia_and_covid_deaths <- clean_int(res$pneumonia_and_covid_deaths)
  res$all_influenza_deaths_j09_j11 <- clean_int(res$all_influenza_deaths_j09_j11)
  res$percent_expected_deaths <- clean_num(res$percent_expected_deaths)

  by_week <- res[res$group == "By week",]
  by_age <- res[res$group == "By age",]
  by_state <- res[res$group == "By state",]
  by_sex <- res[res$group == "By sex",]

  by_week <- by_week[!grepl("total", tolower(by_week$indicator)),]
  by_week$group <- NULL
  by_week$indicator <- as.Date(by_week$indicator, "%m/%d/%Y")
  colnames(by_week) <- c(
    "week", "covid_deaths", "total_deaths", "percent_expected_deaths",
    "pneumonia_deaths", "pneumonia_and_covid_deaths", "all_influenza_deaths_j09_j11"
  )

  by_age$group <- NULL
  colnames(by_age) <- c(
    "age_group", "covid_deaths", "total_deaths", "percent_expected_deaths",
    "pneumonia_deaths", "pneumonia_and_covid_deaths", "all_influenza_deaths_j09_j11"
  )
  by_age$age_group <- sub("&ndash;", "-", by_age$age_group, fixed=TRUE)
  by_age$age_group <- sub("yea.*", "yr", by_age$age_group)

  by_state$group <- NULL
  colnames(by_state) <- c(
    "state", "covid_deaths", "total_deaths", "percent_expected_deaths",
    "pneumonia_deaths", "pneumonia_and_covid_deaths", "all_influenza_deaths_j09_j11"
  )
  by_state <- by_state[by_state$state != "Total US",]

  by_sex$group <- NULL
  colnames(by_sex) <- c(
    "sex", "covid_deaths", "total_deaths", "percent_expected_deaths",
    "pneumonia_deaths", "pneumonia_and_covid_deaths", "all_influenza_deaths_j09_j11"
  )
  by_sex <- by_sex[!grepl("Total", by_sex$sex),]

  list(
    by_week = as_tibble(by_week),
    by_age = as_tibble(by_age),
    by_state = as_tibble(by_state),
    by_sex = as_tibble(by_sex)
  )

}
