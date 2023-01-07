********************************************************************************
** This do file replicates Supplementary Figure 11:  Correlations between Social Capital and Life Expectancy
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
merge 1:1 `geo' using "${public_data}/chetty_2016_JAMA_table_11.dta", keep(match) nogen


* List of social capital measures
* Note: only a subset of measures is available with public data: economic connectedness, clustering, support ratio, civic organizations, and volunteering rate
local vars "ec_`geo' clustering_`geo' support_ratio_`geo' civic_organizations_`geo' volunteering_rate_`geo'"

* Rescale clustering and support ratio to range from 0 to 100
replace clustering_`geo' = clustering_`geo' * 100
replace support_ratio_`geo' = support_ratio_`geo' * 100


* Define weight: no. of bottom-income-quartile men
local weight count_q1_M

* Set SE clustering level 
local cluster_var = "cz"


tempfile merged_data
save `merged_data'


********************************************************************************
**# 1. Panel A: Correlations of Social Capital with Life Expectancy at Age 40 for Bottom-Income-Quartile Men Across Counties
********************************************************************************

use `merged_data', clear
postutil clear

tempname SuppFigure11
postfile `SuppFigure11' str25 variable corr se using "${paper1_figs}/SuppFigure11.dta", replace
foreach var of local vars {

	preserve 
	
	keep if !missing(le_agg_q1_M, `var', `weight', `cluster_var')
	
	* Standardize outcome and social capital measures
	center le_agg_q1_M `var' [aweight = `weight'], inplace standardize		
	
	* Univariate correlations
	reg le_agg_q1_M `var' [aweight = `weight'], vce(cluster `cluster_var')
	post `SuppFigure11' ("`var'") (`=_b[`var']') (`=_se[`var']')
	
	restore
}


postclose `SuppFigure11'
use "${paper1_figs}/SuppFigure11.dta", clear

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
		   xtitle("Magnitude of Pop-Wtd. Univariate Correlation with" "Life Expectancy for Q1 Males", size(small)) ///
		   title("{bf:Correlations between Social Capital and Life Expectancy}" " " "{it:A. Correlations of Social Capital with Life Expectancy at Age 40 for Bottom-Income-Quartile Men Across Counties}" " ", size(small) span) ///
		   xlabel(0(0.2)0.8, format(%03.1f) gmax gmin nogrid labsize(small)) ///
		   legend(order(2 "Positive" 3 "Negative") pos(6) ring(1) row(1) size(small)) 
				
graph export "${paper1_figs}/Supplementary_Figure_11a.pdf", replace	


* Delete correlations tempfile 
erase "${paper1_figs}/SuppFigure11.dta"


********************************************************************************
**# 2. Panel B: Life Expectancy for Bottom-Income-Quartile Men vs. Clustering Coefficient, by County
********************************************************************************

use `merged_data', clear
postutil clear


binscatter le_agg_q1_M clustering_`geo' [aweight = `weight'], ///
		   ylabel(74(2)80, format(%2.0f) nogrid labsize(small)) linetype(qfit) ///
		   xlabel(, format(%2.1f) labsize(small)) /// 
		   ytitle("Life Expectancy for Q1 Males", size(small)) xtitle("Clustering Coefficient (%)", size(small)) lcolor(eltblue) mcolor(eltblue) ///
		   title("{bf:Correlations between Social Capital and Life Expectancy}" " " "{it:B. Life Expectancy for Bottom-Income-Quartile Men vs. Clustering Coefficient, by County}" " ", size(small) span) ///
		   savegraph("${paper1_figs}/Supplementary_Figure_11b.pdf") replace


********************************************************************************
**# 3. Panel C:  Life Expectancy for Bottom-Income-Quartile Men vs. Support Ratio, by County
********************************************************************************

use `merged_data', clear
postutil clear


binscatter le_agg_q1_M support_ratio_`geo' [aweight = `weight'], ///
		   ylabel(74(2)80, format(%2.0f) nogrid labsize(small)) linetype(qfit) ///
		   xlabel(, format(%2.1f) labsize(small)) /// 
		   ytitle("Life Expectancy for Q1 Males", size(small)) xtitle("Support Ratio (%)", size(small)) lcolor(eltblue) mcolor(eltblue) ///
		   title("{bf:Correlations between Social Capital and Life Expectancy}" " " "{it:C. Life Expectancy for Bottom-Income-Quartile Men vs. Support Ratio, by County}" " ", size(small) span) ///
		   savegraph("${paper1_figs}/Supplementary_Figure_11c.pdf") replace
