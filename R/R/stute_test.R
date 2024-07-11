#' @title stute_test
#' @param df df
#' @param Y Y
#' @param D D
#' @param G G
#' @param T T
#' @param order order
#' @param seed seed
#' @param brep brep
#' @param baseline baseline
#' @export

stute_test <- function(
    df,
    Y,
    D,
    G = NULL,
    T = NULL,
    order = 1,
    seed = NULL,
    brep = 500,
    baseline = NULL
) {

    res_mat <- matrix(NA, nrow = 0, ncol = 3)
    t_tot <- 0; t_boot <- matrix(0, nrow = brep, ncol = 1)

    if (is.null(G) & is.null(T)) {
        if (!is.null(baseline)) {
            stop("G and T arguments required when the baseline option is requested.")
        }
        V <- matrix(runif(nrow(df)*brep),nrow=nrow(df),ncol=brep)
        
        updt <- stute(df, Y, D, order, brep, res_mat, V, t_tot, t_boot)
    }



}