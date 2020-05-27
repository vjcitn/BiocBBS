#' generate a list of packages using the manifest
#' @note you may need credentials to clone the manifest repo
#' @param rel character(1) release identifier, defaults to `RELEASE_3_10`
#' @return a character vector of all packages named in selected release
#' @export
get_bioc_packagelist = function(rel = "RELEASE_3_11") {
 system("git clone https://git.bioconductor.org/admin/manifest")
 owd = getwd()
 setwd("manifest")
 on.exit(setwd(owd))
 system(paste("git checkout ", rel))
 proc_software.txt = function() {
  x = readLines("software.txt")[-1]  # first line is comment
  nn = which(nchar(x)==0)
  tmp = x[-nn]
  gsub("Package: ", "", tmp)
 }
 proc_software.txt()
}

