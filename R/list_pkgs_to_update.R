find_impacted = function(beh, vers, ddf=NULL) {
	if (is.null(ddf)) ddf = buildPkgDependencyDataFrame(vers=vers,
	    dependencies=c("Depends", "Imports", "Suggests", "LinkingTo"))
	newpks = unlist(ddf[which(ddf$dependency %in% beh), "Package"])
	if (all(newpks %in% beh)) return(beh)
	beh = union(newpks, beh)
	Recall(beh, vers, ddf)
}
	
list_pkgs_to_update = function(gitspath, vers="3.11") {
	beh = local_gits_behind_bioc(gitspath, biocversion=vers)
	find_impacted(beh, vers)
}
