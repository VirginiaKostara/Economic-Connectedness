********************************************************************************
** This do file replicates Main Figure 4: Association between Upward Income Mobility and Economic Connectedness across Counties
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

* Drop if missing outcome, treatment variable, or weight 
keep if !missing(kfr_pooled_pooled_p25, ec_`geo', `weight')

* Set SE clustering level 
local cluster_var = "cz"


* Rescale outcome variable such that predicted income rank ranges from 0 to 100
replace kfr_pooled_pooled_p25 = kfr_pooled_pooled_p25 * 100


********************************************************************************
**# 1. Plot graph 
********************************************************************************

*==============================================================================*
**## 1.1. Regression slope (200 largest counties)
*==============================================================================*

preserve 

* Keep 200 largest counties
gsort -pop2000
keep if _n <= 200

reg kfr_pooled_pooled_p25 ec_`geo' [aweight = `weight'], vce(cluster `cluster_var')

* Scalars for plotting regression line 
local alpha = _b[_cons]
local beta = _b[ec_`geo']

* Scalars to be displayed
local slope: display %4.1f _b[ec_`geo']
local se: display %3.1f _se[ec_`geo']

restore


*==============================================================================*
**## 1.2. Correlation (200 largest counties)
*==============================================================================*

preserve 

* Keep 200 largest counties
gsort -pop2000
keep if _n <= 200

* Standardize outcome and treatment variables
center kfr_pooled_pooled_p25 ec_`geo' [aweight = `weight'], inplace standardize

		
reg kfr_pooled_pooled_p25 ec_`geo' [aweight = `weight'], vce(cluster `cluster_var')

local corr_top: display %4.2f _b[ec_`geo']
local se_top: display %4.2f _se[ec_`geo']


restore 


*==============================================================================*
**## 1.3. Correlation (All counties)
*==============================================================================*

preserve 


* Standardize outcome and treatment variables
center kfr_pooled_pooled_p25 ec_`geo' [aweight = `weight'], inplace standardize
	
reg kfr_pooled_pooled_p25 ec_`geo' [aweight = `weight'], vce(cluster `cluster_var')

local corr_all: display %4.2f _b[ec_`geo']
local se_all: display %4.2f _se[ec_`geo']
	
	
restore 


*==============================================================================*
**## 1.4. Plot graph 
*==============================================================================*

* Keep 200 largest counties
gsort -pop2000
keep if _n <= 200


* Emphasize selected counties
generate highlight = (county == 06075) /// San Francisco: San Francisco County CA
				   + (county == 18097) /// Indianapolis: Marion County IN
			       + (county == 49035) /// Salt Lake City: Salt Lake County UT
				   + (county == 36061) ///  New York City: New York County NY
				   + (county == 27053) //  Minneapolis: Hennepin County
		
		
* Scatterplot
twoway (scatter kfr_pooled_pooled_p25 ec_`geo' if !highlight, msize(vsmall) mcolor(gs10)) ///
	   (function y = `alpha' + `beta' * x, range(0.4 1.29) lcolor(gs8))  ///
	   (scatter kfr_pooled_pooled_p25 ec_`geo' if highlight, msize(small)  mcolor("31 143 141")) ///
		, ytitle("Predicted Household Income Rank for" "Children with Parents at 25th Income Percentile", size(small))  ///
		  xtitle("Economic Connectedness", size(small)) ///
		  title("{bf:Association between Upward Income Mobility and Economic Connectedness across Counties}" " ", size(small) span) ///
		  legend(off) ylabel(30(5)55, nogrid labsize(small)) xlabel(0.4(0.2)1.2, format(%03.1f) labsize(small)) ///
		  text(33 0.9  "Correlation (All Counties) = `corr_all' (`se_all')", placement(ne) justification(left) color(gs5) size(small)) ///
		  text(31.5 0.9  "Correlation (200 Largest Counties) = `corr_top' (`se_top')", placement(ne) justification(left) color(gs5) size(small)) ///
		  text(30 0.9  "Slope (200 Largest Counties) = `slope' (`se')", placement(ne) justification(left) color(gs5) size(small)) ///
		  text(51 1.29  "San Francisco", placement(nw) justification(left) color("31 143 141") size(small)) ///
		  text(34.2 0.54  "Indianapolis", placement(se) justification(left) color("31 143 141") size(small)) ///
		  text(45.7 1.0  "Salt Lake City", placement(nw) justification(left) color("31 143 141") size(small)) ///
		  text(41.5 0.9 "New York", placement(s) justification(left) color("31 143 141") size(small)) ///
		  text(43 1.04 "Minneapolis", placement(s) justification(left) color("31 143 141") size(small))
		  
graph export "${paper1_figs}/Main_Figure_4.pdf", replace

