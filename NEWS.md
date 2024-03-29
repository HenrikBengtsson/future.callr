# Version (development version)

 * ...


# Version 0.8.2 [2023-08-08]

## Bug Fixes

 * If a 'callr' future failed, because the parallel process crashed,
   the corresponding parallel-worker slot was never released.
 

# Version 0.8.1 [2022-12-13]

## Bug Fixes

 * `run()` for `CallrFuture` would update the RNG state, because
   `callr::r_bg()`, used to launch the future, does so.  This would
   compromise numeric reproducibility, where the `callr` future
   backend would not give the same random numbers as other future
   backends.  Now `run()` launches the future in stealth RNG mode,
   i.e. gives `r_bg()` a semi-random initial seed to work with (by
   removing `.Random.seed`) and then undo the RNG state at the very
   end.
 

# Version 0.8.0 [2022-04-01]

## New Features

 * Now `resolved()` supports early signaling.

 * Now `result()` and `value()` gives a slightly more informative
   error message in case the **callr** process failed with a non-zero
   exit code.


# Version 0.7.0 [2021-11-20]

## New Features

 * Add option to configure **callr** futures to be "supervised" by the
   **callr** package when setting up the plan, i.e. `plan(callr,
   supervise = TRUE)`.

 * Now callr-specific orchestration errors are of class
   `CallrFutureError`, which provides information also on the future
   that failed.
 

# Version 0.6.1 [2021-05-03]

## Bug Fixes

 * A **callr** future that produces a large amount of standard error
   (stderr) could stall forever when collecting its results.  The
   exact reason is unknown but the symptom is currently that the
   underlying **processx** process never terminates, resulting in a
   never-ending wait for the results.  Since futures don't capture
   stderr in other backends, the workaround for now is to discard all
   stderr output.  Note that messages, warnings, etc. are still
   captured and relayed.
 

# Version 0.6.0 [2021-01-02]

## Significant Changes

 * Removed S3 generic function `await()`, which was used for internal
   purposes.

## New Features

 * Add `nbrOfFreeWorkers()`.

## Deprecated and Defunct

 * Removed S3 generic function `await()`, which was used for internal
   purposes.


# Version 0.5.0 [2019-09-27]

## Significant Changes

 * `resolved()` for `CallrFuture` will launch lazy futures [**future**
   (>= 1.15.0)].
 
## New Features

 * Debug messages are now prepended with a timestamp.


# Version 0.4.0 [2019-01-05]

## New Features

 * Now the future label is exposed in the process information
   (e.g. `top`) via a dummy `--future-label="<label>"` argument in the
   **callr** system call.

## Bug Fixes

 * `plan(callr, workers)` where `workers` being a function would
   result in an error when a future was created.
 

# Version 0.3.1 [2018-07-18]

## New Features

 * The 'callr' backend supports the handling of the standard output as
   implemented in **future** (>= 1.9.0).

## Bug Fixes

 * Callr futures did not protect against recursive parallelism,
   e.g. with `plan(list(callr, callr))` the second layer of futures
   would use the same number of workers as the first layer.


# Version 0.3.0 [2018-05-03]

## New Features

 * Argument `workers` of future strategies may now also be a function,
   which is called without argument when the future strategy is set up
   and used as is.  For instance, `plan(callr, workers = halfCores)`
   where `halfCores <- function() { max(1, round(availableCores() /
   2)) }` will use half of the number of available cores.  This is
   useful when using nested future strategies with remote machines.

 * Gathering of results from background processes is made a little bit
   more robust against slow file systems by retrying a few times
   before accepting an error as an error.
  
## Code Refactoring

 * Prepared code to gather a richer set of results from futures.

## Bug Fixes

 * Callr futures did not acknowledge timeout option
   `future.wait.timeout`.
 

# Version 0.2.0 [2018-02-12]

## New Features

 * Producing errors of class `FutureError` where applicable.

## Documentation

 * Minor updates to the vignette related to the **callr** package.
 

# Version 0.1.1 [2017-11-18]

## Bug Fixes

 * Number of workers in `plan(callr, workers = n)` was not respected.


# Version 0.1.0 [2017-11-16]

## New Features

 * Added 'callr' futures. Use `plan(callr)` or `plan(callr, workers =
   4L)`.
