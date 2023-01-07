********************************************************************************
** This do file replicates Main Figure 5: Friending Bias and Exposure by High School and College
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

* Define file paths in R and call Main_Figure_5.R
rcall script "${paper2_code}/Figures/Main_Figure_5.R"


* Clear R session and delete tempfiles 
rcall clear 
cap erase "${paper2_code}/Rplots.pdf"
cap erase "${paper2_code}/Figures/.Rhistory"
