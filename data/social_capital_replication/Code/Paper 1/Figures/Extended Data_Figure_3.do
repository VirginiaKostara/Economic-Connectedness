********************************************************************************
** This do file replicates Extended Data Figure 3: County-Level Univariate Correlations between Other Outcomes and Measures of Social Capital
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
local vars "ec_`geo' clustering_`geo' support_ratio_`geo' civic_organizations_`geo' volunteering_rate_`geo'"

* List of outcomes 
rename (hs_pooled_pooled_p25 teenbrth_pooled_female_p25) (hs_completion teenbirth) 
label var hs_completion "High School Completion"
label var teenbirth "Teen Birth Rate"
local outcomes hs_completion teenbirth

* Define weight: no. of children with parents with below-median household income
local weight = "num_below_p50"

* Set SE clustering level 
local cluster_var = "cz"


tempfile merged_data
save `merged_data'


********************************************************************************
**# 1. Univariate Correlations 
********************************************************************************
					  
foreach depvar of local outcomes {
	
	use `merged_data', clear
	postutil clear
	local varlabel `: var label `depvar''
	
	tempname EDFigure3
	postfile `EDFigure3' str25 variable corr se using "${paper1_figs}/EDFigure3.dta", replace
	foreach var of local vars {

		preserve 
		
		keep if !missing(`depvar', `var', `weight', `cluster_var')
		
		* Standardize outcome and social capital measures
		center `depvar' `var' [aweight = `weight'], inplace standardize		
		
		* Univariate correlations
		reg `depvar' `var' [aweight = `weight'], vce(cluster `cluster_var')
		post `EDFigure3' ("`var'") (`=_b[`var']') (`=_se[`var']')
		
		restore

	}
	
	
	postclose `EDFigure3'
	use "${paper1_figs}/EDFigure3.dta", clear
	
	* Label figure names and title for each outcome 
	if "`depvar'" == "hs_completion" {
		local figure_name = "Extended Data_Figure_3a"
		local panel_title = "A. High School Completion Rate for Children with Parents at 25th Percentile"
	}
	
	else {
		local figure_name = "Extended Data_Figure_3b"
		local panel_title = "B. Teen Birth Rate for Women with Parents at 25th Percentile"
	} 
	
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
			  xtitle("Magnitude of Pop-Wtd. Univariate Correlation with" "`varlabel' across Counties", size(small)) ///
			  title("{bf:County-Level Univariate Correlations between Other Outcomes and Measures of Social Capital}" " " "{it:`panel_title'}" " ", size(small) span) ///
			  xlabel(0(0.2)0.8, format(%03.1f) gmax gmin nogrid labsize(small)) ///
			  legend(order(2 "Positive" 3 "Negative") pos(6) ring(1) row(1) size(small)) 
				  
	graph export "${paper1_figs}/`figure_name'.pdf", replace	
	
	
	* Delete correlations tempfile 
	erase "${paper1_figs}/EDFigure3.dta"
}

	

