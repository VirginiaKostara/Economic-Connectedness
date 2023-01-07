********************************************************************************
** This do file replicates Supplementary Table 3: Correlations Between Economic Connectedness and Racial Shares across Counties
********************************************************************************

clear all 

********************************************************************************
**# 0. Setup 
********************************************************************************

* Define geographic units 
local geo county

* Define weight: no. of children with parents with below-median household income
local weight = "num_below_p50"


* Merge public data to FB dataset 
import delimited "${fb_data}/social_capital_`geo'.csv", clear 
merge 1:1 `geo' using "${public_data}/`geo'_covariates.dta"


* List of covariates: economic connectedness + race shares
local vars "ec_`geo' share_white2000 share_black2000 share_hisp2000 share_asian2000"


********************************************************************************
**# 1. Compute correlations between social capital measures 
********************************************************************************

* Compute correlation between social capital measures
pwcorr `vars' [aweight = `weight']


* Represent correlation matrix as dataset
clear 
svmat r(C), names(col)


* Round numbers to two decimal places 
foreach var of local vars {
	replace `var' = round(float(`var'), 0.01)
}


* Row names for variables
gen vars = ""

local i = 1
foreach var of local vars {
	replace vars = "`var'" if _n == `i'
	local i =`i' + 1
}


* Export table 
order vars, first
export delimited "${paper1_tables}/Supplementary_Table_3.csv", replace
