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
  res$covid_deaths <- cdccovidview:::clean_int(res$covid_deaths)
  res$total_deaths <- cdccovidview:::clean_int(res$total_deaths)
  res$percent_expected_deaths <- cdccovidview:::clean_num(res$percent_expected_deaths)
  res$pneumonia_deaths <- cdccovidview:::clean_int(res$pneumonia_deaths)
  res$pneumonia_and_covid_deaths <- cdccovidview:::clean_int(res$pneumonia_and_covid_deaths)
  res$all_influenza_deaths_j09_j11 <-cdccovidview::: clean_int(res$all_influenza_deaths_j09_j11)
  res$pneumonia_influenza_and_covid_19_deaths <- cdccovidview:::clean_int(res$pneumonia_influenza_and_covid_19_deaths)

  by_week <- res[res$group == "By week", ]
  by_age <- res[res$group == "By age", ]
  by_state <- res[res$group == "By state", ]
  by_sex <- res[res$group == "By sex", ]

  by_week <- by_week[!grepl("total", tolower(by_week$indicator)), ]
  by_week$group <- NULL
  by_week$indicator <- NULL
  by_week$footnote <- NULL
  by_week$state <- NULL
  by_week$start_week <- as.Date(by_week$start_week)
  by_week$end_week <- as.Date(by_week$end_week)
  by_week$data_as_of <- as.Date(by_week$data_as_of)
  colnames(by_week) <- c("data_as_of", "start_week", "end_week", "covid_deaths", "total_deaths",
                         "percent_expected_deaths", "pneumonia_deaths", "pneumonia_and_covid_deaths",
                         "all_influenza_deaths_j09_j11", "pneumonia_influenza_and_covid_19_deaths",
                         "pneumonia_influenza_and_covid_deaths")

  by_age$group <- NULL
  by_age$footnote <- NULL
  by_age$state <- NULL
  by_age$pneumonia_influenza_and_covid_19_deaths <- NULL

  colnames(by_age) <- c("data_as_of", "age_group", "start_week", "end_week", "covid_deaths", "total_deaths",
                        "percent_expected_deaths", "pneumonia_deaths", "pneumonia_and_covid_deaths",
                        "all_influenza_deaths_j09_j11",
                        "pneumonia_influenza_and_covid_deaths")
  by_age$age_group <- sub("&ndash;", "-", by_age$age_group,
                          fixed = TRUE)
  by_age$age_group <- sub("yea.*", "yr", by_age$age_group)
  by_age$data_as_of <- as.Date(by_age$data_as_of)
  by_age$start_week <- as.Date(by_age$start_week)
  by_age$end_week <- as.Date(by_age$end_week)


  by_state$group <- NULL
  by_state$footnote <- NULL
  by_state$indicator <- NULL
  by_state$pneumonia_influenza_and_covid_19_deaths <- NULL

  by_state$data_as_of <- as.Date(by_state$data_as_of)
  by_state$start_week <- as.Date(by_state$start_week)
  by_state$end_week <- as.Date(by_state$end_week)
  colnames(by_state) <- c("data_as_of", "state", "start_week", "end_week", "covid_deaths", "total_deaths",
                          "percent_expected_deaths", "pneumonia_deaths", "pneumonia_and_covid_deaths",
                          "all_influenza_deaths_j09_j11",
                          "pneumonia_influenza_and_covid_deaths")
  by_state <- by_state[by_state$state != "United States", ]


  by_sex$group <- NULL
  by_sex$footnote <- NULL
  by_sex$state <- NULL
  by_sex$pneumonia_influenza_and_covid_19_deaths <- NULL

  by_sex$data_as_of <- as.Date(by_sex$data_as_of)
  by_sex$start_week <- as.Date(by_sex$start_week)
  by_sex$end_week <- as.Date(by_sex$end_week)


  colnames(by_sex) <- c("data_as_of", "sex", "start_week", "end_week", "covid_deaths", "total_deaths",
                        "percent_expected_deaths", "pneumonia_deaths", "pneumonia_and_covid_deaths",
                        "all_influenza_deaths_j09_j11",
                        "pneumonia_influenza_and_covid_deaths")

  by_sex <- by_sex[!grepl("Total deaths", by_sex$sex), ]
  list(by_week = as_tibble(by_week), by_age = as_tibble(by_age),
       by_state = as_tibble(by_state), by_sex = as_tibble(by_sex))

}
