source("incl/start.R")
library("listenv")

message("*** callr() ...")

for (cores in 1:min(2L, availableCores())) {
  ## FIXME:
  if (!fullTest && cores > 1) next

  mprintf("Testing with %d cores ...", cores)
  options(mc.cores = cores - 1L)

  for (globals in c(FALSE, TRUE)) {
    mprintf("*** callr(..., globals = %s) without globals",
            globals)

    f <- callr({
      42L
    }, globals = globals)
    stopifnot(inherits(f, "CallrFuture"))

    print(resolved(f))
    y <- value(f)
    print(y)
    stopifnot(y == 42L)

    mprintf("*** callr(..., globals = %s) with globals", globals)
    ## A global variable
    a <- 0
    f <- callr({
      b <- 3
      c <- 2
      a * b * c
    }, globals = globals)
    print(f)


    ## A callr future is evaluated in a separated
    ## rocess.  Changing the value of a global
    ## variable should not affect the result of the
    ## future.
    a <- 7  ## Make sure globals are frozen
    if (globals) {
      v <- value(f)
      print(v)
      stopifnot(v == 0)
    } else {
      res <- tryCatch({ value(f) }, error = identity)
      print(res)
      stopifnot(inherits(res, "simpleError"))
    }


    mprintf("*** callr(..., globals = %s) with globals and blocking", globals) #nolint
    x <- listenv()
    for (ii in 1:4) {
      mprintf(" - Creating callr future #%d ...", ii)
      x[[ii]] <- callr({ ii }, globals = globals)
    }
    mprintf(" - Resolving %d callr futures", length(x))
    if (globals) {
      v <- sapply(x, FUN = value)
      stopifnot(all(v == 1:4))
    } else {
      v <- lapply(x, FUN = function(f) tryCatch(value(f), error = identity))
      stopifnot(all(sapply(v, FUN = inherits, "simpleError")))
    }

    mprintf("*** callr(..., globals = %s) and errors", globals)
    f <- callr({
      stop("Whoops!")
      1
    }, globals = globals)
    print(f)
    v <- value(f, signal = FALSE)
    print(v)
    stopifnot(inherits(v, "simpleError"))

    res <- try(value(f), silent = TRUE)
    print(res)
    stopifnot(inherits(res, "try-error"))

    ## Error is repeated
    res <- try(value(f), silent = TRUE)
    print(res)
    stopifnot(inherits(res, "try-error"))

  } # for (globals ...)


  message("*** callr(..., workers = 1L) ...")

  a <- 2
  b <- 3
  y_truth <- a * b

  f <- callr({ a * b }, workers = 1L)
  rm(list = c("a", "b"))

  v <- value(f)
  print(v)
  stopifnot(v == y_truth)

  message("*** callr(..., workers = 1L) ... DONE")

  mprintf("Testing with %d cores ... DONE", cores)
} ## for (cores ...)

message("*** callr() ... DONE")

source("incl/end.R")
