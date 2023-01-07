********************************************************************************
** This do file replicates Supplementary Table 1: EC, Exposure, and Bias Across High Schools and Colleges Using Parental vs. Own SES Ranks
********************************************************************************

clear all 


********************************************************************************
**# 1. Calculate statistics by setting and SES type 
********************************************************************************

local key_geos "hs college"


foreach geo of local key_geos {
	
	if "`geo'" == "hs" {
		
		import delimited "${fb_data}/social_capital_high_school.csv", clear 
		
		* High school-level weights: no. of students in each high school (grades 9 to 12). Note that weights are different from that in paper for privacy protection.
		local weight students_9_to_12
	}
	
	else if "`geo'" == "college" {
		
		import delimited "${fb_data}/social_capital_college.csv", clear 
		
		* College-level weights: mean no. of students per cohort. Note that weights are different from that in paper for privacy protection. 
		local weight mean_students_per_cohort 
	}
	
	
	foreach measure in ec exposure bias {
		
		* Correlation between measure constructed with parental SES vs own SES 
		corr `measure'_parent_ses_`geo' `measure'_own_ses_`geo' [aweight = `weight']
		local corr_`measure'_`geo': display %3.2f r(rho)
		
		
		* Mean and SD of measure constructed with parental SES 
		summarize `measure'_parent_ses_`geo' [aweight = `weight']
		local mean_`measure'_parent_`geo': display %3.2f r(mean)
		local sd_`measure'_parent_`geo': display %3.2f r(sd)
		
		
		* Mean and SD of measure constructed with own SES 
		summarize `measure'_own_ses_`geo' [aweight = `weight']
		local mean_`measure'_own_`geo': display %3.2f r(mean)
		local sd_`measure'_own_`geo': display %3.2f r(sd)
	}
}


********************************************************************************
**# 2. Export statistics as table 
********************************************************************************
	
postutil clear
tempname SuppTable1
postfile `SuppTable1' str32 statistic ec_high_school ec_college exposure_high_school exposure_college bias_high_school bias_college using "${paper2_tables}/SuppTable1.dta", replace

post `SuppTable1' ("Corr. using Par vs Own Rank") (`corr_ec_hs') (`corr_ec_college') (`corr_exposure_hs') (`corr_exposure_college') (`corr_bias_hs') (`corr_bias_college')
post `SuppTable1' ("Mean using Parent SES Rank") (`mean_ec_parent_hs') (`mean_ec_parent_college') (`mean_exposure_parent_hs') (`mean_exposure_parent_college') (`mean_bias_parent_hs') (`mean_bias_parent_college')
post `SuppTable1' ("SD using Parent SES Rank") (`sd_ec_parent_hs') (`sd_ec_parent_college') (`sd_exposure_parent_hs') (`sd_exposure_parent_college') (`sd_bias_parent_hs') (`sd_bias_parent_college')
post `SuppTable1' ("Mean using Own SES Rank") (`mean_ec_own_hs') (`mean_ec_own_college') (`mean_exposure_own_hs') (`mean_exposure_own_college') (`mean_bias_own_hs') (`mean_bias_own_college')
post `SuppTable1' ("SD using Own SES Rank") (`sd_ec_own_hs') (`sd_ec_own_college') (`sd_exposure_own_hs') (`sd_exposure_own_college') (`sd_bias_own_hs') (`sd_bias_own_college')


* Export correlations as csv
postclose `SuppTable1'	
use "${paper2_tables}/SuppTable1.dta", clear 
export delimited "${paper2_tables}/Supplementary_Table_1.csv", replace


* Erase tempfile
sleep 5000                                                                      // avoid errors in erasing tempfile
erase "${paper2_tables}/SuppTable1.dta"
