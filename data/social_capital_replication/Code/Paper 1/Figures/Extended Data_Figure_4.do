**********************************************************************************
** This do file replicates Extended Data Figure 4:  Heterogeneity in Relationships between Upward Income Mobility and Social Capital Measures across Counties
********************************************************************************

clear all 

********************************************************************************
**# 1. Panels A, B, C:  Relationship between Upward Mobility, Clustering Coefficient, and Economic Mobility by Zip Code in Selected Counties
********************************************************************************

*==============================================================================*
**## 1.1. Setup
*==============================================================================*

* Define geographic unit 
local geo zip

* Define weight: no. of children with parents with below-median household income
local weight = "num_below_p50"


import delimited "${fb_data}/social_capital_`geo'.csv", clear 
merge 1:1 `geo' using "${public_data}/`geo'_covariates.dta"

	
* Select counties of interest
drop if !(county == 39153 | county == 39035 | county == 39049 | county == 39099) 
		  
gen county_name = "Akron" if county == 39153
replace county_name = "Cleveland" if county == 39035
replace county_name = "Columbus" if county == 39049
replace county_name = "Youngstown" if county == 39099


* Rescale outcome variable such that predicted income rank ranges from 0 to 100
replace kfr_pooled_pooled_p25 = kfr_pooled_pooled_p25 * 100
	
	
* Define bins for clustering (social capital measure) and rescale this measure so it ranges from 0 to 100
egen clustering_bins = xtile(clustering_`geo'), by(county_name) nquantiles(10)
replace clustering_`geo' = clustering_`geo' * 100

* Define bins for economic connectedness
egen ec_bins = xtile(ec_`geo'), by(county_name) nquantiles(10)

	
*==============================================================================*
**## 1.2. Panel A: Relationship between Upward Mobility and Clustering Coefficient by ZIP Code in Selected Counties
*==============================================================================*

binscatter kfr_pooled_pooled_p25 clustering_`geo' [aweight = `weight'], by(county_name) ///
		   msymbols(o d s t) mcolor(red sand eltblue navy) lcolor(red sand eltblue navy) /// 
		   xtitle("Clustering Coefficient (%)", size(small)) ytitle("Upward Mobility", size(small)) ///
		   legend(order(1 "Akron (Summit County)" 2 "Cleveland (Cuyahoga County)" 3 "Columbus (Franklin County)" 4 "Youngstown (Mahoning County)") col(1) pos(11) ring(0) size(small)) ///
		   title("{bf:Heterogeneity in Relationships between Upward Income Mobility and Social Capital Measures across Counties}" " " "{it:A. Upward Mobility vs. Clustering}" " ", size(small) span) ///
		   xq(clustering_bins) xlabel(, format(%03.1f) labsize(small)) ylabel(, nogrid labsize(small)) xscale(range(7 12.1)) graphregion(color(white))
	

graph export "${paper1_figs}/Extended Data_Figure_4a.pdf", replace


*==============================================================================*
**## 1.3. Panel B: Relationship between Upward Mobility and Economic Connectedness by ZIP Code in Selected Counties
*==============================================================================*

binscatter kfr_pooled_pooled_p25 ec_`geo' [aweight = `weight'], by(county_name) ///
		   msymbols(o d s t) mcolor(red sand eltblue navy) lcolor(red sand eltblue navy) /// 
		   xtitle("Economic Connectedness", size(small)) ytitle("Upward Mobility", size(small)) ///
		   legend(order(1 "Akron (Summit County)" 2 "Cleveland (Cuyahoga County)" 3 "Columbus (Franklin County)" 4 "Youngstown (Mahoning County)") col(1) pos(11) ring(0) size(small)) ///
		   title("{bf:Heterogeneity in Relationships between Upward Income Mobility and Social Capital Measures across Counties}" " " "{it:B. Upward Mobility vs. EC}" " ", size(small) span) ///
		   xq(ec_bins) xlabel(, format(%03.1f) labsize(small)) ylabel(30(5)55, nogrid labsize(small)) yscale(range(30 55)) graphregion(color(white))


graph export "${paper1_figs}/Extended Data_Figure_4b.pdf", replace


*==============================================================================*
**## 1.4. Panel C: Relationship between Economic Connectedness and Clustering Coefficient by ZIP Code in Selected Counties
*==============================================================================*

binscatter ec_`geo' clustering_`geo' [aweight = `weight'], by(county_name) ///
		   msymbols(o d s t) mcolor(red sand eltblue navy) lcolor(red sand eltblue navy) /// 
		   xtitle("Clustering Coefficient (%)", size(small)) ytitle("Economic Connectedness", size(small)) ///
		   legend(order(1 "Akron (Summit County)" 2 "Cleveland (Cuyahoga County)" 3 "Columbus (Franklin County)" 4 "Youngstown (Mahoning County)") col(1) pos(11) ring(0) size(small)) ///
		   title("{bf:Heterogeneity in Relationships between Upward Income Mobility and Social Capital Measures across Counties}" " " "{it:C. EC vs. Clustering}" " ", size(small) span) ///
		   xq(clustering_bins) xlabel(, format(%03.1f) labsize(small)) ylabel(, nogrid format(%3.1f) labsize(small)) xscale(range(7 12.1)) graphregion(color(white))
		

