#' FutureError class for errors related to CallrFuture:s
#'
#' @param \ldots Arguments passed to [FutureError][future::FutureError].
#'
#' @export
#' @importFrom future FutureError
#'
#' @keywords internal
CallrFutureError <- function(...) {
  error <- FutureError(...)
  class(error) <- c("CallrFutureError", class(error))
  error
}
