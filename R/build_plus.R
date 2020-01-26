
#' use rcmdcheck and BiocCheck on a folder with package source checked out
#' @param folder source folder for R package
#' @param error_on character(1) see rcmdcheck::rcmdcheck; default is to proceed when error occurs in a check stage
#' @export
build_plus = function(folder, error_on="never") {
 td = tempdir()
 curd = getwd()
 on.exit({
   setwd(curd)
   #close(tff)
   #try(rm(tf), silent=TRUE)
   })
 setwd(td)
 newf = paste0(curd, "/", folder)
 stopifnot(dir.exists(newf))
 pkgbuild::build(newf, dest_path=".")
 fn = grep(basename(newf), dir(full.names=TRUE), value=TRUE)
 stopifnot(length(fn)==1)
 chkt = grep("tar.gz", fn)
 stopifnot(length(chkt)==1)
 c1 = rcmdcheck::rcmdcheck(path=fn, error_on=error_on)
 rcc = rcmdcheck::check_details(c1)
 tf = tempfile()
 tff = file(tf, "w")
 sink(tff, type="message")
 bcc = BiocCheck::BiocCheck(fn)
 sink(NULL)
 list(rcc=rcc, bcc=bcc, bcc_details=readLines(tf))
}
