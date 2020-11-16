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

# Transcript of work in AnVIL, 15 Nov 2020


This workspace develops code for creating an R package library sufficient to install, build and check all Bioconductor software packages.
There is a need for a fault-tolerant approach.  Crucial risks are

- the /tmp folder will fill up, so, prior to starting R, set TMPDIR to a folder with sufficient space
- `R CMD INSTALL` will not find the newly installed packages unless they are installed to a folder in the value of `.libPaths()`, so use `.Rprofile` to set this
- R 4.0.3 installation will time out, but `options(timeout=180)`

Here's what we started out with
```
BiocManager::install("vjcitn/BiocBBSpack")  # this has a function to acquire the list of packages in a release using the manifest repo
library(BiocBBSpack)
pks = get_bioc_packagelist(rel="RELEASE_3_12")
todo = unique(c(pks, unlist(lapply(.libPaths(), dir))))
length(todo)  # 2177
dir.create("repo_3_12")
BiocManager::install(pks, lib="repo_3_12", Ncpus=45)
```

The above yielded 1343 packages in `repo_3_12`.  We returned and continued with:
```
library(BiocBBSpack)
pks = try(get_bioc_packagelist(rel="RELEASE_3_12"))
done = dir("repo_3_12") 
todo = setdiff(pks, done)
print(length(todo))  # 
BiocManager::install(todo, lib="repo_3_12", Ncpus=45)
```
but that did not succeed.  We needed to have .Rprofile update the .libPaths() to include the new repo destination, so it
has the line
```
.libPaths(c("/home/rstudio/repo_3_12", .libPaths()))
```
and now
```
library(BiocBBSpack)
pks = try(get_bioc_packagelist(rel="RELEASE_3_12"))
done = dir("repo_3_12") 
todo = setdiff(pks, done)
print(length(todo))  #
.libPaths(c("repo_3_12", .libPaths())) # not enough because INSTALL uses R CMD ... and .Rprofile must be used to set this?
stopifnot("/home/rstudio/repo_3_12" %in% .libPaths())
options(timeout=180)  # helpful for big downloads
BiocManager::install(todo, lib="repo_3_12", Ncpus=50)
```
runs.  `repo_3_12` has 3125 packages at the end; 97 members of `pks` fail to install on 15 Nov 2020.

# Here is how we go about acquiring sources for build and check

```
dir.create("gits_3_12")
pks = get_bioc_packagelist(rel="RELEASE_3_12")
ps = PackageSet(pks)
populate_local_gits(ps, "gits_3_12")
```

That process took 35 minutes on a large instance in GCP.
