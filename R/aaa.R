httr::user_agent(
  sprintf(
    "cdccovidview package v%s: (<%s>)",
    utils::packageVersion("cdccovidview"),
    utils::packageDescription("cdccovidview")$URL
  )
) -> .CDCCOVIDVIEW_UA

