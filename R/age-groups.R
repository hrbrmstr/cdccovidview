#' Return age groups used in the surveillance
#'
#' @return character vector
#' @export
age_groups <- function() {

  p <- app_params()

  rev(p$ages$label)

}
