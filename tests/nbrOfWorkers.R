source("incl/start.R")

message("*** nbrOfWorkers() ...")

ncores <- availableCores()
n <- nbrOfWorkers(callr)
message("Number of workers: ", n)
stopifnot(n == ncores)

message("*** nbrOfWorkers() ... DONE")

source("incl/end.R")
