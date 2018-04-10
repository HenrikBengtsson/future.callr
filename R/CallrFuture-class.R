#' A callr future is a future whose value will be resolved via callr
#'
#' @param expr The \R expression to be evaluated.
#'
#' @param envir The environment in which global environment
#' should be located.
#'
#' @param substitute Controls whether `expr` should be `substitute()`:d
#' or not.
#'
#' @param globals (optional) a logical, a character vector, a named list, or
#' a [globals::Globals] object.  If `TRUE`, globals are identified by code
#' inspection based on `expr` and `tweak` searching from environment
#' `envir`.  If `FALSE`, no globals are used.  If a character vector, then
#' globals are identified by lookup based their names `globals` searching
#' from environment `envir`.  If a named list or a Globals object, the
#' globals are used as is.
#'
#' @param label (optional) Label of the future.
#'
#' @param workers (optional) The maximum number of workers the callr
#' backend may use at any time.
#'
#' @param \ldots Additional arguments passed to [future::MultiprocessFuture()].
#'
#' @return A CallrFuture object
#'
#' @aliases run.CallrFuture
#' @export
#' @importFrom future MultiprocessFuture getGlobalsAndPackages
#' @keywords internal
CallrFuture <- function(expr = NULL, envir = parent.frame(),
                             substitute = TRUE,
                             globals = TRUE, packages = NULL,
                             label = NULL,
                             workers = NULL,
                             ...) {
  if (substitute) expr <- substitute(expr)

  if (!is.null(label)) label <- as.character(label)

  if (!is.null(workers)) {
    stopifnot(length(workers) >= 1)
    if (is.numeric(workers)) {
      stopifnot(!anyNA(workers), all(workers >= 1))
    } else {
      stopifnot("Argument 'workers' should be numeric: ", mode(workers))
    }
  }

  ## Record globals
  gp <- getGlobalsAndPackages(expr, envir = envir, globals = globals)

  ## Create CallrFuture object
  future <- MultiprocessFuture(expr = gp$expr, envir = envir,
                               substitute = FALSE, workers = workers,
                               label = label, version = "1.8", ...)
  future$.callResult <- TRUE

  future$globals <- gp$globals
  future$packages <- unique(c(packages, gp$packages))
  future$state <- "created"

  future <- structure(future, class = c("CallrFuture", class(future)))

  future
}


#' Prints a callr future
#'
#' @param x An CallrFuture object
#' 
#' @param \ldots Not used.
#'
#' @export
#' @keywords internal
print.CallrFuture <- function(x, ...) {
  NextMethod("print")

  ## Ask for status once
  status <- status(x)
  printf("callr status: %s\n", paste(sQuote(status), collapse = ", "))

  process <- x$process
  if (is_na(status)) {
    printf("callr %s: Not found (happens when finished and deleted)\n",
           class(process)[1])
  } else {
    printf("callr information: PID=%d, %s\n",
           process$get_pid(), capture_output(print(process)))
  }

  invisible(x)
}


status <- function(...) UseMethod("status")

finished <- function(...) UseMethod("finished")

#' Status of callr future
#'
#' @param future The future.
#' 
#' @param \ldots Not used.
#'
#' @return A character vector or a logical scalar.
#'
#' @aliases status finished value
#' 
#' @keywords internal
status.CallrFuture <- function(future, ...) {
  process <- future$process
  if (!inherits(process, "r_process")) return(NA_character_)
  state <- if (process$is_alive()) "running" else "finished"
  future$state <- state
  state
}

#' @keywords internal
finished.CallrFuture <- function(future, ...) {
  status <- status(future)
  if (is_na(status)) return(NA)
  any(c("finished", "error") %in% status)
}


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Future API
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#' @importFrom future resolved
#' @keywords internal
#' @export
resolved.CallrFuture <- function(x, ...) {
  if (inherits(x$result, "FutureResult")) return(TRUE)
  process <- x$process
  if (!inherits(process, "r_process")) return(FALSE)
  !process$is_alive()
}

#' @importFrom future result
#' @keywords internal
#' @export
result.CallrFuture <- function(future, ...) {
  result <- future$result
  if (!is.null(result)) return(result)
  
  if (future$state == "created") {
    future <- run(future)
  }

  result <- await(future, cleanup = FALSE)

  if (!inherits(result, "FutureResult")) {
    label <- future$label
    if (is.null(label)) label <- "<none>"
    stop(FutureError(sprintf("Internal error: Unexpected result retrieved for %s future (%s): %s", class(future)[1], sQuote(label), sQuote(hexpr(future$expr))), future = future))
  }

  future$result <- result
  future$state <- "finished"
  
  result
}


