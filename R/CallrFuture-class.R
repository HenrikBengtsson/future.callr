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
                               label = label, ...)

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
  if ("error" %in% status) printf("Error: %s\n", loggedError(x))

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
loggedError <- function(...) UseMethod("loggedError")
loggedOutput <- function(...) UseMethod("loggedOutput")

#' Status of callr future
#'
#' @param future The future.
#' 
#' @param \ldots Not used.
#'
#' @return A character vector or a logical scalar.
#'
#' @aliases status finished value
#'          loggedError loggedOutput
#' @keywords internal
#'
#' @export
#' @export status
#' @export finished
#' @export value
#' @export loggedError
#' @export loggedOutput
status.CallrFuture <- function(future, ...) {
  process <- future$process
  if (!inherits(process, "r_process")) return(NA_character_)
  future$state <- if (process$is_alive()) "running" else "done"
  future$state
}


#' @export
#' @keywords internal
finished.CallrFuture <- function(future, ...) {
  status <- status(future)
  if (is_na(status)) return(NA)
  any(c("done", "error") %in% status)
}

#' @importFrom future FutureError
#' @export
#' @keywords internal
loggedError.CallrFuture <- function(future, ...) {
  stat <- status(future)
  if (is_na(stat)) return(NULL)

  if (!finished(future)) {
    label <- future$label
    if (is.null(label)) label <- "<none>"
    msg <- sprintf("%s ('%s') has not finished yet", class(future)[1L], label)
    stop(FutureError(msg, future = future))
  }

  if (!"error" %in% stat) return(NULL)

  "loggedError(): TO BE IMPLEMENTED"
} # loggedError()


#' @importFrom future FutureError
#' @export
#' @keywords internal
loggedOutput.CallrFuture <- function(future, ...) {
  stat <- status(future)
  if (is_na(stat)) return(NULL)

  if (!finished(future)) {
    label <- future$label
    if (is.null(label)) label <- "<none>"
    msg <- sprintf("%s ('%s') has not finished yet", class(future)[1L], label)
    stop(FutureError(msg, future = future))
  }

  process <- future$process
  process$read_all_output()
} # loggedOutput()


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Future API
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#' @importFrom future resolved
#' @export
#' @keywords internal
resolved.CallrFuture <- function(x, ...) {
  ## Has internal future state already been switched to be resolved
  resolved <- NextMethod("resolved")
  if (resolved) return(TRUE)

  ## If not, checks the callr registry status
  resolved <- finished(x)
  if (is.na(resolved)) return(FALSE)

  resolved
}

#' @importFrom future value FutureError
#' @export
#' @keywords internal
value.CallrFuture <- function(future, signal = TRUE,
                                   onMissing = c("default", "error"),
                                   default = NULL, cleanup = TRUE, ...) {
  ## Has the value already been collected?
  if (future$state %in% c("finished", "failed", "interrupted")) {
    return(NextMethod("value"))
  }

  if (future$state == "created") {
    future <- run(future)
  }

  stat <- status(future)
  if (is_na(stat)) {
    onMissing <- match.arg(onMissing)
    if (onMissing == "default") return(default)
    label <- future$label
    if (is.null(label)) label <- "<none>"
    msg <- sprintf("The value no longer exists (or never existed) for Future ('%s') of class %s", label, paste(sQuote(class(future)), collapse = ", "))
    stop(FutureError(msg, future = future)) #nolint
  }

  tryCatch({
    future$value <- await(future, cleanup = FALSE)
    future$state <- "finished"
  }, error = function(ex) {
    future$state <- "failed"
    future$value <- ex
  })

  NextMethod("value")
} # value()


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
  }))

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
#' @importFrom future FutureError
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

  mdebug("callr::wait() ...")

  ## Control callr info output
  oopts <- options(callr.verbose = debug)
  on.exit(options(oopts))

  ## Sleep function - increases geometrically as a function of iterations
  sleep_fcn <- function(i) delta * alpha ^ (i - 1)

  ## Poll process
  ii <- 1L
  while (process$is_alive()) {
    timeout_ii <- sleep_fcn(ii)
    if (ii %% 100 == 0)
      mdebug("- iteration %d: callr::wait(timeout = %g)", ii, timeout_ii)
    res <- process$wait(timeout = timeout_ii)
    ii <- ii + 1L
  }
  
  stat <- status(future)
  mdebug("- status(): %s", paste(sQuote(stat), collapse = ", "))
  mdebug("callr::wait() ... done")

  finished <- is_na(stat) || any(c("done", "error") %in% stat)

  res <- NULL
  if (finished) {
    mdebug("Results:")
    label <- future$label
    if (is.null(label)) label <- "<none>"
    if ("done" %in% stat) {
      res <- process$get_result()
    } else if ("error" %in% stat) {
      msg <- sprintf("CallrError in %s ('%s'): %s",
                     class(future)[1], label, loggedError(future))
      stop(FutureError(msg, future = future, output = loggedOutput(future)))
    }
    if (debug) { mstr(res) }
  } else {
    label <- future$label
    msg <- sprintf("AsyncNotReadyError: Polled for results for %s seconds every %g seconds, but asynchronous evaluation for future ('%s') is still running: %s", timeout, delta, label, process$get_pid()) #nolint
    message(msg)
    stop(FutureError(msg, future = future))
  }

  res
} # await()
