*-----------------------------------------------------------------------------
*Balance tests
*-----------------------------------------------------------------------------

*created by: lucy kraftman
*first created: 04/03/19


*----------------------------------------------------------------------------*
* 									SETUP									 *
*----------------------------------------------------------------------------*


*** SET FOLDER PATH IF NEEDED 

/*
		if c(username)=="lucy_k"{
		global main 
		}
		
*/

	global data "$main/data"
	global tables "$main/Output/Tables"



*---------------------------------------------------------------------------*
* MERGE ADDITIONAL VARS
*---------------------------------------------------------------------------*

use "$data/BMEL_childroster", clear
bys hh_id2: egen spacing_ave = mean(spacing)
bys hh_id2: gen count = _n
keep if count==1
keep hh_id2 spacing_ave
merge 1:m hh_id2 using  "$data/final_lk"
drop _merge
merge m:1 vill_id wave using "$data/BMEL_COMM_final"
drop _merge

*---------------------------------------------------------------------------*
* NECESSARY CLEANING
*---------------------------------------------------------------------------*
/* keep baseline and pregnant at baseline */
keep if wave==1
keep if pregbl==1


/* ppi by village */
bys vill_id: egen ave_ppi = mean(PPI)
label var ave_ppi "Average PPI (0-100) in village"

/* ppi within village */
bys vill_id: egen var_ppi = var(PPI)
label var var_ppi "Variance of PPI within village"

/* gini coefficient */
gen gini = .
tostring vill_id, replace
encode vill_id, gen (vill)
ineqdeco PPI, by(vill)