#' @importFrom future run getExpression FutureError
#' @importFrom callr r_bg
#' @keywords internal
#' @S3method run CallrFuture
#' @export
run.CallrFuture <- function(future, ...) {
  FutureRegistry <- import_future("FutureRegistry")
  
  if (future$state != "created") {
    label <- future$label
    if (is.null(label)) label <- "<none>"
    msg <- sprintf("A future ('%s') can only be launched once.", label)
    stop(FutureError(msg, future = future))
  }

  mdebug <- import_future("mdebug")

  ## Assert that the process that created the future is
  ## also the one that evaluates/resolves/queries it.
  assertOwner <- import_future("assertOwner")
  assertOwner(future)

  ## Temporarily disable callr output?
  ## (i.e. messages and progress bars)
  debug <- getOption("future.debug", FALSE)

  ## Get future expression
  expr <- getExpression(future)

  ## Get globals
  globals <- future$globals
  
  ## Make a callr::r_bg()-compatible function
  func <- eval(bquote(function(...) {
    local({
      fasten <- base::attach ## To please R CMD check
      fasten(list(...), pos = 2L, name = "r_bg_arguments")
    })
    .(expr)
  }), enclos = baseenv())

  ## 1. Wait for an available worker
  waitForWorker(type = "callr", workers = future$workers)

  ## 2. Allocate future now worker
  FutureRegistry("workers-callr", action = "add", future = future, earlySignal = FALSE)
  
  ## Launch
  future$process <- r_bg(func, args = globals)
  mdebug("Launched future #%d", future$process$get_pid())

  ## 3. Running
  future$state <- "running"

  invisible(future)
} ## run()


await <- function(...) UseMethod("await")

#' Awaits the value of a callr future
#'
#' @param future The future.
#' 
#' @param timeout Total time (in seconds) waiting before generating an error.
#' 
#' @param delta The number of seconds to wait between each poll.
#' 
#' @param alpha A factor to scale up the waiting time in each iteration such
#' that the waiting time in the k:th iteration is `alpha ^ k * delta`.
#' 
#' @param \ldots Not used.
#'
#' @return The value of the evaluated expression.
#' If an error occurs, an informative Exception is thrown.
#'
#' @details
#' Note that `await()` should only be called once, because
#' after being called the actual asynchronous future may be removed
#' and will no longer available in subsequent calls.  If called
#' again, an error may be thrown.
#'
#' @export
#' @importFrom utils tail
#' @importFrom future FutureError FutureWarning
#' @keywords internal
await.CallrFuture <- function(future, 
                                 timeout = getOption("future.wait.timeout",
                                                     30 * 24 * 60 * 60),
                                 delta = getOption("future.wait.interval", 1.0),
                                 alpha = getOption("future.wait.alpha", 1.01),
                                 ...) {
  mdebug <- import_future("mdebug")
  stopifnot(is.finite(timeout), timeout >= 0)
  stopifnot(is.finite(alpha), alpha > 0)
  
  debug <- getOption("future.debug", FALSE)

  expr <- future$expr
  process <- future$process

  if (debug) mdebug("callr::wait() ...")

  ## Control callr info output
  oopts <- options(callr.verbose = debug)
  on.exit(options(oopts))

  ## Sleep function - increases geometrically as a function of iterations
  sleep_fcn <- function(i) delta * alpha ^ (i - 1)

  ## Poll process
  ii <- 1L
  while (process$is_alive()) {
    timeout_ii <- sleep_fcn(ii)
    if (debug && ii %% 100 == 0)
      mdebug("- iteration %d: callr::wait(timeout = %g)", ii, timeout_ii)
    res <- process$wait(timeout = timeout_ii)
    ii <- ii + 1L
  }

  if (process$is_alive()) {
    mdebug("- callr process: running")
    label <- future$label
    if (is.null(label)) label <- "<none>"
    msg <- sprintf("AsyncNotReadyError: Polled for results for %s seconds every %g seconds, but asynchronous evaluation for %s future (%s) is still running: %s", timeout, delta, class(future)[1], sQuote(label), process$get_pid()) #nolint
    mdebug(msg)
    stop(FutureError(msg, future = future))
  }

  if (debug) {
    mdebug("- callr process: finished")
    mdebug("callr::wait() ... done")
  }

  result <- process$get_result()
  
  ## WORKAROUND: future 1.8.0 does not set the correct 'version' of the result
  result$version <- future$version
  
  if (debug) {
    mdebug("Results:")
    mstr(result)
  }

  ## Retrieve any logged standard output and standard error
  process <- future$process

  result$prototype_only <- list()
  
  result$prototype_only$stdout <- tryCatch({
    process$read_all_output()
  }, error = function(ex) {
    label <- future$label
    if (is.null(label)) label <- "<none>"
    warning(FutureWarning(sprintf("Failed to retrieve standard output from %s (%s). The reason was: %s", class(future)[1], sQuote(label), conditionMessage(ex)), future = future))
    NULL
  })

  result$prototype_only$stderr <- tryCatch({
    process$read_all_error()
  }, error = function(ex) {
    label <- future$label
    if (is.null(label)) label <- "<none>"
    warning(FutureWarning(sprintf("Failed to retrieve standard error from %s (%s). The reason was: %s", class(future)[1], sQuote(label), conditionMessage(ex)), future = future))
    NULL
  })
  
  result
} # await()
