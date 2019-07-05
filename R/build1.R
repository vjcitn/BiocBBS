prep1 = function(pkgname) {
	ddf = as.data.frame(BiocPkgTools::buildPkgDependencyDataFrame())
	stopifnot(pkgname %in% ddf$Package)
	sdd = split(ddf, ddf$Package)
	targ = sdd[[pkgname]] # little data.frame
	deps = setdiff(targ$dependency, "R")
	ii = rownames(installed.packages())
	to_install = setdiff(deps, ii)
	if (length(to_install)>0) {
	       	ans = try(BiocManager::install(to_install))
		if (inherits(ans, "try-error")) return(ans)
		}
	TRUE
}

#' prepare and build a package tarball
#' @param srcpath character(1) path to source folder for a package
#' @param dest character(1) destination folder
#' @export
build1 = function(srcpath, dest=".", ...) {
	n1 = prep1(basename(srcpath))
	if (n1) build(srcpath, dest, ...)
}
