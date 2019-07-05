# BiocBBSpack
sketch of build system shortcuts
..

basic ideas:

to populate a folder with clones of all software packages in
Bioconductor git:

```
library(BiocBBSpack) # uses BiocPkgTools
sapply(bioc_software_packagelist(), getpk)
```

to build a tarball for a package (R CMD build, using pkgbuild package)
use `build1(), which will install, as needed, all dependencies identified
in `BiocPkgTools::buildPkgDependencyDataFrame()` before running
`pkgbuild::build`

For ubuntu 18.04, the linux package set is listed in inst/ubuntu
