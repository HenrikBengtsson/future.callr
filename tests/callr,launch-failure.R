source("incl/start.R")
library("listenv")

options(future.debug = FALSE)

message("*** callr() ...")

message("- Error in ./.Rprofile causes callr process to fail")

plan(callr, workers = 2L)

## STRICTER TEST: Assert that FutureRegistry won't trigger errors
for (kk in seq_len(nbrOfWorkers())) {
  ## Create broken .Rprofile file
  tf <- file.path(tempdir(), ".Rprofile")
  cat("stop('boom')\n", file = tf)
  f <- local({ opwd <- setwd(dirname(tf)); on.exit(setwd(opwd)); future(42L) })
}

tf <- file.path(tempdir(), ".Rprofile")
cat("stop('boom')\n", file = tf)
f <- local({ opwd <- setwd(dirname(tf)); on.exit(setwd(opwd)); future(42L) })

message("  - Waiting for future to finish")
repeat {
  res <- tryCatch(resolved(f), error = identity)
  if (!is.logical(res) || res) break
}
print(res)
stopifnot(inherits(res, "error"), inherits(res, "FutureError"),
          inherits(res, "CallrFutureError"))

message("  - Getting results")
res <- tryCatch(result(f), error = identity)
print(res)
stopifnot(inherits(res, "error"), inherits(res, "FutureError"),
          inherits(res, "CallrFutureError"))

file.remove(tf)

message("*** callr() ... DONE")

source("incl/end.R")
