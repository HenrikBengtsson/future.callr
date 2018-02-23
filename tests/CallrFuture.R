source("incl/start.R")

message("*** CallrFuture() ...")

message("*** CallrFuture() - cleanup ...")

f <- callr({ 1L })
print(f)
res <- await(f)
print(res)
if (inherits(res, "FutureResult")) {
  stopifnot(res$value == 1L)
} else {
  stopifnot(res == 1L)
}

message("*** CallrFuture() - cleanup ... DONE")

message("*** CallrFuture() - exceptions ...")

f <- callr({ 42L })
v <- value(f)
print(v)
res <- tryCatch({
  f <- run(f)
}, FutureError = identity)
print(res)
stopifnot(inherits(res, "FutureError"))

## f <- CallrFuture({ 42L })
## print(f)
## res <- tryCatch({
##   loggedError(f)
## }, error = identity)
## print(res)
## stopifnot(inherits(res, "error"))

## f <- CallrFuture({ 42L })
## print(f)
## res <- tryCatch({
##   loggedOutput(f)
## }, error = identity)
## print(res)
## stopifnot(inherits(res, "error"))

res <- tryCatch({
  f <- CallrFuture(42L, workers = integer(0))
}, error = identity)
print(res)
stopifnot(inherits(res, "error"))

res <- tryCatch({
  f <- CallrFuture(42L, workers = 0L)
}, error = identity)
print(res)
stopifnot(inherits(res, "error"))

res <- tryCatch({
  f <- CallrFuture(42L, workers = TRUE)
}, error = identity)
print(res)
stopifnot(inherits(res, "error"))

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
  }, FutureError = function(ex) ex)
  stopifnot(inherits(res, "FutureError"))
}

message("*** CallrFuture() - timeout ... DONE")


message("*** CallrFuture() ... DONE")

source("incl/end.R")
