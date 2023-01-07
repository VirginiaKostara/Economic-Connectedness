********************************************************************************
** This do file replicates Supplementary Figure 6: Regression of Counties' Causal Effects on Upward Mobility on Social Capital
********************************************************************************

clear all

********************************************************************************
**# 0. Setup 
********************************************************************************

* Define geographic unit 
local geo county

* Merge public data with the FB dataset
import delimited "${fb_data}/social_capital_`geo'.csv", clear 
merge 1:1 `geo' using "${public_data}/`geo'_covariates.dta"


* List of social capital measures
* Note: only a subset of measures is available with public data: economic connectedness, clustering, support ratio, civic organizations, and volunteering rate
* As such, the multivariate analyses are not directly comparable to those in the paper
local vars "ec_`geo' clustering_`geo' support_ratio_`geo' civic_organizations_`geo' volunteering_rate_`geo'"

* Define weight: no. of children with parents with below-median household income
local weight = "num_below_p50"

* Set SE clustering level 
local cluster_var = "cz"


tempfile merged_data
save `merged_data'


********************************************************************************
**# 1. Panel A: Multivariable Regression Coefficients 
********************************************************************************
						 
use `merged_data', clear
postutil clear 
	
* standardize outcome and social capital measures with non-null observations
keep if !missing(`cluster_var')
quietly reg causal_p25_cz_cty_kr26 `vars' [aweight = `weight'], vce(cluster `cluster_var')
keep if e(sample) == 1
center causal_p25_cz_cty_kr26 `vars' [aweight = `weight'], inplace standardize
	
* Now run regression on standardized variables
reg causal_p25_cz_cty_kr26 `vars' [aweight = `weight'], vce(cluster `cluster_var') 

postutil clear
tempname SuppFigure6a
postfile `SuppFigure6a' str25 variable corr se using "${paper1_figs}/SuppFigure6a.dta", replace

foreach var of local vars {
	post `SuppFigure6a' ("`var'") (`=_b[ `var' ]') (`=_se[ `var' ]')
}

postclose `SuppFigure6a'
use "${paper1_figs}/SuppFigure6a.dta", clear

* We will plot the magnitude of the correlation (corr) while using different markers to indicate its sign
gen og_corr = corr
replace corr = abs(corr)

* Upper and lower 95% confidence intervals. Note that lower confidence interval is always nonnegative for presentation purposes.
gen conf_upper =  corr + 1.96 * se
gen conf_lower =  max(corr - 1.96 * se, 0) 

* Variable to order social capital measures on graph
gen var_order = - _n
	
* corrplot
twoway (rcap conf_upper conf_lower var_order,  color(gs6) horizontal msize(medsmall) lwidth(medthin)) ///
	   (scatter var_order corr if og_corr >= 0, mcolor(green) msymbol(circle) msize(medium))  ///
	   (scatter var_order corr if og_corr < 0, mcolor(red) msymbol(triangle) msize(medium)) ///
		 , ylabel(-1 `"Economic Connectedness"' ///
				  -2 `"Clustering"' ///
				  -3 `"Support Ratio"' ///
				  -4 `"Civic Organizations"' ///
				  -5 `"Volunteering Rate"' ///
				  , labsize(small) nogrid) ///	
		   ytitle("") ///
		   xtitle("Multivariable Regression Coefficient" "on Standardized Measure", size(small)) ///
		   title("{bf:Regression of Counties' Causal Effects on Upward Mobility on Social Capital}" " " "{it:A. Multivariable Regression Coefficients}" " ", size(small) span) ///
		   xlabel(0(0.1)0.4, format(%03.1f) gmax gmin nogrid labsize(small)) ///
		   legend(order(2 "Positive" 3 "Negative") pos(6) ring(1) row(1) size(small)) 

graph export "${paper1_figs}/Supplementary_Figure_6a.pdf", replace


* Delete correlations tempfile 
erase "${paper1_figs}/SuppFigure6a.dta"


********************************************************************************
**# 2. Panel B: Incremental R-Squared
********************************************************************************

use `merged_data', clear
postutil clear

keep if !missing(ec_`geo', clustering_`geo', support_ratio_`geo', civic_organizations_`geo', volunteering_rate_`geo') 

postutil clear
tempname SuppFigure6b
postfile `SuppFigure6b' str8 variable float r2 using "${paper1_figs}/SuppFigure6b.dta", replace


* R2 from regression including all social capital measures (r2_all)					  
reg causal_p25_cz_cty_kr26 `vars' [aweight = `weight']
scalar r2_all = e(r2)


* For each social capital measure, calculate the R2 from regression excluding that measure (r2_sub)
* The incremental R2 from including that measure is r2_additional = r2_all - r2_sub
foreach var of local vars {
	
	local vars_sub = subinstr("`vars'", "`var'", "", .)

	reg causal_p25_cz_cty_kr26 `vars_sub' [aweight = `weight']
	scalar r2_sub = e(r2)
	scalar r2_additional = r2_all - r2_sub
	
	post `SuppFigure6b' ("`var'") (`= r2_additional')
}


* Plot graph
postclose `SuppFigure6b'
use "${paper1_figs}/SuppFigure6b.dta", clear
gen var_order = - _n
 
twoway (scatter var_order r2, mcolor("41 182 164") msymbol(circle) msize(medium)),  ///
		ylabel(-1 `"Economic Connectedness"' ///
			   -2 `"Clustering"' ///
			   -3 `"Support Ratio"' ///
			   -4 `"Civic Organizations"' ///
			   -5 `"Volunteering Rate"' ///
				, labsize(small) nogrid) ///
		ytitle("") ///
		xtitle("Increase in R{superscript:2} from Additional Regressor", size(small)) ///
		xlabel(0(0.01)0.02, format(%03.2f) gmax gmin nogrid labsize(small)) ///
		title("{bf:Regression of Counties' Causal Effects on Upward Mobility on Social Capital}" " " "{it:B. Additional R{superscript:2} for Social Capital Measures}" " ", size(small) span)

graph export "${paper1_figs}/Supplementary_Figure_6b.pdf", replace


* Delete tempfile 
erase "${paper1_figs}/SuppFigure6b.dta"

