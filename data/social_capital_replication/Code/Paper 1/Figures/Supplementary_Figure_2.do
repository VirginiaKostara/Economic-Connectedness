********************************************************************************
** This do file replicates Supplementary Figure 2: LASSO Estimates & Incremental R-Squared of Predictors in Multivariable Models
********************************************************************************

clear all


* Define geographic units 
local geo = "county"

* Define weight: no. of children with parents with below-median household income
local weight = "num_below_p50"


import delimited "${fb_data}/social_capital_`geo'.csv", clear 
merge 1:1 `geo' using "${public_data}/`geo'_covariates.dta"


********************************************************************************	
**# 1. Panel A: LASSO for Social Capital Measures	
********************************************************************************	

* List of social capital measures
* Note: only a subset of measures is available with public data: economic connectedness, clustering, support ratio, civic organizations, and volunteering rate
* As such, multivariate analyses are not directly comparable with those in the paper
local vars "ec_`geo' clustering_`geo' support_ratio_`geo' civic_organizations_`geo' volunteering_rate_`geo'"


* Lasso 
lasso linear kfr_pooled_pooled_p25 `vars' [iweight = `weight']
lassocoef
coefpath, legend(col(3) label(1 `"Economic Connectedness"') ///
						label(2 `"Clustering"') ///
						label(3 `"Support Ratio"') ///
						label(4 `"Civic Organizations"') ///
						label(5 `"Volunteering Rate"') ///
				 size(vsmall) symysize(*0.5) symxsize(*0.5)) /// 
		  ylabel(, format(%03.2f) gmax gmin nogrid labsize(small)) ///
		  xlabel(, format(%03.2f) labsize(small)) ///
		  ytitle("Standardized LASSO Coefficients", size(small)) ///
		  xtitle("L1 Norm of Standardized Coefficient Vector", size(small)) ///
		  title("{bf:LASSO Estimates and Incremental R{superscript:2} of Predictors in Multivariable Models}", size(small) span) ///
		  subtitle("{it:A. LASSO for Social Capital Measures}", size(small) span)
		  
graph export "${paper1_figs}/Supplementary_Figure_2a.pdf", replace


********************************************************************************
**# 2. Panel B: LASSO Including Other Neighborhood Characteristics
********************************************************************************

* Economic connectedness + list of neighborhood characteristics
local vars ec_`geo' /// 
		   med_hhinc2000 ///
		   nonpoor_share2000 ///
		   income_segregation ///
		   racial_segregation ///
		   share_black2000 ///
		   gini99_simple /// 
		   jobs_total_5mi_2015 ///
		   job_growth_2004_2013 ///
           emp2000 ///
		   gsmn_math_g3_2013 ///
	       frac_coll_plus2000 ///
		   share_hisp2000 ///
	       singleparent_share2000 
		   
		   
lasso linear kfr_pooled_pooled_p25 `vars' [iweight = `weight']
lassocoef
coefpath, legend(col(4) label(1 `"Economic Connectedness"') ///
						label(2 `"Median HH Income"') ///
						label(3 `"Share Above Poverty Line"') ///
						label(4 `"Income Segregation"') /// 
						label(5 `"Racial Segregation"') /// 
						label(6 `"Share Black"') ///
						label(7 `"Income Gini"' ) /// 
						label(8 `"Jobs Within 5 Miles"' ) /// 
						label(9 `"Job Growth 2004–2013"') /// 
						label(10 `"2000 Employment Rate"') ///
						label(11 `"Mean 3rd Grade Math Score"') ///
						label(12 `"Share College Grad."') ///
						label(13 `"Share Hispanic"') /// 
						label(14 `"Share Single Parent HH"') ///
				 size(vsmall) symysize(*0.5) symxsize(*0.5)) ///
		  ytitle("Standardized LASSO Coefficients", size(small)) ///
		  xtitle("L1 Norm of Standardized Coefficient Vector", size(small)) ///
		  ylabel(, format(%03.2f) gmax gmin nogrid labsize(small)) ///
		  xlabel(0(0.02)0.08, format(%03.2f) labsize(small)) ///
		  title("{bf:LASSO Estimates and Incremental R{superscript:2} of Predictors in Multivariable Models}", size(small) span) ///
		  subtitle("{it:B. LASSO Including Other Neighborhood Characteristics}", size(small) span)

graph export "${paper1_figs}/Supplementary_Figure_2b.pdf", replace	 


********************************************************************************
**# 3. Panel C: Additional R-Squared for Social Capital Measures
********************************************************************************

preserve

* List of social capital measures
* Note: only a subset of measures is available with public data: economic connectedness, clustering, support ratio, civic organizations, and volunteering rate
* As such, multivariate analyses are not directly comparable with those in the paper
local vars "ec_`geo' clustering_`geo' support_ratio_`geo' civic_organizations_`geo' volunteering_rate_`geo'"

keep if !missing(ec_`geo', clustering_`geo', support_ratio_`geo', civic_organizations_`geo', volunteering_rate_`geo') 

postutil clear
tempname multivariateCorrs
postfile `multivariateCorrs' str8 variable float r2 using "${paper1_figs}/SuppFigure2c.dta", replace


* R2 from regression including all social capital measures (r2_all)					  
reg kfr_pooled_pooled_p25 `vars' [aweight = `weight']
scalar r2_all = e(r2)


* For each social capital measure, calculate the R2 from regression excluding that measure (r2_sub)
* The incremental R2 from including that measure is r2_additional = r2_all - r2_sub
foreach var of local vars {
	
	local vars_sub = subinstr("`vars'", "`var'", "", .)

	reg kfr_pooled_pooled_p25 `vars_sub' [aweight = `weight']
	scalar r2_sub = e(r2)
	scalar r2_additional = r2_all - r2_sub
	
	post `multivariateCorrs' ("`var'") (`= r2_additional')
}


* Plot graph
postclose `multivariateCorrs'
use "${paper1_figs}/SuppFigure2c.dta", clear
gen var_order = - _n
 
twoway (scatter var_order r2, mcolor("41 182 164") msymbol(circle) msize(medium)),  ///
		ylabel(-1 `"Economic Connectedness"' ///
			   -2 `"Clustering"' ///
			   -3 `"Support Ratio"' ///
			   -4 `"Civic Organizations"' ///
			   -5 `"Volunteering Rate"' ///
				, labsize(small) nogrid) ///
		ytitle("") ///
		xtitle("Increase in R{superscript:2} from Additional Regressor", size(small)) ///
		xlabel(0(0.1)0.4, format(%03.1f) gmax gmin nogrid labsize(small)) ///
		title("{bf:LASSO Estimates and Incremental R{superscript:2} of Predictors in Multivariable Models}" " " "{it:C. Additional R{superscript:2} for Social Capital Measures}" " ", size(small) span)

graph export "${paper1_figs}/Supplementary_Figure_2c.pdf", replace


* Delete tempfile 
erase "${paper1_figs}/SuppFigure2c.dta"

restore

********************************************************************************
**# 4. Panel D: Additional R-Squared Including Other Neighborhood Characteristics
********************************************************************************

preserve


* Economic connectedness + list of neighborhood characteristics
local vars ec_`geo' /// 
		   med_hhinc2000 ///
		   racial_segregation /// 
		   share_black2000 ///
		   gini99_simple ///
		   gsmn_math_g3_2013 ///
		   singleparent_share2000

keep if !missing(ec_`geo', med_hhinc2000, racial_segregation, share_black2000, gini99_simple, gsmn_math_g3_2013, singleparent_share2000) 

postutil clear
tempname multivariateCorrs
postfile `multivariateCorrs' str8 variable float r2 using "${paper1_figs}/SuppFigure2d.dta", replace


* R2 from regression including ec + all neighborhood characteristics (r2_all)					  
reg kfr_pooled_pooled_p25 `vars' [aweight = `weight']
scalar r2_all = e(r2)


* For each measure, calculate the R2 from regression excluding that measure (r2_sub)
* The incremental R2 from including that measure is r2_additional = r2_all - r2_sub
foreach var of local vars {
	
	local vars_sub = subinstr("`vars'", "`var'", "", .)

	reg kfr_pooled_pooled_p25 `vars_sub' [aweight = `weight']
	scalar r2_sub = e(r2)
	scalar r2_additional = r2_all - r2_sub
	
	post `multivariateCorrs' ("`var'") (`= r2_additional')
}


* Plot graph
postclose `multivariateCorrs'
use "${paper1_figs}/SuppFigure2d.dta", clear
gen var_order = - _n
 
twoway (scatter var_order r2, mcolor("41 182 164") msymbol(circle) msize(medium)),  ///
		ylabel(-1 `" "Economic Connectedness" "' ///
			   -2 `" "Median HH Income" "' ///
			   -3 `" "Racial Segregation" "' ///
			   -4 `" "Share Black" "' ///
               -5 `" "Income Gini" "' ///
		       -6 `" "Mean 3rd Grade Math Score" "' ///
			   -7 `" "Share Single Parent HH" "' ///
				, labsize(small) nogrid) ///
		ytitle("") ///
		xtitle("Increase in R{superscript:2} from Additional Regressor", size(small)) ///
		xlabel(0(0.02)0.12, format(%03.2f) gmax gmin nogrid labsize(small)) ///
		title("{bf:LASSO Estimates and Incremental R{superscript:2} of Predictors in Multivariable Models}" " " "{it:D. Additional R{superscript:2} Including Other Neighborhood Characteristics}" " ", size(small) span)

graph export "${paper1_figs}/Supplementary_Figure_2d.pdf", replace


* Delete tempfile 
erase "${paper1_figs}/SuppFigure2d.dta"


restore
