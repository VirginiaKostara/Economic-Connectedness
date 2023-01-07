********************************************************************************
** This do file replicates Supplementary Figure 10:  Race-Specific Upward Mobility, Economic Connectedness, and Share of Black Residents across ZIP Codes
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


* Rescale upward mobility to range from 0 to 100
replace kfr_white_pooled_p25 = kfr_white_pooled_p25 * 100
replace kfr_black_pooled_p25 = kfr_black_pooled_p25 * 100

* Rescale share black to range from 0 to 100
replace share_black2000 = share_black2000 * 100


* Drop if EC is missing to ensure comparability of samples across control/no control. 
drop if missing(ec_`geo')
		

********************************************************************************
**# 1. Panel A: Upward Mobility for White Individuals vs. Black Share, by ZIP Code
********************************************************************************

local race = "white"

* Define weight: no. of children with parents with below-median household income (race-specific)
local weight = "kid_`race'_pooled_blw_p50_n"


binscatter kfr_`race'_pooled_p25 share_black2000 [aweight = `weight'], ///
		   ylabel(40(2)48, format(%2.0f) nogrid labsize(small)) linetype(qfit) ///
		   xlabel(-10(10)50, format(%2.0f) labsize(small)) /// 
		   ytitle("Upward Mobility", size(small)) xtitle("Black Share (%)", size(small)) lcolor(eltblue) mcolor(eltblue) ///
		   title("{bf:Race-Specific Upward Mobility, Economic Connectedness, and Share of Black Residents across ZIP Codes}" " " "{it:A. Upward Mobility for White Individuals vs. Black Share, by ZIP Code}" " ", size(small) span) ///
		   savegraph("${paper1_figs}/Supplementary_Figure_10a.pdf") replace


********************************************************************************
**# 2. Panel B: Upward Mobility for White Individuals vs. Black Share Controlling for EC, by ZIP Code
********************************************************************************

local race = "white"

* Define weight: no. of children with parents with below-median household income (race-specific)
local weight = "kid_`race'_pooled_blw_p50_n"


binscatter kfr_`race'_pooled_p25 share_black2000 [aweight = `weight'], controls(ec_`geo') ///
		   ylabel(40(2)48, format(%2.0f) nogrid labsize(small)) linetype(qfit) ///
		   xlabel(-10(10)50, format(%2.0f) labsize(small)) /// 
		   ytitle("Upward Mobility", size(small)) xtitle("Black Share (%)", size(small)) lcolor(eltblue) mcolor(eltblue) ///
		   title("{bf:Race-Specific Upward Mobility, Economic Connectedness, and Share of Black Residents across ZIP Codes}" " " "{it:B. Upward Mobility for White Individuals vs. Black Share Controlling for EC, by ZIP Code}" " ", size(small) span) ///
		   savegraph("${paper1_figs}/Supplementary_Figure_10b.pdf") replace		   
		   
		   
********************************************************************************
**# 3. Panel C: Upward Mobility for Black Individuals vs. Black Share, by ZIP Code
********************************************************************************

local race = "black"

* Define weight: no. of children with parents with below-median household income (race-specific)
local weight = "kid_`race'_pooled_blw_p50_n"


binscatter kfr_`race'_pooled_p25 share_black2000 [aweight = `weight'], ///
		   ylabel(30(1)35, format(%2.0f) nogrid labsize(small)) linetype(qfit) ///
		   xlabel(0(20)100, format(%2.0f) labsize(small)) /// 
		   ytitle("Upward Mobility", size(small)) xtitle("Black Share (%)", size(small)) lcolor(eltblue) mcolor(eltblue) ///
		   title("{bf:Race-Specific Upward Mobility, Economic Connectedness, and Share of Black Residents across ZIP Codes}" " " "{it:C. Upward Mobility for Black Individuals vs. Black Share, by ZIP Code}" " ", size(small) span) ///
		   savegraph("${paper1_figs}/Supplementary_Figure_10c.pdf") replace


********************************************************************************
**# 4. Panel D: Upward Mobility for Black Individuals vs. Black Share Controlling for EC, by ZIP Code
********************************************************************************

local race = "black"

* Define weight: no. of children with parents with below-median household income (race-specific)
local weight = "kid_`race'_pooled_blw_p50_n"


binscatter kfr_`race'_pooled_p25 share_black2000 [aweight = `weight'], controls(ec_`geo') ///
		   ylabel(30(1)35, format(%2.0f) nogrid labsize(small)) linetype(qfit) ///
		   xlabel(0(20)100, format(%2.0f) labsize(small)) /// 
		   ytitle("Upward Mobility", size(small)) xtitle("Black Share (%)", size(small)) lcolor(eltblue) mcolor(eltblue) ///
		   title("{bf:Race-Specific Upward Mobility, Economic Connectedness, and Share of Black Residents across ZIP Codes}" " " "{it:D. Upward Mobility for Black Individuals vs. Black Share Controlling for EC, by ZIP Code}" " ", size(small) span) ///
		   savegraph("${paper1_figs}/Supplementary_Figure_10d.pdf") replace
