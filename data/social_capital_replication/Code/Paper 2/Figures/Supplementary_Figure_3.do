********************************************************************************
** This do file replicates Supplementary Figure 3: Predictors of Friending Bias in Colleges
********************************************************************************

clear all 

********************************************************************************
**# 0. Setup
********************************************************************************

* Merge FB data with public covariates
import delimited "${fb_data}/social_capital_college.csv", clear
merge 1:1 college using "${public_data}/college_characteristics.dta", keep(match) nogen


* Define weight: mean no. of students per cohort. Note that this is different from the weight used in the paper for privacy protection.
local weight mean_students_per_cohort

* Drop extreme outliers 
drop if mean_students_per_cohort >= 25000

* Rescale bias such that it ranges from 0 to 100
replace bias_parent_ses_college = bias_parent_ses_college * 100


********************************************************************************
**# 1. Panel A: Friending Bias vs. School Cohort Size
********************************************************************************

* Binscatter
binscatter bias_parent_ses_college mean_students_per_cohort [aweight = `weight'], ///
		   ylabel(, nogrid labsize(small)) linetype(qfit) lcolor(eltblue) mcolor(eltblue) ///
		   xlabel(, labsize(small)) /// 
		   ytitle("Friending Bias among" "Low-Parental-SES Students (%)", size(small)) xtitle("Number of Students per Cohort", size(small))  ///
		   title("{bf:Predictors of Friending Bias in Colleges}" " " "{it:A. Friending Bias vs. School Cohort Size}" " ", size(small) span) ///
		   savegraph("${paper2_figs}/Supplementary_Figure_3a.pdf") replace

		   
********************************************************************************
**# 2. Panel B Friending Bias vs. Exposure
********************************************************************************

* Rescale exposure to range from 0 to 100 
replace exposure_parent_ses_college = exposure_parent_ses_college * 100 / 2


* Binscatter
binscatter bias_parent_ses_college exposure_parent_ses_college [aweight = `weight'], ///
		   ylabel(, nogrid labsize(small)) linetype(qfit) lcolor(eltblue) mcolor(eltblue) ///
		   xlabel(, labsize(small)) /// 
		   ytitle("Friending Bias among" "Low-Parental-SES Students (%)", size(small)) xtitle("Share of Above-Median-Parental-SES Students", size(small))  ///
		   title("{bf:Predictors of Friending Bias in Colleges}" " " "{it:B. Friending Bias vs. Exposure}" " ", size(small) span) ///
		   savegraph("${paper2_figs}/Supplementary_Figure_3b.pdf") replace		   
		   
		   
********************************************************************************
**# 3. Panel C: Friending Bias vs. Racial Diversity
********************************************************************************
		   
* Gen Herfindahl-Hirschman Index for racial diversity (higher values mean more diversity)
gen frac_black = black_share_fall_2000
gen frac_hispanic = hisp_share_fall_2000
gen frac_asian = asian_or_pacific_share_fall_2000
gen frac_white = 1 - frac_black - frac_hispanic - frac_asian 
gen hhi = 1 - (frac_black ^ 2 + frac_white ^ 2 + frac_asian ^ 2 + frac_hispanic ^ 2)


* Binscatter
binscatter bias_parent_ses_college hhi [aweight = `weight'], ///
		   ylabel(, nogrid labsize(small)) linetype(qfit) lcolor(eltblue) mcolor(eltblue) ///
		   xlabel(, labsize(small)) /// 
		   ytitle("Friending Bias among" "Low-Parental-SES Students (%)", size(small)) xtitle("Racial Diversity (Herfindahl-Hirschman Index)", size(small))  ///
		   title("{bf:Predictors of Friending Bias in Colleges}" " " "{it:C. Friending Bias vs. Racial Diversity}" " ", size(small) span) ///
		   savegraph("${paper2_figs}/Supplementary_Figure_3c.pdf") replace		   
		   
		   
********************************************************************************
**# 4. Panel D: Friending Bias vs. Share White
********************************************************************************
		   
* Rescale share white to range from 0 to 100
replace frac_white = frac_white * 100


* Binscatter
binscatter bias_parent_ses_college frac_white [aweight = `weight'], ///
		   ylabel(, nogrid labsize(small)) linetype(qfit) lcolor(eltblue) mcolor(eltblue) ///
		   xlabel(, labsize(small)) /// 
		   ytitle("Friending Bias among" "Low-Parental-SES Students (%)", size(small)) xtitle("Share of White Students (%)", size(small))  ///
		   title("{bf:Predictors of Friending Bias in Colleges}" " " "{it:D. Friending Bias vs. Share White}" " ", size(small) span) ///
		   savegraph("${paper2_figs}/Supplementary_Figure_3d.pdf") replace	

