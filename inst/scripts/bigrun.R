# crude way of building bioc_tarballs from bioc_sources using R
num_cores = 8
library(pkgbuild)
library(BiocBBSpack)
cands = list_packs_to_update("../bioc_sources", ".")
library(parallel)
options(mc.cores=num_cores)
chk = mclapply(cands, function(x) {Sys.sleep(runif(1, 2, 6)); try(build1(x, "."))})
save(chk, file="../chk.rda")
Sys.sleep(30)
chk2 = mclapply(cands, function(x) {Sys.sleep(runif(1, 2, 6)); try(build1(x, "."))})
save(chk2, file="../chk2.rda")
