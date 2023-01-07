********************************************************************************
** This do file replicates Extended Data Figure 1: Predictors of Friending Bias in High Schools Using Parental SES
********************************************************************************

clear all 

********************************************************************************
**# 0. Setup
********************************************************************************

* Merge FB data with public covariates
import delimited "${fb_data}/social_capital_high_school.csv", clear
rename high_school nces_school_id

merge 1:1 nces_school_id using "${public_data}/nces_highschools.dta", keep(match) nogen
destring nces_school_id, gen(nces_id) force 
drop if missing(nces_id) 

merge 1:1 nces_id using "${public_data}/crdc_nces_collapse_hs.dta", keep(match master) nogen


* Define weight: no. of students in each high school (grades 9-12)
local weight students_9_to_12

* Rescale bias such that it ranges from 0 to 100
replace bias_parent_ses_hs = bias_parent_ses_hs * 100


********************************************************************************
**# 1. Panel A: Friending Bias vs. AP Enrollment
********************************************************************************

* Code negative values in AP enrollment as missing
replace tot_apenr_m = . if tot_apenr_m < 0
replace tot_apenr_f = . if tot_apenr_f < 0

* Gen % of students in at least one AP course 
gen frac_ap = (tot_apenr_m + tot_apenr_f) / (tot_enr_m + tot_enr_f) * 100


* Binscatter
binscatter bias_parent_ses_hs frac_ap [aweight = `weight'], ///
		   ylabel(-0.5(0.5)2, nogrid labsize(small)) linetype(qfit) lcolor(eltblue) mcolor(eltblue) ///
		   xlabel(0(10)50, labsize(small)) /// 
		   ytitle("Friending Bias among" "Low-Parental-SES Students (%)", size(small)) xtitle("Share in at least one Advanced Placement Course (%)", size(small))  ///
		   title("{bf:Predictors of Friending Bias in High Schools Using Parental SES}" " " "{it:A. Friending Bias vs. AP Enrollment}" " ", size(small) span) ///
		   savegraph("${paper2_figs}/Extended Data_Figure_1a.pdf") replace
	
	
********************************************************************************
**# 2. Panel B: Friending Bias vs. Gifted & Talented Enrollment
********************************************************************************

* Code negative values in gifted and talented enrollment as missing
replace tot_gtenr_m = . if tot_gtenr_m < 0
replace tot_gtenr_f = . if tot_gtenr_f < 0

* Gen % of students in Gifted & Talented program
gen frac_gt = (tot_gtenr_m + tot_gtenr_f) / (tot_enr_m + tot_enr_f) * 100


* Binscatter
binscatter bias_parent_ses_hs frac_gt [aweight = `weight'], ///
		   ylabel(0(0.5)2.5, nogrid labsize(small)) linetype(qfit) lcolor(eltblue) mcolor(eltblue) ///
		   xlabel(0(20)60, labsize(small)) /// 
		   ytitle("Friending Bias among" "Low-Parental-SES Students (%)", size(small)) xtitle("Share in Gifted and Talented Program (%)", size(small))  ///
		   title("{bf:Predictors of Friending Bias in High Schools Using Parental SES}" " " "{it:B. Friending Bias vs. Gifted and Talented Enrollment}" " ", size(small) span) ///
		   savegraph("${paper2_figs}/Extended Data_Figure_1b.pdf") replace


********************************************************************************
**# 3. Panel C: Friending Bias vs. School Cohort Size
********************************************************************************

* Gen mean cohort size 
gen students_per_cohort = students_9_to_12 / 4


* Binscatter
binscatter bias_parent_ses_hs students_per_cohort [aweight = `weight'], ///
		   ylabel(-2(1)2, nogrid labsize(small)) linetype(qfit) lcolor(eltblue) mcolor(eltblue) ///
		   xlabel(0(200)1000, labsize(small)) /// 
		   ytitle("Friending Bias among" "Low-Parental-SES Students (%)", size(small)) xtitle("Number of Students per Cohort", size(small))  ///
		   title("{bf:Predictors of Friending Bias in High Schools Using Parental SES}" " " "{it:C. Friending Bias vs. School Cohort Size}" " ", size(small) span) ///
		   savegraph("${paper2_figs}/Extended Data_Figure_1c.pdf") replace

		   
********************************************************************************
**# 4. Panel D: Friending Bias vs. Exposure
********************************************************************************

* Rescale exposure to range from 0 to 100 
replace exposure_parent_ses_hs = exposure_parent_ses_hs * 100 / 2


* Binscatter
binscatter bias_parent_ses_hs exposure_parent_ses_hs [aweight = `weight'], ///
		   ylabel(-1(1)2, nogrid labsize(small)) linetype(qfit) lcolor(eltblue) mcolor(eltblue) ///
		   xlabel(20(20)80, labsize(small)) /// 
		   ytitle("Friending Bias among" "Low-Parental-SES Students (%)", size(small)) xtitle("Share of Above-Median-Parental-SES Students", size(small))  ///
		   title("{bf:Predictors of Friending Bias in High Schools Using Parental SES}" " " "{it:D. Friending Bias vs. Exposure}" " ", size(small) span) ///
		   savegraph("${paper2_figs}/Extended Data_Figure_1d.pdf") replace		   
		   
		   
********************************************************************************
**# 5. Panel E: Friending Bias vs. Racial Diversity
********************************************************************************
		   
* Gen Herfindahl-Hirschman Index for racial diversity (higher values mean more diversity)
gen hhi = 1 - (frac_students_black ^ 2 + frac_students_white ^ 2 + frac_students_asian ^ 2 + frac_students_hispanic ^ 2)


* Binscatter
binscatter bias_parent_ses_hs hhi [aweight = `weight'], ///
		   ylabel(-1(1)3, nogrid labsize(small)) linetype(qfit) lcolor(eltblue) mcolor(eltblue) ///
		   xlabel(0(0.2)0.8, labsize(small)) /// 
		   ytitle("Friending Bias among" "Low-Parental-SES Students (%)", size(small)) xtitle("Racial Diversity (Herfindahl-Hirschman Index)", size(small))  ///
		   title("{bf:Predictors of Friending Bias in High Schools Using Parental SES}" " " "{it:E. Friending Bias vs. Racial Diversity}" " ", size(small) span) ///
		   savegraph("${paper2_figs}/Extended Data_Figure_1e.pdf") replace		   
		   
		   
********************************************************************************
**# 6. Panel E: Friending Bias vs. Share White
********************************************************************************
		   
* Rescale share white to range from 0 to 100
replace frac_students_white = frac_students_white * 100


* Binscatter
binscatter bias_parent_ses_hs frac_students_white [aweight = `weight'], ///
		   ylabel(-2(1)3, nogrid labsize(small)) linetype(qfit) lcolor(eltblue) mcolor(eltblue) ///
		   xlabel(0(20)100, labsize(small)) /// 
		   ytitle("Friending Bias among" "Low-Parental-SES Students (%)", size(small)) xtitle("Share of White Students (%)", size(small))  ///
		   title("{bf:Predictors of Friending Bias in High Schools Using Parental SES}" " " "{it:F. Friending Bias vs. Share White}" " ", size(small) span) ///
		   savegraph("${paper2_figs}/Extended Data_Figure_1f.pdf") replace	

