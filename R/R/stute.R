#' @param df df
#' @param Y Y
#' @param D D
#' @param order order
#' @param brep brep
#' @param res_mat res_mat
#' @param V V
#' @param t_tot t_tot
#' @param t_boot t_boot
#' @param panel panel
#' @noRd

stute <- function(df,Y,D,order,brep,res_mat,V,t_tot,t_boot,panel=FALSE) {
    df <- df[order(df[[D]], df[[Y]]), ]
    N <- nrow(df)
    y <- as.vector(df[[Y]])
    X <- matrix(NA, N,order+1)
    for (j in 0:order) {
        X[1:N,j+1] <- df[[D]]^j
    }
    c1 <- (sqrt(5) + 1) / (2 * sqrt(5))
    c2 <- (1 - sqrt(5)) / 2
    c3 <- sqrt(5)
    F <- cbind(V,df[[D]])
    F <- F[order(F[,ncol(F)]), ][, 1:(ncol(F)-1)]
    F <- c2 + c3 * (F > c1)

    res_list <- list()
    stute_res <- stute_core(X,y,F)
    res_list$res_mat <- rbind(res_mat, stute_res[1, 1:2])
    if (panel) {
        res_list$t_tot <- t_tot +  stute_res[1, 1]
        res_list$t_boot <- t_boot + stute_res[2,]
    }
    return(res_list)
}

