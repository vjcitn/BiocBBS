#' use HTTPS to clone a package from Bioconductor git
#' @param x character(1) package name expected to be a Bioconductor package in git
#' @return result of system()
#' @examples
#' td = tempdir()
#' wd = getwd()
#' setwd(td)
#' lk = getpk("parody")
#' if (FALSE) lk2 = try(getpk("parody_z")) # should fail
#' setwd(wd)
#' @export
getpk = function (x) 
system(sprintf("git clone --depth 1 https://git.bioconductor.org/packages/%s.git", 
    x))

#' get vector of Bioc software package names
#' @import BiocPkgTools
#' @return character vector
#' @export
bioc_software_packagelist = function() {
	ddf = buildPkgDependencyDataFrame()
	unique(ddf$Package)
}
