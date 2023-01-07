********************************************************************************
** This do file replicates Main Figure 5: Friending Bias and Exposure by High School and College, Based on Own SES
********************************************************************************

clear all 

********************************************************************************
**# 1. Call R to plot graph
********************************************************************************

* Clear R session
rcall clear 


* Define file paths in R
rcall: (fb_data <- "${fb_data}")
rcall: (paper2_figs <- "${paper2_figs}")

* Define file paths in R and call Supplementary_Figure_2.R
rcall script "${paper2_code}/Figures/Supplementary_Figure_2.R"


* Clear R session and delete tempfiles 
rcall clear 
cap erase "${paper2_code}/Rplots.pdf"
cap erase "${paper2_code}/Figures/.Rhistory"
