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
#' @param supervise (optional) Argument passed to [callr::r_bg()].
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
                        supervise = FALSE,
                        ...) {
  if (substitute) expr <- substitute(expr)

  ## Record globals
  gp <- getGlobalsAndPackages(expr, envir = envir, globals = globals)

  future <- MultiprocessFuture(expr = gp$expr, envir = envir,
                               substitute = FALSE,
                               globals = gp$globals,
                               packages = unique(c(packages, gp$packages)),
                               label = label, ...)

  future <- as_CallrFuture(future, workers = workers, supervise = supervise)
  
  future
}


as_CallrFuture <- function(future, workers = NULL, ...) {
  args <- list(...)
  names <- names(args)
  stopifnot(is.character(names), all(nzchar(names)))
  
  if (is.function(workers)) workers <- workers()
  if (!is.null(workers)) {
    stop_if_not(length(workers) >= 1)
    if (is.numeric(workers)) {
      stop_if_not(!anyNA(workers), all(workers >= 1))
    } else {
      stop("Argument 'workers' should be numeric: ", mode(workers))
    }
  }
  future$workers <- workers
  for (name in names) future[[name]] <- args[[name]]
  
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
  resolved <- NextMethod()
  if (resolved) return(TRUE)
  
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
  cmdargs <- NULL

  fasten <- NULL ## To please R CMD check
  tmpl_expr <- bquote_compile(function(globals) {
    if (length(globals) > 0) {
      local({
        fasten <- base::attach ## To please R CMD check
        fasten(globals, pos = 2L, name = "r_bg_arguments")
      })
    }
    rm(list = "globals")
    .(expr)
  })

  function(future, ...) {
    ## Memoization
    if (identical(cmdargs, NULL)) {
      cmdargs <- eval(formals(r_bg)$cmdargs)
    }

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
    expr <- bquote_apply(tmpl_expr)
    func <- eval(expr, enclos = baseenv())
  
    ## 1. Wait for an available worker
    waitForWorker(type = "callr", workers = future$workers)
  
    ## 2. Allocate future now worker
    FutureRegistry("workers-callr", action = "add", future = future, earlySignal = FALSE)
  
    ## Discard standard output? (as soon as possible)
    stdout <- if (isTRUE(stdout)) "|" else NULL

    ## Discard standard error
    ## WORKAROUND: https://github.com/HenrikBengtsson/future.callr/issues/14
    ## For unknown reasons, process$is_alive() will always return TRUE if
    ## we capture stderr, which means that await() will never return.
    ## Since we don't capture and relay stderr in other backends, it's safe
    ## to discard all standard error output. /HB 2021-04-05
    stderr <- NULL

    ## Add future label to process call?
    if (!is.null(future$label)) {
      ## Ideally this comes after a '--args' argument to R, but that is
      ## not possible with the current r_bg() because it will *append*
      ## '-f a-file.R' after these. /HB 2018-11-10
      cmdargs <- c(cmdargs, sprintf("--future-label=%s", shQuote(future$label)))
    }

    ## Have callr "supervise" the subprocess?
    supervise <- future$supervise

    ## Launch
    future$process <- r_bg(func, args = list(globals = globals), stdout = stdout, stderr = stderr, cmdargs = cmdargs, supervise = supervise)
    if (debug) mdebugf("Launched future (PID=%d)", future$process$get_pid())
  
    ## 3. Running
    future$state <- "running"
  
    invisible(future)
  } ## run()
})


#' @importFrom utils tail
#' @importFrom future FutureError FutureWarning
await <- local({
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
    for (ii in 4:0) {
      result <- tryCatch({
        process$get_result()
      }, error = identity)
      if (!inherits(result, "error")) break
      if (ii > 0L) {
        if (debug) mdebug("- process$get_result() failed; will retry after 0.1s")
        Sys.sleep(0.1)
      }
    }
    
    ## Failed?
    if (inherits(result, "error")) {
      msg <- post_mortem_failure(result, future = future)
      stop(CallrFutureError(msg, future = future))
    }
    
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
    ## Comment: This is unlikely to ever happen because you cannot
    ## capture stderr reliably in R, cf.
    ## https://github.com/HenrikBengtsson/Wishlist-for-R/issues/55
    ## /2021-04-05
    if (is.null(result$stderr) && FALSE) {
      prototype_fields <- c(prototype_fields, "stderr")
      result$stderr <- tryCatch({
        res <- process$read_all_error()
        res
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



post_mortem_failure <- function(ex, future) {
  assert_no_references <- import_future("assert_no_references")
  summarize_size_of_globals <- import_future("summarize_size_of_globals")

  stop_if_not(inherits(ex, "error"))
  stop_if_not(inherits(future, "Future"))
  
  ## (1) Information on the future
  label <- future$label
  if (is.null(label)) label <- "<none>"
  stop_if_not(length(label) == 1L)

  ## (2) Trimmed error message
  reason <- conditionMessage(ex)

  ## (3) POST-MORTEM ANALYSIS:
  postmortem <- list()
                 
  process <- future$process
  pid <- tryCatch(process$get_pid(), error = function(e) NA_integer_)
  start_time <- tryCatch(format(process$get_start_time(), format = "%Y-%m-%dT%H:%M:%S%z"), error = function(e) NA_character_)
  msg2 <- sprintf("The parallel worker (PID %.0f) started at %s", pid, start_time)
  if (process$is_alive()) {
    msg2 <- sprintf("%s is still running", msg2)
  } else {
    exit_code <- tryCatch(process$get_exit_status(), error = function(e) NA_integer_)
    msg2 <- sprintf("%s finished with exit code %.0f", msg2, exit_code)
  }
  postmortem$alive <- msg2

  ## (c) Any non-exportable globals?
  globals <- future[["globals"]]
  postmortem$non_exportable <- assert_no_references(globals, action = "string")

  ## (d) Size of globals
  postmortem$global_sizes <- summarize_size_of_globals(globals)

  ## (4) The final error message
  msg <- sprintf("%s (%s) failed. The reason reported was %s",
                 class(future)[1], label, sQuote(reason))
  stop_if_not(length(msg) == 1L)
  if (length(postmortem) > 0) {
    postmortem <- unlist(postmortem, use.names = FALSE)
    msg <- sprintf("%s. Post-mortem diagnostic: %s",
                   msg, paste(postmortem, collapse = ". "))
    stop_if_not(length(msg) == 1L)
  }

  msg
} # post_mortem_failure()
