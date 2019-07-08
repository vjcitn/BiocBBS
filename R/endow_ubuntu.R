#' output of sudo apt --list installed for a suitable ubuntu environment
#' @return a path
#' @export
default_packtxt = function()
 system.file("ubuntu/ubuntu_18.04_installed_apt.txt",
   package="BiocBBSpack")

#' use sudo apt-get in system() to endow and ubuntu system for BBS activities
#' @param packtxtfun a function providing a path to output of sudo apt --list installed
#' @note Uses sudo apt-get install.  Also, there will be a EULA query and a services query that must be handled interactively.
#' @return Value of system().
#' @export
endow_ubuntu = function(packtxtfun = default_packtxt) {
  allp = readLines(packtxtfun())
  cln = gsub("/.*", "", allp[-1])  # drop first record 'listing...'
  string = paste(cln, collapse=" ")
  tf = tempfile()
  writeLines(string, tf)
  on.exit(unlink(tf))
  system(paste("sudo apt-get install ", tf, collapse = " "))
}


