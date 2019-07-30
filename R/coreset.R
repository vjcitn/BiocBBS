#' define a small collection of packages of interest
#' @return a character vector
#' @examples
#' coreset()
#' @export
coreset = function() {
 c("SummarizedExperiment", "GenomicRanges",
   "BiocFileCache", "Rsamtools", "rhdf5", 
   "SingleCellExperiment", "ensembldb", "parody")
}

setOldClass("biocPkgList")

setClass("PackageSet",
  representation(pkgnames="character",
    dependencies="list", info="biocPkgList"))

#' constructor for PackageSet instances
#' @param cvec character() vector
#' @note Will issue message if some element of cvec is not
#' found in BiocPkgTools::biocPkgList() result
#' @export
PackageSet = function(cvec) {
 all_info = BiocPkgTools::biocPkgList()
 odd = setdiff(cvec, all_info$Package)
 if (length(odd)>0) message("Some elements of cvec are not in Bioconductor.")
 info = all_info[which(all_info$Package %in% cvec),]
 new("PackageSet", pkgnames=cvec, info=info)
}

setMethod("show", "PackageSet",
  function(object) {
  cat("BiocBBSpack PackageSet instance.\n")
  cat(sprintf(" There are %s packages listed.\n", 
    length(object@pkgnames)))
  cat(sprintf(" There are %s unique dependencies listed.\n", 
    length(unique(unlist(object@dependencies)))))
})

#' a vector listing the key dependencies with correct orthography
#' @return character vector
#' @examples
#' full_dep_opts()
#' @export
full_dep_opts = function() c("Depends", "Imports", "LinkingTo", "Suggests")

.add_dependencies = function(pkgset, deps, omit="R") {
  full_pkg_tbl = BiocPkgTools::buildPkgDependencyDataFrame(
    dependencies = deps)
  kp = full_pkg_tbl[ which(full_pkg_tbl$Package %in% pkgset@pkgnames), ]
  deplist = split(kp$dependency, kp$Package)
  if (length(omit)>0) deplist = lapply(deplist, function(x) setdiff(x, omit))
  pkgset@dependencies = deplist
  pkgset
}

setGeneric("add_dependencies", function(pkgset, deps=full_dep_opts(),
      omit="R")
  standardGeneric("add_dependencies"))
#' @export
setMethod("add_dependencies", "PackageSet",
   function(pkgset, deps, omit="R") {
   .add_dependencies(pkgset, deps, omit)
   })
  
#' use git via BiocBBSpack::getpk to retrieve sources into a folder
#' @param pkgset instance of PackageSet
#' @param gitspath character(1) folder to be created if it does not exist
#' @return invisibly, the list of folders created under gitspath
#' @examples
#' ps = PackageSet(coreset()[c(3,8)]) # two simple packages
#' td = tempdir()
#' ll = populate_local_gits(ps, td)
#' ll
#' @export
populate_local_gits = function(pkgset, gitspath) {
   if (!dir.exists(gitspath)) dir.create(gitspath)
   curd = getwd()
   on.exit(setwd(curd))
   setwd(gitspath)
   ans = lapply(pkgset@pkgnames, function(x) try(getpk(x)))
   chk = sapply(ans, inherits, "try-error")
   if (any(chk)) message("there was a try-error thrown; check contents of gitspath")
   invisible(dir())
}

read_descriptions = function(gitspath, fields=c("Package", "Version")) {
 stopifnot(dir.exists(gitspath))
 tops = dir(gitspath, full=TRUE)
 ds = paste0(tops, "/DESCRIPTION")
 lapply(ds, read.dcf, fields=fields)
}

#' check all repos in a folder for version entry less than
#' the one reported by BiocPkgTools::biocPkgList
#' @param gitspath character(1) folder where repos for packages are cloned
#' @note DESCRIPTION will be read from each folder in gitspath.
#' @return a character vector of names of packages whose git sources are out of date
#' @examples
#' ps = PackageSet(coreset()[c(3,8)]) # two simple packages
#' tf = tempfile()
#' dir.create(tf)
#' ll = populate_local_gits(ps, tf)
#' curd = getwd()
#' setwd(tf)
#' pd = readLines("parody/DESCRIPTION")
#' pd = gsub("Version.*", "Version: 1.0", pd)
#' writeLines(pd, "parody/DESCRIPTION")
#' local_gits_behind_bioc(tf)
#' setwd(curd)
#' unlink(tf)
#' @export
local_gits_behind_bioc = function(gitspath) {
 ds = read_descriptions(gitspath)
 curinfo = BiocPkgTools::biocPkgList()
 pks = sapply(ds, "[", 1)
 info = curinfo[which(curinfo$Package %in% pks), c("Package", "Version")]
 basevers = info$Version
 names(basevers) = info$Package
 basevers = basevers[pks] # ensure common ordering
 vs = sapply(ds, "[", 2)
 chk = which(vs < basevers)
 pks[chk]
}

#' provide a list of packages for which dependencies are not installed
#' @export
local_gits_with_uninstalled_dependencies = function(gitspath,
   dependencies = c("Depends", "Imports", "LinkingTo")) {
 pks = dir(gitspath)
 pset = PackageSet(pks)
 pset = add_dependencies(pset, deps=dependencies) # may not want Suggests
 all_needed = unique(c(pset@pkgnames, unlist(pset@dependencies)))
 allinst = rownames(installed.packages())
 absent = setdiff(all_needed, allinst)
 chk = lapply(pset@dependencies, function(x)
    intersect(x, absent))
 hasabs = sapply(chk, function(x) length(x)>0)
 chk[hasabs]
}
