source("incl/start.R")

message("*** callr() - terminating workers ...")

plan(callr, workers = 2L)

all <- nbrOfWorkers()
free <- nbrOfFreeWorkers()
stopifnot(
  nbrOfWorkers() == 2L,
  nbrOfFreeWorkers() == 2L
)

## Force R worker to quit
f <- future({ tools::pskill(pid = Sys.getpid()) })
res <- tryCatch(value(f), error = identity)
print(res)
stopifnot(inherits(res, "FutureError"))

stopifnot(
  nbrOfWorkers() == all,
  nbrOfFreeWorkers() == free
)

message("*** callr() - terminating workers ... DONE")

source("incl/end.R")
