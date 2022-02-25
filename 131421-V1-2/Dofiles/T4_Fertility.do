*-----------------------------------------------------------------------------
*NUMBER AND TIMING OF BIRTH
*-----------------------------------------------------------------------------

*created by: lucy kraftman
*first created: 05/04/19


*----------------------------------------------------------------------------*
* 									SETUP									 *
*----------------------------------------------------------------------------*


set more off
set mem 800m

/*
*** SET FOLDER PATH
		if c(username)=="lucy_k"{
		global main "/Users/lucy_k/Dropbox/IFS/CDGP_analysis/15 paper_lk"
	}
	
	global do "$main/Do Files"
	global data "$main/Data"
	global tables "$main/Output/Tables/Effects"

	*/
	


use "$data/final_lk", clear

*----------------------------------------------------------------------------*
*						CLEAN
*----------------------------------------------------------------------------*


// children who have died

egen numcdiedml = anycount(wncalv_o_1 wncalv_o_2 wncalv_o_3) if wave==2, values(2)
replace numcdiedml =. if wave!=2 | (wq4a_20 == . & wq4a_20_c==.)
gen anycdiedml = (numcdiedml>0) if numcdiedml!=.
lab var anycdiedml		"Any child born btw BL and ML died"
lab var numcdiedml		"Num childr born btw BL and ML who died"

egen numcdiedel = anycount(wncalv_o_1 wncalv_o_2 wncalv_o_3) if wave==3, values(2)
replace numcdiedel = . if wave!=3 | (wq4a_20 == . & wq4a_20_c==.)
gen anycdiedel = (numcdiedel>0) if numcdiedel!=.
lab var anycdiedel		"Any child born btw BL and EL died"
lab var numcdiedel		"Num childr born btw ML and EL who died"

gen agedeath1 = wncddn_o_1
replace agedeath1 = 0 if wncddm_o_1==1 & wncddm_o_1<=5
replace agedeath1 = 0.5 if wncddm_o_1 ==1 & wncddn_o_1 >5 & wncddn_o_1 <=21
replace agedeath1 = 1 if wncddm_o_1 ==1 & wncddn_o_1 > 21 & wncddn_o_1 <= 36
replace agedeath1 = 12 if wncddn_o_1 ==1 & wncddm_o_1== 3

gen anycless6mdied = 1 if agedeath1 < 6
replace anycless6mdied = 0 if agedeath1 >= 6 & agedeath1 !=. 
replace anycless6mdied = 0 if wncalv_o_1 == 1

// month of birth

gen NC_dob_ymb = NC_dob_ym if wave==2
lab var NC_dob_ymb		"Month of birth of ML child"

// birth space between ML and EL

gen birth_spacemlel = EC_dob_mdy - NC_dob_mdy  if EC_ID !=.
replace birth_spacemlel = birth_spacemlel/30.5 
label var birth_spacemlel "Number Months between birth of ML Child and EL Child"
gen birth_spacemlel_above2 = 1 if birth_spacemlel > 24 & birth_spacemlel !=.
replace birth_spacemlel_above2 = 0 if birth_spacemlel <=24

preserve
local tocoll "numcdied anycdied anync numnctot"
foreach v of local tocoll {
	gen `v'_mel = `v'ml if wave==2
	replace `v'_mel = `v'el if wave==3
}
gen tokeep = el_compl==1
keep hh_id2 tokeep  *_mel

collapse (sum) numc* numnctot* (max) anyc* anync*  tokeep, by(hh_id2)
drop if tokeep!=1
gen wave=3
tempfile totals
save `totals'
restore

merge 1:1 hh_id2 wave using `totals', nogen keep (1 3)

foreach var in agedeath1 anycless6mdied {
gen `var'ml = `var' if wave == 2
gen `var'el = `var' if wave == 3
}

lab var anyncml				"Any child born btw BL and ML"
lab var anyncel				"Any child born btw ML and EL"
lab var numnctotml			"Num childr born btw BL and ML"
lab var numnctotel			"Num childr born btw ML and EL"
lab var anync_mel			"Any child born btw BL and EL"
lab var numnctot_mel		"Num childr born btw BL and EL"
lab var anycdied_mel		"Any child born btw BL and EL died"
lab var numcdied_mel		"Num childr born btw BL and EL who died"
lab var agedeath1ml		"Age of death of child who died btw BL and ML"
lab var agedeath1el		"Age of death of child who died btw ML and EL"
lab var anycless6mdiedml		"Any child died under age 6 months btw BL and ML"
lab var anycless6mdiedel	"Any child died under age 6 months btw ML and EL"


/* months preg at baseline */
recode qw_11_iw (98=.)
bys hh_id2: gen preg_w1 = qw_11_iw if wave==1 
bys hh_id2: egen month_pregbl = mean(preg_w1) 
drop preg_w1


/* carry everything forward to EL */
sort hh_id2 wave
bysort hh_id2: carryforward anyncml numnctotml anycdiedml numcdiedml NC_dob_ymb agedeath1ml anycless6mdiedml, replace


* TABLE 4 FERTILITY
local vars 			anyncml anyncel numnctotml  numnctotel NC_dob_ymb  birth_spacemlel 						birth_spacemlel_above2 anycdiedml anycdiedel agedeath1ml 					agedeath1el anycless6mdiedml  anycless6mdiedel


#delimit ;

keep if wave == 3;

efftab `vars' if pregbl==1 , out("$tables/s7_fert_p.xlsx") title("Fertility, preg") 
				controls(i.lga_id i.tranche) options(robust cluster(PSU)) ancova;
