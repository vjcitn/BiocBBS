#' tar cz a binary package into 'root' folder
#' @param x character(1) package name
#' @param root character(1) folder path where zip will lie
#' @note package name includes R_x86_64-pc-linux-gnu before .tar.gz
zipit = function(x, root="/home/rstudio/zips") { 
  system(sprintf("tar czf %s/%s_%s_R_x86_64-pc-linux-gnu.tar.gz %s", root,
     x, getver(x), x))}
