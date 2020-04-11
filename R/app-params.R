.app_params <- function() {

  httr::GET(
    url = "https://gis.cdc.gov/grasp/COVIDNet/InitJSON/covid_phase03_init.json",
    .CDCCOVIDVIEW_UA
  ) -> res

  httr::stop_for_status(res)

  if (has_bom(res)) {
    out <- sans_bom(res)
  } else {
    out <- httr::content(res, as = "text")
  }

  out <- jsonlite::fromJSON(out)

  out

}

app_params <- memoise::memoise(.app_params)
