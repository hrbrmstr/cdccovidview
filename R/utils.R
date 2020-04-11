clean_int <- function(x) {
  suppressWarnings(as.integer(gsub(",", "", x)))
}

clean_num <- function(x) {
  suppressWarnings(as.numeric(gsub(",", "", x)))
}

set_names <- function(object = nm, nm) { names(object) <- nm ; object }

as_tibble <- function(x) {
  class(x) <- c("tbl_df", "tbl", "data.frame")
  x
}

tibble <- function(...) {
  as_tibble(data.frame(..., stringsAsFactors = FALSE))
}

# Tests whether a raw httr response or character vector has a byte order mark (BOM)
has_bom <- function(resp, encoding="UTF-8") {
  if (inherits(resp, "response")) {
    F <- resp$content[1:4]
    switch(encoding,
           `UTF-8`=F[1]==as.raw(0xef) & F[2]==as.raw(0xbb) & F[3]==as.raw(0xbf),
           `UTF-16`=F[1]==as.raw(0xff) & F[2]==as.raw(0xfe),
           `UTF-16BE`=F[1]==as.raw(0xfe) & F[2]==as.raw(0xff),
           { message("Unsupported encoding") ; return(NA) }
    )
  } else if (inherits(resp, "character")) {
    switch(encoding,
           `UTF-8`=grepl("^ï»¿", resp[1]),
           `UTF-16`=grepl("^ÿþ", resp[1]),
           `UTF-16BE`=grepl("^þÿ", resp[1]),
           { message("Unsupported encoding") ; return(NA) }
    )
  } else {
    message("Expected either an httr::response object or a character")
    return(NA)
  }
}

# Remove byte order mark (BOM) from \code{httr::response} object or character vector
sans_bom <- function(resp) {

  if (inherits(resp, "response")) {

    F <- resp$content[1:4]
    if (F[1]==as.raw(0xef) & F[2]==as.raw(0xbb) & F[3]==as.raw(0xbf)) {
      iconv(readBin(resp$content[4:length(resp$content)], character()), from="UTF-8", to="UTF-8")
    } else if (F[1]==as.raw(0xff) & F[2]==as.raw(0xfe)) {
      iconv(readBin(resp$content[3:length(resp$content)], character()), from="UTF-16", to="UTF-8")
    } else if (F[1]==as.raw(0xfe) & F[2]==as.raw(0xff)) {
      iconv(readBin(resp$content[3:length(resp$content)], character()), from="UTF-16BE", to="UTF-8")
    } else {
      stop("Did not detect a BOM in the httr::response object content.", call.=FALSE)
    }

  } else if (inherits(resp, "character")) {

    if (grepl("^ï»¿", resp[1])) {
      iconv(readBin(sub("^ï»¿", "", resp), character()), from="UTF-8", to="UTF-8")
    } else if (grepl("^ÿþ", resp[1])) {
      iconv(readBin(sub("^ÿþ", "", resp), character()), from="UTF-16", to="UTF-8")
    } else if (grepl("^þÿ", resp[1])) {
      iconv(readBin(sub("^þÿ", "", resp), character()), from="UTF-16BE", to="UTF-8")
    } else {
      stop("Did not detect a BOM in the content.", call.=FALSE)
    }

  } else {
    stop("Expected either an httr::response object or a character", call.=FALSE)
  }
}
