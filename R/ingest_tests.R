#' ingest test sources for a package
#' @param src_folder path to an R package folder tree (i.e., folder that includes DESCRIPTION)
#' @return named list with one element per test file
#' @note looks for files in tests/testthat and inst/unitTests and applies readLines to these
#' @export
ingest_tests = function(src_folder) {
 anstt = NULL
 ansut = NULL
 if (dir.exists(tdir <- paste0(src_folder, "/tests"))) {
   if (dir.exists(ttdir <- paste0(tdir, "/testthat"))) {
     anstt = lapply(fn <- dir(ttdir, full.names=TRUE), readLines)
     names(anstt) = fn
     }
   }
 if (dir.exists(tdir <- paste0(src_folder, "/inst/unitTests"))) {
     fn <- dir(tdir, full.names=TRUE)
     ok = sapply(fn, function(x) !dir.exists(x))
     if (any(!ok)) fn = fn[which(ok)]
     ansut = lapply(fn, readLines)
     names(ansut) = fn
 }
 return(c(anstt, ansut))
}
