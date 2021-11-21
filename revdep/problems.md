# dipsaus

<details>

* Version: 0.1.9
* GitHub: https://github.com/dipterix/dipsaus
* Source code: https://github.com/cran/dipsaus
* Date/Publication: 2021-10-13 16:52:04 UTC
* Number of recursive dependencies: 76

Run `revdep_details(, "dipsaus")` for more info

</details>

## In both

*   checking installed package size ... NOTE
    ```
      installed size is  5.9Mb
      sub-directories of 1Mb or more:
        doc    1.3Mb
        libs   3.5Mb
    ```

# iml

<details>

* Version: 0.10.1
* GitHub: https://github.com/christophM/iml
* Source code: https://github.com/cran/iml
* Date/Publication: 2020-09-24 12:30:14 UTC
* Number of recursive dependencies: 163

Run `revdep_details(, "iml")` for more info

</details>

## In both

*   checking dependencies in R code ... NOTE
    ```
    Namespace in Imports field not imported from: ‘keras’
      All declared Imports should be used.
    ```

# SpaDES.core

<details>

* Version: 1.0.9
* GitHub: https://github.com/PredictiveEcology/SpaDES.core
* Source code: https://github.com/cran/SpaDES.core
* Date/Publication: 2021-09-30 14:20:06 UTC
* Number of recursive dependencies: 146

Run `revdep_details(, "SpaDES.core")` for more info

</details>

## In both

*   checking tests ...
    ```
      Running ‘test-all.R’/software/c4/cbi/software/R-4.1.2-gcc8/lib64/R/bin/BATCH: line 60:  2360 Segmentation fault      ${R_HOME}/bin/R -f ${in} ${opts} ${R_BATCH_OPTIONS} > ${out} 2>&1
    
     ERROR
    Running the tests in ‘tests/test-all.R’ failed.
    Last 50 lines of output:
       7: FUN(...)
       8: Cache(FUN = get(moduleCall, envir = fnEnv), sim = sim, eventTime = cur[["eventTime"]],     eventType = cur[["eventType"]], .objects = moduleSpecificObjects,     notOlderThan = notOlderThan, outputObjects = moduleSpecificOutputObjects,     classOptions = classOptions, showSimilar = showSimilar, cacheRepo = sim@paths[["cachePath"]])
       9: Cache(FUN = get(moduleCall, envir = fnEnv), sim = sim, eventTime = cur[["eventTime"]],     eventType = cur[["eventType"]], .objects = moduleSpecificObjects,     notOlderThan = notOlderThan, outputObjects = moduleSpecificOutputObjects,     classOptions = classOptions, showSimilar = showSimilar, cacheRepo = sim@paths[["cachePath"]])
      10: eval(fnCallAsExpr)
      11: eval(fnCallAsExpr)
    ...
      49: doTryCatch(return(expr), name, parentenv, handler)
      50: tryCatchOne(expr, names, parentenv, handlers[[1L]])
      51: tryCatchList(expr, classes, parentenv, handlers)
      52: tryCatch(code, testthat_abort_reporter = function(cnd) {    cat(conditionMessage(cnd), "\n")    NULL})
      53: with_reporter(reporters$multi, lapply(test_paths, test_one_file,     env = env, wrap = wrap))
      54: test_files(test_dir = test_dir, test_package = test_package,     test_paths = test_paths, load_helpers = load_helpers, reporter = reporter,     env = env, stop_on_failure = stop_on_failure, stop_on_warning = stop_on_warning,     wrap = wrap, load_package = load_package)
      55: test_files(test_dir = path, test_paths = test_paths, test_package = package,     reporter = reporter, load_helpers = load_helpers, env = env,     stop_on_failure = stop_on_failure, stop_on_warning = stop_on_warning,     wrap = wrap, load_package = load_package, parallel = parallel)
      56: test_dir("testthat", package = package, reporter = reporter,     ..., load_package = "installed")
      57: test_check("SpaDES.core")
      An irrecoverable exception occurred. R is aborting now ...
    ```

