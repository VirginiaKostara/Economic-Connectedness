**********************************************************************************
** This do file replicates Supplementary Figure 5: Social Capital and Upward Mobility in Counties with Predominantly White Residents
********************************************************************************

clear all 

********************************************************************************
**# 0. Setup
********************************************************************************

clear all


* Define geographic units 
local geo = "county"

* Define weight: no. of children with parents with below-median household income
local weight = "num_below_p50"

* Set SE clustering level 
local cluster_var = "cz"


import delimited "${fb_data}/social_capital_`geo'.csv", clear 
merge 1:1 `geo' using "${public_data}/`geo'_covariates.dta"


* Keep counties with 90+% white population
keep if share_white2000 > 0.9

* Rescale upward mobility variable 
replace kfr_pooled_pooled_p25 = kfr_pooled_pooled_p25 * 100


tempfile merged_data
save `merged_data'

********************************************************************************
**# 1. Panel B: Relationship between Upward Mobility and Economic Connectedness
********************************************************************************

use `merged_data', clear


* Regression line slope 
reg kfr_pooled_pooled_p25 ec_`geo' [aweight = `weight']
local beta  = _b[ ec_`geo']
local alpha = _b[_cons]

* Correlation coefficient
corr kfr_pooled_pooled_p25 ec_`geo' [aweight = `weight']
local overall_corr = strofreal(`r(rho)', "%9.2f")

* Keep 200 most populous counties for consistency with main figure 4
gsort -pop2000
keep if _n <= 200
			

* Scatterplot
twoway (scatter kfr_pooled_pooled_p25 ec_`geo', msize(vsmall) mcolor(gs10)) ///
       (function y = `alpha' + `beta' * x, range(0.6 1.3) lcolor(gs8))  ///
	   , ytitle("Predicted Household Income Rank for" "Children with Parents at 25th Percentile", size(small))  ///
		 xtitle("Economic Connectedness", size(small)) ///
		 title("{bf:Social Capital and Upward Mobility in Counties with Predominantly White Residents}" " " "{it:B. Relationship between Upward Mobility and Economic Connectedness}" " ", size(small) span) ///
		 legend(off) ylabel(30(5)55, nogrid labsize(small)) xlabel(0.5(0.2)1.3, format(%03.1f) labsize(small)) ///
		 text(33 1.0  "Correlation = `overall_corr'", placement(ne) justification(left) color(gs8) size(small))

graph export "${paper1_figs}/Supplementary_Figure_5b.pdf", replace		


********************************************************************************
**# 2. Panel C: Univariate Correlations between Upward Mobility and Social Capital
********************************************************************************

* List of social capital measures
* Note: only a subset of measures is available with public data: economic connectedness, clustering, support ratio, civic organizations, and volunteering rate
local vars "ec_`geo' clustering_`geo' support_ratio_`geo' civic_organizations_`geo' volunteering_rate_`geo'"


use `merged_data', clear
postutil clear

tempname SuppFigure5c
postfile `SuppFigure5c' str25 variable corr se using "${paper1_figs}/SuppFigure5c.dta", replace
foreach var of local vars {

	preserve 
	
	keep if !missing(kfr_pooled_pooled_p25, `var', `weight', `cluster_var')
	
	* Standardize outcome and social capital measures
	center kfr_pooled_pooled_p25 `var' [aweight = `weight'], inplace standardize		
	
	* Univariate correlations
	reg kfr_pooled_pooled_p25 `var' [aweight = `weight'], vce(cluster `cluster_var')
	post `SuppFigure5c' ("`var'") (`=_b[`var']') (`=_se[`var']')
	
	restore
}


postclose `SuppFigure5c'
use "${paper1_figs}/SuppFigure5c.dta", clear

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
		   xtitle("Magnitude of Pop-Wtd. Univariate Correlation with" "Upward Mobility across Counties", size(small)) ///
		   title("{bf:Social Capital and Upward Mobility in Counties with Predominantly White Residents}" " " "{it:C. Univariate Correlations between Upward Mobility and Social Capital}" " ", size(small) span) ///
		   xlabel(0(0.2)0.8, format(%03.1f) gmax gmin nogrid labsize(small)) ///
		   legend(order(2 "Positive" 3 "Negative") pos(6) ring(1) row(1) size(small)) 
				
graph export "${paper1_figs}/Supplementary_Figure_5c.pdf", replace	


* Delete correlations tempfile 
erase "${paper1_figs}/SuppFigure5c.dta"


********************************************************************************
**# 3. Panel D: Univariate Correlations between Upward Mobility and Other Neighborhood Characteristics 
********************************************************************************

* Covariates for univariate correlations: economic connectedness + list of neighboring characteristics 
local vars ec_`geo' /// 
		   med_hhinc2000 ///
		   nonpoor_share2000 ///
		   income_segregation ///
		   racial_segregation ///
		   share_black2000 ///
		   gini99_simple /// 
		   jobs_total_5mi_2015 ///
		   job_growth_2004_2013 ///
           emp2000 ///
		   gsmn_math_g3_2013 ///
	       frac_coll_plus2000 ///
		   share_hisp2000 ///
	       singleparent_share2000 
					  
					  	
use `merged_data', clear
postutil clear

tempname SuppFigure5d
postfile `SuppFigure5d' str25 variable corr se using "${paper1_figs}/SuppFigure5d.dta", replace
foreach var of local vars {

	preserve 
	
	keep if !missing(kfr_pooled_pooled_p25, `var', `weight', `cluster_var')
	
	* Standardize outcome and social capital measures
	center kfr_pooled_pooled_p25 `var' [aweight = `weight'], inplace standardize		
	
	* Univariate correlations
	reg kfr_pooled_pooled_p25 `var' [aweight = `weight'], vce(cluster `cluster_var')
	post `SuppFigure5d' ("`var'") (`=_b[`var']') (`=_se[`var']')
	
	restore
}


postclose `SuppFigure5d'
use "${paper1_figs}/SuppFigure5d.dta", clear

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
		 , ylabel(-1 `" "Economic Connectedness" "' ///
				  -2 `" "Median HH Income" "' ///
				  -3 `" "Share Above Poverty Line" "' ///
				  -4 `" "Income Segregation" "' ///
				  -5 `" "Racial Segregation" "' ///
				  -6 `" "Share Black" "' ///
				  -7 `" "Income Inequality (Gini coefficient)" "' /// 
				  -8 `" "Jobs Within 5 Miles" "' ///
				  -9 `" "Job Growth 2004–2013" "' ///
				  -10 `" "2000 Employment Rate" "' ///
				  -11 `" "Mean 3rd Grade Math Score" "' ///
				  -12 `" "Share College Grad." "' ///
				  -13 `" "Share Hispanic" "' ///
				  -14 `" "Share Single Parent HH" "' ///
				  , labsize(small) nogrid) ///	
		   ytitle("") ///
		   xtitle("Magnitude of Pop-Wtd. Univariate Correlation with" "Upward Mobility across Counties", size(small)) ///
		   title("{bf:Social Capital and Upward Mobility in Counties with Predominantly White Residents}" " " "{it:D. Univariate Correlations between Upward Mobility and Other Neighborhood Characteristics}" " ", size(small) span) ///
		   xlabel(0(0.2)0.8, format(%03.1f) gmax gmin nogrid labsize(small)) ///
		   legend(order(2 "Positive" 3 "Negative") pos(6) ring(1) row(1) size(small)) 
				
graph export "${paper1_figs}/Supplementary_Figure_5d.pdf", replace	


* Delete correlations tempfile 
erase "${paper1_figs}/SuppFigure5d.dta"






