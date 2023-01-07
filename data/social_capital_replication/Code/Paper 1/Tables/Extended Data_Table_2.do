**********************************************************************************
** This do file replicates Extended Data Table 2: Correlations between Social Capital Measures and Upward Income Mobility
********************************************************************************

clear all 


* Define weight: no. of children with parents with below-median household income
local weight = "num_below_p50"


********************************************************************************
**# 1. Compute correlations 
********************************************************************************

* Define geographic units 
local key_geos = "county zip"


foreach geo of local key_geos {


	* Merge public data to FB dataset 
	import delimited "${fb_data}/social_capital_`geo'.csv", clear 
	merge 1:1 `geo' using "${public_data}/`geo'_covariates.dta"


	* Define dependent variable: upward income mobility
	local depvar kfr_pooled_pooled_p25

	
	if "`geo'" == "county" {
		
		* List of social capital measures
		* Note: only a subset of measures is available with public data: economic connectedness, childhood economic connectedness, clustering, support ratio, volunteering rate, and civic organizations
		local univariate_covs_reduced ec_`geo' child_ec_`geo' clustering_`geo' support_ratio_`geo' volunteering_rate_`geo' civic_organizations_`geo'

		* Define variable to cluster on 
		local cluster_var = "cz"
	}
	
	else if "`geo'" == "zip" {
		
		* List of social capital measures
		* Note: only a subset of measures is available with public data: economic connectedness, clustering, support ratio, volunteering rate, and civic organizations
		local univariate_covs_reduced ec_`geo' clustering_`geo' support_ratio_`geo' volunteering_rate_`geo' civic_organizations_`geo'

		* Define variable to cluster on 
		local cluster_var = "county"
	}
	
	
	* Prepare temporary files to save correlations
	postutil clear
	tempname EDTable2_`geo'
	postfile `EDTable2_`geo'' str32 variable float `geo'Corr float `geo'SE using "${paper1_tables}/EDTable2_`geo'.dta", replace
	
	
	foreach var of local univariate_covs_reduced {

		local varname "`var'"

		preserve 
			
		* Drop if missing outcome, social capital measure, weight, or cluster variable 
		keep if !missing(`depvar', `var', `weight', `cluster_var')
			
		* Standardize outcome and social capital measure 
		center `depvar' `var' [aweight = `weight'], inplace standardize		
			
		* Compute correlations
		reg `depvar' `var' [aweight = `weight'], vce(cluster `cluster_var')
		post `EDTable2_`geo'' ("`varname'") (`= _b[`var']') (`= _se[`var']')
			
		restore
	}
	
	postclose `EDTable2_`geo''
}	


********************************************************************************
**# 2. Export table 
********************************************************************************										  
	
use "${paper1_tables}/EDTable2_county.dta", replace

gen id = _n
merge 1:1 variable using "${paper1_tables}/EDTable2_zip.dta"
sort id 
drop id
drop _merge


* Round numbers to two decimal places 
foreach var in countyCorr countySE zipCorr zipSE {
	replace `var' = round(float(`var'), 0.01)
}

export delimited "${paper1_tables}/Extended Data_Table_2.csv", replace


* Delete tempfiles 
erase "${paper1_tables}/EDTable2_county.dta"
erase "${paper1_tables}/EDTable2_zip.dta"