*   checking re-building of vignette outputs ... WARNING
    ```
    Error(s) in re-building vignettes:
    --- re-building ‘i-introduction.Rmd’ using rmarkdown
    --- finished re-building ‘i-introduction.Rmd’
    
    sh: line 1:  2542 Segmentation fault      '/software/c4/cbi/software/R-4.1.2-gcc8/lib64/R/bin/R' --vanilla --no-echo > '/scratch/henrik/RtmpUgCUoR/file9cc1ec7d872' 2>&1 < '/scratch/henrik/RtmpUgCUoR/file9cc4d7ec834'
    --- re-building ‘ii-modules.Rmd’ using rmarkdown
    
    Attaching package: 'magrittr'
    
    The following object is masked from 'package:raster':
    ...
    --- finished re-building ‘iv-advanced.Rmd’
    
    --- re-building ‘v-automated-testing.Rmd’ using rmarkdown
    --- finished re-building ‘v-automated-testing.Rmd’
    
    SUMMARY: processing the following files failed:
      ‘ii-modules.Rmd’ ‘iii-cache.Rmd’
    
    Error: Vignette re-building failed.
    Execution halted
    ```

# targets

<details>

* Version: 0.8.1
* GitHub: https://github.com/ropensci/targets
* Source code: https://github.com/cran/targets
* Date/Publication: 2021-10-26 18:00:02 UTC
* Number of recursive dependencies: 143

Run `revdep_details(, "targets")` for more info

</details>

## Newly broken

*   checking dependencies in R code ...sh: line 1:  7566 Illegal instruction     R_DEFAULT_PACKAGES=NULL '/software/c4/cbi/software/R-4.1.2-gcc8/lib64/R/bin/R' --vanilla --no-echo 2>&1 < '/scratch/henrik/Rtmpw0Rl81/file1ce854b2e769'
    ```
     NOTE
    
     *** caught illegal operation ***
    address 0x2afbea974d23, cause 'illegal operand'
    
    Traceback:
     1: dyn.load(file, DLLpath = DLLpath, ...)
     2: library.dynam(lib, package, package.lib)
     3: loadNamespace(p)
     4: withCallingHandlers(expr, message = function(c) if (inherits(c,     classes)) tryInvokeRestart("muffleMessage"))
     5: suppressMessages(loadNamespace(p))
     6: withCallingHandlers(expr, warning = function(w) if (inherits(w,     classes)) tryInvokeRestart("muffleWarning"))
     7: suppressWarnings(suppressMessages(loadNamespace(p)))
     8: doTryCatch(return(expr), name, parentenv, handler)
     9: tryCatchOne(expr, names, parentenv, handlers[[1L]])
    10: tryCatchList(expr, classes, parentenv, handlers)
    11: tryCatch(suppressWarnings(suppressMessages(loadNamespace(p))),     error = function(e) e)
    12: tools:::.check_packages_used(package = "targets")
    An irrecoverable exception occurred. R is aborting now ...
    ```

## Newly fixed

*   checking dependencies in R code ...sh: line 1:  6714 Illegal instruction     R_DEFAULT_PACKAGES=NULL '/software/c4/cbi/software/R-4.1.2-gcc8/lib64/R/bin/R' --vanilla --no-echo 2>&1 < '/scratch/henrik/Rtmpzu43Lx/file19924bbe4709'
    ```
     NOTE
    
     *** caught illegal operation ***
    address 0x2b51ddf5dd23, cause 'illegal operand'
    
    Traceback:
     1: dyn.load(file, DLLpath = DLLpath, ...)
     2: library.dynam(lib, package, package.lib)
     3: loadNamespace(p)
     4: withCallingHandlers(expr, message = function(c) if (inherits(c,     classes)) tryInvokeRestart("muffleMessage"))
     5: suppressMessages(loadNamespace(p))
     6: withCallingHandlers(expr, warning = function(w) if (inherits(w,     classes)) tryInvokeRestart("muffleWarning"))
     7: suppressWarnings(suppressMessages(loadNamespace(p)))
     8: doTryCatch(return(expr), name, parentenv, handler)
     9: tryCatchOne(expr, names, parentenv, handlers[[1L]])
    10: tryCatchList(expr, classes, parentenv, handlers)
    11: tryCatch(suppressWarnings(suppressMessages(loadNamespace(p))),     error = function(e) e)
    12: tools:::.check_packages_used(package = "targets")
    An irrecoverable exception occurred. R is aborting now ...
    ```

