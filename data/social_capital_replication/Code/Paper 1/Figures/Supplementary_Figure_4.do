**********************************************************************************
** This do file replicates Supplementary Figure 4: ZIP Code-Level Correlations between Economic Mobility and Neighborhood Characteristics
********************************************************************************

clear all 

********************************************************************************
**# 0. Setup
********************************************************************************

* Define geographic unit 
local geo zip

* Merge public data with the FB dataset
import delimited "${fb_data}/social_capital_`geo'.csv", clear 
merge 1:1 `geo' using "${public_data}/`geo'_covariates.dta"

* Define weight: no. of children with parents with below-median household income
local weight = "num_below_p50"

* List of outcomes 
local outcomes kfr_pooled_pooled_p25
label var kfr_pooled_pooled_p25 "Upward Mobility"

* Set SE clustering level 
local cluster_var = "county"


tempfile merged_data
save `merged_data'


********************************************************************************
**# 1. Panel A:  Relationship between Upward Mobility and EC
********************************************************************************

preserve


* Create new variable (standardized economic connectedness) for correlations
center ec_`geo' [aweight = `weight'], standardize gen(std_SEC)

* Rescale mobility variable 
replace kfr_pooled_pooled_p25 = kfr_pooled_pooled_p25 * 100


* Get slope + SE
reg kfr_pooled_pooled_p25 ec_`geo' [aweight = `weight'], vce(cluster `cluster_var')
local mobilitySlope: display %2.1f _b[ec_`geo']
local mobilitySE: display %2.1f _se[ec_`geo']


* Get corr + SE
center kfr_pooled_pooled_p25 [aweight = `weight'], standardize gen(std_kfr_pooled_pooled_p25)

reg std_kfr_pooled_pooled_p25 std_SEC [aweight = `weight'], vce(cluster `cluster_var')
local corr: display %3.2f _b[std_SEC]
local corrSE: display %3.2f _se[std_SEC]


* Plot graph
binscatter kfr_pooled_pooled_p25 ec_`geo' [aweight = `weight'], ///
xlabel(, format(%2.1f) labsize(small)) ylabel(, nogrid labsize(small)) ///
ytitle("Predicted Household Income Rank for" "Children w/ Parents at 25th Pctile", size(small)) ///
xtitle("Economic Connectedness", size(small)) /// 
text(33 1.0  "Slope = `mobilitySlope' (`mobilitySE')", placement(ne) justification(left) color(gs5) size(small)) ///
text(31 1.0  "Correlation = `corr' (`corrSE')", placement(ne) justification(left) color(gs5) size(small)) ///
lcolor("sand") mcolor("sand") ///
title("{bf:ZIP Code-Level Correlations between Economic Mobility and Neighborhood Characteristics}" " " "{it:A. Relationship between Upward Mobility and Economic Connectedness}" " ", size(small) span)
	
	
graph export "${paper1_figs}/Supplementary_Figure_4a.pdf", replace


restore

********************************************************************************
**# 2. Panel B:  Univariate Correlations
********************************************************************************

* Covariates for univariate correlations: economic connectedness + list of neighboring characteristics 
local vars ec_`geo' /// 
		   hhinc_mean2000 ///
           nonpoor_share2000 ///						 
           share_black2000 ///					
		   jobs_total_5mi_2015 ///
           job_growth_2004_2013 ///
           emp2000 ///
           gsmn_math_g3_2013 ///
           frac_coll_plus2000 ///
           share_hisp2000 ///
           singleparent_share2000 
					  
					  
foreach depvar of local outcomes {
	
	use `merged_data', clear
	postutil clear
	local varlabel `: var label `depvar''
	
	tempname SuppFigure4b
	postfile `SuppFigure4b' str25 variable corr se using "${paper1_figs}/SuppFigure4b.dta", replace
	foreach var of local vars {

		preserve 
		
		keep if !missing(`depvar', `var', `weight', `cluster_var')
		
		* Standardize outcome and social capital measures
		center `depvar' `var' [aweight = `weight'], inplace standardize		
		
		* Univariate correlations
		reg `depvar' `var' [aweight = `weight'], vce(cluster `cluster_var')
		post `SuppFigure4b' ("`var'") (`=_b[`var']') (`=_se[`var']')
		
		restore

	}
	
	
	postclose `SuppFigure4b'
	use "${paper1_figs}/SuppFigure4b.dta", clear
	
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
					 -2 `" "Mean HH Income" "' ///
					 -3 `" "Share Above Poverty Line" "' ///		
					 -4 `" "Share Black" "' ///	
					 -5 `" "Jobs Within 5 Miles" "' ///
					 -6 `" "Job Growth 2004–2013" "' ///
					 -7 `" "2000 Employment Rate" "' ///
					 -8 `" "Mean 3rd Grade Math Score" "' ///
					 -9 `" "Share College Grad." "' ///
					 -10 `" "Share Hispanic" "' ///
					 -11 `" "Share Single Parent HH" "' ///
					 , labsize(small) nogrid) ///	
			  ytitle("") ///
			  xtitle("Magnitude of Pop-Wtd. Univariate Correlation with" "`varlabel' across ZIP Codes", size(small) color(gs6)) ///
			  xlabel(0(0.2)0.8, format(%03.1f) gmax gmin nogrid labsize(small)) ///
			  legend(order(2 "Positive" 3 "Negative") pos(6) ring(1) row(1) size(small)) ///
			  title("{bf:ZIP Code-Level Correlations between Economic Mobility and Neighborhood Characteristics}" " " "{it:B. Univariate Correlations}" " ", size(small) span)
				  
	graph export "${paper1_figs}/Supplementary_Figure_4b.pdf", replace	
	
	
	* Delete correlations tempfile 
	erase "${paper1_figs}/SuppFigure4b.dta"
}


	
********************************************************************************
**# 3. Panel C: Coefficients from Multivariate Regression 
********************************************************************************

