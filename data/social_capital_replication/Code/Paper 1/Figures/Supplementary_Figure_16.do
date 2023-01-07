********************************************************************************
** This do file replicates Supplementary Figure 16: Proportion of Friendships by SES Percentile Rank
********************************************************************************

clear all

********************************************************************************
**# 1. Panel B: Proportion of Friends by SES Percentile Rank for Individuals in the Upper Tail
********************************************************************************

* Import 100 x 100 friendship matrix datast 
import delimited "${fb_data}/100_x_100_friendship_matrix.csv", clear

* Zoom in on the 90th; 95th; and 100th own-SES percentiles 
keep if inlist(own_ses_percentile, 90, 95, 100)

* Reshape to plot proportion of friends against friends' SES rank 
reshape long friend_prob_p, i(own_ses_percentile) j(friend_ses_percentile)

* Rescale proportion of friends to range from 0 to 100
replace friend_prob_p = friend_prob_p * 100


* Scatterplot, separately for each own-SES percentile but displayed on the same graph 
scatter friend_prob_p friend_ses_percentile if own_ses_percentile == 90, msize(0.5) mcolor(eltblue) || ///
scatter friend_prob_p friend_ses_percentile if own_ses_percentile == 95, msize(0.5) mcolor(sand) || ///
scatter friend_prob_p friend_ses_percentile if own_ses_percentile == 100, msize(0.5) mcolor(navy) ///
///
legend(label(1 "Individuals at 90th SES percentile") label(2 "Individuals at 95th SES percentile") label(3 "Individuals at 100th SES percentile") size(small)) ///
ylabel(, nogrid labsize(small)) xlabel(, labsize(small)) /// 
ytitle("Percentage of Friends", size(small)) xtitle("Friends' SES Percentile Rank", size(small)) ///
title("{bf:Proportion of Friendships by SES Percentile Rank}" " " "{it:B. Proportion of Friends by SES Percentile Rank for Individuals in the Upper Tail}" " ", size(small) span)

graph export "${paper1_figs}/Supplementary_Figure_16b.pdf", replace