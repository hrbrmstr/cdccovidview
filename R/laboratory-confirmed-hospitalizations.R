#' Retrieve Laboratory-Confirmed COVID-19-Associated Hospitalizations
#'
#' This function grabs all data for all networks, catchments, seasons, and ages.
#' In the future there will be ways of selecting just the desired target areas.
#'
#' @return data frame
#' @export
laboratory_confirmed_hospitalizations <- function() {

  p <- cdccovidview:::app_params()

  catch <- p$catchments[, c("networkid", "name", "area", "catchmentid")]

  age_grp <- p$ages[, c("label", "ageid")]

  seas <- p$seasons[, "seasonid", drop=FALSE]
  colnames(seas) <- "ID"

  .get_one <- function(net_id = 1, cat_id = 22) {

    unclass(jsonlite::toJSON(list(
      AppVersion = jsonlite::unbox("Public"),
      networkid = jsonlite::unbox(as.integer(net_id)),
      catchmentid = jsonlite::unbox(as.integer(cat_id)),
      seasons = seas,
      agegroups = data.frame(ID = 1:9L)
    ))) -> body

    c(
      `Content-Type` = 'application/json;charset=UTF-8'
    ) -> headers

    httr::POST(
      url = 'https://gis.cdc.gov/grasp/covid19_3_api/PostPhase03DownloadData', httr::add_headers(.headers=headers),
      .CDCCOVIDVIEW_UA,
      body = body
    ) -> res

    httr::stop_for_status(res)

    if (has_bom(res)) {
      out <- sans_bom(res)
    } else {
      out <- httr::content(res, as = "text")
    }

    out <- jsonlite::fromJSON(out)

    out <- as_tibble(out$datadownload)

    colnames(out) <- gsub("-", "_", colnames(out))

    out

  }

  lapply(1:nrow(catch), function(.idx) {
    .get_one(
      net_id = catch$networkid[.idx],
      cat_id = catch$catchmentid[.idx]
    )
  }) -> res

  out <- do.call(rbind.data.frame, res)

  as_tibble(out)

}
