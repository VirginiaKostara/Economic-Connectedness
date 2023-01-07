********************************************************************************
** This do file replicates Main Table 2: Associations between Upward Mobility, Economic Connectedness, and Other Neighborhood Characteristics
********************************************************************************

clear all 

********************************************************************************
**# 1. Panel A: Economic Connectedness vs. Median Income and Poverty Rates
********************************************************************************

* Define geographic units 
local key_geos = "county zip"

* Define weight: no. of children with parents with below-median household income
local weight = "num_below_p50"

* Set SE clustering level 
local cluster_var = "cz"


foreach geo in `key_geos' {	
	
	
	* Merge economic connectedness variable from FB dataset to public data
	import delimited "${fb_data}/social_capital_`geo'.csv", clear 
	keep `geo' ec_`geo'
	merge 1:1 `geo' using "${public_data}/`geo'_covariates.dta"
	
	
	* Drop if missing outcome, treatment variables, or weight
	drop if missing(kfr_pooled_pooled_p25, ec_`geo', med_hhinc2000, poor_share2000, `weight')
	
	* Rename economic connectedness variable for table 
	rename ec_`geo' ec		
	
		
	* Standardize variables to have mean 0 and std dev 1 
	center kfr_pooled_pooled_p25 ec med_hhinc2000 poor_share2000 [aweight = `weight'], inplace standardize 
	
			  
	* Regress upward mobility on median household income 
	eststo: reg kfr_pooled_pooled_p25 med_hhinc2000 if !missing(ec) [aweight = `weight'], vce(cluster `cluster_var') 

	* Regress upward mobility on median household income and economic connectedness
	eststo: reg kfr_pooled_pooled_p25 med_hhinc2000 ec [aweight = `weight'], vce(cluster `cluster_var') 
	
	* Regress upward mobility on poverty rates
	eststo: reg kfr_pooled_pooled_p25 poor_share2000 if !missing(ec) [aweight = `weight'], vce(cluster `cluster_var') 

	* Regress upward mobility on poverty rates and economic connectedness
	eststo: reg kfr_pooled_pooled_p25 poor_share2000 ec [aweight = `weight'], vce(cluster `cluster_var') 		
}


* Label vars 
label var ec "Economic connectedness"
label var med_hhinc2000 "Median income"
label var poor_share2000 "Poverty rate"
label var kfr_pooled_pooled_p25 "Upward mobility"


esttab using "${paper1_tables}/Main_Table_2a.csv", ///
order(med_hhinc2000 poor_share2000 ec) b(%9.3fc) se(%9.3fc) replace nocons star(* 0.1 ** 0.05 *** 0.01) label

eststo clear


********************************************************************************
**# 2. Panel B: Economic Connectedness vs. Segregation and Inequality
********************************************************************************

* Define geographic units 
local geo = "county"

* Define weight: no. of children with parents with below-median household income
local weight = "num_below_p50"

* Set SE clustering level 
local cluster_var = "cz"


* Merge economic connectedness variable from FB dataset to public data
import delimited "${fb_data}/social_capital_`geo'.csv", clear 
keep `geo' ec_`geo'
merge 1:1 `geo' using "${public_data}/`geo'_covariates.dta"


* Drop if missing economic connectedness
drop if missing(ec_`geo')

* Label vars 
label var income_segregation "Income segregation"
label var racial_segregation "Racial segregation"
label var gini99_simple "Income inequality (Gini coefficient)"
label var ec "Economic connectedness"
label var kfr_pooled_pooled_p25 "Upward mobility"
	
	
local vars_to_loop_over income_segregation racial_segregation gini99_simple

foreach var of local vars_to_loop_over {
	
	preserve
	
	* Standardize variables to have mean 0 and std dev 1 
	center kfr_pooled_pooled_p25 `var' ec_`geo' [aweight = `weight'], inplace standardize 
	
	
	* Regress upward mobility on relevant neighborhood characteristic 
	eststo: reg kfr_pooled_pooled_p25 `var' [aweight = `weight'], vce(cluster `cluster_var')
	
	* Regress upward mobility on relevant neighborhood characteristic and economic connectedness
	eststo: reg kfr_pooled_pooled_p25 `var' ec_`geo' [aweight = `weight'], vce(cluster `cluster_var')	
	
	restore
}


esttab using "${paper1_tables}/Main_Table_2b.csv", ///
order(income_segregation racial_segregation gini99_simple ec_`geo') b(%9.3fc) se(%9.3fc) replace nocons star(* 0.1 ** 0.05 *** 0.01) label

eststo clear


********************************************************************************
**# 3. Panel C: Economic Connectedness vs. Share of Black Residents
********************************************************************************

* Define geographic units 
local key_geos = "county zip"

* Define races 
local races = "black white"

* Set SE clustering level 
local cluster_var = "cz"


foreach geo in `key_geos' {	
	
	* Merge economic connectedness variable from FB dataset to public data
	import delimited "${fb_data}/social_capital_`geo'.csv", clear 
	keep `geo' ec_`geo'
	merge 1:1 `geo' using "${public_data}/`geo'_covariates.dta"

	
	* Drop if missing economic connectedness
	drop if missing(ec_`geo')
	
	* Rename economic connectedness variable for table 
	rename ec_`geo' ec
	
	* Label vars 
	label var share_black2000 "Share black"
	label var ec "Economic connectedness"
	label var kfr_black_pooled_p25 "Upward mobility for black individuals"
	label var kfr_white_pooled_p25 "Upward mobility for white individuals"
		  
	foreach race in `races' {
		
		preserve
		
		* Weight: no. of children with parents with below-median household income (separately for each race)
		local weight = "kid_`race'_pooled_blw_p50_n" 
		
		* Standardize variables to have mean 0 and std dev 1 
	    center kfr_`race'_pooled_p25 ec share_black2000 [aweight = `weight'], inplace standardize 
		
		
		* Regress upward mobility for individuals of the relevant race on share of black people in the population
		reg kfr_`race'_pooled_p25 share_black2000 if !missing(ec) [aweight = `weight'], vce(cluster `cluster_var') 
		eststo `race'_`geo'
		
		* Regress upward mobility for individuals of the relevant race on share of black people in the population and economic connectedness
		reg kfr_`race'_pooled_p25 share_black2000 ec [aweight = `weight'], vce(cluster `cluster_var') 	
		eststo `race'_`geo'_ec
		
		restore	
	}		
}


esttab black_county black_county_ec black_zip black_zip_ec white_county white_county_ec white_zip white_zip_ec ///
using "${paper1_tables}/Main_Table_2c.csv", ///
order(share_black2000 ec) b(%9.3fc) se(%9.3fc) replace nocons star(* 0.1 ** 0.05 *** 0.01) label

eststo clear


