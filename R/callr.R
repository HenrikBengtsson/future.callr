#' callr futures
#'
#' A callr future is an asynchronous multiprocess
#' future that will be evaluated in a background R session.
#'
#' @inheritParams CallrFuture
#' 
#' @param workers The number of processes to be available for concurrent
#' callr futures.
#' 
#' @param \ldots Additional arguments passed to `CallrFuture()`.
#'
#' @return An object of class [CallrFuture].
#'
#' @details
#' callr futures rely on the \pkg{callr} package, which is supported
#' on all operating systems.
#'
#' @importFrom future availableCores
#' @export
callr <- function(expr, envir = parent.frame(), substitute = TRUE,
                     globals = TRUE, label = NULL,
                     workers = availableCores(), ...) {
  if (substitute) expr <- substitute(expr)

  if (is.null(workers)) workers <- availableCores()

  future <- CallrFuture(expr = expr, envir = envir, substitute = FALSE,
                        globals = globals,
                        label = label,
                        workers = workers,
                        ...)

  if (!future$lazy) future <- run(future)

  future
}
class(callr) <- c("callr", "multiprocess", "future", "function")
attr(callr, "tweakable") <- "supervise"
