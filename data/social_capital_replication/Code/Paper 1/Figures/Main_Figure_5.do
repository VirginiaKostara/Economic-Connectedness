********************************************************************************
** This do file replicates Main Figure 5: County-Level Correlations between Upward Income Mobility and Neighborhood Characteristics
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
		   

* Define weight: no. of children with parents with below-median household income
local weight = "num_below_p50"

* Set SE clustering level 
local cluster_var = "cz"


tempfile merged_data
save `merged_data'


********************************************************************************
**# 1. Panel A: Univariate Correlations 
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

tempname MainFigure5a
postfile `MainFigure5a' str25 variable corr se using "${paper1_figs}/MainFigure5a.dta", replace
foreach var of local vars {

	preserve 
	
	keep if !missing(kfr_pooled_pooled_p25, `var', `weight', `cluster_var')
	
	* Standardize outcome and social capital measures
	center kfr_pooled_pooled_p25 `var' [aweight = `weight'], inplace standardize		
	
	* Univariate correlations
	reg kfr_pooled_pooled_p25 `var' [aweight = `weight'], vce(cluster `cluster_var')
	post `MainFigure5a' ("`var'") (`=_b[`var']') (`=_se[`var']')
	
	restore
}


postclose `MainFigure5a'
use "${paper1_figs}/MainFigure5a.dta", clear

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
		   title("{bf:County-Level Correlations between Upward Income Mobility and Neighborhood Characteristics}" " " "{it:A. Univariate Correlations}" " ", size(small) span) ///
		   xlabel(0(0.2)0.8, format(%03.1f) gmax gmin nogrid labsize(small)) ///
		   legend(order(2 "Positive" 3 "Negative") pos(6) ring(1) row(1) size(small)) 
				
graph export "${paper1_figs}/Main_Figure_5a.pdf", replace	


* Delete correlations tempfile 
erase "${paper1_figs}/MainFigure5a.dta"

	
********************************************************************************
**# 2. Panel B: Coefficients from Multivariate Regression 
********************************************************************************

* Covariates for multivariate regression: economic connectedness + list of neighboring characteristics 
local vars ec_`geo' /// 
		   med_hhinc2000 ///
		   racial_segregation ///
		   share_black2000 ///
		   gini99_simple /// 
		   gsmn_math_g3_2013 ///
	       singleparent_share2000 

						 
use `merged_data', clear
postutil clear 
	
* standardize outcome and covariates with non-null observations
keep if !missing(`cluster_var')
quietly reg kfr_pooled_pooled_p25 `vars' [aweight = `weight'], vce(cluster `cluster_var')
keep if e(sample) == 1
center kfr_pooled_pooled_p25 `vars' [aweight = `weight'], inplace standardize
	
* Now run regression on standardized variables
reg kfr_pooled_pooled_p25 `vars' [aweight = `weight'], vce(cluster `cluster_var') 

postutil clear
tempname MainFigure5b
postfile `MainFigure5b' str25 variable corr se using "${paper1_figs}/MainFigure5b.dta", replace

foreach var of local vars {
	post `MainFigure5b' ("`var'") (`=_b[ `var' ]') (`=_se[ `var' ]')
}

postclose `MainFigure5b'
use "${paper1_figs}/MainFigure5b.dta", clear

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
				  -3 `" "Racial Segregation" "' ///
				  -4 `" "Share Black" "' ///
				  -5 `" "Income Inequality (Gini coefficient)" "' ///
				  -6 `" "Mean 3rd Grade Math Score" "' ///
				  -7 `" "Share Single Parent HH" "' ///
				  , labsize(small) nogrid) ///	
		   ytitle("") ///
		   xtitle("Multivariable Regression Coefficient" "on Standardized Measure", size(small)) ///
		   title("{bf:County-Level Correlations between Upward Income Mobility and Neighborhood Characteristics}" " " "{it:B. Coefficients from Multivariate Regression}" " ", size(small) span) ///
		   xlabel(0(0.2)0.6, format(%03.1f) gmax gmin nogrid labsize(small)) ///
		   legend(order(2 "Positive" 3 "Negative") pos(6) ring(1) row(1) size(small)) 

graph export "${paper1_figs}/Main_Figure_5b.pdf", replace


* Delete correlations tempfile 
erase "${paper1_figs}/MainFigure5b.dta"


