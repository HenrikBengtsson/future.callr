# future.processx: A Future API for Parallel Processing using 'processx'

## Introduction
The [future] package provides a generic API for using futures in R.
A future is a simple yet powerful mechanism to evaluate an R expression
and retrieve its value at some point in time.  Futures can be resolved
in many different ways depending on which strategy is used.
There are various types of synchronous and asynchronous futures to
choose from in the [future] package.

This package, [future.processx], provides a type of futures that
utilizes the [processx] package.

For example,
```r
> library("future.processx")
> plan(processx)
>
> x %<-% { Sys.sleep(5); 3.14 }
> y %<-% { Sys.sleep(5); 2.71 }
> x + y
[1] 5.85
```
This is obviously a toy example to illustrate what futures look like
and how to work with them.


## Using the processx backend
The future.processx package implements a future wrapper for processx.


| Backend                  | Description                                                              | Alternative in future package
|:-------------------------|:-------------------------------------------------------------------------|:------------------------------------
| `processx`          | sequential evaluation in a separate R process (on current machine)       | `plan(processx, workers = 4L)`


## Demos
The [future] package provides a demo using futures for calculating a
set of Mandelbrot planes.  The demo does not assume anything about
what type of futures are used.
_The user has full control of how futures are evaluated_.
For instance, to use processx futures, run the demo as:
```r
library("future.processx")
plan(processx)
demo("mandelbrot", package = "future", ask = FALSE)
```


[processx]: https://cran.r-project.org/package=processx
[future]: https://cran.r-project.org/package=future
[future.processx]: https://github.com/HenrikBengtsson/processx

## Installation
R package future.processx is only available via [GitHub](https://github.com/HenrikBengtsson/future.processx) and can be installed in R as:
```r
source('http://callr.org/install#HenrikBengtsson/future.processx')
```




## Contributions

This Git repository uses the [Git Flow](http://nvie.com/posts/a-successful-git-branching-model/) branching model (the [`git flow`](https://github.com/petervanderdoes/gitflow-avh) extension is useful for this).  The [`develop`](https://github.com/HenrikBengtsson/future.processx/tree/develop) branch contains the latest contributions and other code that will appear in the next release, and the [`master`](https://github.com/HenrikBengtsson/future.processx) branch contains the code of the latest release.

Contributing to this package is easy.  Just send a [pull request](https://help.github.com/articles/using-pull-requests/).  When you send your PR, make sure `develop` is the destination branch on the [future.processx repository](https://github.com/HenrikBengtsson/future.processx).  Your PR should pass `R CMD check --as-cran`, which will also be checked by <a href="https://travis-ci.org/HenrikBengtsson/future.processx">Travis CI</a> and <a href="https://ci.appveyor.com/project/HenrikBengtsson/future-processx">AppVeyor CI</a> when the PR is submitted.


## Software status

| Resource:     | GitHub        | Travis CI       | Appveyor         |
| ------------- | ------------------- | --------------- | ---------------- |
| _Platforms:_  | _Multiple_          | _Linux & macOS_ | _Windows_        |
| R CMD check   |  | <a href="https://travis-ci.org/HenrikBengtsson/future.processx"><img src="https://travis-ci.org/HenrikBengtsson/future.processx.svg" alt="Build status"></a>   | <a href="https://ci.appveyor.com/project/HenrikBengtsson/future-processx"><img src="https://ci.appveyor.com/api/projects/status/github/HenrikBengtsson/future.processx?svg=true" alt="Build status"></a> |
| Test coverage |                     | <a href="https://codecov.io/gh/HenrikBengtsson/future.processx"><img src="https://codecov.io/gh/HenrikBengtsson/future.processx/branch/develop/graph/badge.svg" alt="Coverage Status"/></a>     |                  |
