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

When using `callr` futures, each future is resolved in a fresh background R session which ends as soon as the value of the future has been collected.   In contrast, `multisession` futures are resolved in background R worker sessions that serve multiple futures over their life spans.  The advantage with using a new R process for each future is that it is that the R environment is guaranteed not to be contaminated by previous futures, e.g. memory allocations, finalizers, modified options, and loaded and attached packages.  The disadvantage, is an added overhead of lauching a new R process.  I not aware of formal benchmarking of this extra overhead.  Likewise, I am not aware of performance comparisons of `callr` to alternative future backends.

Another advantage with `callr` futures compared to `multisession` futures is that they do not communicate via R (socket) connections.  This avoids the limitation in the number of parallel futures that can be active at any time that `multisession` futures and `cluster` futures in general have, which they inherit from `SOCKcluster` clusters as defined by the parallel package.  The number of parallel futures these can serve is limited by the [maximum number of open connections in R](https://github.com/HenrikBengtsson/Wishlist-for-R/issues/28), which currently is 125 (excluding the three reserved by R itself).  Note that these 125 slots have to be shared with file connections etc.  To increase this limit, R needs to be rebuild from source.  Because `callr` futures rely on [processx internally they do not make use of these R-specific connections](https://github.com/r-lib/processx/issues/91) and therefore there is no limit in the number of background R processes that can be usedsimulatenously. (*) Currently, [parallelx is limited to 64 parallel processes on Windows but there is a plan to remove that limitation](https://github.com/r-lib/processx/issues/91#issuecomment-351214242).

A third advantage with `callr` futures, is that there is not risk for port-clashing with other processes on the system when clusters are set up.  To lower the risk for such clashes `SOCKcluster`:s request random ports, but clashes still occur at times.   Furthermore, on Windows, the firewall triggers an alert that the user needs to approve whenever a not-previously-approved port is requested by R - [which happens also for local, non-public ports](https://stackoverflow.com/questions/47353848/localhost-connection-without-firewall-popup/47542866) that are used by `SOCKcluster`:s.  When using `callr` futures, no sockets and therefore no ports are involved.




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
