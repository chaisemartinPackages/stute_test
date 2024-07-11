#' @param df df
#' @param Y Y
#' @param D D
#' @param order order
#' @param brep brep
#' @param res_mat res_mat
#' @param V V
#' @param t_tot t_tot
#' @param t_boot t_boot
#' @importFrom matlib Ginv 
#' @noRd

stute <- function(df,Y,D,order,brep,res_mat,V,t_tot,t_boot) {
    df <- df[order(df[[D]], df[[Y]]), ]
    N <- nrow(df)
    y <- as.vector(df[[Y]])
    X <- matrix(NA, N,order+1)
    for (j in 0:order) {
        X[1:N,j+1] <- df[[D]]^j
    }
    c1 <- (sqrt(5) + 1) / (2 + sqrt(5))
    c2 <- (1 - sqrt(5)) / 2
    c3 <- sqrt(5)
    F <- cbind(V,df[[D]])
    F <- F[order(F[,ncol(F)]), ][, 1:(ncol(F)-1)]
    F <- c2 + c3 * (F > c1)

    out_mat <- matrix(NA, nrow = 1, ncol = 3)
    out_mat[1, 2:3] <- stute_core(X,y,F)

#    for (i in 1:brep) {
#        y_st <- X %*% b + (matrix(c2,nrow=N,ncol=1) + c3*as.numeric(F[,i] > c1)) * e_lin
#        b_st <- Ginv(t(X) %*% X) %*% (t(X) %*% y_st)
#        e_lin_st <- y_st - X %*% b_st
#        bres[i,1] <- stute_stat(e_lin_st)
#    }
#    out_mat[1,3] <- mean(as.numeric(bres > out_mat[1,2]))

    print(out_mat)
}

