#' @title A print method for stute_test
#' @name print.stute_test
#' @description A customized printed display for stute_test output
#' @param x A stute_test object
#' @param ... Undocumented
#' @returns No return, custom print method for stute_test objects.
#' @export
#' @noRd
print.stute_test <- function(x, ...) {
    dis_mat <- matrix(NA, nrow = nrow(x$results), ncol = ncol(x$results))
    if (is.null(x$args$group) & is.null(x$args$time)) {
        cat("\n(Cramer-von Mises) Cross Sectional Stute Test\n")
        dis_mat[1,1] <- sprintf("%.7f", x$results[1,1])
        dis_mat[1,2] <- sprintf("%.4f", x$results[1,2])
    } else if (!is.null(x$args$group) & !is.null(x$args$time)) {
        cat("\n(Cramer-von Mises) Panel Stute Test\n")
        if (!is.null(x$args$baseline)) {
            cat(sprintf("Baseline: %s\n", x$args$baseline))
        }
        dis_mat[,1] <- sprintf("%.7f", x$results[,1])
        dis_mat[,2] <- sprintf("%.4f", x$results[,2])
    }
    rownames(dis_mat) <- rownames(x$results)
    colnames(dis_mat) <- colnames(x$results)
    print(noquote(dis_mat), drop = FALSE)
    if (!is.null(x$joint)) {
        cat(sprintf("\nJoint Stute test: %.4f (%.4f)\np-value in parentheses.\n",x$joint[1,1],x$joint[1,2]))
    }
    cat("\n")
}

#' @title A summary method for stute_test
#' @name summary.stute_test
#' @description A customized summary display for stute_test output
#' @param object A stute_test object
#' @param ... Undocumented
#' @returns No return, custom summary method for stute_test objects.
#' @export
#' @noRd
summary.stute_test <- function(object, ...) {
    print(object)
}