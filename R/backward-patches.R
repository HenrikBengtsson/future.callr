## Until future.callr imports this from future (>= 1.8.1)
#' @importFrom future FutureError
UnexpectedFutureResultError <- function(future) {
  label <- future$label
  if (is.null(label)) label <- "<none>"
  expr <- hexpr(future$expr)
  result <- future$result
  result_string <- hpaste(as.character(result))
  if (nchar(result_string) > 512L)
    result_string <- paste(substr(result_string, start = 1L, stop = 512L),
                           "...")
  msg <- sprintf("Unexpected result (of class %s != %s) retrieved for %s future (label = %s, expression = %s): %s",
                 sQuote(class(result)[1]), sQuote("FutureResult"),
                 class(future)[1], sQuote(label), sQuote(expr),
                 result_string)
  cond <- FutureError(msg, future = future)
  class(cond) <- c("UnexpectedFutureResultError", class(cond))
  cond
}
