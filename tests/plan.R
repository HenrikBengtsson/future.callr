source("incl/start,load-only.R")

message("*** plan() ...")

message("*** future::plan(future.callr::callr)")
oplan <- future::plan(future.callr::callr)
print(future::plan())
future::plan(oplan)
print(future::plan())


library("future.callr")
plan(callr)

for (type in c("callr")) {
  mprintf("*** plan('%s') ...", type)

  plan(type)
  stopifnot(inherits(plan(), "callr"))

  a <- 0
  f <- future({
    b <- 3
    c <- 2
    a * b * c
  })
  a <- 7  ## Make sure globals are frozen
  v <- value(f)
  print(v)
  stopifnot(v == 0)

  mprintf("*** plan('%s') ... DONE", type)
} # for (type ...)


message("*** Assert that default backend can be overridden ...")

mpid <- Sys.getpid()
print(mpid)

plan(callr)
pid %<-% { Sys.getpid() }
print(pid)
stopifnot(pid != mpid)


message("*** plan() ... DONE")

source("incl/end.R")
