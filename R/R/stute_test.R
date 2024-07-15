#' @title Linearity test from Stute (1997) <https:https://www.jstor.org/stable/2242560>
#' @param df (data.frame) A dataframe object.
#' @param Y (char) Outcome variable.
#' @param D (char) Treatment/independent variable.
#' @param group (char) Group variable.
#' @param time (char) Time variable.
#' @param order (numeric) If this option is specified, the program tests whether the conditional expectation of \eqn{Y} given \eqn{D} is a \eqn{#}-degree polynomial in \eqn{D}. With \code{order = 0}, the command tests the hypothesis that the conditional mean of \eqn{Y} given \eqn{D} is constant.
#' @param seed (numeric) This option allows to specify the seed for the wild bootstrap routine.
#' @param brep (numeeric) This option allows to specify the number of wild bootstrap replications. The default is 500.
#' @param baseline (numeric) This option allows to select one of the periods in the data as the baseline or omitted period. For instance, in a dataset with the support  of \code{time} equal to \eqn{(2001, 2002, 2003)}, \code{stute_test(..., baseline = 2001)} will test the hypotheses that the expectations of \eqn{Y_2002 - Y_2001} and \eqn{Y_2003 - Y_2001} are linear functions of \eqn{D_2002 - D_2001} and \eqn{D_2003 - D_2001}. This option can only be specified in \code{panel} mode.
#' @section Overview:
#' This program implements the non-parametric test that the expectation of Y given D is linear proposed by Stute (1997). In the [companion vignette](), we sketch the intuition behind the test, as to motivate the use of the package and its options. Please refer to Stute (1997) and Section 3 of de Chaisemartin and D'Haultfoeuille (2024) for further details.
#' 
#' This package allows for two estimation settings:
#' 
#' 1. \code{cross-section}. The test is run using the full dataset, treating each observation as an independent realization of \eqn{(Y,D)}. 
#' 
#' 2. \code{panel}. The test is run for all values of \code{time}, using a panel with \eqn{G} groups/units and \eqn{T} periods. In this mode, the test statistics will be computed among observations having the same value of \code{time}. The program will also return a joint test on the sum of the period-specific estimates. Due to the fact that inference on the joint statistic is performed via the bootstrap distribution of the  sum of the test statistics across time periods, this  mode requires a strongly balanced panel with no gaps.
#' @examples
#' set.seed(0)
#' GG <- 10; TT <- 5;
#' data <- as.data.frame(matrix(NA, nrow = GG * TT, ncol = 0))
#' data$G <- (1:nrow(data) - 1) %% GG + 1
#' data$T <- floor((1:nrow(data)-1)/GG) + 2000
#' data <- data[order(data$G, data$T), ]
#' data$D <- runif(n=nrow(data))
#' data$Y <- runif(n=nrow(data))
#' stute_test(df = data, Y = "Y", D = "D")
#' stute_test(df = data, Y = "Y", D = "D", group = "G", time = "T")
#' stute_test(df = data, Y = "Y", D = "D", group = "G", time = "T", baseline = 2001)
#' @importFrom plm pdata.frame is.pbalanced
#' @importFrom stats runif
#' @import dplyr
#' @export

stute_test <- function(
    df,
    Y,
    D,
    group = NULL,
    time = NULL,
    order = 1,
    seed = NULL,
    brep = 500,
    baseline = NULL
) {
    args <- list()
    for (v in names(formals(stute_test))) {
        if (!(v %in% c("df", "..."))) {
            args[[v]] <- get(v)
        }
    }
    res <- list(args = args)

    res_mat <- matrix(NA, nrow = 0, ncol = 2)
    t_tot <- 0; t_boot <- matrix(0, nrow = brep, ncol = 1)
    rowt <- c()

    if (is.null(group) & is.null(time)) {
        if (!is.null(baseline)) {
            stop("group and time arguments required when the baseline option is requested.")
        }
        V <- matrix(runif(nrow(df)*brep),nrow=nrow(df),ncol=brep)
        
        res_mat <- stute(df, Y, D, order, brep, res_mat, V, t_tot, t_boot)$res_mat
    } else if (!is.null(group) & !is.null(time)) {
        df <- pdata.frame(df, index = c(group, time)) 
        if (!is.pbalanced(df)) {
            stop("balanced panel required in panel mode.")
        }
        GG <- length(unique(df[[group]]))
        V <- matrix(runif(GG*brep),nrow=GG,ncol=brep)
        GG <- NULL
        outcome <- Y; treat <- D;
        if (!is.null(baseline)) {
            if (sum(df[[time]] == baseline) == 0) {
                stop("Baseline period not found in the support of the time variable.")
            }
            for (v in c(Y,D)) {
                df$base_temp_XX <- ifelse(df[[time]] == baseline, df[[v]], NA)
                df <- df %>% group_by(.data[[group]]) %>% mutate(base_XX =  mean(.data$base_temp_XX, na.rm = TRUE)) %>% ungroup()
                df[[paste0(v,"_b")]] <- df[[v]] - df$base_XX
                df$base_XX <- df$base_temp_XX <- NULL
            }
            outcome <- paste0(Y,"_b"); treat <- paste0(D,"_b");
            df <- subset(df, df[[time]] != baseline)
        }
        for (t in unique(df[[time]])) {
            res_list <- stute(subset(df, df[[time]] == t), outcome, treat, order, brep, res_mat, V, t_tot, t_boot, panel = TRUE)
            for (v in names(res_list)) {
                assign(v, res_list[[v]])
            }
            res_list <- NULL
            rowt <- c(rowt, t)
        }
    }
    colnames(res_mat) <- c("t stat", "p-value")
    if (!is.null(rowt)) {
        if (!is.null(baseline)) {
            rownames(res_mat) <- as.character(as.numeric(rowt) - baseline)
        } else {
            rownames(res_mat) <- rowt
        }
        joint <- matrix(NA, nrow = 1, ncol = 2)
        joint[1,1] <- t_tot
        joint[1,2] <- mean(as.numeric(t_boot > t_tot))
        colnames(joint) <- c("t stat", "p-value")
        rownames(joint) <- ""
        res$joint <- joint
    } else {
        rownames(res_mat) <- ""
    }
    res$results <- res_mat
    class(res) <- "stute_test"
    return(res)
}