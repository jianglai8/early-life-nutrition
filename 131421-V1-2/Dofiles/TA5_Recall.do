*-----------------------------------------------------------------------------
*RECALL OF INFORMATION 2
*-----------------------------------------------------------------------------

*created by: lucy kraftman
*first created: 02/04/19


*----------------------------------------------------------------------------*
* 									SETUP									 *
*----------------------------------------------------------------------------*


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


*----------------------------------------------------------------------------*
*						CLEAN
*----------------------------------------------------------------------------*
rename mq10d_02_* mposter_*
rename mq10d_05_* mradio_*
rename mq10d_08_* mhtalk_*
rename mq10e_03_* msmall_*
rename mq10e_09_* mcouns_*

local vars poster radio small couns htalk
global pers "m w"
foreach var of local vars {
foreach x in $pers {
label var `x'`var'_1  "KM1 Exclusive Breastfeeding"
label var `x'`var'_2 "KM2 Breastfeed Immediately"
label var `x'`var'_3  "KM3 Complimentary Foods"
label var `x'`var'_4 "KM4 Hygiene and Sanitation"
label var `x'`var'_5 "KM5 Use Health Facilities"
label var `x'`var'_6 "KM6 Attend Antenatal Care"
label var `x'`var'_7 "KM7 Additional Meal in Preg"
label var `x'`var'_8 "KM8 Nutritious Food"
label var `x'`var'_9 "No KM Mentioned"
}
}

global poster "poster_1 poster_2 poster_3 poster_4 poster_5 poster_6 poster_7 poster_8 poster_9 "
global radio "radio_1 radio_2 radio_3 radio_4 radio_5 radio_6 radio_7 radio_8 radio_9 "
global small "small_1 small_2 small_3 small_4 small_5 small_6 small_7 small_8 small_9 "
global couns "couns_1 couns_2 couns_3 couns_4 couns_5 couns_6 couns_7 couns_8 couns_9"
global htalk "htalk_1 htalk_2 htalk_3 htalk_4 htalk_5 htalk_6 htalk_7 htalk_8 htalk_9"

foreach var in $poster $radio $small $couns $htalk {
rename w`var' `var'1
rename m`var' `var'2
}

bys hh_id2: carryforward poster* radio* small* couns* htalk* , replace


drop wkm*

foreach x in 1 2 { 
foreach num in 1 2 3 4 5 6 7 8 9 {
egen km`num'`x' = rowtotal(poster_`num'`x' radio_`num'`x' htalk_`num'`x'), missing
replace km`num'`x' = 1 if km`num'`x' >= 1 & km`num'`x' !=.
}
egen kms`x' = rowtotal(km1`x' km2`x' km3`x' km4`x' km5`x' km6`x' km7`x' km8`x'), missing
gen atleast1kms`x' = 1 if kms`x' >= 1 & kms`x'!=.
replace atleast1kms`x' = 0 if kms`x'==0
gen allkms`x' = 1 if kms`x'>=8 & kms`x'!=.
replace allkms`x' = 0 if kms`x' <8
gen nonekms`x' = 1 if kms`x'==0
replace nonekms`x' = 0 if kms`x' > 0 & kms`x'!=.
}


foreach x in 1 2 {
foreach num in 1 2 3 4 5 6 7 8 9 {
egen hkm`num'`x' = rowtotal(couns_`num'`x' small_`num'`x'), missing
replace hkm`num'`x' = 1 if hkm`num'`x' >= 1 & hkm`num'`x' !=.
}
egen hkms`x' = rowtotal(hkm1`x' hkm2`x' hkm3`x' hkm4`x' hkm5`x' hkm6`x' hkm7`x' hkm8`x'), missing
gen atleast1hkms`x'= 1 if hkms`x' >= 1 & hkms`x'!=.
replace atleast1hkms`x'= 0 if hkms`x'==0
gen allhkms`x' = 1 if hkms`x'>=8 & hkms`x'!=.
replace allhkms`x' = 0 if hkms`x' <8
gen nonehkms`x' = 1 if hkms`x'==0
replace nonehkms`x' = 0 if hkms`x' > 0 & hkms`x'!=.
}

rename kms1 numkms1
rename kms2 numkms2
rename hkms1 numhkms1
rename hkms2 numhkms2

/* MAKE TABLE */

