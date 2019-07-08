#' create tarballs from source folders
#' @param paths vector of paths to R package source folders
#' @param dest location where pkgbuild::build will deliver tarball
#' @param ncores sets options(mc.cores) value
#' @export
parallel_tarballs = function(paths, dest=".", ncores=6) {
	options(mc.cores=ncores)
	todo = dir("../bioc_sources", full.names=TRUE)
	ans = parallel::mclapply(paths, function(x) try(build1(x, dest)))
	res = list(todo=todo, ans=ans)
	save(res, file="res.rda")
}

#' compare destdir to srcdir and list package paths needing tarballs
#' @param srcdir folder holding multiple R package source folders
#' @param destdir folder where tarballs may be found
#' @note Elementary filename processing only -- no version checking at this time
#' @export
list_packs_to_update = function(srcdir, destdir) {
	done = dir(destdir, pattern="tar.gz")
	done = gsub("_.*", "", done)
	todo = dir(srcdir)
	todof = dir(srcdir, full.names=TRUE)
	names(todof) = todo
	todo = setdiff(todo, done)
	todof[todo]
}
