********************************************************************************
** This do file replicates Supplementary Figure 8: Upward Mobility, Economic Connectedness, and Income Levels across ZIP Codes
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


* Rescale upward mobility and poverty rate to range from 0 to 100
replace kfr_pooled_pooled_p25 = kfr_pooled_pooled_p25 * 100
replace poor_share2000 = poor_share2000 * 100
	
* Drop if EC is missing to ensure comparability of samples across control/no control. 
drop if missing(ec_`geo')
	

********************************************************************************
**# 1. Panel A: Upward Mobility vs. Median Income, by ZIP Code 
********************************************************************************

binscatter kfr_pooled_pooled_p25 med_hhinc2000 [aweight = `weight'], ///
		   ylabel(35(5)50, format(%02.0f) nogrid labsize(small)) yscale(range(34 50)) ///
		   xlabel(20000(20000)80000, angle(45) labsize(small)) xscale(range(20000 80000)) /// 
		   ytitle("Upward Mobility", size(small)) xtitle("Median Household Income (US$)", size(small)) lcolor(eltblue) mcolor(eltblue) ///
		   title("{bf:Upward Mobility, Economic Connectedness, and Income Levels across ZIP Codes}" " " "{it:A. Upward Mobility vs. Median Income, by ZIP Code}" " ", size(small) span) ///
		   savegraph("${paper1_figs}/Supplementary_Figure_8a.pdf") replace

		   
********************************************************************************
**# 2. Panel B: Upward Mobility vs. Median Income Controlling for EC, by ZIP Code
********************************************************************************

binscatter kfr_pooled_pooled_p25 med_hhinc2000 [aweight = `weight'], controls(ec_`geo') ///
		   ylabel(35(5)50, format(%02.0f) nogrid labsize(small)) yscale(range(34 50)) ///
		   xlabel(20000(20000)80000, angle(45) labsize(small)) xscale(range(20000 80000)) /// 
		   ytitle("Upward Mobility", size(small)) xtitle("Median Household Income (US$)", size(small)) lcolor(eltblue) mcolor(eltblue) ///
		   title("{bf:Upward Mobility, Economic Connectedness, and Income Levels across ZIP Codes}" " " "{it:B. Upward Mobility vs. Median Income Controlling for EC, by ZIP Code}" " ", size(small) span) ///
		   savegraph("${paper1_figs}/Supplementary_Figure_8b.pdf") replace


********************************************************************************
**# 3. Panel C: Upward Mobility vs. Poverty Rate, by ZIP Code 
********************************************************************************

binscatter kfr_pooled_pooled_p25 poor_share2000 [aweight = `weight'], ///
		   ylabel(30(5)50, format(%02.0f) nogrid labsize(small)) yscale(range(30 50)) ///
		   xlabel(0(10)40, labsize(small)) xscale(range(0 43)) /// 
		   ytitle("Upward Mobility", size(small)) xtitle("Poverty Rate (%)", size(small)) lcolor(eltblue) mcolor(eltblue) ///
		   title("{bf:Upward Mobility, Economic Connectedness, and Income Levels across ZIP Codes}" " " "{it:C. Upward Mobility vs. Poverty Rate, by ZIP Code}" " ", size(small) span) ///
		   savegraph("${paper1_figs}/Supplementary_Figure_8c.pdf") replace

		   
********************************************************************************
**# 4. Panel D: Upward Mobility vs. Poverty Rate Controlling for EC, by ZIP Code
********************************************************************************

binscatter kfr_pooled_pooled_p25 poor_share2000 [aweight = `weight'], controls(ec_`geo') ///
		   ylabel(30(5)50, format(%02.0f) nogrid labsize(small)) yscale(range(30 50)) ///
		   xlabel(0(10)40, labsize(small)) xscale(range(0 43)) /// 
		   ytitle("Upward Mobility", size(small)) xtitle("Poverty Rate (%)", size(small)) lcolor(eltblue) mcolor(eltblue) ///
		   title("{bf:Upward Mobility, Economic Connectedness, and Income Levels across ZIP Codes}" " " "{it:D. Upward Mobility vs. Poverty Rate Controlling for EC, by ZIP Code}" " ", size(small) span) ///
		   savegraph("${paper1_figs}/Supplementary_Figure_8d.pdf") replace
		   
		   