**********************************************************************************
** This do file replicates Extended Data Figure 5: Association between Economic Connectedness and Counties' Causal Effects on Upward Income Mobility
********************************************************************************

clear all 

********************************************************************************
**# 0. Setup 
********************************************************************************

* Define geographic unit 
local geo county

* Set SE clustering level 
local cluster_var = "cz"


import delimited "${fb_data}/social_capital_`geo'.csv", clear 
merge 1:1 `geo' using "${public_data}/`geo'_covariates.dta"


/* 
To calculate the signal correlation, we multiply the raw correlation by the ratio of the raw standard deviation to the signal standard deviation to adjust for noise.
From Table II, Panel A, Column 3 of Chetty and Hendren (2018b), the raw standard deviation is 0.434 and the signal standard deviation is 0.165. 
The ratio of the raw standard deviation to the signal standard deviation is then 0.434 / 0.165 = 2.63
*/			
local raw_to_signal_ratio 2.63 


* Use precision weights from Chetty and Hendren (2018b)
gen weights = (1 / causal_p25_cz_cty_kr26_se) ^ 2


* Rescale dependent variable to estimate effect of growing up in a county for 20 years
replace causal_p25_cz_cty_kr26 = causal_p25_cz_cty_kr26 * 20


********************************************************************************
** 1. Plot graph 
********************************************************************************

preserve 

keep if !missing(ec_`geo', causal_p25_cz_cty_kr26, weights, `cluster_var')

* Estimate regression coefficients
reg causal_p25_cz_cty_kr26 ec_`geo' [aweight = weights], vce(cluster `cluster_var')
local slope = "`: display %3.1f _b[ec_`geo']'"
local slope_se = "`: display %3.1f _se[ec_`geo']'"


* Estimate signal correlation
center ec_`geo' causal_p25_cz_cty_kr26 [aweight = weights], inplace standardize 

reg causal_p25_cz_cty_kr26 ec_`geo' [aweight = weights], vce(cluster `cluster_var')

local raw_corr = "`: display %3.2f _b[ec_`geo']'"
local signal_corr = "`: display %3.2f _b[ec_`geo'] * `raw_to_signal_ratio''"
local signal_corr_approx_se = "`: di %3.2f _se[ec_`geo'] * `raw_to_signal_ratio''"

restore


* Binscatter
binscatter causal_p25_cz_cty_kr26 ec_`geo' [aweight = weights], ///
	text(-3 0.90  "Slope = `slope' (`slope_se')", placement(ne) justification(left) color(gs5) size(small)) ///
	text(-3.5 0.90  "Signal Correlation = `signal_corr' (`signal_corr_approx_se')", placement(ne) justification(left) color(gs5) size(small)) ///
	title("{bf:Association between Economic Connectedness and Counties' Causal Effects on Upward Income Mobility}" " ", size(small) span) ///
	xtitle("Economic Connectedness", size(small)) ytitle("County-Level Causal Effect" "(Percentile Change in Earnings Rank, From Birth)", size(small)) ///
	xlabel(, format(%3.1f) labsize(small)) ylabel(, nogrid labsize(small)) lcolor(sand) mcolor(eltblue)
	
graph export "${paper1_figs}/Extended Data_Figure_5.pdf", replace


