#' @title rnames method for stute_test
#' @name rnames.stute_test
#' @description A customized rnames method for stute_test output
#' @param obj A stute_test object
#' @param ... Undocumented
#' @import rnames
#' @returns The same output as rnames.
#' @export
#' @noRd
rnames.stute_test <- function(obj, ...) {
    class(obj) <- "list"
    return(rnames(obj = obj))
}