forval num = 1/210 {
replace gini = r(gini_`num') if vill == `num'
}

label var gini "Village level Gini Coefficient"


/* label poverty line */
label var poor "Below $1.90 per day"

/* generate totla number of children */

gen nchild = nchild02 + nchild35 + nchild612 + nchild1317
label var nchild "Number children below 18"


* labels */
label var m_hf "HF is best place to deliver Baby"
label var w_hf "HF is best place to deliver Baby"
label var exclusive_6months "Breastfeed exclusively for 6 months"
label var w_immediate "Breastfeed Immediately"
label var m_immediate "Breastfeed Immediately"

drop ociycf15


/* number of obs */
destring vill_id, replace
foreach x in IW_ID  IWH_ID hh_id2 OC_ID NC_ID {
gen c_`x' =.
 sum `x' if treatp==0
replace c_`x' = r(N) if treatp == 0
sum `x' if treatp == 1
replace c_`x' = r(N) if treatp == 1
label var c_`x' "Observations"
}


bys vill_id: gen c = _n
gen c0 = 1 if c == 1 & treatp==0
gen c1 = 1 if c == 1 & treatp==1
gen c_vill_id = sum(c0) if treatp==0
replace c_vill_id = sum(c1) if treatp==1

/* globals */
global Household "c_hh_id2 hhsize nchild totfoodexp_musd foodshare poor totpayusd fprob  hhownany "
global Community "c_vill_id cq1_01_natural cq1_01_manmade mktdist hfdist"
global Women " c_IW_ID hrq1_08_iw   hrq1_12_iw  wpolyg_blv  wq3a_01 wpaytot2usd wactfreq3 "
global Husband " c_IWH_ID hrq1_08_iwh  hrq1_12_iwh mq2a_01  mpaytot2usd mactfreq1"
global W_Knowledge " w_hf exclusive_6months"
global H_Knowledge "m_hf m_exclusive_6months"
global OldChild "c_OC_ID oc_age spacing_ave ociycf1 ociycf11 ocq1b_05 ocq1b_09 ocq1b_10 oc_stn_who oc_wst_who"
global NewChild "qw_11_iw"


/* check if dummy to report SD */
gen dummy =.
foreach var in $Household $Community $Women $W_Knowledge $Husband $H_Knowledge $OldChild {
qui su `var'		
	if (inlist(r(max),0,1)) 	replace dummy=1
	if (!inlist(r(max),0,1)) 	replace dummy=0
	}
	
*---------------------------------------------------------------------------*
* BALANCE TESTS 
*---------------------------------------------------------------------------*

* TABLE 1 : HH AND COMMUNITY *
local i = 0

quietly foreach v in mean_1 sd_1 mean_2 sd_2 df t_stat p_value {
gen double `v' = .
}
quietly foreach v in varname varlabel {
gen `v' = ""
}

preserve
bys vill_id: gen count= _n
keep if count==1
global panel " Community"
foreach x in $panel {
local i = 0 
foreach var in $`x'  {
ttest `var', by(treatp)
ret li
local i = `i' + 1
replace varname = "`var´" in `i'
replace varlabel =  `"`: var label `var''"' in `i'
replace mean_1 = r(mu_1) in `i'
replace mean_2 = r(mu_2) in `i'
reg `var' treatp i.lga_id i.tranche, cluster(PSU)
return li
mat li r(table) 
gen double `var'`i' = _b[treatp] / _se[treatp]
replace p_value = 2*normal(-abs(`var'`i')) in `i'
local i = `i' + 1 
replace varname = "" in `i'
replace varlabel =  "" in `i'
ttest `var', by(treatp)
replace mean_1 = r(sd_1) in `i'
replace mean_2 = r(sd_2) in `i'

}



format mean_* %9.3f
format sd_* %9.3f
format df %9.3f
format p_value %9.3f
char mean_1[varname] "Control Mean"
char mean_2[varname] "T Mean"
char df[varname] "Dif"
char p_value[varname] "P-value T-C"
char varlabel[varname] " "
list varlabel mean_1 mean_2 p_value  in 1/`i' , noobs sep(0) subvarname table


listtab varlabel mean_1  mean_2  p_value  in 1/`i' using "$tables/Balance.csv" , ///
delimit(",") replace ///
head(,Control,T,P-value, ,Mean(SD),Mean(SD),T-C, Panel:`x') 
}

restore

global panel " Household Women Husband"
foreach x in $panel {
local i = 0 
foreach var in $`x'  {
ttest `var', by(treatp)
ret li
local i = `i' + 1
replace varname = "`var´" in `i'
replace varlabel =  `"`: var label `var''"' in `i'
replace mean_1 = r(mu_1) in `i'
replace mean_2 = r(mu_2) in `i'
reg `var' treatp i.lga_id i.tranche, cluster(PSU)
return li
mat li r(table) 
gen double `var'`i' = _b[treatp] / _se[treatp]
replace p_value = 2*normal(-abs(`var'`i')) in `i'
local i = `i' + 1 
replace varname = "" in `i'
replace varlabel =  "" in `i'
ttest `var', by(treatp)
replace mean_1 = r(sd_1) in `i'
replace mean_2 = r(sd_2) in `i'

}
format mean_* %9.3f
format sd_* %9.3f
format df %9.3f
format p_value %9.3f
char mean_1[varname] "Control Mean"
char mean_2[varname] "T Mean"
char df[varname] "Dif"
char p_value[varname] "P-value T-C"
char varlabel[varname] " "
list varlabel mean_1 mean_2 p_value  in 1/`i' , noobs sep(0) subvarname table


listtab varlabel mean_1  mean_2  p_value  in 1/`i' , appendto("$tables/Balance.csv" ) ///
delimit(",") replace ///
head(Panel:`x') 

}


/* TABLE 2 : CHILDREN AND KNOWLEDGE ABOUT CHILDREN */


global panel " W_Knowledge"
foreach x in $panel {
local i = 0 
foreach var in $`x'  {
ttest `var', by(treatp)
ret li
local i = `i' + 1
replace varname = "`var´" in `i'
replace varlabel =  `"`: var label `var''"' in `i'
replace mean_1 = r(mu_1) in `i'
replace mean_2 = r(mu_2) in `i'
reg `var' treatp i.lga_id i.tranche, cluster(PSU)
return li
mat li r(table) 
gen double `var'`i' = _b[treatp] / _se[treatp]
replace p_value = 2*normal(-abs(`var'`i')) in `i'
local i = `i' + 1 
replace varname = "" in `i'
replace varlabel =  "" in `i'
ttest `var', by(treatp)
replace mean_1 = r(sd_1) in `i'
replace mean_2 = r(sd_2) in `i'


}

format mean_* %9.3f
format sd_* %9.3f
format df %9.3f
format p_value %9.3f
char mean_1[varname] "Control Mean"
char mean_2[varname] "T Mean"
char df[varname] "Dif"
char p_value[varname] "P-value T-C"
char varlabel[varname] " "
list varlabel mean_1 mean_2 p_value  in 1/`i' , noobs sep(0) subvarname table


listtab varlabel mean_1  mean_2  p_value  in 1/`i' using "$tables/Balance2.csv", ///
delimit(",") replace ///
head(,Control,T,P-value, ,Mean(SD),Mean(SD),T-C, Panel:`x') 

}

global panel "H_Knowledge OldChild NewChild"
foreach x in $panel {
local i = 0 
foreach var in $`x'  {
ttest `var', by(hi_no)
ret li
local i = `i' + 1
replace varname = "`var´" in `i'
replace varlabel =  `"`: var label `var''"' in `i'
replace mean_1 = r(mu_1) in `i'
replace mean_2 = r(mu_2) in `i'
reg `var' treatp i.lga_id i.tranche, cluster(PSU)
return li
mat li r(table) 
gen double `var'`i' = _b[treatp] / _se[treatp]
replace p_value = 2*normal(-abs(`var'`i')) in `i'
local i = `i' + 1 
replace varname = "" in `i'
replace varlabel =  "" in `i'
ttest `var', by(hi_no)
replace mean_1 = r(sd_1) in `i'
replace mean_2 = r(sd_2) in `i'

}

format mean_* %9.3f
format sd_* %9.3f
format df %9.3f
format p_value %9.3f
char mean_1[varname] "Control Mean"
char mean_2[varname] "T Mean"
char df[varname] "Dif"
char p_value[varname] "P-value T-C"
char varlabel[varname] " "
list varlabel mean_1 mean_2 p_value  in 1/`i' , noobs sep(0) subvarname table



listtab varlabel mean_1 mean_2 p_value in 1/`i', appendto("$tables/Balance2.csv")  ///
delimit(",") replace ///
head(Panel:`x') 
}



		
		