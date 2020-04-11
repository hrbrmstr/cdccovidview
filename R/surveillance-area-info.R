#' Show network & network catchments
#'
#' @return data frame
#' @export
surveillance_areas <- function() {

  p <- app_params()

  out <- p$catchments[,c("name", "area")]

  as_tibble(out)

}