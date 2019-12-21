#' NOT EXPORTED -- use docker, bioconductor/bioconductor_full:(devel or release)
#' output of sudo apt list --installed for a suitable ubuntu environment
#' @return a path
default_packtxt = function()
 system.file("ubuntu/ubuntu_18.04_installed_apt.txt",
   package="BiocBBSpack")

#' NOT EXPORTED -- use docker, bioconductor/bioconductor_full:(devel or release)
#' use sudo apt-get in system() to provision an ubuntu system for BBS activities
#' @param packtxtfun a function providing a path to output of sudo apt --list installed
#' @note Uses sudo apt-get install.  Also, there will be a EULA query and a services query that must be handled interactively.
#' it may be necessary to use commands  sudo add-apt-repository -y ppa:opencpu/poppler;
#'    sudo apt-get update
#'    sudo sudo apt-get install -y libpoppler-cpp-dev
#' @return Value of system().
provision_ubuntu = function(packtxtfun = default_packtxt) {
  allp = readLines(packtxtfun())
  cln = gsub("/.*", "", allp[-1])  # drop first record 'listing...'
  string = paste(cln, collapse=" ")
  tf = tempfile()
  writeLines(string, tf)
  on.exit(unlink(tf))
  system(paste("sudo apt-get install ", readLines(tf), collapse = " "))
}

#' NOT EXPORTED -- use docker, bioconductor/bioconductor_full:(devel or release)
#' list ubuntu packages that are needed but have not been installed
#' @note will use apt list --installed and a warning will come back as apt has no stable CLI interface
find_needed_ubuntu_packages = function() {
  req_allp = readLines(default_packtxt())
  req_cln = gsub("/.*", "", req_allp[-1])  # drop first record 'listing...'
  exist = system("apt list --installed", intern=TRUE)
  exist_cln = gsub("/.*", "", exist[-1])  # drop first record 'listing...'
  setdiff(req_cln, exist_cln)
}
