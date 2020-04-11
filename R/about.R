#' Display information about the data source
#'
#' @param display if `html` (the default) a formatted version of
#'     the description is provided, otherwise a plaintext version
#'     will be provided.
#' @export
about <- function(display = c("html", "text")) {

  display <- match.arg(display, c("html", "text"))

  p <- app_params()

  if (display == "html") {

    p$app_text[
      p$app_text$description %in% c("HTMLSplashDisclaimer"),
    ]$text -> splsh

    htmltools::html_print(
      htmltools::div(
        htmltools::HTML(splsh),
        style = "margin:10%; font-family:sans-serif"
      )
    )

  } else {

    p$app_text[
      p$app_text$description %in% c("ImageExportDisclaimer"),
    ]$text -> splsh

    cat(strwrap(splsh), sep="\n")

  }

}
