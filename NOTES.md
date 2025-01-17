Installing the package locally for development with Nix:

```r
lib_local <- ".lib_local"
withr::with_libpaths(lib_local, devtools::install(quick = FALSE))
withr::with_libpaths(lib_local, require(rankGap))
```