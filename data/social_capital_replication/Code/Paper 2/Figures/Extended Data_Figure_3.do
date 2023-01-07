********************************************************************************
** This do file replicates Extended Data Figure 3: Friending Bias versus Racial Diversity
********************************************************************************

clear all 


********************************************************************************
**# 1. Prepare ZIP-level data on friending bias and racial diversity 
********************************************************************************

import delimited "${fb_data}/social_capital_zip.csv", clear 
merge 1:1 zip using "${public_data}/zip_covariates.dta"
 
 
* Gen Herfindahl-Hirschman Index for racial diversity (higher values mean more diversity)
gen hhi = 1 - (share_white_2018 ^ 2 + share_black_2018 ^ 2 + share_natam_2018 ^ 2 + share_asian_2018 ^ 2 + share_hawaii_2018 ^ 2 + share_hispanic_2018 ^ 2)

* ZIP-level weights: no. of children with parents below median HH income
gen weight = num_below_p50

* Identify this as a zip-level dataset 
gen group = "zip"


rename nbhd_bias_zip bias 
keep bias hhi weight group

tempfile EDFigure3_zip
save `EDFigure3_zip'


********************************************************************************
**# 2. Prepare college-level data on friending bias and racial diversity 
********************************************************************************

import delimited "${fb_data}/social_capital_college.csv", clear
merge 1:1 college using "${public_data}/college_characteristics.dta", keep(master match) nogen


* Gen Herfindahl-Hirschman Index for racial diversity (higher values mean more diversity)
gen frac_black = black_share_fall_2000
gen frac_hispanic = hisp_share_fall_2000
gen frac_asian = asian_or_pacific_share_fall_2000
gen frac_white = 1 - frac_black - frac_hispanic - frac_asian 
gen hhi = 1 - (frac_white ^ 2 + frac_black ^ 2 + frac_asian ^ 2 + frac_hispanic ^ 2)

* College-level weights: mean no. of students per cohort. Note that this is different from the weight used in the paper for privacy protection.
gen weight = mean_students_per_cohort 

* Identify this as a college-level dataset 
gen group = "college"


rename bias_own_ses_college bias 
keep bias hhi weight group 

tempfile EDFigure3_college 
save `EDFigure3_college'


********************************************************************************
**# 3. Plot graph 
********************************************************************************

use `EDFigure3_zip', clear 
append using `EDFigure3_college'


* Rescale bias to range from 0 to 100
replace bias = bias * 100


* Binscatter (separately for each dataset, but displayed on the same graph)
* Note: it is important that group is named "college" for the college-level dataset and "zip" for the zip-level dataset so that college will be plotted first and zip second. Else labels will be mixed up.
binscatter bias hhi [aweight = weight], by(group) ///
		   ylabel(0(5)25, nogrid labsize(small)) xlabel(0(0.2)0.8, format(%02.1f) labsize(small)) /// 
		   lcolors(eltblue sand) mcolors(eltblue sand) msymbol(d o) ///
		   legend(row(1) order(1 "College" 2 "Neighborhood") size(small)) ///
		   ytitle("Friending Bias among Low-SES Individuals (%)", size(small)) xtitle("Racial Diversity (Herfindahl-Hirschman Index) in Group", size(small)) ///
		   title("{bf:Friending Bias vs. Racial Diversity}", size(small) span) ///
		   savegraph("${paper2_figs}/Extended Data_Figure_3.pdf") replace


