prep1 = function(pkgname) {
        dtypes = c("Depends", "Imports", "Suggests", "LinkingTo")
	ddf = as.data.frame(
           BiocPkgTools::buildPkgDependencyDataFrame(dependencies=dtypes))
	stopifnot(pkgname %in% ddf$Package)
	sdd = split(ddf, ddf$Package)
	targ = sdd[[pkgname]] # little data.frame
	deps = setdiff(targ$dependency, "R")
	ii = rownames(installed.packages())
	to_install = setdiff(deps, ii)
	if (length(to_install)>0) {
	       	ans = try(BiocManager::install(to_install, ask=FALSE, update=FALSE))
		if (inherits(ans, "try-error")) return(ans)
		}
	TRUE
}

#' prepare and build a package tarball
#' @param srcpath character(1) path to source folder for a package
#' @param dest character(1) destination folder
#' @note If preparation for building triggers a try-error, the resulting 
#' exception object is returned.  Otherwise the result of pkgbuild::build()
#' is returned.
#' @export
build1 = function(srcpath, dest=".", ...) {
	n1 = prep1(basename(srcpath))
        if (!is(n1, "logical")) return(n1)
	if (n1) try(pkgbuild::build(srcpath, dest, ...))
}
