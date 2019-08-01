#' create tarballs from source folders
#' @param paths vector of paths to R package source folders
#' @param dest location where pkgbuild::build will deliver tarball
#' @param ncores sets options(mc.cores) value
#' @return the result of parallel::mclapply, which may include some try-error objects
#' @note This function will call `build1_with_buildsink` to capture the build log messages in a file.  The file will have suffix `.bldlog.txt`.
#' If the build for package i throws a try-error, that object will be saved in an
#' object basename(paths[i])_err, serialized to basename(paths[i])_err.rda
#' @export
parallel_tarballs = function(paths, dest=".", ncores=6) {
	options(mc.cores=ncores)
	parallel::mclapply(paths, function(x) {
          chk = try(build1_with_buildsink(x, dest))
          if (inherits(chk, "try-error")) {
             errobj = paste0(basename(x), "_err")
             assign(errobj, chk)
             save(get(errobj), file=paste0(errobj, ".rda"))
          }
        chk  # for some runs it may suffice to hand back
        })
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
