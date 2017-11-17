#' future.processx: A Future for processx
#'
#' The \pkg{future.processx} package implements the Future API
#' on top of \pkg{processx}.
#' The Future API is defined by the \pkg{future} package.
#'
#' To use processx futures, load \pkg{future.processx}, and
#' select the type of future you wish to use, e.g. `plan(processx)`.
#'
#' @examples
#' \donttest{
#' plan(processx)
#' demo("mandelbrot", package = "future", ask = FALSE)
#' }
#'
#' @docType package
#' @name future.processx
NULL
