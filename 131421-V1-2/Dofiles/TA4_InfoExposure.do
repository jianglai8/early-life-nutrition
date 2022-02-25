*-----------------------------------------------------------------------------
*EXPOSURE TO CHANNELS 
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

keep hh_id2 wave pregbl lga_id treatp tranche PSU treat hi hi_no li_no wlchan1 wlchan2 wlchan3 wlchan4 wlchan6 wlchan7try wlchan7 wlchan5 wlchan_lonum wlchan_lonone wlchan_loany wlchan_loall wlchan_hinum wlchan_hinone wlchan_hiall wlchan7avl mlchan1 mlchan2 mlchan3 mlchan4 mlchan6 mlchan7try mlchan7 mlchan_lonum mlchan_lonone mlchan_loany mlchan_loall mlchan_hinum mlchan_hinone mlchan_hiall mlchan7avl


global A "lchan_loany lchan_loall "
global B "lchan_hinone lchan_hiall lchan6 lchan7avl lchan7try lchan7"

foreach var in $A $B {
rename w`var' `var'1
rename m`var' `var'2
}

keep lchan* hh_id2 wave treatp pregbl lga_id tranche PSU
carryforward lchan*, replace

/* reshape long for tables */
reshape long lchan6 lchan7try lchan7 lchan_lonone lchan_loany lchan_loall lchan1 lchan2 lchan3 lchan4 lchan_hinone lchan_hiall lchan7avl, i(hh_id2 wave) j(gender)
*----------------------------------------------------------------------------*
* 									TABLES 
*----------------------------------------------------------------------------*

	lab var lchan1		"Posters"
	lab var lchan2		"Radio programme/ad"
	lab var lchan3		"Health talk"
	lab var lchan4		"Food demonstration"

	lab var lchan6		"Support group"
	lab var lchan7avl	"Says 1:1 counselling available in village"
	lab var lchan7try	"If yes: tried to obtain 1:1 counselling"
	lab var lchan7		"If yes: obtained 1:1 counselling"
	lab var lchan_lonone	"None"
	lab var lchan_loall		"All"
	lab var lchan_loany		"At least one"
	lab var lchan_hinone	"None"
	lab var lchan_hiall		"All"

preserve
keep if wave==3
keep if pregbl==1
quietly foreach v in mean_1  mean_2 mean_3 t_stat df p_value_t1 p_value_t2 p_value mean_4  mean_5 mean_6 t_statb p_value_t1b p_value_t2b p_value_b p_value_c p_value1 p_value2 {
gen double `v' = .
}
quietly foreach v in varname varlabel {
gen `v' = ""
}

* panel a.
local panel "A B"
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

if "`x'"=="A" local add using "$tables/Exposure.csv" , delimit(",") replace   head(,,Women,,Husband,,"Women V Husband", ,Control,T,C-T,Control,T,C-T,C,T ,Mean(SD),Mean(SD),,P-Value,Mean(SD),Mean(SD),P-Value,P-Value "Panel `x': Low-intensity channels ") 
if "`x'"=="B" local add , appendto("$tables/Exposure.csv") delimit(",")  head("Panel `x': High-intensity channels") 

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

restore

