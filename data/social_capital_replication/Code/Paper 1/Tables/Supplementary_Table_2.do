**********************************************************************************
** This do file replicates Supplementary Table 2: Heterogeneity in ZIP Code-Level Relationships between Social Capital and Upward Income Mobility across Counties
********************************************************************************

clear all 

********************************************************************************
**# 0. Setup 
********************************************************************************

* Define geographic unit 
local geo zip

import delimited "${fb_data}/social_capital_`geo'.csv", clear 
merge 1:1 `geo' using "${public_data}/`geo'_covariates.dta", nogen


* List of social capital measures; rename for brevity 
rename ec_`geo' ec
rename clustering_`geo' clustering 
rename support_ratio_`geo' support_ratio 
rename volunteering_rate_`geo' volunteering_rate 
local vars "ec clustering support_ratio volunteering_rate"

* Define weight: no. of children with parents with below-median household income
local weight = "num_below_p50"

* Drop ZIP-level population so we don't confuse it with county-level population later 
drop pop2018 


* Keep the 250 most populous counties 
merge m:1 county using "${public_data}/county_covariates.dta", nogen keep(match master) keepusing(pop2018) 
drop if missing(pop2018)
gen minus_pop2018 = -pop2018
egen pop_rank = group(minus_pop2018 county)
keep if pop_rank <= 250

* Drop if missing outcome or weight 
keep if !missing(kfr_pooled_pooled_p25, `weight')


********************************************************************************
**# 1. Estimate correlations
********************************************************************************

* Going to loop over each county and store correlation coefficient
drop if missing(county)
levelsof county, local(counties)


foreach var of local vars {
	
	* Create variable to store correlation between kfr and that measure and the standard error of the correlation, by county
	gen correlation_`var' = .
	gen corr_std_err_`var' = .
	
	* Loop over counties
	foreach county of local counties {
		
		preserve 
		
		* Keep one county at a time
		keep if county == `county'
		
		* Drop missing obs
		keep if !missing(kfr_pooled_pooled_p25, `var', `weight')
		
		* Standardize variables
		capture center kfr_pooled_pooled_p25 `var' [aweight = `weight'], inplace standardize	

		* Regress kfr on measure of social capital of interest with heteroskedastic-robust standard errors
		capture reg kfr_pooled_pooled_p25 `var' [aweight = `weight'], vce(robust)
		
		if _rc == 0 { 
			
			* Store the correlation coefficient and standard error
			local coeff = _b[`var']
			local std_err = _se[`var']
			
			restore
			
			replace correlation_`var' = `coeff' if county == `county'
			replace corr_std_err_`var' = `std_err' if county == `county'
		} 
		
		else restore	
	}
}
	

* Collapse by county	
collapse (mean) correlation_* corr_std_err_*, by(county)
	
	
********************************************************************************
**# 2. Calculate signal-noise ratios 
********************************************************************************

* Merge in county-level weights
merge 1:1 county using "${public_data}/county_covariates.dta", nogen keep(match master) keepusing(`weight') 

* Prepare temporary file to save estimates as dataset 
postutil clear
tempname SuppTable2
postfile `SuppTable2' str32 variable float mean_corr float signal_sd float noise_sd str32 opp_sign using "${paper1_tables}/SuppTable2.dta", replace


foreach var of local vars {

	* Mean correlation
	summarize correlation_`var' [aweight = `weight']
	local mean_corr: display %3.2f r(mean)
	
	
	* Noise SD of correlation 
	gen noise_variance_`var' = corr_std_err_`var' ^ 2
	summarize noise_variance_`var' [aweight = `weight']
	local noise_variance = r(mean)
	local noise_sd: display %3.2f sqrt(`noise_variance')

	
	* Signal SD of correlation 
	summarize correlation_`var' [aweight = `weight']
	local total_variance = r(sd) ^ 2 
	local signal_variance = `total_variance' - `noise_variance'
	local signal_sd: display %3.2f sqrt(`signal_variance')
	
	
	* % of correlations that are of the opposite sign as the mean
	if `mean_corr' > 0 local pct_opposite: display %3.1f normal(- `mean_corr' / `signal_sd') * 100
	else local pct_opposite: display %3.1f (1 - normal(- `mean_corr' / `signal_sd')) * 100
	local pct_opposite = "`pct_opposite'" + "%"

	
	post `SuppTable2' ("`var'") (`mean_corr') (`signal_sd') (`noise_sd') ("`pct_opposite'")
	
}


postclose `SuppTable2'
use "${paper1_tables}/SuppTable2.dta", clear
export delimited "${paper1_tables}/Supplementary_Table_2.csv", replace


* Delete tempfiles 
sleep 5000                                                                      // wait for 5 seconds before deleting tempfile to avoid error
erase "${paper1_tables}/SuppTable2.dta"


