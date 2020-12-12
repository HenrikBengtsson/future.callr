#' @importFrom future nbrOfWorkers nbrOfFreeWorkers
#' @export
nbrOfFreeWorkers.callr <- local({
  FutureRegistry <- import_future("FutureRegistry")
  
  function(evaluator = NULL, background = FALSE, ...) {
  #  assert_no_positional_args_but_first()
    workers <- nbrOfWorkers(evaluator)
    usedWorkers <- length(FutureRegistry("workers-callr", action = "list",
                          earlySignal = FALSE))
    workers <- workers - usedWorkers
    stop_if_not(length(workers) == 1L, !is.na(workers), workers >= 
        0L, is.finite(workers))
    workers
  }
})
