ps = BiocPkgTools::biocPkgList(version="3.10")
library(BiocBBSpack)
pp = PackageSet(ps$Package)
provision_r = function(pkgset, ncpu=6) {
        vec = pkgset@pkgnames
        BiocManager::install(vec, Ncpus=ncpu)
}
provision_r(pp)

# with 6 CPU in jetstream M1.Xlarge this installed 3355
# packages in 2h20m

# however, valid() showed that this image had 290 old
# experiment data and some old CRAN packages, so
# install([out of date], Ncpus=8) was run
