********************************************************************************
** This do file replicates Main Table 1: Associations between friending bias, exposure and upward income mobility across areas
********************************************************************************

clear all 


* Define geographic units 
local geos zip county


foreach geo of local geos {	
		
	* Merge public and FB data 
	import delimited "${fb_data}/social_capital_`geo'.csv", clear 
	keep `geo' exposure_grp_mem_`geo' bias_grp_mem_`geo'
	merge 1:1 `geo' using "${public_data}/`geo'_covariates.dta"
		
	* Set SE clustering level  
	if "`geo'" == "county" local cluster_var cz
	if "`geo'" == "zip" local cluster_var county	

	* Rescale variables such that they range from 0 to 100
	replace kfr_pooled_pooled_p25 = kfr_pooled_pooled_p25 * 100
	replace exposure_grp_mem_`geo' = exposure_grp_mem_`geo' * 100
	
	
	* Logged independent variables 
	gen ln_bias = ln(1 - bias_grp_mem_`geo')
	gen ln_group_exposure = ln(exposure_grp_mem_`geo')
	gen ln_group_cec = ln_bias + ln_group_exposure
	
	label var ln_bias "log(1 - friending bias)"
	label var ln_group_exposure "log(high-SES exposure)"
	label var ln_group_cec "log(EC)"
	
	* Logged outcome variable for columns 1-6
	gen ln_kfr = ln(kfr_pooled_pooled_p25)
	label var ln_kfr "log(upward income mobility)"
	
	
	* Create Table
	if "`geo'" == "zip"{
		
		* Sample restrictions (columns 1-6)
		keep if !missing(`cluster_var', ln_kfr, ln_group_cec, ln_bias, ln_group_exposure)
		
		* Define weight for columns 1-6: no. of children with parents with below-median household income (this is different from the weight used in the paper for privacy protection)
		local weight = "num_below_p50"

		
		* Col 1: Regress log upward income mobility on log economic connectedness
		eststo: reg ln_kfr ln_group_cec [aweight = `weight'], vce(cluster `cluster_var') 

		* Col 2: Regress log upward income mobility on log exposure and log bias
		eststo: reg ln_kfr ln_group_exposure ln_bias [aweight = `weight'], vce(cluster `cluster_var') 	
				
		* Col 3: Regress log upward income mobility on log economic connectedness with county FE
		eststo: areg ln_kfr ln_group_cec [aweight = `weight'], absorb(county) vce(cluster `cluster_var') 

		* Col 4: Regress log upward income mobility on log exposure and log bias with county FE
		eststo: areg ln_kfr ln_group_exposure ln_bias [aweight = `weight'], absorb(county) vce(cluster `cluster_var') 	
	}
	
	else if "`geo'" == "county" {
		
		preserve 
		
		* Sample restrictions (columns 1-6)
		keep if !missing(`cluster_var', ln_kfr, ln_group_cec, ln_bias, ln_group_exposure)
		
		* Define weight for columns 1-6: no. of children with parents with below-median household income (this is different from the weight used in the paper for privacy protection)
		local weight = "num_below_p50"
		
		
	    * Col 5: Regress log upward income mobility on log economic connectedness 
		eststo: reg ln_kfr ln_group_cec [aweight = `weight'], vce(cluster `cluster_var') 

		* Col 6: Regress log upward income mobility on log exposure and log bias
		eststo: reg ln_kfr ln_group_exposure ln_bias [aweight = `weight'], vce(cluster `cluster_var') 	
		
		restore

		
		
		* Sample restrictions (column 7)
		keep if !missing(`cluster_var', kfr_26_pooled_pooled_p25, causal_p25_cz_cty_kr26, num_below_p50)
		
		* Define weight for column 7: inverse of the county-level squared standard error of Chetty and Hendren (2018)'s estimate of the annual causal exposure effect of growing up in that county.
		gen inv_weights = (1 / causal_p25_cz_cty_kr26_se)^2
		local weight = "inv_weights"
		
		
		* Construct dependent variable: log expected mean predicted household income rank in adulthood for children with parents at the 25th percentile of the income distribution overall in the United States 
		*                               plus 20 times the raw annual causal exposure effect of growing up in the county reported in Chetty and Hendren (2018).
		summarize kfr_26_pooled_pooled_p25 [aweight = `weight']
		local avg = r(mean) * 100 
		summarize causal_p25_cz_cty_kr26 [aweight = num_below_p50], detail
		drop if (causal_p25_cz_cty_kr26 < r(p1) | causal_p25_cz_cty_kr26 > r(p99))                               // trim outliers (top and bottom 1% of causal exposure effect estimates)

		gen ln_causal = ln(`avg' + causal_p25_cz_cty_kr26 * 20)
		label var ln_causal "log(causal upward income mobility)"

		
		* Col 7: Regress log causal upward income mobility on log exposure and log bias 
		eststo: reg ln_causal ln_group_exposure ln_bias [aweight = `weight'] , vce(cluster `cluster_var')
	}
		
}


esttab using "${paper2_tables}/Main_Table_1.csv", ///
order(ln_group_cec ln_group_exposure ln_bias) b(%9.3fc) se(%9.3fc) replace nocons star(* 0.1 ** 0.05 *** 0.01) label

eststo clear