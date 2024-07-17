clear
set obs 100
set seed 0
gen D = uniform()
gen Y = (uniform())^(1/5) * D
gen Y_sq = (uniform())^(1/5) * D^(2 * (uniform())^(0.6))
sort D
gen N = _n

graph set window fontface "Times New Roman"

stute_test Y D
local pval = r(main)[1,3]
local test: di %9.4fc r(main)[1,2]
tw lfit Y D if D <= 0.2, lc(gs4) || ///
lfit Y D if D <= 0.4, lc(gs6) || ///
lfit Y D if D <= 0.6, lc(gs8) || ///
lfit Y D if D <= 0.8, lc(gs10) || ///
lfit Y D if D <= 1, lc(gs12) || ///
scatter Y D, mc(white) mlc(black) || ///
, ylabel(none) xticks(none) ytitle("Y") xlabel(none) leg(off) xline(0.2(0.2)1, lc(black) lp(dot) lw(0.2)) ///
title("(a)") name(gr1, replace) note("Stute (1997) Test: `test' (p = `pval')", size(vsmall))
 
stute_test Y_sq D
local pval = r(main)[1,3]
local test: di %9.4fc r(main)[1,2]
tw lfit Y_sq D if D <= 0.2, lc(gs4) || ///
lfit Y_sq D if D <= 0.4, lc(gs6) || ///
lfit Y_sq D if D <= 0.6, lc(gs8) || ///
lfit Y_sq D if D <= 0.8, lc(gs10) || ///
lfit Y_sq D if D <= 1, lc(gs12) || ///
scatter Y_sq D, mc(red) mlc(black) || ///
, ylabel(none) xticks(none) ytitle("Y") xlabel(none) leg(off) xline(0.2(0.2)1, lc(black) lp(dot) lw(0.2)) ///
title("(b)") name(gr2, replace) note("Stute (1997) Test: `test' (p = `pval')", size(vsmall))


cap drop *res*
reg Y D
predict res, res
gen m_res = (sum(res)/N)^2
reg Y_sq D
predict res_sq, res
gen m_res_sq = (sum(res_sq)/N)^2
scatter m_res D, mc(white) mlc(black) || /// 
scatter m_res_sq D, mc(red) mlc(black) || ///
, ylabel(0) xticks(none) ytick(0) ytitle("c{subscript:G}(D){superscript:2}") xlabel(none) ///
leg(order(1 "(a)" 2 "(b)") pos(6) col(2)) name(gr3, replace)

gr combine gr1 gr2, name(gr12, replace) imargin(8 0 0 0)
gr combine gr12 gr3, xcommon ycommon col(1) imargin(0 0 0 0)
gr export "visual_stute.pdf", replace