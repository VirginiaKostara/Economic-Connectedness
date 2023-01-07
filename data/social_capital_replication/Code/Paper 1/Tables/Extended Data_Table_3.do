********************************************************************************
** This do file replicates Extended Data Table 3: Associations between Race-Specific Upward Income Mobility and Economic Connectedness in Racially Homogeneous Areas
********************************************************************************

clear all

* Define geographic units 
local key_geos = "county zip"

* Define races 
* Note: we cannot estimate correlations for hispanic counties/zctas with the public data
local races = "white black"

* Define race share thresholds 
local race_share_thresholds = "80 90"

* Define weight: no. of children with parents with below-median household income
local weight = "num_below_p50"


postutil clear
tempname EDTable3
postfile `EDTable3' str32 variable float Corr float SE float N float mean_race_shares using "${paper1_tables}/EDTable3.dta", replace


******************************************************************
**# 1. Correlation between race-specific upward income mobility and economic connectedness at the county and ZIP code geo 
******************************************************************

* Loop over race groups 
foreach race of local races {
	
	* Loop over county and zcta geo 
	foreach geo of local key_geos {
		
		* Loop over race share thresholds  
		foreach threshold of local race_share_thresholds {
			
			* There are too few predominantly black counties to do analysis at the county level
			if ("`race'" == "black") & "`geo'" == "county" continue
			
			* Set SE clustering level 
			if "`geo'" == "county" local cluster_var = "cz"
			else if "`geo'" == "zip" local cluster_var = "county"
	
		
			* Merge economic connectedness variable from FB dataset to public data
			import delimited "${fb_data}/social_capital_`geo'.csv", clear 
			keep `geo' ec_`geo'
			merge 1:1 `geo' using "${public_data}/`geo'_covariates.dta"
		
			* Only keep counties/zctas above a certain threshold of white or black share
			replace share_`race'2000 = 100 * share_`race'2000
			keep if share_`race'2000 > `threshold'
		
			* Get the mean race share in the sample 
			summarize share_`race'2000 [aweight = `weight']
			local mean_share_`race' = r(mean)

			* Standardize variables to have mean 0 and std dev 1
			keep if !missing(kfr_`race'_pooled_p25, ec_`geo', `weight', `cluster_var')
			center kfr_`race'_pooled_p25 ec_`geo' [aweight = `weight'], inplace standardize 
		
			* Regress standardized upward mobility on standardized EC 
			reg kfr_`race'_pooled_p25 ec_`geo' [aweight = `weight'], vce(cluster `cluster_var')
		
			* Store correlation, SE and number of obs 
			local corr = _b[ec_`geo']
			local se = _se[ec_`geo']
			local num_obs = e(N)
		
			post `EDTable3' ("kfr `race' `geo' (>`threshold'%)") (`corr') (`se') (`num_obs') (`mean_share_`race'')
		}	
	}
}


postclose `EDTable3'	


********************************************************************************
**# 2. Export table 
********************************************************************************		

use "${paper1_tables}/EDTable3.dta", clear 


* Round correlation and SE to two decimal places 
foreach var in Corr SE {
	replace `var' = round(float(`var'), 0.01)
}

* Round mean race shares to nearest integer 
foreach var in mean_race_shares {
	replace `var' = round(float(`var'), 1)
}


export delimited "${paper1_tables}/Extended Data_Table_3.csv", replace


* Delete tempfiles 
erase "${paper1_tables}/EDTable3.dta"

