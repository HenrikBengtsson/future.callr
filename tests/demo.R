source("incl/start.R")

options(future.demo.mandelbrot.nrow = 2L)
options(future.demo.mandelbrot.resolution = 50L)
options(future.demo.mandelbrot.delay = FALSE)

message("*** Demos ...")

message("*** Mandelbrot demo of the 'future' package ...")

plan(callr)
demo("mandelbrot", package = "future", ask = FALSE)

message("*** Demos ... DONE")

source("incl/end.R")
