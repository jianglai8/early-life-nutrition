*-----------------------------
* BITS OF ANALYSIS FOR IRR
*-----------------------------

/*
*** SET FOLDER PATH IF NEEDED 
		if c(username)=="lucy_k"{
		global main "/Users/lucy_k/Dropbox/IFS/CDGP_analysis/15 paper_lk"
		}
	
	
	global data "$main/data"
	global graphs "$main/Output/Graphs"
	global tables "$main/Output/Tables"
*/

use "$data/final_lk", clear

*-----------------------------
* age earning profile
*-----------------------------
rename hrq1_08_iw hrq1_08_iww 
rename hrq1_08_iwh hrq1_08_iwm
rename wq3a_01 wq2a_01

foreach x in w m {
gen `x'age = 1 if hrq1_08_iw`x' <= 25
replace `x'age = 2 if hrq1_08_iw`x' > 25 & hrq1_08_iw`x' <= 35
replace `x'age = 3 if hrq1_08_iw`x' > 35 & hrq1_08_iw`x' <= 45
replace `x'age = 4 if hrq1_08_iw`x' > 45 & hrq1_08_iw`x' <= 55
replace `x'age = 5 if hrq1_08_iw`x' > 55 & hrq1_08_iw`x' <= 65
replace `x'age = 6 if hrq1_08_iw`x' > 65 & hrq1_08_iw`x' !=.

local num = 1
foreach var in `x'earnings `x'q2a_01 {
reg `var' i.`x'age
eststo s`num'
}
local num = `num' + 1
}

*** these results produced are the numbers used in the first sheet in the excel file 'IRR_v2'
esttab using "$main/Output/Excel Files/ForIRR.rtf", replace
*** USE THE INFO PRODUCED IN EXCEL SPREADSHEET


