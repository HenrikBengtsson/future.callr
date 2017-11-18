# future.callr: A Future API for Parallel Processing using 'callr'

## Introduction
The [future] package provides a generic API for using futures in R.
A future is a simple yet powerful mechanism to evaluate an R expression
and retrieve its value at some point in time.  Futures can be resolved
in many different ways depending on which strategy is used.
There are various types of synchronous and asynchronous futures to
choose from in the [future] package.

This package, [future.callr], provides a type of futures that
utilizes the [callr] package.

For example,
```r
> library("future.callr")
> plan(callr)
>
> x %<-% { Sys.sleep(5); 3.14 }
> y %<-% { Sys.sleep(5); 2.71 }
> x + y
[1] 5.85
```
This is obviously a toy example to illustrate what futures look like
and how to work with them.


## Using the callr backend
The future.callr package implements a future wrapper for callr.


| Backend | Description                                                      | Alternative in future package
|:--------|:-----------------------------------------------------------------|:------------------------------
| `callr` | parallel evaluation in a separate R process (on current machine) | `plan(multisession)`


## Demos
The [future] package provides a demo using futures for calculating a
set of Mandelbrot planes.  The demo does not assume anything about
what type of futures are used.
_The user has full control of how futures are evaluated_.
For instance, to use callr futures, run the demo as:
```r
library("future.callr")
plan(callr)
demo("mandelbrot", package = "future", ask = FALSE)
```


[callr]: https://cran.r-project.org/package=callr
[future]: https://cran.r-project.org/package=future
[future.callr]: https://github.com/HenrikBengtsson/callr

## Installation
R package future.callr is only available via [GitHub](https://github.com/HenrikBengtsson/future.callr) and can be installed in R as:
```r
source('http://callr.org/install#HenrikBengtsson/future.callr')
```

### Pre-release version

To install the pre-release version that is available in Git branch `develop` on GitHub, use:
```r
source('http://callr.org/install#HenrikBengtsson/future.callr@develop')
```
This will install the package from source.  



## Contributions

This Git repository uses the [Git Flow](http://nvie.com/posts/a-successful-git-branching-model/) branching model (the [`git flow`](https://github.com/petervanderdoes/gitflow-avh) extension is useful for this).  The [`develop`](https://github.com/HenrikBengtsson/future.callr/tree/develop) branch contains the latest contributions and other code that will appear in the next release, and the [`master`](https://github.com/HenrikBengtsson/future.callr) branch contains the code of the latest release.

Contributing to this package is easy.  Just send a [pull request](https://help.github.com/articles/using-pull-requests/).  When you send your PR, make sure `develop` is the destination branch on the [future.callr repository](https://github.com/HenrikBengtsson/future.callr).  Your PR should pass `R CMD check --as-cran`, which will also be checked by <a href="https://travis-ci.org/HenrikBengtsson/future.callr">Travis CI</a> and <a href="https://ci.appveyor.com/project/HenrikBengtsson/future-callr">AppVeyor CI</a> when the PR is submitted.


## Software status

| Resource:     | GitHub        | Travis CI       | Appveyor         |
| ------------- | ------------------- | --------------- | ---------------- |
| _Platforms:_  | _Multiple_          | _Linux & macOS_ | _Windows_        |
| R CMD check   |  | <a href="https://travis-ci.org/HenrikBengtsson/future.callr"><img src="https://travis-ci.org/HenrikBengtsson/future.callr.svg" alt="Build status"></a>   | <a href="https://ci.appveyor.com/project/HenrikBengtsson/future-callr"><img src="https://ci.appveyor.com/api/projects/status/github/HenrikBengtsson/future.callr?svg=true" alt="Build status"></a> |
| Test coverage |                     | <a href="https://codecov.io/gh/HenrikBengtsson/future.callr"><img src="https://codecov.io/gh/HenrikBengtsson/future.callr/branch/develop/graph/badge.svg" alt="Coverage Status"/></a>     |                  |
