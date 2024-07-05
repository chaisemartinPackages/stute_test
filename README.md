# stute_test

Linearity test from Stute (1997).

## Setup

```
net install stute_test, from("https://raw.githubusercontent.com/chaisemartinPackages/stute_test/main/Stata/dist") replace
```

## Syntax

```
stute_test Y D [G T], order(#) brep(#) seed(#) baseline(#)
```

where

+ **Y** is the dependent variable.
+ **D** is the independent variable.
+ **G** is the group variable.
+ **T** is the time variable.

## Overview

This program implements the non-parametric test that the expectation of Y given D is linear proposed by Stute (1997). In the next section, we sketch the intuition behind the test, as to motivate the use of the package and its options. Please refer to Stute (1997) and Section 3 of de Chaisemartin and D'Haultfoeuille (2024) for further details.

This package allows for two estimation settings:

1. **cross-section**: `stute_test Y D`. The test is run using the full dataset, treating each observation as an independent realization of (**Y**, **D**). 

2. **panel**: `stute_test Y D G T`. The test is run for all values of **T**, using a panel with **G** groups/units and **T** periods. In this mode, the test statistics will be computed among observations having the same value of **T**. The program will also return a joint test on the sum of the period-specific estimates. Due to the fact that inference on the joint statistic is performed via the bootstrap distribution of the sum of the test statistics across time periods, this mode requires a **strongly balanced panel** with no gaps. This requirement can be checked by running ```xtset G T```.

## Formal description

Let $Y$ and $D$ be two random variables. Let $m(D) = E[Y|D]$. The null hypothesis of the test is that $m(D) = \alpha_0 + \alpha_1 D$ for two real numbers $\alpha_0$ and $\alpha_1$. This means that, under the null, $m(.)$ is linear in $D$. This hypothesis can be tested in a sample with $N$ i.i.d. realizations of $(Y, D)$ using the following test statistic from Stute (1997):

$$
T = \dfrac{1}{N^2}\sum_{i = 1}^N \left(\sum_{j = 1}^i \varepsilon_{(j)} \right)^2
$$

where $\varepsilon_{(j)}$ is the residual from a linear regression of $Y$ on $D$ and a constant of the $j$-th observation after sorting by $D$. In other words, $T$ is obtained by sorting the data from the smallest to the largest value of $D$ and summing the squares of the total cumulative sums of the linear regression residuals.

Stute et al. (1998) show that, under the null, $T$ is finite. Conversely, under the alternative, at least one of the inner sums tends to infinity, hence $T$ diverges. Inference is performed using wild bootstrap. Specifically, $T$ is re-computed replacing $Y$ with $Y^\ast$, i.e. the predicted value of $Y$ from the linear regression of $Y$ on $D$ and a constant, plus the residuals multiplied by a two-point random variable, denoted as $V_{(j)}$, such that:

$$
P\left(V_{(j)} = \frac{1 + \sqrt{5}}{2}\right) = \frac{\sqrt{5}-1}{2}, P\left(V_{(j)} = \frac{1 - \sqrt{5}}{2}\right) = \frac{3 - \sqrt{5}}{2}.
$$

Denote with $T^{\ast}_b$ the $T^{\ast}$ statistic computed at the $b$-th bootstrap replication. The p-value from $B$ bootstrap replications is computed as 

$$
\frac{1}{B}\sum_{b = 1}^B \mathbb{1}\lbrace T < T^\ast_b\rbrace
$$

Intuitively, under the alternative, the p-value should be zero, due to the fact that T diverges.

This test also works with panel data. In that case, the $T$ statistic is computed for each value of the time variable. Moreover, $V_{(j)}$ remains constant at the group level across the computation of the period-specific test statistics. Hence, the residual of group $g$ from a linear regression of $Y_{g,t}$ on $D_{g,t}$ and a constant are multiplied by $V_g$, regardless of $t$. Lastly, the individual test results can be summed into a joint test statistic. In this case, inference is performed using the distribution of the sum of the bootstrap statistics. Denote with $T_\ell$ the $\ell$-th period test statistic and with $T^\ast_{\ell,b}$ its $b$-th bootstrap estimate. In a dataset with $L$ periods, the p-value of the joint test is computed as follows:

$$
\frac{1}{B}\sum_{b = 1}^B \mathbb{1}\left\lbrace\sum_{\ell = 1}^L T_\ell < \sum_{\ell = 1}^L T^*_{\ell, b}\right\rbrace.
$$

## Options

+ **order(**#**)** If this option is specified, the program tests whether the conditional expectation of **Y** given **D** is a #-degree polynomial in **D**. 
With **order(**0**)**, the command tests the hypothesis that the conditional mean of **Y** given **D** is constant.

+ **seed(**#**)** This option allows to specify the seed for the wild bootstrap routine.

+ **brep(**#**)** This option allows to specify the number of wild bootstrap replications. The default is 500.

+ **baseline(**#**)** This option allows to select one of the periods in the data as the baseline or omitted period. For instance, in a dataset with the support of **T** equal to (2001, 2002), `stute_test Y D G T, baseline(2001)` will test the hypothesis that the expectation of $Y_{2002} - Y_{2001}$ is a linear function of $D_{2002} - D_{2001}$. This option can only be specified in **panel** mode.

## Example

```
clear
set seed 0
set obs 200
gen G = mod(_n-1, 40) + 1
bys G: gen T = _n
gen D = uniform()
gen Y = 1 + uniform()*D
stute_test Y D, seed(0)
stute_test Y D G T, seed(0)
stute_test Y D G T, baseline(1) seed(0)
```

## References


de Chaisemartin, C, D'Haultfoeuille, X (2024). [Two-way Fixed Effects and Difference-in-Difference Estimators in Heterogeneous Adoption Designs](https://ssrn.com/abstract=4284811)


Stute, W (1997). [Nonparametric model checks for regression](https://www.jstor.org/stable/2242560).

Stute, W, Manteiga, W, Quindimil, M (1998). [Bootstrap approximations in model checks for regression](https://www.tandfonline.com/doi/abs/10.1080/01621459.1998.10474096). 


