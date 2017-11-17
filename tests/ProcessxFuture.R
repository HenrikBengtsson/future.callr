source("incl/start.R")

message("*** ProcessxFuture() ...")

message("*** ProcessxFuture() - cleanup ...")

f <- processx({ 1L })
print(f)
res <- await(f)
print(res)
stopifnot(res == 1L)

message("*** ProcessxFuture() - cleanup ... DONE")

message("*** ProcessxFuture() - exceptions ...")

## f <- ProcessxFuture({ 42L })
## print(f)
## res <- tryCatch({
##   loggedError(f)
## }, error = function(ex) ex)
## print(res)
## stopifnot(inherits(res, "error"))

## f <- ProcessxFuture({ 42L })
## print(f)
## res <- tryCatch({
##   loggedOutput(f)
## }, error = function(ex) ex)
## print(res)
## stopifnot(inherits(res, "error"))

res <- try(f <- ProcessxFuture(42L, workers = integer(0)), silent = TRUE)
print(res)
stopifnot(inherits(res, "try-error"))

res <- try(f <- ProcessxFuture(42L, workers = 0L), silent = TRUE)
print(res)
stopifnot(inherits(res, "try-error"))

res <- try(f <- ProcessxFuture(42L, workers = TRUE), silent = TRUE)
print(res)
stopifnot(inherits(res, "try-error"))

message("*** ProcessxFuture() - exceptions ... DONE")


message("*** ProcessxFuture() - timeout ...")

if (fullTest) {
  plan(processx)

  options(future.wait.timeout = 0.15, future.wait.interval = 0.1)

  f <- future({
    Sys.sleep(5)
    x <- 1
  })
  print(f)

  res <- tryCatch({
    value(f)
  }, error = function(ex) ex)
  stopifnot(inherits(res, "error"))
}

message("*** ProcessxFuture() - timeout ... DONE")


message("*** ProcessxFuture() ... DONE")

source("incl/end.R")
