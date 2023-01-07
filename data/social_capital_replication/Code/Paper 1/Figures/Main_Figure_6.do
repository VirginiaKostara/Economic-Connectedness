********************************************************************************
** This do file replicates Main Figure 6: Associations Between Upward Income Mobility, Economic Connectedness, and Median Household Income, by ZIP Code
********************************************************************************

clear all 

********************************************************************************
**# 0. Setup 
********************************************************************************

* Define geographic unit 
local geo zip

* Merge public data with the FB dataset
import delimited "${fb_data}/social_capital_`geo'.csv", clear 
merge 1:1 `geo' using "${public_data}/`geo'_covariates.dta"


* Quintiles of upward mobility
xtile kfr_quintile = kfr_pooled_pooled_p25, nquantiles(5)
pctile kfr_cutoffs = kfr_pooled_pooled_p25, nquantiles(5)                       // lower cutoffs for each quintile between 2 and 5
replace kfr_cutoffs = kfr_cutoffs * 100                                         // rescale mobility rank from 0-1 to 0-100

* Label quintile ranges for plot 
local kfr_q5_label = ">" + string(round(kfr_cutoffs[4]))
local kfr_q4_label = string(round(kfr_cutoffs[3])) + "-" + string(round(kfr_cutoffs[4]))
local kfr_q3_label = string(round(kfr_cutoffs[2])) + "-" + string(round(kfr_cutoffs[3]))
local kfr_q2_label = string(round(kfr_cutoffs[1])) + "-" + string(round(kfr_cutoffs[2]))
local kfr_q1_label = "<" + string(round(kfr_cutoffs[1]))


* Drop observations with missing data 
keep if !missing(ec_`geo', med_inc_2018, pop2018, kfr_pooled_pooled_p25)


* Drop observations with (1) income below the 5th percentile (2) income above the 95th percentile (3) population size below the 10th percentile 
xtile med_inc_ventile = med_inc_2018, nquantiles(20)
xtile pop_decile = pop2018, nquantiles(10)
drop if (med_inc_ventile == 1 | med_inc_ventile == 20 | pop_decile == 1)


* Save cleaned dataset as tempfile 
save "${paper1_figs}/MainFigure6.dta", replace


********************************************************************************
**# 1. Call R to plot graph
********************************************************************************

* Clear R session
rcall clear 

* Define quintile ranges in R
forval quintile = 1(1)5 {
	rcall: (kfr_q`quintile'_label <- "`kfr_q`quintile'_label'")
}

* Define file paths in R and call animation_funnel.R
rcall script "${paper1_code}/Figures/Main_Figure_6.R", args(paper1_figs <- "${paper1_figs}")

* Clear R session and delete tempfiles 
rcall clear 
erase "${paper1_figs}/MainFigure6.dta"
cap erase "${master_folder}/Rplots.pdf"
cap erase "${paper1_code}/.Rhistory"
