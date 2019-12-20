
#' check a repo for activity at remote, specifically modifications to DESCRIPTION
#' @param repo_path character(1) path for a git repo
#' @return a vector of results of git diff
#' @note Main purpose is to achieve the side effect of git pull in the 
#' repo when appropriate.  R session visits repo, performs git commands using
#' system(), and returns to folder where this function was called.
#' @export
check_for_update_and_pull = function( repo_path ) {
	cmd1 = "git fetch origin master"
	cmd2 = "git diff FETCH_HEAD -- ./DESCRIPTION"
	cmd3 = "git pull"
	curd = getwd()
	setwd( repo_path )
	on.exit( setwd(curd) )
	system(cmd1, intern=TRUE)
	lk = system(cmd2, intern=TRUE)
	if (length(lk)>0) system(cmd3, intern=TRUE)
}

