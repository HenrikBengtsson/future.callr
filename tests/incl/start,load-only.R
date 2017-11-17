## Record original state
ovars <- ls()
oopts <- options(warn = 1L, mc.cores = 2L, future.debug = TRUE)
oopts$future.delete <- getOption("future.delete")
oplan <- future::plan()

## Use local processx futures by default
future::plan(future.processx::processx)

fullTest <- (Sys.getenv("_R_CHECK_FULL_") != "")

all_strategies <- function() {
  strategies <- Sys.getenv("R_FUTURE_TESTS_STRATEGIES")
  strategies <- unlist(strsplit(strategies, split = ","))
  strategies <- gsub(" ", "", strategies)
  strategies <- strategies[nzchar(strategies)]
  strategies <- c(future:::supportedStrategies(), strategies)
  unique(strategies)
}

test_strategy <- function(strategy) {
  strategy %in% all_strategies()
}

await <- future.processx:::await
import_future <- future.processx:::import_future
is_false <- future.processx:::is_false
is_na <- future.processx:::is_na
is_os <- future.processx:::is_os
hpaste <- future.processx:::hpaste
mcat <- future.processx:::mcat
mprintf <- future.processx:::mprintf
mprint <- future.processx:::mprint
mstr <- future.processx:::mstr
printf <- future.processx:::printf
trim <- future.processx:::trim
attach_locally <- function(x, envir = parent.frame()) {
  for (name in names(x)) {
    assign(name, value = x[[name]], envir = envir)
  }
}
