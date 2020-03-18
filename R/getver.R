#' in folder superior to a built package, retrieve version
#' @param x character(1) name of folder holding built package
#' @export
getver = function(x) { read.dcf(paste0(x, "/DESCRIPTION"))[,"Version"][[1]] }
