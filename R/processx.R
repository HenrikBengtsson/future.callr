#' processx futures
#'
#' A processx future is an asynchronous multiprocess
#' future that will be evaluated in a background R session.
#'
#' @inheritParams ProcessxFuture
#' 
#' @param workers The number of processes to be available for concurrent
#' processx futures.
#' 
#' @param \ldots Additional arguments passed to `ProcessxFuture()`.
#'
#' @return An object of class [ProcessxFuture].
#'
#' @details
#' processx futures rely on the \pkg{processx} package, which is supported
#' on all operating systems.
#'
#' @importFrom future availableCores
#' @export
#' @keywords internal
processx <- function(expr, envir = parent.frame(), substitute = TRUE,
                     globals = TRUE, label = NULL,
                     workers = availableCores(), ...) {
  if (substitute) expr <- substitute(expr)

  if (is.null(workers)) workers <- availableCores()
  stopifnot(length(workers) == 1L, is.numeric(workers),
            is.finite(workers), workers >= 1L)

  oopts <- options(mc.cores = workers)
  on.exit(options(oopts))

  future <- ProcessxFuture(expr = expr, envir = envir, substitute = FALSE,
                           globals = globals,
                           label = label,
                           ...)

  if (!future$lazy) future <- run(future)

  future
}
class(processx) <- c("processx", "multiprocess", "future", "function")
