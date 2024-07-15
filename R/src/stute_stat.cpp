#include <iostream>
#include <vector>
#include <cmath>
#include "RcppArmadillo.h"

using namespace std;
using namespace Rcpp;
using namespace arma;

template <typename T>
Rcpp::NumericVector arma2vec(const T& x) {
    return Rcpp::NumericVector(x.begin(), x.end());
}

arma::mat vrep(const arma::colvec& A, const int B) {
    arma::mat V(A.n_rows, B);
    for (int k = 0; k < B; k++) {
        V.col(k) = A;
    }
    return(V);
}

// [[Rcpp::depends(RcppArmadillo)]]
// [[Rcpp::export]]
arma::rowvec stute_stat(arma::mat& V) {
    int N =  V.n_rows, B = V.n_cols;
    arma::mat L(N, N);
    arma::rowvec C(B);
    arma::rowvec I(N);
    L.fill(1);I.fill(1);
    L = trimatl(L);
    arma::mat H = pow(L * V, 2);
    C = I * H * pow(N,-2);
    return(C);
}

double p_val(arma::rowvec& B, double J) {
    double p = 0;
    int L = B.n_cols;
    for (int j = 0; j < L; j++) {
        p += B[j] > J;
    }
    return(p/L);
}

// [[Rcpp::depends(RcppArmadillo)]]
// [[Rcpp::export]]
NumericMatrix stute_core(const arma::mat& X, const arma::colvec& y, const arma::mat& F) {
    NumericMatrix J(2,F.n_cols);

    arma::mat lin_res(X.n_rows, 1);
    lin_res.col(0) = y - X*solve(X, y);
    J.row(0)[0] = arma2vec(stute_stat(lin_res))[0];

    int B = F.n_cols;
    arma::mat Y_st = vrep(y,B) - vrep(lin_res,B) + F % vrep(lin_res, B);
    arma::mat lin_res_st = Y_st - X * solve(X,Y_st);
    arma::rowvec bres = stute_stat(lin_res_st);
    J.row(0)[1] = p_val(bres, J.row(0)[0]);
    J.row(1) = arma2vec(bres);

    return(J);
}
