**-------------------------------------------------------------------------------------------------------------
*** 	ESTIMATE RELATIVE PRICE OF LIVESTOCK FROM RENTS
*** 	
***-------------------------------------------------------------------------------------------------------------




*** SET FOLDER PATH IF NEEDED 

/*

set more off
set mem 800m
set maxvar 8000

		if c(username)=="lucy_k"{
		global main "/Users/lucy_k/Dropbox/IFS/CDGP_analysis/15 paper_lk"
	}
	
	global data "$main/Data"
	global graphs "$main/Output/Graphs"
	global tables "$main/Output/Tables/Effects"
	global do "$main/Do Files"
*/

/* define controls */

use "$data/final_lk", clear 



*----------------------------------------------------------*
* calculate price for one month of animal

local animalexp  animal_05_exppu animal_06_exppu animal_07_exppu animal_08_exppu 

efftab `animalexp' if pregbl==1, out("$tables/exp_animal_p.xlsx") title("Exp animal, preg") ///
				controls(i.lga_id i.tranche `allX') options(robust cluster(PSU)) ancova

*  baseline figures 

keep if wave==1
keep mq3_* treatp pregbl animal* xr

recode mq3_selrev* (9999998=.) (0=.)
local animalsell mq3_selrev_01 mq3_selrev_02 mq3_selrev_03 mq3_selrev_04 mq3_selrev_05 mq3_selrev_06 mq3_selrev_07 mq3_selrev_08 mq3_selrev_09 mq3_selrev_10 mq3_selrev_11 mq3_selrev_12 mq3_selrev_13
foreach var of local animalsell {
replace `var' = `var'*xr
}

estpost tabstat `animalexp' `animalsell', stat(N mean sd p50 p10 p90) column(statistics)
eststo s1
esttab s1 using "$tables/sumstats_livestock.csv" , replace ///
cells("count(fmt(0)) mean(fmt(3)) sd(fmt(3)) p10(fmt(3)) p50(fmt(3)) p90(fmt(3)) ") noobs nomtitle nonumber ///
varlabels (`e(labels)') label
