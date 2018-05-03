## Record original state
ovars <- ls()
oopts <- options(warn = 1L, mc.cores = 2L, future.debug = TRUE)
oopts$future.delete <- getOption("future.delete")
oplan <- future::plan()

## Use local callr futures by default
future::plan(future.callr::callr)

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

await <- future.callr:::await
import_future <- future.callr:::import_future
is_false <- future.callr:::is_false
is_na <- future.callr:::is_na
is_os <- future.callr:::is_os
hpaste <- future.callr:::hpaste
mcat <- future.callr:::mcat
mprintf <- future.callr:::mprintf
mprint <- future.callr:::mprint
mstr <- future.callr:::mstr
printf <- future.callr:::printf
trim <- future.callr:::trim
attach_locally <- function(x, envir = parent.frame()) {
  for (name in names(x)) {
    assign(name, value = x[[name]], envir = envir)
  }
}

