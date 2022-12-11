source("incl/start.R")

options(future.debug = FALSE)

message("*** RNG ...")

plan(callr, workers = 2L)

message("- future() does not update RNG state")

rng0 <- globalenv()$.Random.seed

f1 <- future(1)
stopifnot(identical(globalenv()$.Random.seed, rng0))  ## RNG changed?

f2 <- future(2)
stopifnot(identical(globalenv()$.Random.seed, rng0))  ## RNG changed?


message("- resolved() does not update RNG state")

f1 <- future(1)
f2 <- future(2)

d1 <- resolved(f1)
stopifnot(identical(globalenv()$.Random.seed, rng0))  ## RNG changed?

d2 <- resolved(f2)
stopifnot(identical(globalenv()$.Random.seed, rng0))  ## RNG changed?


message("- result() does not update RNG state")

f1 <- future(1)
f2 <- future(2)

r1 <- result(f1)
stopifnot(identical(r1$value, 1))
stopifnot(identical(globalenv()$.Random.seed, rng0))  ## RNG changed?

r2 <- result(f2)
stopifnot(identical(r2$value, 2))
stopifnot(identical(globalenv()$.Random.seed, rng0))  ## RNG changed?


message("- value() does not update RNG state")

f1 <- future(1)
f2 <- future(2)

v1 <- value(f1)
stopifnot(identical(v1, 1))
stopifnot(identical(globalenv()$.Random.seed, rng0))  ## RNG changed?

v2 <- value(f2)
stopifnot(identical(v2, 2))
stopifnot(identical(globalenv()$.Random.seed, rng0))  ## RNG changed?

message("*** RNG ... DONE")

source("incl/end.R")
