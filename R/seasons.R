#' Show available seasons
#'
#' @return data frame
#' @export
available_seasons <- function() {

  p <- app_params()

  out <- p$seasons[, c("description", "seasonid", "startweek", "endweek")]

  as_tibble(out)

}