graph export "${paper1_figs}/Extended Data_Figure_4c.pdf", replace 


********************************************************************************
**# 2. Panel D: Distributions of ZIP Code-Level Correlations between Upward Mobility and Social Capital Measures across Counties
********************************************************************************

*==============================================================================*
**## 2.1. Calculate correlations by county 
*==============================================================================*

import delimited "${fb_data}/social_capital_`geo'.csv", clear 
merge 1:1 `geo' using "${public_data}/`geo'_covariates.dta"


* Drop ZIP-level population so we don't confuse it with county-level population 
drop pop2018

* Keep the 250 most populous counties 
merge m:1 county using "${public_data}/county_covariates.dta", nogen keep(match master) keepusing(pop2018) 
drop if missing(pop2018)
gen minus_pop2018 = -pop2018
egen pop_rank = group(minus_pop2018 county)
keep if pop_rank <= 250


** Prepare dataset storing correlations between kfr and soc cap measures by county

* Covariates
local soc_cap_measures = "ec_`geo' clustering_`geo' support_ratio_`geo' volunteering_rate_`geo'"

* Going to loop over each county and store correlation coefficient
drop if missing(county)
levelsof county, local(counties)
	
* Loop over each measure of social capital
foreach var of local soc_cap_measures {
	
	* Create variable to store correlation between kfr and that measure by county
	gen corr_`var' = .
	
	* Loop over counties
	foreach county of local counties {
		
		preserve 
		
		* Keep one county at a time
		keep if county == `county'
		
		* Drop missing obs
		keep if !missing(kfr_pooled_pooled_p25, `var', `weight')
		
		* Standardize variables
		capture center kfr_pooled_pooled_p25 `var' [aweight = `weight'], inplace standardize	

		* Regress kfr on measure of social capital of interest
		capture reg kfr_pooled_pooled_p25 `var' [aweight = `weight']
		
		if _rc == 0 { 
			
			* Store the correlation coefficient
			local coeff = _b[`var']
			restore
			replace corr_`var' = `coeff' if county == `county'
		} 
		
		else restore	
	}
}


* Collapse the correlation coefficients by county	
collapse (mean) corr_*, by(county)


*==============================================================================*
**## 2.2. Plot graph
*==============================================================================*

* Merge in county-level weights 
merge 1:1 county using "${public_data}/county_covariates.dta", nogen keep(match master) keepusing(`weight') 


* Prepare variables for reshaping
rename corr_support_ratio_`geo' correlation1
rename corr_clustering_`geo' correlation2
rename corr_volunteering_rate_`geo' correlation3
rename corr_ec_`geo' correlation4

gen `weight'1 = `weight'
gen `weight'2 = `weight'
gen `weight'3 = `weight'
gen `weight'4 = `weight'

keep county correlation1 correlation2 correlation3 correlation4 `weight'1 `weight'2 `weight'3 `weight'4
reshape long correlation `weight', i(county) j(var)

gen variable = "support_ratio_`geo'" if var == 1
replace variable = "clustering_`geo'" if var == 2
replace variable = "volunteering_rate_`geo'" if var == 3
replace variable = "ec_`geo'" if var == 4
drop var


* Density plots for each social capital measure
kdensity correlation, nograph gen(x fx)
local binwidth = 0.25

kdensity correlation [aweight = `weight'] if variable == "support_ratio_`geo'", nograph gen(fx_support_ratio) at(x) kernel(gaussian) bwidth(`binwidth')
kdensity correlation [aweight = `weight'] if variable == "clustering_`geo'", nograph gen(fx_clustering) at(x) kernel(gaussian) bwidth(`binwidth')
kdensity correlation [aweight = `weight'] if variable == "volunteering_rate_`geo'", nograph gen(fx_volunteering_rate) at(x) kernel(gaussian) bwidth(`binwidth')
kdensity correlation [aweight = `weight'] if variable == "ec_`geo'", nograph gen(fx_ec) at(x) kernel(gaussian) bwidth(`binwidth')
  
label var fx_support_ratio "Support Ratio"
label var fx_clustering "Clustering"
label var fx_volunteering_rate "Volunteering Rate"
label var fx_ec "Economic Connectedness"


* Combine density plots
line fx_ec fx_support_ratio fx_clustering fx_volunteering_rate x if inrange(x, -1, 1), sort ///
     ytitle("Density", size(small)) xtitle("County-Level Weighted Correlation Coefficient across ZIP Codes", size(small)) /// 
	 lcolor(red sand eltblue navy) ///
	 lpattern(solid dash longdash dash_dot) ///
     ylab("", labsize(small)) xlab(, format(%03.1f) labsize(small)) ///
	 title("{bf:Heterogeneity in Relationships between Upward Income Mobility and Social Capital Measures across Counties}" " " "{it:D. Distribution of ZIP-Level Relationships, by County}" " ", size(small) span) ///
	 legend(order(2 "Support Ratio" 3 "Clustering" 1 "Economic Connectedness" 4 "Volunteering Rate") rows(3) size(small)) graphregion(color(white))


graph export "${paper1_figs}/Extended Data_Figure_4d.pdf", replace

