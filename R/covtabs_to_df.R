#' convert result of a collection of `covr_tab.coverage` results to a single data.frame
#' @param x a list of results of `covr_tab.coverage`
#' @return a data.frame instane with columns `package`, `func`, and `pctcov`
#' @export
covtabs_to_df = function(x) {
  repts = lapply(x, "[[", 2) # ignore overall
  lens = sapply(repts, length)
  pknames = rep(basename(names(repts)), lens)
  repdfs = lapply(repts, function(z) data.frame(func=basename(names(z)), pctcov=as.numeric(z), 
     stringsAsFactors=FALSE))
  dat = do.call(rbind, repdfs)
  ans = data.frame(package=pknames, dat, stringsAsFactors=FALSE) 
  rownames(ans) = NULL
  ans
}
