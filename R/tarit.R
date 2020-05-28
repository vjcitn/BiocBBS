getver = function(x) { read.dcf(paste0(x, "/DESCRIPTION"))[,"Version"][[1]] }

tarit = function(compiled_pkgfolder) {
   ver = getver(compiled_pkgfolder)
   targ  = paste0(compiled_pkgfolder, "_", ver, ".tar.gz")
   system(paste0("tar czf ", compiled_pkgfolder, "_", ver, ".tar.gz ", compiled_pkgfolder), intern=TRUE)
   targ
}

dotarmv = function(x, dest="~/binmay27") {
    pk = tarit(x)
    system(paste("mv ", pk, " ", dest), intern=TRUE)
   }


#' tar cz a binary package into 'root' folder
#' @param x character(1) package name
#' @param root character(1) folder path where zip will lie
#' @note package name includes R_x86_64-pc-linux-gnu before .tar.gz
zipit = function(x, root="/home/rstudio/zips") { 
  system(sprintf("tar czf %s/%s_%s_R_x86_64-pc-linux-gnu.tar.gz %s", root,
     x, getver(x), x))}
