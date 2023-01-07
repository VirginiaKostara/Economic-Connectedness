********************************************************************************
** This metafile defines all globals and runs all other do files for Paper 1
********************************************************************************

clear all
version 17.0


** Install external packages (comment out if already installed)

ssc install binscatter, replace
ssc install center, replace 
ssc install egenmore, replace 
ssc install estout, replace
ssc install grstyle, replace
ssc install gtools, replace

* Packages to call R from within Stata (R installation required)
net install github, from("https://haghish.github.io/github/")
github install haghish/rcall, stable                                            // this will create an "rcall" subfolder in this code folder


/* 
Note: If you encounter an error relating to installation of the R package "readstata13", please directly install this package in R before running this do file, 
using the command 
                    install.packages("readstata13") 
in R
*/


********************************************************************************
**# 0. Define file paths
********************************************************************************

* Change the global "master_folder" to the location of the README file on your computer
global master_folder = "C:/Users/auz066/Desktop/social_capital_replication"

global public_data = "${master_folder}/Other public covariate data"
global fb_data = "${master_folder}/Social Capital Data"


global paper1_code = "${master_folder}/Code/Paper 1"

global paper1_figs = "${master_folder}/Paper 1 Exhibits/Figures"
global paper1_tables = "${master_folder}/Paper 1 Exhibits/Tables"


********************************************************************************
**# 1. Download social capital data 
********************************************************************************

* This code block downloads the social capital datasets from the Humanitarian Data Exchange (HDX) data repository and saves them in the folder "Social Capital Data" in this replication package 

* County-level dataset 
import delimited "https://data.humdata.org/dataset/85ee8e10-0c66-4635-b997-79b6fad44c71/resource/ec896b64-c922-4737-b759-e4bd7f73b8cc/download/social_capital_county.csv", clear 
export delimited "${fb_data}/social_capital_county.csv", replace 

* ZIP Code-level dataset 
import delimited "https://data.humdata.org/dataset/85ee8e10-0c66-4635-b997-79b6fad44c71/resource/ab878625-279b-4bef-a2b3-c132168d536e/download/social_capital_zip.csv", clear 
export delimited "${fb_data}/social_capital_zip.csv", replace 

* High school dataset 
import delimited "https://data.humdata.org/dataset/85ee8e10-0c66-4635-b997-79b6fad44c71/resource/0de85271-031d-4849-bda8-c8582a67e11b/download/social_capital_high_school.csv", clear 
export delimited "${fb_data}/social_capital_high_school.csv", replace 

* College dataset 
import delimited "https://data.humdata.org/dataset/85ee8e10-0c66-4635-b997-79b6fad44c71/resource/7bd697cf-c572-47a6-b15b-8450cc5c7ef8/download/social_capital_college.csv", clear 
export delimited "${fb_data}/social_capital_college.csv", replace


********************************************************************************
**# 2. Stata graph styles
********************************************************************************

grstyle init

* background color 
grstyle color background white

* graph size
grstyle graphsize y 5
grstyle graphsize x 8

* legend options
grstyle linestyle legend none

* axis options
grstyle color axis_title gs5
grstyle gsize axis_title 3.7
grstyle color axisline gs5
grstyle gsize axis_title_gap tiny
grstyle linewidth axisline medium

* symbols
grstyle symbolsize p medsmall
grstyle linewidth p	medthick

* tick options
grstyle color tick gs5
grstyle color tick_label gs5
grstyle gsize tick_label 3.7
grstyle anglestyle vertical_tick 0
grstyle linewidth tick medium

grstyle color key_label gs5

grstyle margin graph "2 2 5 7"


********************************************************************************
**# 3. Execute do files for Paper 1
********************************************************************************

* Main Tables
do "${paper1_code}/Tables/Main_Table_1.do"
do "${paper1_code}/Tables/Main_Table_2.do"

* Main Figures
* Note: Main Figure 1 cannot be replicated with public data. Use our data exploration tool at https://socialcapital.org to recreate Main Figure 2.
do "${paper1_code}/Figures/Main_Figure_3.do"
do "${paper1_code}/Figures/Main_Figure_4.do"
do "${paper1_code}/Figures/Main_Figure_5.do"
do "${paper1_code}/Figures/Main_Figure_6.do"


* Extended Data Tables
* Note: Extended Data Tables 1 and 4 cannot be replicated with public data 
do "${paper1_code}/Tables/Extended Data_Table_2.do"
do "${paper1_code}/Tables/Extended Data_Table_3.do"

* Extended Data Figures 
* Note: Extended Data Figures 2 and 6 cannot be replicated with public data. Use our data exploration tool at https://socialcapital.org to recreate Extended Data Figure 1.
do "${paper1_code}/Figures/Extended Data_Figure_3.do"
do "${paper1_code}/Figures/Extended Data_Figure_4.do"
do "${paper1_code}/Figures/Extended Data_Figure_5.do"


* Supplementary Tables
* Note: When restricted to the set of social capital measures that we publicly release, Supplementary Table 1 is the same as Main Table 1. Supplementary Table 5 cannot be replicated with public data.
do "${paper1_code}/Tables/Supplementary_Table_2.do"
do "${paper1_code}/Tables/Supplementary_Table_3.do"

* Supplementary Figures
* Note: Supplementary Figures 1; 12; 13; 14; and 15 cannot be replicated with public data. Use our data exploration tool at https://socialcapital.org to recreate Supplementary Figure 5A.
do "${paper1_code}/Figures/Supplementary_Figure_2.do"
do "${paper1_code}/Figures/Supplementary_Figure_3.do"
do "${paper1_code}/Figures/Supplementary_Figure_4.do"
do "${paper1_code}/Figures/Supplementary_Figure_5.do"
do "${paper1_code}/Figures/Supplementary_Figure_6.do"
do "${paper1_code}/Figures/Supplementary_Figure_7.do"
do "${paper1_code}/Figures/Supplementary_Figure_8.do"
do "${paper1_code}/Figures/Supplementary_Figure_9.do"
do "${paper1_code}/Figures/Supplementary_Figure_10.do"
do "${paper1_code}/Figures/Supplementary_Figure_11.do"
do "${paper1_code}/Figures/Supplementary_Figure_16.do"


********************************************************************************

* Remove custom scheme 
grstyle clear, erase

* Remove R tempfiles 
cap erase "${paper1_code}/Rplots.pdf"
cap erase "${paper1_figs}/.Rhistory"
