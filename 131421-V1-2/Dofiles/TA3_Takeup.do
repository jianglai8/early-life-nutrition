*-----------------------------------------------------------------------------
*TAKE UP 
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


foreach x in 1 2 {
recode wq12a_0`x' (98=.)
recode wq12a_0`x' (2=0)
recode wq12a_0`x' (1=1)
}

foreach x in 1 2 {
recode mq10a_0`x' (98=.)
recode mq10a_0`x' (2=0)
recode mq10a_0`x' (1=1)
}


 replace payfrac_33 = 100*payfrac_33
 gen payfrac_33_ex = payfrac_33 if cash_ml ==1 | cash_el ==1
 label var payfrac_33_ex "Fraction of payments if exited"

 /* gen amount received per month */
gen pay_monthly =  totpdf_all_usd / numpaym
label var pay_monthly "Monthly transfer (deflated USD)"

/* age of NC with first payment */
gen age_nc_fp = datefp - NC_dob_ym
label var age_nc_fp "Age of NC at First Payment"

// cash reciepts

gen cash_ever = (cash_all!=1) if !inlist(cash_all,.,8,9,10,11,12,13)
gen cash_currml = cash_ml==2 if cash_ml!=.
gen cash_currel = cash_el==2 if cash_el!=.
bys hh_id2 (wave): carryforward cash_currml, replace
lab var cash_ever		"Ever received transfer"
lab var cash_currml		"Receiving transfer at ML"
lab var cash_currel		"Receiving transfer at EL"

gen cash_ever_ml = 1 if cash_ml==2 | cash_ml==1 & wave == 2
replace cash_ever_ml = 0 if cash_ml == 0 & wave==2
gen cash_ever_el = 1 if cash_el == 1 | cash_el == 2  & wave == 3
replace cash_ever_el = 0  if cash_el ==0 & wave == 3

gen paymonthlyml = pay_monthly if wave==2
gen paymonthlyel = pay_monthly if wave==3
bys hh_id2 (wave): carryforward paymonthlyml cash_ever_ml, replace

global A "cash_ever "
global B "age_nc_fp ncfp_prenatal ncfp_trim1 ncfp_trim2 ncfp_trim3 ncfp_mob ncfp_afterb"
global C "numpaym totpdf_all_usd cash_ever_ml cash_ever_el "


*----------------------------------------------------------------------------*
* 									TABLES 
*----------------------------------------------------------------------------*


/* POOLED RECEIVING AT ML / EL */
quietly foreach v in mean_1 sd_1 mean_2 sd_2  t_stat df p_value_t  {
gen double `v' = .
}
quietly foreach v in varname varlabel {
gen `v' = ""
}


foreach num in 0 1 {
preserve
keep if wave==3
* panel a.
local panel "A B C"
foreach x in `panel' {
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
replace p_value_t = 2*normal(-abs(`var'`i')) in `i'
local i = `i' + 1 
replace varname = "" in `i'
replace varlabel =  "" in `i'
ttest `var', by(treatp)
replace mean_1 = r(sd_1) in `i'
replace mean_2 = r(sd_2) in `i'
}

if "`x'"=="A" local add using "$tables/Takeup_pool.csv" , delimit(",") replace   head(,Control,Treated,,P-value, ,Mean(SD),Mean(SD),, "Panel: `x'") 
if "`x'"=="B" local add , appendto("$tables/Takeup_pool.csv") delimit(",")  head("Panel`x': Timing of First Transfer ") 
if "`x'"=="C" local add , appendto("$tables/Takeup_pool.csv") delimit(",")  head("Panel: `x'") 

format mean_* %12.3f
format sd_* %12.3f
format df %12.3f
format p_value_* %12.3f
char mean_1[varname] "Control Mean"
char mean_2[varname] "Treated Mean"

char df[varname] "Dif"
char p_value_t[varname] "P-value"
char varlabel[varname] " "
list varlabel mean_1 mean_2 p_value_t  in 1/`i' , noobs sep(0) subvarname table

listtab varlabel mean_1  mean_2    in 1/`i' `add'

}
restore
}

