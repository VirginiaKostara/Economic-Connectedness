********************************************************************************
** This do file replicates Extended Data Table 1: EC, Exposure and Friending Bias: Variation across Areas and Settings
********************************************************************************

clear all 

********************************************************************************
**# 0. Setup 
********************************************************************************

* Define geographic units 
local geo zip

* Define weight: no. of children with parents with below-median household income (this is different from the weight used in the paper for privacy protection)
local weight = "num_below_p50"


* Merge public data to FB dataset 
import delimited "${fb_data}/social_capital_`geo'.csv", clear 
merge 1:1 `geo' using "${public_data}/`geo'_covariates.dta"


* Note: We cannot replicate panel A with public data.


********************************************************************************
**# 1. Panel B: Variation in EC, Exposure, and Bias across ZIP Codes
********************************************************************************

local vars ec_grp_mem_`geo' exposure_grp_mem_`geo' bias_grp_mem_`geo'

foreach var of local vars {
	
	* Standard deviation across ZIP codes
    summarize `var' [aweight = `weight']
	local sd_`var': display %3.2f r(sd)
	
	
	* Share of ZIP-code level variation across counties
    areg `var' [aweight = `weight'], absorb(county)
	local r2_zip_`var': display %3.2f e(r2_a)
}


* Export results
putexcel set "${paper2_tables}/Extended Data_Table_1b.xlsx", replace

putexcel B1 = "EC"
putexcel C1 = "Exposure"
putexcel D1 = "Friending Bias"
putexcel A2 = "Standard Deviation Across ZIP Codes"	
putexcel B2 = `sd_ec_grp_mem_`geo''
putexcel C2 = `sd_exposure_grp_mem_`geo''
putexcel D2 = `sd_bias_grp_mem_`geo''
putexcel A3 = "Share of ZIP-Code-Level Variation Across Counties"
putexcel B3 = `r2_zip_ec_grp_mem_`geo''
putexcel C3 = `r2_zip_exposure_grp_mem_`geo''
putexcel D3 = `r2_zip_bias_grp_mem_`geo''
