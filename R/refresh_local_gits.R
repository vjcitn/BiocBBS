#' perform git pull for modified packages in a repo collection
#' @param gitspath character(1) path to repos
#' @param version character(1) version tag for Bioconductor packages
#' @note Simply uses lapply to visit folders and run 'git pull' in system()
#' @return list of folder names visited
#' @export
refresh_local_gits = function(gitspath, version="3.11") {
	beh = local_gits_behind_bioc(gitspath, "3.11")
	beh = paste0(gitspath, "/", beh)
	lapply(beh, function(x) {curd = getwd(); setwd(x); system("git pull", intern=TRUE); setwd(curd)})
}