global A "allkms atleast1kms nonekms numkms km1 km2 km3 km4 km5 km6 km7 km8"
global B "allhkms atleast1hkms nonehkms numhkms hkm1 hkm2 hkm3 hkm4 hkm5 hkm6 hkm7 hkm8"

keep *kms* hkm* km* hh_id2 wave hi treat treatp pregbl lga_id tranche PSU li_no hi_no cash_ml

reshape long allkms atleast1kms nonekms numkms km1 km2 km3 km4 km5 km6 km7 km8 allhkms atleast1hkms nonehkms numhkms hkm1 hkm2 hkm3 hkm4 hkm5 hkm6 hkm7 hkm8, i(hh_id2 wave) j(gender)

bys hh_id2: carryforward $A, replace


	lab var allkms		"All"
	lab var atleast1kms		"At least one"
	lab var nonekms		"None"
	lab var numkms		"Number"

lab var km1 	"1 Exclusive Breastfeeding"
label var km2 "2 Breastfeed Immediately"
label var km3  "3 Complimentary Foods"
label var km4 "4 Hygiene and Sanitation"
label var km5 "5 Use Health Facilities"
label var km6 "6 Attend Antenatal Care"
label var km7 "7 Additional Meal in Preg"
label var km8 "8 Nutritious Food"



* PRODUCE TABLE

keep if wave==2
keep if pregbl==1
quietly foreach v in mean_1  mean_2 mean_3 t_stat df p_value_t1 p_value_t2 p_value mean_4  mean_5 mean_6 t_statb p_value_t1b p_value_t2b p_value_b p_value_c p_value1 p_value2 {
gen double `v' = .
}
quietly foreach v in varname varlabel {
gen `v' = ""
}

* panel a.
local panel "A"
foreach x in `panel' {
local i = 0 
foreach var in $`x'  {
ttest `var' if gender==1, by(treatp)
ret li
local i = `i' + 1
replace varname = "`var´" in `i'
replace varlabel =  `"`: var label `var''"' in `i'
replace mean_1 = r(mu_1) in `i'
replace mean_2 = r(mu_2) in `i'
reg `var' treatp i.lga_id i.tranche if gender==1, cluster(PSU)
return li
mat li r(table) 
gen double `var'`i'w = _b[treatp] / _se[treatp]
replace p_value = 2*normal(-abs(`var'`i'w)) in `i'
/*husbands*/
ttest `var' if gender==2, by(treatp)
ret li
replace mean_3 = r(mu_1) in `i'
replace mean_4 = r(mu_2) in `i'
reg `var' treatp i.lga_id i.tranche if gender==2, cluster(PSU)
return li
mat li r(table) 
gen double `var'`i'm = _b[treatp] / _se[treatp]
replace p_value_b = 2*normal(-abs(`var'`i'm)) in `i'
/*between h and m */
reg `var' gender i.lga_id i.tranche if treatp==0, cluster(PSU)
return li
mat li r(table) 
gen double `var'`i'a =  _b[gender] / _se[gender]
replace p_value_c = 2*normal(-abs(`var'`i'a)) in `i'
reg `var' gender i.lga_id i.tranche if treatp==1, cluster(PSU)
return li
mat li r(table) 
gen double `var'`i'b = _b[gender] / _se[gender]
replace p_value1 = 2*normal(-abs(`var'`i'b)) in `i'
}


if "`x'"=="A" local add using "$tables/Recall_detail.csv" , delimit(",") replace   head(,,Women,,Husband,,"Women V Husband", ,Control,T,C-T,Control,T,C-T,C,T ,Mean(SD),Mean(SD),P-Value,Mean(SD),Mean(SD),P-Value,P-Value,P-Value "Panel `x': Low-intensity channels ") 
if "`x'"=="B" local add , appendto("$tables/Recall_detail.csv") delimit(",")  head("Panel `x': High-intensity channels") 

format mean_* %3.2f
format df %12.3f
format p_value* %12.3f
char mean_1[varname] "Control Mean"
char mean_2[varname] "T Mean"
char mean_3[varname] "Control Mean"
char mean_4[varname] "T Mean"
char df[varname] "Dif"
char varlabel[varname] " "
list varlabel mean_1 mean_2 p_value mean_3 mean_4 p_value_b p_value_c p_value1 in 1/`i' , noobs sep(0) subvarname table
listtab varlabel mean_1 mean_2 p_value mean_3 mean_4 p_value_b p_value_c p_value1   in 1/`i' `add'
}


