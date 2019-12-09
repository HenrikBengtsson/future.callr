#' future.callr: A Future for callr
#'
#' The \pkg{future.callr} package implements the Future API
#' on top of \pkg{callr}.
#' The Future API is defined by the \pkg{future} package.
#'
#' To use callr futures, load \pkg{future.callr}, and
#' select the type of future you wish to use, e.g. `plan(callr)`.
#'
#' @examples
#' \donttest{
#' plan(callr)
#' demo("mandelbrot", package = "future", ask = FALSE)
#' }
#'
#' @docType package
#' @aliases future.callr-package
#' @name future.callr
NULL


