********************************************************************************
** This do file replicates Main Table 1: Correlation Matrix for Social Capital Measures across Counties
********************************************************************************

clear all 

********************************************************************************
**# 0. Setup 
********************************************************************************

* Define geographic units 
local geo county

* Define weight: no. of children with parents with below-median household income
local weight = "num_below_p50"


import delimited "${fb_data}/social_capital_`geo'.csv", clear


* List of social capital measures
* Note: only a subset of measures is available with public data: economic connectedness, clustering, support ratio, civic organizations, and volunteering rate
local vars "ec_`geo' clustering_`geo' support_ratio_`geo' civic_organizations_`geo' volunteering_rate_`geo'"


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
export delimited "${paper1_tables}/Main_Table_1.csv", replace
