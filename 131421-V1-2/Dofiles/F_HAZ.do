
*-----------------------------
* ANTRHO 
*-----------------------------

set more off
set mem 800m

*** SET FOLDER PATH IF NEEDED 
/*
		if c(username)=="lucy_k"{
		global main "/Users/lucy_k/Dropbox/IFS/CDGP_analysis/15 paper_lk"
	}
	
	global data "$main/Data"
	global graphs "$main/Output/Graphs"
	global tables "$main/Output/Tables/Effects"
	global do "$main/Do Files"
*/


use "$data/final_lk", clear

/* keep only CDGP child pregnant at baseline */
keep if pregbl == 1


*-----------------------------
* clean
*-----------------------------


/* replace height and weight to missing if HAZ not calculated (out of range) */
local child "nc ec"
foreach c of local child {
replace `c'_height = . if `c'_haz_who==.
replace `c'_weight = . if `c'_haz_who==.

lab var NC_age 			"Age in months"
lab var `c'_height 		"Height (cm)"
lab var `c'_weight 		"Weight (cm)"
lab var `c'_bmiz 		"BMI-for-age Z-score"
lab var `c'_haz_who 		"Height-for-Age (HAZ)"
lab var `c'_stn_who 		"% who are classed as Stunted (HAZ < -2)"
lab var `c'_sstn_who 	"% who are classed as Severely Stunted (HAZ < -3)"
lab var `c'_waz_who 		"Weight-for-Age (WAZ)"
lab var `c'_uwt_who 		"% who are classed as Underweight (WAZ < -2)"
lab var `c'_suwt_who 	"% who are classed as Severely Underweight (WAZ < -3)"
lab var `c'_whz_who 		"Height-for-Weight (WHZ)"
lab var `c'_wst_who 		"% who are classed as Wasted (WHZ < -2)"
lab var `c'_swst_who 	"% who are classed as Severely Wasted (WHZ < -3)"
lab var `c'_muac 		"Middle Upper Arm Circ. (MUAC)"
lab var `c'_maln 		"% who are classed as Malnourished (MUAC < 125)"
lab var `c'_smaln 		"% who are classed as Severely Malnourished (MUAC < 115)"
}


local ncvars 	nc_haz_who nc_stn_who nc_sstn_who 	nc_waz_who nc_uwt_who nc_suwt_who 	nc_whz_who nc_wst_who nc_swst_who	nc_muac nc_maln nc_smaln

				/* make percent */
				
				
	
*-----------------------------
* graphs
*-----------------------------

* raw

cdfplot nc_haz_who if wave==3 , by(treatp)  xline(-2, lpattern(dash)) ///
		opt1(lpattern(dash)) ///
		legend(label(1 "Control") label(2 "Treated") region(lwidth(none)) tstyle(body) ring(0) position(10) rows(1)) ///
		graphregion(color(white)) bgcolor(white) 
		graph export "$graphs/haz_w3_cdf.eps", replace 
		
cdfplot oc_haz_who if wave==2  , by(treatp) xline(-2, lpattern(dash)) ///
		opt1(lpattern(dash)) ///
		legend(label(1 "Control") label(2 "Treated") region(lwidth(none)) tstyle(body) ring(0) position(10) rows(1)) ///
		graphregion(color(white)) bgcolor(white) 
		graph export "$graphs/haz_oc_w2_cdf.eps", replace 
		
		
lpoly oc_haz_who oc_age if wave==1 & oc_age < 60 & oc_age > 10, ci noscatter ///
ytitle(Height-for-Age (Z)) xtitle(Age in Months) ylabel(-3(.5)-.5) graphregion(color(white)) bgcolor(white) title("") legend(off) 
graph export "$graphs/anthro_oc.eps", replace


		