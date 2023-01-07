********************************************************************************
** This do file replicates Supplementary Figure 9:  Upward Mobility, Economic Connectedness, and Measures of Inequality and Segregation across Counties
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


* Rescale upward mobility to range from 0 to 100
replace kfr_pooled_pooled_p25 = kfr_pooled_pooled_p25 * 100
	
* Drop if EC is missing to ensure comparability of samples across control/no control. 
drop if missing(ec_`geo')
	

********************************************************************************
**# 1. Panel A: Upward Mobility vs. Income Segregation, by County 
********************************************************************************

binscatter kfr_pooled_pooled_p25 income_segregation [aweight = `weight'], ///
		   ylabel(38(1)43, format(%02.0f) nogrid labsize(small)) ///
		   xlabel(0(0.05)0.2, format(%03.2f) labsize(small)) /// 
		   ytitle("Upward Mobility", size(small)) xtitle("Income Segregation", size(small)) lcolor(eltblue) mcolor(eltblue) ///
		   title("{bf:Upward Mobility, Economic Connectedness, and Measures of Inequality and Segregation across Counties}" " " "{it:A. Upward Mobility vs. Income Segregation, by County}" " ", size(small) span) ///
		   savegraph("${paper1_figs}/Supplementary_Figure_9a.pdf") replace

		   
********************************************************************************
**# 2. Panel B: Upward Mobility vs. Income Segregation Controlling for EC, by County
********************************************************************************

binscatter kfr_pooled_pooled_p25 income_segregation [aweight = `weight'], controls(ec_`geo') ///
		   ylabel(38(1)43, format(%02.0f) nogrid labsize(small)) ///
		   xlabel(0(0.05)0.2, format(%03.2f) labsize(small)) /// 
		   ytitle("Upward Mobility", size(small)) xtitle("Income Segregation", size(small)) lcolor(eltblue) mcolor(eltblue) ///
		   title("{bf:Upward Mobility, Economic Connectedness, and Measures of Inequality and Segregation across Counties}" " " "{it:B. Upward Mobility vs. Income Segregation Controlling for EC, by County}" " ", size(small) span) ///
		   savegraph("${paper1_figs}/Supplementary_Figure_9b.pdf") replace

		   
********************************************************************************
**# 3. Panel C: Upward Mobility vs. Racial Segregation, by County
********************************************************************************
		   
binscatter kfr_pooled_pooled_p25 racial_segregation [aweight = `weight'], ///
		   ylabel(37(2)43, format(%02.0f) nogrid labsize(small)) ///
		   xlabel(0(0.1)0.4, format(%02.1f) labsize(small)) /// 
		   ytitle("Upward Mobility", size(small)) xtitle("Racial Segregation", size(small)) lcolor(eltblue) mcolor(eltblue) ///
		   title("{bf:Upward Mobility, Economic Connectedness, and Measures of Inequality and Segregation across Counties}" " " "{it:C. Upward Mobility vs. Racial Segregation, by County}" " ", size(small) span) ///
		   savegraph("${paper1_figs}/Supplementary_Figure_9c.pdf") replace

		   
********************************************************************************
**# 4. Panel D: Upward Mobility vs. Racial Segregation Controlling for EC, by County
********************************************************************************

binscatter kfr_pooled_pooled_p25 racial_segregation [aweight = `weight'], controls(ec_`geo') ///
		   ylabel(37(2)43, format(%02.0f) nogrid labsize(small)) ///
		   xlabel(0(0.1)0.4, format(%02.1f) labsize(small)) /// 
		   ytitle("Upward Mobility", size(small)) xtitle("Racial Segregation", size(small)) lcolor(eltblue) mcolor(eltblue) ///
		   title("{bf:Upward Mobility, Economic Connectedness, and Measures of Inequality and Segregation across Counties}" " " "{it:D. Upward Mobility vs. Racial Segregation Controlling for EC, by County}" " ", size(small) span) ///
		   savegraph("${paper1_figs}/Supplementary_Figure_9d.pdf") replace
		   
********************************************************************************
**# 5. Panel E: Upward Mobility vs. Gini Coefficient, by County
********************************************************************************
		   
binscatter kfr_pooled_pooled_p25 gini99_simple [aweight = `weight'], ///
		   ylabel(36(2)48, format(%02.0f) nogrid labsize(small)) ///
		   xlabel(0.2(0.1)0.5, format(%02.1f) labsize(small)) /// 
		   ytitle("Upward Mobility", size(small)) xtitle("Income Gini Excluding Top 1%", size(small)) lcolor(eltblue) mcolor(eltblue) ///
		   title("{bf:Upward Mobility, Economic Connectedness, and Measures of Inequality and Segregation across Counties}" " " "{it:E. Upward Mobility vs. Gini Coefficient, by County}" " ", size(small) span) ///
		   savegraph("${paper1_figs}/Supplementary_Figure_9e.pdf") replace


********************************************************************************
**# 6. Panel F: Upward Mobility vs. Gini Coefficient Controlling for EC, by County
********************************************************************************
		   
binscatter kfr_pooled_pooled_p25 gini99_simple [aweight = `weight'], controls(ec_`geo') ///
		   ylabel(36(2)48, format(%02.0f) nogrid labsize(small)) ///
		   xlabel(0.2(0.1)0.5, format(%02.1f) labsize(small)) /// 
		   ytitle("Upward Mobility", size(small)) xtitle("Income Gini Excluding Top 1%", size(small)) lcolor(eltblue) mcolor(eltblue) ///
		   title("{bf:Upward Mobility, Economic Connectedness, and Measures of Inequality and Segregation across Counties}" " " "{it:F. Upward Mobility vs. Gini Coefficient Controlling for EC, by County}" " ", size(small) span) ///
		   savegraph("${paper1_figs}/Supplementary_Figure_9f.pdf") replace

		   