* Covariates for multivariate regression: economic connectedness + list of neighboring characteristics 
local vars ec_`geo' /// 
		   hhinc_mean2000 ///
		   share_black2000 ///
		   gsmn_math_g3_2013 ///
	       singleparent_share2000 

						 
foreach depvar of local outcomes {
		
	use `merged_data', clear
		
	postutil clear 
	local varlabel `: var label `depvar''
		
	* standardize outcome and covariates with non-null observations
	keep if !missing(`cluster_var')
	quietly reg `depvar' `vars' [aweight = `weight'], vce(cluster `cluster_var')
	keep if e(sample) == 1
	center `depvar' `vars' [aweight = `weight'], inplace standardize
		
	* Now run regression on standardized variables
	reg `depvar' `vars' [aweight = `weight'], vce(cluster `cluster_var') 

	postutil clear
	tempname SuppFigure4c
	postfile `SuppFigure4c' str25 variable corr se using "${paper1_figs}/SuppFigure4c.dta", replace

	foreach var of local vars {
		post `SuppFigure4c' ("`var'") (`=_b[ `var' ]') (`=_se[ `var' ]')
	}

	postclose `SuppFigure4c'
	use "${paper1_figs}/SuppFigure4c.dta", clear

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
					 -2 `" "Mean HH Income" "' ///
					 -3 `" "Share Black" "' ///
					 -4 `" "Mean 3rd Grade Math Score" "' ///
					 -5 `" "Share Single Parent HH" "' ///
				     , labsize(small) nogrid) ///	
			  ytitle("") ///
			  xtitle("Multivariable Regression Coefficient" "on Standardized Measure", size(small) color(gs6)) ///
			  xlabel(0(0.2)0.6, format(%03.1f) gmax gmin nogrid labsize(small)) ///
			  legend(order(2 "Positive" 3 "Negative") pos(6) ring(1) row(1) size(small)) ///
			  title("{bf:ZIP Code-Level Correlations between Economic Mobility and Neighborhood Characteristics}" " " "{it:C. Coefficients from Multivariable Regression}" " ", size(small) span)
	
	graph export "${paper1_figs}/Supplementary_Figure_4c.pdf", replace
	
	
	* Delete correlations tempfile 
	erase "${paper1_figs}/SuppFigure4c.dta"
}






