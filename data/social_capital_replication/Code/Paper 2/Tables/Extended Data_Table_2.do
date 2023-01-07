********************************************************************************
** This do file replicates Extended Data Table 2: Validation of SES Predictions and Group Assignments using Publicly Available Data
********************************************************************************

clear all 


* Create table
postutil clear
tempname EDTable2
postfile `EDTable2' str32 setting float Corr using "${paper2_tables}/EDTable2.dta", replace


*****************************************************************************
* 1. ZIP: Correlate % of individuals with household income above the national median (ACS data) and neighborhood exposure (Facebook data) 
*****************************************************************************

/*
Source: 2014-2018 ACS. We focus on the 25-44 age range, consistent with our primary analysis sample.

Variable definitions (also see the variable labels):

ajzme003 "Median household income for householders 25 to 44 years"

ajzle019 "No. of householders 25 to 44 years"
ajzle020 "No. of householders 25 to 44 years with less than $10,000 HH income"
ajzle021 "No. of householders 25 to 44 years with $10,000-$14,999 HH income"
ajzle022 "No. of householders 25 to 44 years with $15,000-$19,999 HH income"
ajzle023 "No. of householders 25 to 44 years with $20,000-$24,999 HH income"
ajzle024 "No. of householders 25 to 44 years with $25,000-$29,999 HH income"
ajzle025 "No. of householders 25 to 44 years with $30,000-$34,999 HH income"
ajzle026 "No. of householders 25 to 44 years with $35,000-$39,999 HH income"
ajzle027 "No. of householders 25 to 44 years with $40,000-$44,999 HH income"
ajzle028 "No. of householders 25 to 44 years with $45,000-$49,999 HH income"
ajzle029 "No. of householders 25 to 44 years with $50,000-$59,999 HH income"
ajzle030 "No. of householders 25 to 44 years with $60,000-$74,999 HH income"
ajzle031 "No. of householders 25 to 44 years with $75,000-$99,999 HH income"
ajzle032 "No. of householders 25 to 44 years with $100,000-$124,999 HH income"
ajzle033 "No. of householders 25 to 44 years with $125,000-$149,999 HH income"
ajzle034 "No. of householders 25 to 44 years with $150,000-$199,999 HH income"
ajzle035 "No. of householders 25 to 44 years with $200,000 or more HH income"
*/
use "${public_data}/zip_income_bins_and_median_income_by_age_14_18.dta", clear


* Find the across-ZIP median of within-ZIP median HH incomes
summarize ajzme003 [aweight = ajzle019], detail

/* 
The across-ZIP median is $64,443 - which means that some householders in the $60,000-$74,999 bucket are below median, and others are above median. 
For simplicity, assume a uniform distribution of income within this bracket.
Then the share of householders within the $60,000-$74,999 bucket who have above-median income is [(74,999 - r(p50)) / (74,999 - 60,000)]
*/
scalar define share_above_median_60k_75k = (74999 - r(p50)) / (74999 - 60000)


/* 
Since the across-ZIP median is $64,443, the share of householders with above median income is 
(share of householders within the $60,000-$74,999 bucket who have above-median income * no. of householders within the $60,000-$74,999 bucket + no. of householders in higher-income buckets) / no. of householders 
*/
gen share_above_median_acs_14_18 = (share_above_median_60k_75k * ajzle030 + ajzle031 + ajzle032 + ajzle033 + ajzle034 + ajzle035) / ajzle019


* Merge to FB data
keep zip share_above_median_acs_14_18
merge 1:1 zip using "${public_data}/zip_covariates.dta", keep(match) keepusing(pop2018) nogen
preserve 
import delimited "${fb_data}/social_capital_zip.csv", clear
tempfile social_capital_zip 
save `social_capital_zip'
restore 
merge 1:1 zip using `social_capital_zip', keep(master match) nogen


/* 
Correlate % of individuals with household income above the national median (ACS) and neighborhood exposure (FB), weighted by ZIP-level population from 2018 ACS
Note that the FB variable we use here is different from that in the paper for privacy protection
*/
corr share_above_median_acs_14_18 nbhd_exposure_zip [aweight = pop2018]
local zip_corr: display %3.2f abs(r(rho))                                       //        
post `EDTable2' ("ZIP Codes") (`zip_corr') 


*****************************************************************************
* 2. High school: Correlate % of students eligible for free or reduced lunch (NCES data) and exposure based on parental SES (Facebook data)
*****************************************************************************

import delimited "${fb_data}/social_capital_high_school.csv", clear
rename high_school nces_school_id

merge 1:1 nces_school_id using "${public_data}/nces_highschools.dta", nogen


/*
Correlate % of students eligible for free or reduced lunch (NCES data) and exposure based on parental SES (Facebook data), weighted by no. of students in grades 9 to 12
Note that the FB variable we use here is different from that in the paper for privacy protection
*/
corr exposure_parent_ses_hs frac_students_fr_red_lunch_5yr_m [aweight = students_9_to_12]
local hs_corr: display %3.2f abs(r(rho))
post `EDTable2' ("High Schools") (`hs_corr') 


*****************************************************************************
* 3. College: Correlate % of students with parental hh income in top two quintiles (Chetty et al. 2020b) and exposure based on parental SES (Facebook data)
*****************************************************************************

import delimited "${fb_data}/social_capital_college.csv", clear

* Merge mean no. of students per cohort to FB data
merge 1:1 college using "${public_data}/college_characteristics.dta", keep(match) keepusing(mean_students_per_cohort) nogen

* Use super OPEID (see Chetty et al. 2020b) as college group identifier
gen opeid = college / 100
merge 1:1 opeid using "${public_data}/chetty_2020b_QJE_opeid_superopeid_crosswalk.dta", keep(match) keepusing(superopeid_name super_opeid) nogen
drop if superopeid_name == "COLLEGES WITH INSUFFICIENT DATA"

* Drop extreme outliers 
drop if mean_students_per_cohort >= 25000

* Collapse exposure based on parental SES by super OPEID and weight by the mean no. of students per cohort in each college. Now super OPEID is a unique identifier in this dataset.
collapse exposure_parent_ses_college [aweight = mean_students_per_cohort], by(super_opeid)	

* Merge to the dataset from Chetty et al. 2020b Table 3, keeping only our analysis sample (cohorts between 1985 and 1994)		
merge 1:m super_opeid using "${public_data}/chetty_2020b_QJE_table_3.dta", keep(match) keepusing(cohort count par_q4 par_q5) nogen
keep if inrange(cohort, 1985, 1994)


* Generate the college x cohort-level share of students with parents in top two quintiles (Chetty et al. 2020b)
gen par_q4_q5 = par_q4 + par_q5


/*
Correlate % of students with parental hh income in top two quintiles (Chetty et al. 2020b) and exposure based on parental SES (Facebook data), weighted by no. of students in each college x cohort
Note that the FB variable we use here is different from that in the paper for privacy protection.
*/
corr par_q4_q5 exposure_parent_ses_college [aweight = count]
local college_corr: display %3.2f r(rho)
post `EDTable2' ("Colleges") (`college_corr') 


* Export correlations as csv
postclose `EDTable2'	
use "${paper2_tables}/EDTable2.dta", clear 
export delimited "${paper2_tables}/Extended Data_Table_2.csv", replace


* Erase tempfile
erase "${paper2_tables}/EDTable2.dta"