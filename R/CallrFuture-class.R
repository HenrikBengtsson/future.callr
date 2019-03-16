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

  if (is.function(workers)) workers <- workers()
  if (!is.null(workers)) {
    stop_if_not(length(workers) >= 1)
    if (is.numeric(workers)) {
      stop_if_not(!anyNA(workers), all(workers >= 1))
    } else {
      stop("Argument 'workers' should be numeric: ", mode(workers))
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
  NextMethod()

  ## Ask for status once
  process <- x$process
  if (inherits(process, "r_process")) {
    status <- if (process$is_alive()) "running" else "finished"
    x$state <- status
  } else {
    status <- NA_character_
  }
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

#' @export
getExpression.CallrFuture <- function(future, mc.cores = 1L, ...) {
  NextMethod(mc.cores = mc.cores)
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

#' @importFrom future result UnexpectedFutureResultError
#' @keywords internal
#' @export
result.CallrFuture <- function(future, ...) {
  result <- future$result
  if (!is.null(result)) {
    if (inherits(result, "FutureError")) stop(result)
    return(result)
  }
  
  if (future$state == "created") {
    future <- run(future)
  }

  result <- await(future, cleanup = FALSE)

  if (!inherits(result, "FutureResult")) {
    ex <- UnexpectedFutureResultError(future)
    future$result <- ex
    stop(ex)
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
run.CallrFuture <- local({
  FutureRegistry <- import_future("FutureRegistry")
  assertOwner <- import_future("assertOwner")

  ## MEMOIZATION
  cmdargs <- eval(formals(r_bg)$cmdargs)
  
  function(future, ...) {
    if (future$state != "created") {
      label <- future$label
      if (is.null(label)) label <- "<none>"
      msg <- sprintf("A future ('%s') can only be launched once.", label)
      stop(FutureError(msg, future = future))
    }
  
    ## Assert that the process that created the future is
    ## also the one that evaluates/resolves/queries it.
    assertOwner(future)
  
    ## Temporarily disable callr output?
    ## (i.e. messages and progress bars)
    debug <- getOption("future.debug", FALSE)
  
    ## Get future expression
    stdout <- if (isTRUE(future$stdout)) TRUE else NA
    expr <- getExpression(future, stdout = stdout)
  
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
  
    ## Discard standard output? (as soon as possible)
    stdout <- if (isTRUE(stdout)) "|" else NULL
    
    ## Launch
    if (!is.null(future$label)) {
      ## Ideally this comes after a '--args' argument to R, but that is
      ## not possible with the current r_bg() because it will *append*
      ## '-f a-file.R' after these. /HB 2018-11-10
      cmdargs <- c(cmdargs, sprintf("--future-label=%s", shQuote(future$label)))
    }
    future$process <- r_bg(func, args = globals, stdout = stdout, cmdargs = cmdargs)
    if (debug) mdebugf("Launched future (PID=%d)", future$process$get_pid())
  
    ## 3. Running
    future$state <- "running"
  
    invisible(future)
  } ## run()
})


await <- function(...) UseMethod("await")

#' Awaits the result of a callr future
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
#' @return The FutureResult of the evaluated expression.
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
await.CallrFuture <- local({
  FutureRegistry <- import_future("FutureRegistry")

  function(future, timeout = getOption("future.wait.timeout", 30*24*60*60),
                   delta = getOption("future.wait.interval", 1.0),
                   alpha = getOption("future.wait.alpha", 1.01),
                   ...) {
    stop_if_not(is.finite(timeout), timeout >= 0)
    stop_if_not(is.finite(alpha), alpha > 0)
    
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
    t_timeout <- Sys.time() + timeout
    ii <- 1L
    while (process$is_alive()) {
      ## Timed out?
      if (Sys.time() > t_timeout) break
      timeout_ii <- sleep_fcn(ii)
      if (debug && ii %% 100 == 0)
        mdebugf("- iteration %d: callr::wait(timeout = %g)", ii, timeout_ii)
      res <- process$wait(timeout = timeout_ii)
      ii <- ii + 1L
    }
  
    if (process$is_alive()) {
      if (debug) mdebug("- callr process: running")
      label <- future$label
      if (is.null(label)) label <- "<none>"
      msg <- sprintf("AsyncNotReadyError: Polled for results for %s seconds every %g seconds, but asynchronous evaluation for %s future (%s) is still running: %s", timeout, delta, class(future)[1], sQuote(label), process$get_pid()) #nolint
      if (debug) mdebug(msg)
      stop(FutureError(msg, future = future))
    }
  
    if (debug) {
      mdebug("- callr process: finished")
      mdebug("callr::wait() ... done")
    }
  
    ## callr:::get_result() assert that "result" and "error" files exist
    ## based on file.exist().  In case there is a delay in the file system
    ## we might get a false-positive error:
    ## "Error: callr failed, could not start R, or it has crashed or was killed"
    ## If so, let's retry a few times before giving up.
    ## NOTE: This was observed, somewhat randomly, on R-devel (2018-04-20 r74620)
    ## on Linux (local and on Travis) with tests/demo.R /HB 2018-04-27
    if (debug) mdebug("- callr:::get_result() ...")
    for (ii in 1:5) {
      result <- tryCatch({
        process$get_result()
      }, error = identity)
      if (!inherits(result, "error")) break
      if (debug) mdebug("- process$get_result() failed; will retry after 0.1s")
      Sys.sleep(0.1)
    }
    if (inherits(result, "error")) result <- process$get_result()
    if (debug) mdebugf("- callr:::get_result() ... done (after %d attempts)", ii)
  
    if (debug) {
      mdebug("Results:")
      mstr(result)
    }
  
    ## Retrieve any logged standard output and standard error
    process <- future$process
  
    ## PROTOTYPE RESULTS BELOW:
    prototype_fields <- NULL
    
    ## Has 'stderr' already been collected (by the future package)?
    if (is.null(result$stderr)) {
      prototype_fields <- c(prototype_fields, "stderr")
      result$stderr <- tryCatch({
        process$read_all_error()
      }, error = function(ex) {
        label <- future$label
        if (is.null(label)) label <- "<none>"
        warning(FutureWarning(sprintf("Failed to retrieve standard error from %s (%s). The reason was: %s", class(future)[1], sQuote(label), conditionMessage(ex)), future = future))
        NULL
      })
    }
  
    if (length(prototype_fields) > 0) {
      result$PROTOTYPE_WARNING <- sprintf("WARNING: The fields %s should be considered internal and experimental for now, that is, until the Future API for these additional features has been settled. For more information, please see https://github.com/HenrikBengtsson/future/issues/172", hpaste(sQuote(prototype_fields), max_head = Inf, collapse = ", ", last_collapse  = " and "))
    }
  
    FutureRegistry("workers-callr", action = "remove", future = future)
    
    result
  } # await()
})
