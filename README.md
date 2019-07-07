# BiocBBSpack
sketch of build system shortcuts
..

Major issue to make this work: [pkgbuild](https://github.com/r-lib/pkgbuild) had to be modified to avoid querying user on actions taken on inst/doc contents when present
the fork with a special version number is at [github.com/vjcitn](https://github.com/vjcitn/pkgbuild).

See [this issue](https://github.com/vjcitn/BiocBBSpack/issues/7#issue-464989015) for basic layout of tasks working as of July 7 2019, leading to configuration of a linux builder and creation of 1700 software tarballs in half a day on a 24 core machine with 60GB RAM; the builder configuration is about 3h and does not need to be repeated in extenso; the tarball creation is 2 minutes/package/core on average.

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
