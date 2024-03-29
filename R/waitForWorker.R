#' @importFrom future FutureError
waitForWorker <- function(type,
         workers,
         await = NULL,
         timeout = getOption("future.wait.timeout", 30 * 24 * 60 * 60),
         delta = getOption("future.wait.interval", 0.2),
         alpha = getOption("future.wait.alpha", 1.01)) {
  debug <- getOption("future.debug", FALSE)

  stop_if_not(length(type) == 1, is.character(type), !is.na(type), nzchar(type))
  stop_if_not(is.null(await) || is.function(await))
  workers <- as.integer(workers)
  stop_if_not(length(workers) == 1, is.finite(workers), workers >= 1L)
  stop_if_not(length(timeout) == 1, is.finite(timeout), timeout >= 0)
  stop_if_not(length(alpha) == 1, is.finite(alpha), alpha > 0)

  ## FutureRegistry to use
  reg <- sprintf("workers-%s", type)

  ## Use a default await() function?
  if (is.null(await)) {
    await <- function() FutureRegistry(reg, action = "collect-first")
  }  
 
  ## Number of occupied workers
  usedWorkers <- function() {
    length(FutureRegistry(reg, action = "list", earlySignal = FALSE))
  }

  t0 <- Sys.time()
  dt <- 0
  iter <- 1L
  interval <- delta
  finished <- FALSE
  while (dt <= timeout) {
    ## Check for available workers
    used <- usedWorkers()
    finished <- (used < workers)
    if (finished) break

    if (debug) mdebugf("Poll #%d (%s): usedWorkers() = %d, workers = %d", iter, format(round(dt, digits = 2L)), used, workers)

    ## Wait
    Sys.sleep(interval)
    interval <- alpha * interval
    
    ## Finish/close workers, iff possible
    await()

    iter <- iter + 1L
    dt <- difftime(Sys.time(), t0)
  }

  if (!finished) {
    msg <- sprintf("TIMEOUT: All %d workers are still occupied after %s (polled %d times)", workers, format(round(dt, digits = 2L)), iter)
    if (debug) mdebug(msg)
    stop(FutureError(msg))
  }
}
