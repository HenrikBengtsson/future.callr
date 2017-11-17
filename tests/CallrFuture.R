source("incl/start.R")

message("*** CallrFuture() ...")

message("*** CallrFuture() - cleanup ...")

f <- callr({ 1L })
print(f)
res <- await(f)
print(res)
stopifnot(res == 1L)

message("*** CallrFuture() - cleanup ... DONE")

message("*** CallrFuture() - exceptions ...")

## f <- CallrFuture({ 42L })
## print(f)
## res <- tryCatch({
##   loggedError(f)
## }, error = function(ex) ex)
## print(res)
## stopifnot(inherits(res, "error"))

## f <- CallrFuture({ 42L })
## print(f)
## res <- tryCatch({
##   loggedOutput(f)
## }, error = function(ex) ex)
## print(res)
## stopifnot(inherits(res, "error"))

res <- try(f <- CallrFuture(42L, workers = integer(0)), silent = TRUE)
print(res)
stopifnot(inherits(res, "try-error"))

res <- try(f <- CallrFuture(42L, workers = 0L), silent = TRUE)
print(res)
stopifnot(inherits(res, "try-error"))

res <- try(f <- CallrFuture(42L, workers = TRUE), silent = TRUE)
print(res)
stopifnot(inherits(res, "try-error"))

message("*** CallrFuture() - exceptions ... DONE")


message("*** CallrFuture() - timeout ...")

if (fullTest) {
  plan(callr)

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

message("*** CallrFuture() - timeout ... DONE")


message("*** CallrFuture() ... DONE")

source("incl/end.R")
