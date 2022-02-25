*-----------------------------------------------------------------------------
* DATA PREP FOR PAPER 
*-----------------------------------------------------------------------------

*created by: lucy kraftman
*first created: 08/03/19


*----------------------------------------------------------------------------*
* 									SETUP									 *
*----------------------------------------------------------------------------*
set more off
set mem 800m
set maxvar 8000
set matsize 11000


*** SET FOLDER PATH IF NEEDED 

	
		if c(username)=="lucy_k"{
		global main "/Users/lucy_k/Dropbox/IFS/CDGP_analysis/15 paper_lk"
	}
	

	
	global do "$main/Do Files"
	global data "$main/Data"
	global tables "$main/Output/Tables"
	
	
	

use "$data/BMEL_HH_final", clear 

merge m:1 vill_id wave using "$data/BMEL_COMM_final"

drop _merge

*---------------------------------
* ATTRITION CLEANING
*-----------------------------***

*--------------------------------*
* GENERAL 

/* attrition */
recode ml_attr el_attr (1=0) (2=1) (3=1) (4=1) 
bys hh_id2 (wave): carryforward ml_attr, replace

/* secure village */
gen insecvill_ml = 1 if insechh == 1 & wave==2
bys hh_id2: egen insec_ml = mean(insecvill_ml)
replace insec_ml = 0 if insec_ml ==.
drop insecvill_ml

gen insecvill_el = 1 if insechh == 1 & wave==3
bys hh_id2: egen insec_el = mean(insecvill_el)
replace insec_el = 0 if insec_el ==.
drop insecvill_el

recode hrq1_08_iw hrq1_08_iwh (98=.)

gen insec_ml_el = 1 if insec_ml==1 & insec_el==1
gen insec_ml_notel = 1 if insec_ml==1 & insec_el==0
gen insec_notml_el = 1 if insec_ml==0 & insec_el==1
gen insec_noml_noel = 1 if insec_ml==0 & insec_el==0
replace insec_ml_el = 0 if insec_ml_notel == 1 | insec_notml_el == 1 | insec_noml_noel == 1 
replace insec_ml_notel =0 if insec_ml_el == 1 | insec_notml_el == 1 | insec_noml_noel == 1 
replace insec_notml_el =0 if insec_ml_el == 1 | insec_ml_notel == 1 | insec_noml_noel == 1 

gen insec_dynamic = 1 if insec_noml_noel==1
replace insec_dynamic = 2 if insec_ml_notel == 1
replace insec_dynamic = 3 if insec_notml_el == 1
replace insec_dynamic = 4 if insec_ml_el == 1

label define insec 1 "Not Insecure at ML or EL" 2 "Insecure at ML, not EL" 3 "Insecure at EL, not ML" 4 "Insecure at ML and EL"
label values insec_dynamic insec

*---------------------------------------------------------------------------*
* WOMEN

/*women attrition */
global wave "ml el"

label define treat_name 0 "Control" 1 "T1" 2 "T2"
label values treat treat_name

label var insec_ml "Insecure ML"
label var insec_el "Insecure EL"
label var ml_attr "Mother Attrition ML"
label var el_attr "Mother Attrition EL"

*---------------------------------------------------------------------------*
* HUSBAND


/* woman attrited: if no interview was done, or if woman is not interviewed (e.g. dead) */
gen attr_ml_hus = (!inlist(ml_attr,0) |( husmode!="NORMAL" & husmode!="HEAD" )) if wave==2		/* hus */
gen attr_el_hus = (!inlist(el_attr,0) | (husmode!="NORMAL" & husmode!="HEAD") ) if wave==3		/* hus */
bys hh_id2: carryforward attr_ml_hus, replace
*---------------------------------------------------------------------------*
* CHILDREN

/* clean vars for oc attrition at bl and nc attrition at el */

/* oc response at ML */
gen ocavlml = (ocq1a_02!=.) if inlist(ml_compl,1,2)			/* use first question in OC questionnaire to establish if data is available */
gen ocavlbl = (OC_ID!=.) if wave==1
sort hh_id2 wave
bysort hh_id2: carryforward ocavlbl, replace
gen attr_ml_oc = (!inlist(ml_compl,1,2) | ocavlml!=1) 		if wave==2 & ocavlbl==1

/* nc at endline */	
gen ncavlel = (ncq1a_02!=.) if inlist(el_compl,1,2)			/* use first question in NC questionnaire to establish if data is available */
gen ncavlml = (NC_ID!=.) if wave==2
sort hh_id2 wave
bysort hh_id2: carryforward ncavlml, replace
gen attr_el_nc = (!inlist(el_compl,1,2) | ncavlel!=1) 		if wave==3 & ncavlml==1




*---------------------------------------------------------------------------*
* EXCHANGE RATE CALCS
*---------------------------------------------------------------------------*

sca ppp1_bl = 94.1585 
sca ppp1_ml = 120.2660 


*---------------------------------------------------------------------------*
*RURAL CPI CALCULATION
*---------------------------------------------------------------------------*

sca ppp2_bl = 99.4 
sca ppp2_ml = 127.552 

*---------------------------------------------------------------------------*
*CASH TAKEUP
*---------------------------------------------------------------------------*
drop phone
/* import resulting data */
merge m:1 hh_id2 using "$data/MIS_summary.dta"
/* convert to USD using 2014 RCPI-adjusted PPP */

*****************************************************************************
* clean baseline
*****************************************************************************

recode hrq1_08_iw~v  (96=.)


/****************************************************************************/
/* BCC EXPOSURE		 														*/
/****************************************************************************/

/* KEY MESSAGES --------------------------------------------------*/

/* rename variables */
rename wq12d_02_* wposter_*
rename wq12d_05_* wradio_*
rename wq12d_08_* whtalk_*
rename wq12d_14_* wsms_*
rename wq12e_03_* wsmall_*
rename wq12e_09_* wcouns_*

/* replace zeros when not exposed to channel */
forvalues m=1(1)9 {
	replace wposter_`m'=0 	if !inlist(wq12d_01,1,.)
	replace wradio_`m'=0 	if !inlist(wq12d_03,1,.)
	replace whtalk_`m'=0 	if !inlist(wq12d_06,1,.)
	replace wsms_`m'=0		if !inlist(wq12d_12,1,.)
	replace wsmall_`m'=0 	if !inlist(wq12e_01,1,.)
	replace wcouns_`m'=0 	if !inlist(wq12e_04,1,.)
	egen wkm`m' = anymatch(wposter_`m' wradio_`m' whtalk_`m' wsms_`m' wsmall_`m' wcouns_`m'), values(1)
	replace wkm`m' = . if wposter_`m'==.
}

lab var wkm1 "KM1 Exclusive Breastfeeding"
lab var wkm2 "KM2 Breastfeed Immediately"
lab var wkm3 "KM3 Complementary Foods"
lab var wkm4 "KM4 Hygiene and Sanitation"
lab var wkm5 "KM5 Use Health Facilities"
lab var wkm6 "KM6 Attend Antenatal Care"
lab var wkm7 "KM7 Additional Meal in Preg"
lab var wkm8 "KM8 Nutritious Food"
lab var wkm9 "No KM Mentioned"


/* CHANNELS --------------------------------------------------*/

lab def chnlab	1 "Posters" 2 "Radio"	3 "Health Talks"	4 "Food Demos"	5 "SMS/Calls"		6 "Group Meetings"	7 "One-to-One"
				
				
/* WOMEN exposure to each BCC channel */
recode wq12d_01	wq12d_03 wq12d_06 wq12d_09 wq12d_12	(2=0)
recode wq12e_01 wq12e_05 wq12e_07	(2=0)
replace wq12e_05=0 if inlist(wq12e_04,2,98)
replace wq12e_07=0 if wq12e_05==0

/* HUSBANDS exposure to each BCC channel */
recode mq10d_01	mq10d_03 mq10d_06 mq10d_09	(2=0)
recode mq10e_01 mq10e_05 mq10e_07	(2=0)
replace mq10e_05=0 if inlist(mq10e_04,2,98)
replace mq10e_07=0 if mq10e_05==0

/* LOW intensity channels ---------------------------------------------------*/
rename wq12d_01 wlchan1
rename wq12d_03 wlchan2
rename wq12d_06 wlchan3
rename wq12d_09 wlchan4
rename wq12d_12 wlchan5
rename mq10d_01 mlchan1
rename mq10d_03 mlchan2
rename mq10d_06 mlchan3
rename mq10d_09 mlchan4

/* none, all channels */
egen wlchan_lonum = rowtotal(wlchan1 wlchan2 wlchan3 wlchan4), mi
recode wlchan_lonum (0=1) (1/4=0), gen (wlchan_lonone)
recode wlchan_lonum (0=0) (1/4=1), gen (wlchan_loany)
recode wlchan_lonum (4=1) (0/4=0), gen (wlchan_loall)

egen mlchan_lonum = rowtotal(mlchan1 mlchan2 mlchan3 mlchan4), mi
recode mlchan_lonum (0=1) (1/4=0), gen (mlchan_lonone)
recode mlchan_lonum (0=0) (1/4=1), gen (mlchan_loany)
recode mlchan_lonum (4=1) (0/3=0), gen (mlchan_loall)


/* HIGH intensity channels --------------------------------------------------*/
rename wq12e_01 wlchan6
rename wq12e_07 wlchan7
rename mq10e_01 mlchan6
rename mq10e_07 mlchan7

/* none, all channels */
egen wlchan_hinum = rowtotal(wlchan6 wlchan7), mi
recode wlchan_hinum (0=1) (1/2=0), gen (wlchan_hinone)
recode wlchan_hinum (2=1) (0/1=0), gen (wlchan_hiall)

egen mlchan_hinum = rowtotal(mlchan6 mlchan7), mi
recode mlchan_hinum (0=1) (1/2=0), gen (mlchan_hinone)
recode mlchan_hinum (2=1) (0/1=0), gen (mlchan_hiall)

/* 1:1 available/tried accessing it */
recode wq12e_04 (2 98=0), gen(wlchan7avl)
rename wq12e_05 wlchan7try
replace wlchan7try 		= . if wlchan7avl!=1 /* sequential missingness */
replace wlchan7		 	= . if wlchan7try!=1

recode mq10e_04 (2 98=0), gen(mlchan7avl)
rename mq10e_05 mlchan7try
replace mlchan7try 		= . if mlchan7avl!=1	/* sequential missingness */
replace mlchan7		 	= . if mlchan7try!=1

/* LABELS */
local subj	"w m"
foreach	s of local subj {
	lab var `s'lchan1		"Posters"
	lab var `s'lchan2		"Radio programme/ad"
	lab var `s'lchan3		"Health talk"
	lab var `s'lchan4		"Food demonstration"
	cap lab var `s'lchan5		"Voice message"
	lab var `s'lchan6		"Support group"
	lab var `s'lchan7avl	"Says 1:1 counselling available in village"
	lab var `s'lchan7try	"If yes, tried to obtain 1:1 counselling"
	lab var `s'lchan7		"If yes, obtained 1:1 counselling"
	lab var `s'lchan_lonone		"None"
	lab var `s'lchan_loall		"All"
	lab var `s'lchan_loany		"At least one"
	lab var `s'lchan_hinone		"None"
	lab var `s'lchan_hiall		"All"
}

*---------------------------------------------------------------------------*
*HOUSEHOLD LEVEL OUTCOMES
*---------------------------------------------------------------------------*
/* age */
recode hrq1_08_iw hrq1_08_iwh (98=.) (96=.)

/* religion/ethnicity */

recode mq6a_02 (6=1) (1 2 4 7 8 9 10 14=0), gen(ethn_hausa) 
lab var ethn_hausa			"Hausa ethnicity" 
recode mq6a_01 (1=1) (2 3 4 7 9 11=0), gen(lang_hausa) 
lab var lang_hausa			"Hausa language" 
recode mq6a_03 (1=1) (2=0), gen(relig_islam) 
lab var relig_islam			"Islam religion" 


/* BORROWING */
recode mq5b_01_1-mq5b_01_3 mq5b_01_5-mq5b_01_8 (98=.) 
egen anyborr=rowtotal(mq5b_01_1-mq5b_01_3 mq5b_01_5-mq5b_01_8) , mi 
recode anyborr (1/max=1) 
replace anyborr=. if mq5b_01_1==. 
lab var anyborr			"Any household member borrowing money" 

gen anyborr_bank = (mq5b_01_1 == 1 | mq5b_01_2 == 1 | mq5b_01_3 == 1) if mq5b_01_1!=. 
lab var anyborr_bank	"\hspace{6pt} from bank, savings association, microfinance, or NGO" 
gen anyborr_friends = mq5b_01_5 
lab var anyborr_friends	"\hspace{6pt} from family members or friends" 
gen anyborr_other = (mq5b_01_6 == 1 | mq5b_01_7 == 1 | mq5b_01_8 == 1 | mq5b_01_9 == 1) if mq5b_01_1!=. 
lab var anyborr_other	"\hspace{6pt} from shop, landlord, moneylender, or other" 

gen totborr = mq5_totborr 
recode totborr (99999998=.) (9999998=.) 
su totborr, det 
replace totborr=. if !inrange(totborr, 1, r(p99)) 
replace totborr=0 if anyborr==0 
gen totborr0=totborr/1000 
gen totborr_usd=totborr*xr 
lab var totborr0			"Tot. value of borrowing '000NGN" 
lab var totborr_usd			"Tot. value of borrowing (PPP USD)" 

/* SAVINGS */
recode mq5c_01_* (98=.) 
egen anysav=anymatch(mq5c_01_*) , values(1) 
replace anysav=. if mq5c_01_1==. 
lab var anysav			"Any HH member saving money" 
gen anysav2 = anysav 
replace anysav2 =1 if mq5c_03==1 
lab var anysav2			"Any household member saving money (incl. in-kind)" 

gen anysav_bank = (mq5c_01_1 == 1 | mq5c_01_2 == 1 | mq5c_01_4 == 1) if mq5c_01_1!=. 
lab var anysav_bank		"\hspace{6pt} at bank, savings association, microfinance, or NGO" 
gen anysav_home	= mq5c_01_3 
lab var anysav_home		"\hspace{6pt} at home" 
gen anysav_inform = mq5c_01_5 
lab var anysav_inform	"\hspace{6pt} at informal savings group" 

recode mq5_totsav2 (99999998=.) (9999998=.), gen(totsav2) 
su totsav2, det 
replace totsav2=. if !inrange(totsav2, 1, r(p99)) 
replace totsav2=0 if anysav2==0 
gen totsav20=totsav2/1000 
gen totsav2_usd=totsav2*xr 
lab var totsav20		"Tot. value of savings (incl. in-kind) '000NGN" 
lab var totsav2_usd		"Tot. value of savings (incl. in-kind, PPP USD)" 

/* RELEVANT ASSETS -----------------------------------------------------------*/
gen mobile_own = mq6c_own_19 
lab var mobile_own			"Owns mobile phone" 
/* merge mobile phone coverage */
merge m:1 vill_id wave using "$data/BMEL_COMM_final", keepusing(cq5_01_any) keep(1 3) nogen 
rename cq5_01_any vill_mobcov 
lab var vill_mobcov			"Lives in village with mobile coverage" 

/* EXPENDITURE ---------------------------------------------------------------*/

drop totexp_m totexp_musd totexp_meq totexp_mequsd
/* recalculate total expenditure */
local exptype "m musd meq mequsd"
foreach t of local exptype {
	egen totexp_`t' = rowtotal(totfoodexp_`t' totnfexp_`t' totdurexp_`t') if totfoodexp_`t' !=. & totnfexp_`t' !=. , missing
	replace totexp_`t' = . if totexp_`t' == 0
	}
	

* calculate a monthly expenditure that does not include large one off expenditures
foreach var in mq4_02_1 mq4_02_2 mq4_02_3 mq4_02_4 mq4_02_5 mq4_02_6 mq4_02_7 mq4_02_8 mq4_02_9 mq4_02_10 mq4_02_11 mq4_04_1 mq4_04_2 mq4_04_3 mq4_04_4 mq4_04_5 mq4_04_6 mq4_04_7 mq4_04_8 mq4_04_9 mq4_04_10 mq4_04_11 mq4_04_12 mq4_04_13 {
recode `var' (99999998 =.)
gen month_`var' = `var'*4.2
}
foreach var in mq4_06_1 mq4_06_2 mq4_06_3 mq4_06_4 mq4_06_5 mq4_06_6 mq4_06_7 mq4_06_8 mq4_06_9 mq4_06_10 {
recode `var' (99999998 =.)
}

egen monthly_foodexp = rowtotal(month_mq4_04_*)
egen monthly_exp = rowtotal( month_mq4_02_*  month_mq4_04_*  mq4_06_* )
foreach var in monthly_foodexp monthly_exp {
replace `var' = . if `var' == 0
}
gen foodshare = monthly_foodexp / monthly_exp


lab var totfoodexp_m 		"Monthly food expenditure"  
lab var totnfexp_m 			"Monthly non-food expenditure"  
lab var totdurexp_m 		"Monthly durables expenditure"  
lab var totfoodexp_musd 	"Monthly food expenditure (USD PPP)"  
lab var totnfexp_musd 		"Monthly non-food expenditure (USD PPP)"  
lab var totdurexp_musd 		"Monthly durables expenditure (USD PPP)"  
lab var totfoodexp_meq 		"Monthly food expenditure (eq)"  
lab var totnfexp_meq 		"Monthly non-food expenditure (eq)"  
lab var totdurexp_meq 		"Monthly durables expenditure (eq)"  
lab var totfoodexp_mequsd 	"Monthly food expenditure (eq USD PPP)"  
lab var totnfexp_mequsd 	"Monthly non-food expenditure (eq USD PPP)"  
lab var totdurexp_mequsd	"Monthly durables expenditure (eq USD PPP)"  
lab var totexp_m			"Total monthly exp" 
lab var totexp_musd			"Total monthly exp (USD PPP)" 
lab var totexp_meq			"Total monthly exp (eq)" 
lab var totexp_mequsd		"Total monthly exp (eq USD PPP)" 
lab var foodshare "Share of expen on food"


/* WORK AND LAND ------------------------------------------------------------ */

/* woman land and crop sales */
recode wq2_01 (2 = 0) (98=.) 
gen wmnanycropsales = (wcropsales>0 & wcropsales!=.) if wq2_01!=. 
rename wcropsales wmncropsales 
replace wmncropsales=0 if wq2_07_1!=. & wmncropsales==.  /* to zero if cultivated crop but missing sales */
recode wmncropsales (99999998=.) 
su wmncropsales, det 
replace wmncropsales=. if wmncropsales>r(p99) 
replace wmncropsales = 0 if wq2_01==0 
replace wmncropsales = wmncropsales/12 					/* to monthly */
gen wmncropsalesusd = wmncropsales*xr 					/* to USD */
lab var wq2_01			"Cultivated land" 
lab var wmnanycropsales	"Sold any crops" 
lab var wmncropsales	"Monthly revenue from crops" 
lab var wmncropsalesusd	"Monthly revenue from crops (PPP USD)" 

/* woman work */
recode wq3a_01 (2 = 0) (98=.) 
gen wpaytot2 = wpaytot 
recode wpaytot2 (99999998=.) 
su wpaytot2, det 
replace wpaytot2 =.  if wpaytot2>r(p99) 
replace wpaytot2 = wpaytot2/7*30 						/* to monthly */
gen wpaytot2usd = wpaytot2*xr 							/* to USD */
lab var wq3a_01			"Any Work activity" 
lab var wpaytot2 		"Total Monthly Earnings" 
lab var wpaytot2usd 	"Total Monthly Earnings (PPP USD)" 

recode wq3_a_1 (2=1) (1 3=0), gen(wmainact_forhh) 
lab var wmainact_forhh	"Does main activity for herself or the household (not someone else)" 


/* man land and crop sales */
recode mq1_01 (2 = 0) (98=.) 
gen husanycropsales = (mcropsales>0 & mcropsales!=.) if mq1_01!=. 
rename mcropsales huscropsales 
replace huscropsales=0 if mq1_07_1!=. & huscropsales==.  /* to zero if cultivated crop but missing sales */
recode huscropsales (1/max=1), gen(huscropsalesany) 
su huscropsales, det 
replace huscropsales=. if huscropsales>r(p99) 
replace huscropsales = 0 if mq1_01==0 
replace huscropsales = huscropsales/12 					/* to monthly */
gen huscropsalesusd = huscropsales*xr 					/* to USD */
lab var mq1_01			"Cultivated land" 
lab var husanycropsales	"Sold any crops" 
lab var huscropsales	"Monthly revenue from crops" 
lab var huscropsalesusd	"Monthly revenue from crops (PPP USD)" 


/* woman work */
recode mq2a_01 (2 = 0) (98=.) 
gen mpaytot2 = mpaytot 
recode mpaytot2 (99999998=.) 
su mpaytot2, det 
replace mpaytot2 =.  if mpaytot2>r(p99) 
replace mpaytot2 = mpaytot2/7*30 						/* to monthly */
gen mpaytot2usd = mpaytot2*xr 							/* to USD */
lab var mq2a_01			"Any Work activity" 
lab var mpaytot2 		"Total Monthly Earnings" 
lab var mpaytot2usd 	"Total Monthly Earnings (PPP USD)" 

recode mq2_a_1 (2=1) (1 3=0), gen(mmainact_forhh) 
lab var mmainact_forhh	"Does main activity for himself or the household (not someone else)" 


/* total */
gen totpay =  mpaytot2 
replace totpay = totpay+ wpaytot2 if wpaytot2!=. 
lab var totpay 			"Husband + Woman Total Monthly Pay" 
gen totpayusd = totpay*xr 							/* to USD */
lab var totpayusd 		"Husband + Woman Total Monthly Pay (PPP USD)" 

/* labour supply */
recode whpayjobdays mhpayjobdays (98=.) 
replace whpayjobdays=0 if wq3a_01==0 
replace mhpayjobdays=0 if mq2a_01==0 
lab var whpayjobdays		"Days/week working (highest-earning activity)" 
lab var mhpayjobdays		"Days/week working (highest-earning activity)" 



local codes_agric 		"1 2 3 66 67"
local codes_selfemp 	" 36 42 61 62 63 64"
local codes_prof 		"47 48 49 65 "
local codes_other		"961"
local workcategs 	"agric selfemp prof other"
local mf 			"w m"

foreach p of local mf {
	foreach c of local workcategs {
		if ("`p'" == "w") gen `p'work_`c' = 0 if wq3a_01!=.
		if ("`p'" == "m") gen `p'work_`c' = 0 if mq2a_01!=.
		
		foreach i of local codes_`c' {
			replace `p'work_`c' = 1 if `p'actfreq`i'==1
		}
	}
}
lab var wwork_agric		"Has agricultural job"
lab var wwork_selfemp	"Has business/self-employment job"
lab var wwork_prof		"Has professional job"
gen wwork_anim = wactfreq3
replace wwork_anim = 0 if wq3a_01==0
lab var wwork_anim		"Reared/tended to animals"
lab var wwork_other		"Other type of work activity"

lab var mwork_agric		"Has agricultural job"
lab var mwork_selfemp	"Has business/self-employment job"
lab var mwork_prof		"Has professional job"
gen mwork_anim = mactfreq3
replace mwork_anim = 0 if mq2a_01==0
lab var mwork_anim		"Reared/tended to animals"
lab var mwork_other		"Other type of work activity"

/****************************************************************************/
/* HUSBAND			INCOME														*/
/****************************************************************************/
recode mq2a_01 (2 = 0) (98=.)		/* participation */

recode mpaytot2 (99999998=.)
utrim mpaytot2
replace mpaytot2 = mpaytot2/7*30
lab var mpaytot2 		"Husband Total Monthly Pay (trim p99, w0)"
gen lmpaytot2 = log(mpaytot2)
lab var lmpaytot2		"(log) Husband Monthly Pay (trim p99)"


utrim mtotrevenue
utrim mtotinpexp
gen mprofit = mtotrevenue - mtotinpexp
foreach v in mtotrevenue mtotinpexp mprofit {
	replace `v' = `v'/7*30
}
lab var mtotrevenue		"Revenue business (month)"
lab var mtotinpexp		"Input expenditure business (month)"
lab var mprofit			"Business profit (month)"

tabrrd, stub(mactfreq) cut(0.01) 	/* activities */

global  earnings mtotrevenue mtotinpexp mprofit mpaytot2
foreach v in $earnings {
	qui su `v', det
	replace `v'=. if `v' > r(p99)		/* trim */
	replace `v'= `v' *xr 				/* to USD */
}
/****************************************************************************/
/* WOMAN		INCOME															*/
/****************************************************************************/
recode wq3a_01 (2 = 0) (98=.)		/* participation */

recode wpaytot2 (99999998=.)
utrim wpaytot2
replace wpaytot2 = wpaytot2/7*30
lab var wpaytot2 		"Woman Total Monthly Pay (trim p99, w0)"
gen lwpaytot2 = log(wpaytot2)
lab var lwpaytot2		"(log) Woman Monthly Pay (trim p99)"


utrim wtotrevenue
utrim wtotinpexp
gen wprofit = wtotrevenue - wtotinpexp
foreach v in wtotrevenue wtotinpexp wprofit {
	replace `v' = `v'/7*30
}


tabrrd, stub(wactfreq) cut(0.01) 	/* activities */

/* convert to USD PPP */

global  earnings wtotrevenue wtotinpexp wprofit wpaytot2
foreach v in $earnings {
	qui su `v', det
	replace `v'=. if `v' > r(p99)		/* trim */
	replace `v'= `v' *xr 				/* to USD */
}

/****************************************************************************/
/* TOTAL		INCOME															*/
/****************************************************************************/
gen wearnings = wpaytot2 if wave==2 | wave==1
replace wearnings = wpaytot2 + wtotrevenue if wave==3
gen mearnings = mpaytot2 if  wave==2 | wave==1
replace mearnings = mpaytot2 + mtotrevenue if wave==3

label var wearnings "Earnings from Employment and Self Employment"
label var mearnings "Earnings from Employment and Self Employment"

gen totwmincome = wpaytot2
replace totwmincome = mpaytot2 + wpaytot2 if inlist(wave,1,2) & mpaytot2!=.
replace totwmincome = mprofit + mpaytot2 + wprofit + wpaytot2 if wave==3 & mpaytot2!=. & mprofit!=.
lab var totwmincome		"Total W+H income (month, profit + payments)"

gen totwmincome_grant = totwmincome
replace totwmincome_grant = totwmincome_grant + 4000*xr if cash_ml==2 & wave==2
replace totwmincome_grant = totwmincome_grant + 4000*xr if cash_el==2 & wave==3
lab var totwmincome_grant		"Total W+H income + grant (month, profit + payments)"


/* generate total implied income from what they spend save and borrow */

* translate savings and borrowing into flows
foreach var in sav2 borr {
gen `var'_bl = tot`var'_usd if wave==1
gen `var'_ml = tot`var'_usd if wave==2
gen `var'_el = tot`var'_usd if wave==3

foreach x in bl ml el {
bys hh_id2: egen tot`var'_`x' = mean(`var'_`x')
drop `var'_`x'
}
}

gen savstock_ml = (totsav2_ml - totsav2_bl)/25
gen savstock_el = (totsav2_el - totsav2_el)/23
gen borrstock_ml = (totborr_ml - totborr_bl)/25
gen borrstock_el = (totborr_el - totborr_ml)/23

gen savstock = savstock_ml if wave==2
replace savstock = savstock_el if wave==3

gen borrstock = borrstock_ml if wave==2
replace borrstock = borrstock_el if wave==3

* calculate implied income
gen totimpincome = totexp_musd + savstock - borrstock
replace totimpincome = totexp_musd + savstock - borrstock + wtotinpexp + mtotinpexp if wave==3 & wtotinpexp!=. & mtotinpexp!=.
replace totimpincome = totexp_musd + savstock - borrstock + mtotinpexp if wave == 3 & wtotinpexp==.
lab var totimpincome		"Total W+H implied income (month)"

gen totimpincome_grant = totimpincome
replace totimpincome_grant = totimpincome_grant + 3500*xr if cash_ml==2 & wave==2
replace totimpincome_grant = totimpincome_grant + 4000*xr if cash_el==2 & wave==3
lab var totimpincome_grant		"Total W+H implied income + grant (month)"

gen income_residual = totimpincome - wearnings - mearnings

/*
/* put to missing for ML (so EL only result) */
local tomissml		wpaytot2 lwpaytot2 wtotrevenue wtotinpexp wprofit
					mpaytot2 lmpaytot2 mtotrevenue mtotinpexp mprofit
					totwmincome totwmincome_grant;
foreach v of local  tomissml {;
	replace `v' = . if wave==2;
};
*/

* INSTEAD:  recognise they are different and don't compare the p-values but still show it 



/* FOOD SECURITY ------------------------------------------------------------ */
foreach v of varlist wq10bml_01_1 wq10bml_01_2 wq10bml_01_3 wq10bml_01_4 {
	recode `v' (2=1) (1=0), gen(`v'r)
	recode `v' (2=0) (98=.)
}


lab var wq10bml_01_1r	"during Kaka 2015 (MidOct 15 to Dec 15)"		
lab var wq10bml_01_2r	"during Sanyi (Dec 15 to Feb 16)"	
lab var wq10bml_01_3r	"during Rani (Mar 16 to May 16)"		
lab var wq10bml_01_4r	"during Damuna (Jun 16 to MidOct 16)"

lab var fprob			"in past year"
recode HHS (2/6=1) (0 1=0), gen(HHSh)
lab var HHSh			"Moderate/severe household hunger (past 30 days)"
lab var HHS				"Household hunger scale (past 30 days)"

lab var fprob			"Had not enough food in past 12 months"
recode wq10a_04 (2=0) (8 98 = .)
lab var	wq10a_04		"Had not enough food in past 30 days"
recode wq10a_10 (2=0) (8 98 = .)
lab var	wq10a_10		"Reduced number of meals in past 30 days"

/* recodes */ 
recode wq2_01 ocq1b_09 ocq1b_10 ocq1b_05 mq5c_03 wq3a_01 wq10a_04  wq10bbl_01_1 mq9b_01_1 mq9b_01_2 mq9b_07 wq7b_09  wq7b_07 wq10bbl_01_2 wq10bbl_01_3 wq10bbl_01_4 wq7b_01_1 wq7b_01_2 wq7b_05c_96 wq7b_05c_6 wq7b_05c_5  wq7b_05c_4  wq7b_05c_3  wq7b_05c_2  wq7b_05c_1  mq9b_09  wq7b_09 hrq1_14_iwh hrq1_12_iw  hrq1_12_iwh mq1_01 wq10bml_01_1 wq10bml_01_2 wq10bml_01_3 wq10bml_01_4 (2=0)(98=.)
recode  wq7b_02  wq7b_05 wq7b_06num~r  hrq1_08_iwh   mq9b_05 mq9b_06num~r  mq9b_06time  (98=.)
recode  wq7b_02 (96=.)
recode  wq7b_02 (2=0) (3=0) (4=0) (5=0) 
recode  mq9b_02 (2=0) (3=0) (4=0) (5=0) (98=.) (96=.)
recode  wq7b_05 mq9b_05 (2=0) (3=0) (4=0) (5=0) (6=0) (7=0) (96=.)
recode mq9b_06bwe~s (998=.)
recode  mq5b_01_9  (2=0)
recode qw_11_iw (98=.)
recode  mq9b_05c_1  (98=.) (2=0) 
recode  qw_02_iw (8=.)
recode wpolyg_blv (2=0)
/* make oc gender var */
gen oc_female = 1 if OC_gend ==2
replace oc_female=0 if OC_gend==1

label var oc_female "Female"

recode wq6a_05  (6 8=.)

recode wq6a_07  (6 8=.)

global borrow "mq5b_01_1 mq5b_01_3 mq5b_01_4 mq5b_01_5 mq5b_01_9 mq5b_01_8 mq5b_01_7 mq5b_01_6 mq5b_01_5 mq5b_01_4"

recode $borrow (98=.)
recode  mq5b_01_9  (2=0)

global bor "mq5b_01_1 mq5b_01_3 mq5b_01_4 mq5b_01_5  mq5b_01_6b  mq5b_01_6a mq5b_01_9 mq5b_01_8 mq5b_01_7 mq5b_01_6 mq5b_01_5 mq5b_01_4"

/* generate a variable that indicates if HH borrowed from any source */
gen borrow = 0
foreach v in $bor {
replace borrow = 1 if inlist(`v', 1)
}

/* household has any animals */
egen hhownany = rowtotal(mq3_anycowbull mq3_anycalf mq3_anysheep mq3_anygoat mq3_anycamel mq3_anydonk mq3_anychick mq3_anyguinea), mi
recode hhownany (1/max=1)
lab var hhownany		"HH Owns Any Animals"

label var borrow "Percent HH with any member borrowing"
label var wpolyg_blv "In a Polygamous Relationship"
label var wq3a_01 "WM: Paid/Unpaid Work in Past Year"
label var  wq6a_05 "WM has say in Major HH Purchases?"
label var wq6a_07 "WM has say in What Food to Buy?"
label var PPI "PPI Povery Score (0-100)"
label var  qw_02_iw "Rank of Spouse e.g. 1st/2nd/3rd Wife"
label var ocq1b_05 "Had Diarrhoea in Past 2w"
label var  OC_age "Age (Months)"
label var qw_11_iw "Women Months Pregnant"
label var mq2a_01 "Paid/Unpaid Work in Past Year"
label var cq1_01_natural "Natural Shock in Village in Past Year"
label var cq1_01_manmade "Man Made Shock in Village in Past Year"
label var mktdist "Distance to Closest Market (KM - Straight Line)"
label var hfdist "Distance to Closest Health Facility (KM - Straight Line)"
label var totpayusd "Total Monthly Pay (PPP USD)"
label var hrq1_08_iw "Age (Years)"
label var hrq1_14_iw "Ever Attended School"
label var hrq1_12_iw "Can Read/Write In At Least One Language"
label var wq3a_01 "Paid/Unpaid Work in Past Year"
label var hrq1_08_iwh "Age (Years)"
label var hrq1_14_iwh "Ever Attended School"
label var hrq1_12_iwh "Can Read/Write In At Least One Language"
label var mq2a_01 "Paid/Unpaid Work in Past Year"
label var ociycf1 "Child Put to the Breast Immediately"
label var ociycf11 "Appropriately Breastfed"
label var oc_stn_who "Stunted (HAZ<-2)" 
label var oc_wst_who "Wasted (WAZ<-2) "
label var ocASQcomm "OC ASQ Communication Skills"
label var borrow "Any household member borrowing money"

gen hi = 1 if treat == 2
replace hi = 0 if treat==1

gen hi_no = 1 if treat==2
replace hi_no = 0 if treat==0

gen li_no = 1 if treat==1
replace li_no = 0 if treat==0

/* create variable for total monthly income */
recode wq3a_01 (2=0)
recode mq2a_01 (2=0) (98=.)


/* SHOCKS */

recode cq1_01_* (2=0)

*-----------------------------------------
* pregnancy
*------------------------------------------

/* compute age at BL */

/* carry back to ML (including months pregnant at bl) */
gen monthspregbl = qw_11_iw
bysort hh_id2: carryforward  monthspregbl, replace
recode monthspregbl (98=.)
lab var monthspregbl 		"Months pregnant at BL"

******************************************************************
* CHILD OUTCOMES 
******************************************************************

*--------------------------------------------
* ANTHRO
*--------------------------------------------

local child oc nc ec wm
foreach c of local child {
foreach var in  height weight muac {
replace `c'_`var' =. if `c'_`var' >= 997
}
}


*-------------------------------------------
* ASQ 
*-------------------------------------------
gen ncASQtotal = ncASQcomm + ncASQmoto if wave==2
gen ocASQtotal = ocASQcomm + ocASQmoto if wave==2
replace ncASQtotal = ncASQcomm + ncASQmoto + ncASQpsoc if wave==3
gen ecASQtotal = ecASQcomm + ecASQmoto + ecASQpsoc if wave==3


local child "oc nc ec"
foreach c of local child {
foreach var in ASQtotal ASQcomm ASQmoto  {
egen `c'`var'_mean = mean(`c'`var') , by(wave) 
egen `c'`var'_std = sd(`c'`var'), by(wave) 
replace `c'`var'_std = (`c'`var' - `c'`var'_mean) / `c'`var'_std 
}
} 

local child " nc ec"
foreach c of local child {
foreach var in  ASQpsoc  {
egen `c'`var'_mean = mean(`c'`var') , by(wave) 
egen `c'`var'_std = sd(`c'`var'), by(wave) 
replace `c'`var'_std = (`c'`var' - `c'`var'_mean) / `c'`var'_std 
}
} 


local child "oc nc ec"
foreach c of local child {
lab var `c'ASQtotal_std "Total Skills"
lab var `c'ASQcomm_std		"Communication Skills"
lab var `c'ASQcommref	"% Low Communication Skills"
lab var `c'ASQmoto_std		"Gross Motor Skills"
lab var `c'ASQmotoref	"% Low Gross Motor Skills"

}

local child "nc ec"
foreach c of local child {
lab var `c'ASQpsoc_std		"Personal-Social Skills"
lab var `c'ASQpsocref	"% Low Personal-Social Skills"
}

* alternate adjustment

rename NC_age nc_age
rename EC_age ec_age
rename OC_age oc_age

local child "oc nc ec"
foreach c of local child {
foreach x in ASQtotal ASQcomm ASQmoto {
reg `c'`x' i.`c'_age if treatp==0
predict demean`c'`x', xb
gen `c'`x'_demean = `c'`x' - demean`c'`x'
gen `c'`x'_demeansq = `c'`x'_demean^2
reg `c'`x'_demeansq i.nc_age
predict demeansq`c'`x', xb
gen `c'`x'_agestd = `c'`x'_demean/sqrt(demeansq`c'`x')
}
}

local child2 "nc ec"
foreach c of local child2 {
foreach x in ASQpsoc {
reg `c'`x' i.`c'_age if treatp==0
predict demean`c'`x', xb
gen `c'`x'_demean = `c'`x' - demean`c'`x'
gen `c'`x'_demeansq = `c'`x'_demean^2
reg `c'`x'_demeansq i.nc_age
predict demeansq`c'`x', xb
gen `c'`x'_agestd = `c'`x'_demean/sqrt(demeansq`c'`x')
}
}


* ANOTHER alternate adjustment - LPOLY



local child "nc ec"
foreach c of local child {
foreach x in ASQcomm ASQmoto {
lpoly `c'`x' `c'_age if treatp==0, at(`c'_age) gen(d`c'`x')
gen `c'`x'_d = `c'`x' - d`c'`x'
gen `c'`x'_ds = `c'`x'_d^2
lpoly `c'`x'_ds nc_age if treatp==0, at(`c'_age) gen(ds`c'`x')
gen `c'`x'_poly = `c'`x'_d/sqrt(ds`c'`x')
}
}


rename nc_age NC_age 
rename ec_age EC_age

*--------------------------------------------------------------
* TIME
*---------------------------------------------------------------


local child  nc
foreach x of local child {
tab `x'q1e_02_mum, gen(`x'timespent)
tab `x'q1e_03_mum, gen(`x'timeplay)

gen `x'timespent = 1 if `x'timespent1== 1 | `x'timespent2== 1
replace `x'timespent = 2 if `x'timespent3==1 
replace `x'timespent = 3 if `x'timespent4==1 | `x'timespent5==1
replace `x'timespent = 9 if `x'timespent6==1

gen `x'timeplay = 1 if `x'timeplay1==1 | `x'timeplay2==1 | `x'timeplay3==1
replace `x'timeplay = 2 if `x'timeplay4==1
replace `x'timeplay = 3 if `x'timeplay5==1 | `x'timeplay6==1
replace `x'timeplay = 9 if `x'timeplay7==1

drop `x'timespent1-`x'timespent6 `x'timeplay1-`x'timeplay7

tab `x'timespent, gen(`x'timespent)
tab `x'timeplay, gen(`x'timeplay)
}


*--------------------------------------------------------------
* HEALTH 
*-------------------------------------------------------------

local child1 "oc nc ec"

foreach c of local child1 {

recode `c'q1a_02 `c'q1b_01 `c'q1b_05 `c'q1b_09 `c'q1b_10 (2=0) (98=.)

gen `c'noill = 1-`c'q1b_01
gen `c'nodiar = 1- `c'q1b_05
local `c'health		`c'noill `c'nodiar
aind ``c'health', treat(treatp) gen(`c'health_aind) restd
lab var `c'health_aind			"Child Health Outcomes Index"

local `c'healthb `c'q1a_02 `c'vacc_allbasic
aind ``c'healthb', treat(treatp) gen(`c'healthbe_aind) restd
lab var `c'healthbe_aind			"Child health behaviours index"


}




*---------------------------------------------------------------
* ANTHRO outcomes
*---------------------------------------------------------------

#delimit;

/* age group for adjustment */
egen NC_age_a = cut(NC_age) if wave==2, at(14, 21, 28) icodes;
egen NC_age_a2 = cut(NC_age) if wave==3, at (21, 28, 34, 40, 46, 49) icodes;
replace NC_age_a = NC_age_a2 if wave==3;
drop NC_age_a2;
tab NC_age NC_age_a, mi;
lab def agegl		0 "14-20" 1 "21-27" 2 "28-33" 3 "34-39" 4 "40-45" 5 "46 - 51";
bys hh_id2: egen NC_ageg = mean(NC_age_a);

egen NC_age_b = cut(NC_age) if wave==2, at (0,6,12,18,24,30) icodes;
egen NC_age_b2 = cut(NC_age) if wave==3, at (21, 28, 34, 40, 46) icodes;
replace NC_age_b = NC_age_b2 if wave==3;
drop NC_age_b2;
tab NC_age NC_age_b, mi;
bys hh_id2: egen NC_agegb = mean(NC_age_b);

gen NC_age_sq = NC_age^2;
gen NC_age_cub = NC_age^3;

/* replace height and weight to missing if HAZ not calculated (out of range) */
local child "nc ec";
foreach c of local child {;
replace `c'_height = . if `c'_haz_who==.;
replace `c'_weight = . if `c'_haz_who==.;

lab var NC_age 			"Age in months";
lab var `c'_height 		"Height (cm)";
lab var `c'_weight 		"Weight (cm)";
lab var `c'_bmiz 		"BMI-for-age Z-score";
lab var `c'_haz_who 		"Height-for-Age (HAZ)";
lab var `c'_stn_who 		"% who are classed as Stunted (HAZ < -2)";
lab var `c'_sstn_who 	"% who are classed as Severely Stunted (HAZ < -3)";
lab var `c'_waz_who 		"Weight-for-Age (WAZ)";
lab var `c'_uwt_who 		"% who are classed as Underweight (WAZ < -2)";
lab var `c'_suwt_who 	"% who are classed as Severely Underweight (WAZ < -3)";
lab var `c'_whz_who 		"Height-for-Weight (WHZ)";
lab var `c'_wst_who 		"% who are classed as Wasted (WHZ < -2)";
lab var `c'_swst_who 	"% who are classed as Severely Wasted (WHZ < -3)";
lab var `c'_muac 		"Middle Upper Arm Circ. (MUAC)";
lab var `c'_maln 		"% who are classed as Malnourished (MUAC < 125)";
lab var `c'_smaln 		"% who are classed as Severely Malnourished (MUAC < 115)";
};

******************************************************************
* woman OUTCOMES 
******************************************************************


/* WOMAN HEALTH----------------------------------------------- */


utrim wm_bmi;

gen smaln1=(wm_muac<185) if wm_muac!=.;
gen mmaln1=(wm_muac<=220 & wm_muac>=185) if wm_muac!=.;
gen maln1=(wm_muac<=220) if wm_muac!=.;
gen smaln2=(wm_muac<190) if wm_muac!=.;
gen mmaln2=(wm_muac<=230 & wm_muac>=190) if wm_muac!=.;
gen maln2=(wm_muac<=230) if wm_muac!=.;
lab var smaln1		"Sev. Malnourished (Def.1)";
lab var mmaln1		"Mod. Malnourished (Def.1)";
lab var smaln2		"Sev. Malnourished (Def.2)";
lab var mmaln2		"Mod. Malnourished (Def.2)";
lab var maln1		"Malnourished (Def.1)";
lab var maln2		"Malnourished (Def.2)";

/* WOMAN KAPS ----------------------------------------------- */


/* generate a var for best place is hf */
gen m_hf = 1 if mq9b_02 == 1 ;
replace m_hf = 0 if mq9b_02 == 0 ;

gen w_hf = 1 if wq7b_02 == 1 ;
replace w_hf = 0 if wq7b_02 == 0;

/* generate start immediately */
gen w_immediate = 1 if wq7b_05==1 ;
replace w_immediate = 0 if wq7b_05 ==0 & wq7b_05 !=.;
gen m_immediate = 1 if mq9b_05==1 ;
replace m_immediate = 0 if mq9b_05 ==0 & mq9b_05 !=.;

/* generate never water if hot */
gen mnowaterhot = 1- mq9b_05c_1 ;
label var mnowaterhot "Do not give baby water when hot outside" ;

gen wnowaterhot = 1- wq7b_05c_1 ;
label var wnowaterhot "Do not give baby water when hot outside" ;



/* generate a variable for exclusive breastfeed */
gen exclusive_6months = 0 ;
replace exclusive_6months = 1 if  wq7b_06time==3 & wq7b_06number==6 ;
replace exclusive_6months = 1 if wq7b_06time==2 & wq7b_06number>=26 & wq7b_06number<=30 ;
label var  exclusive_6months "Exclusively Breastfeed in first 6 months" ;


recode wq7a_01 wq7b_01_1 wq7b_01_2 wq7b_01_3 wq7b_01_4 (8=98);
recode wq7b_01_1 wq7b_01_2 wq7b_01_3 wq7b_01_4 (2 =0) (98=.);

recode wq7a_01 (1/2=1) (3/5=0), gen(eatmorepreg);
recode wq7b_02 (2 3 96=0) (98=.), gen(besthf);
recode wq7b_05 (2/max=0), gen(wbfimmed);
recode wq7b_05 (3/max=0) (1 2 =1), gen(wbf1h);

recode wq7b_07 wq7b_09  (2 = 0) (98=.);
gen wq7b_06nobreastneg = 1-wq7b_06nobreast;

recode wq7b_06bweeks (0/25 = 0) (34/86=0) (26/30=1) (98=.), gen(wexclbf6m);

lab var	wq7b_01_1			"for a check-up, even if healthy";
lab var	wq7b_01_3			"if about to give birth and travel cost is 2000NGN";
lab var	wq7b_01_4			"if about to give birth and no female staff available";
lab var besthf				"Best place to give birth is health facility";
lab var wbfimmed			"Best to start breastfeeding immediately";
lab var wq7b_06nobreastneg	"Baby should not receive other liquids on first day";
lab var wq7b_09				"Colostrum is good for the baby";
lab var wexclbf6m			"Best to breastfeed exclusively for 6-7 months";

/* for Anderson index */
global wkapvars 		wq7b_01_1
						besthf wbfimmed wq7b_06nobreastneg wq7b_09 wexclbf6m
						;

/* anderson index  */

preserve;
tempfile bl ;
keep if wave==1 ; 
aind wq7b_01_1 besthf wbfimmed wq7b_06nobreastneg wq7b_09 wnowaterhot exclusive_6month, treat(treat) gen(wkap_aind_bl)  restd;
lab var wkap_aind_bl			"Woman knowledge index";
keep hh_id2 wave wkap_aind_bl ;
save "`bl'" ;
restore ;

drop _merge ; 
merge 1:1 hh_id2 wave using "`bl'" ;
drop _merge ;

preserve;
tempfile ml ;
drop if wave==3 ; 
aind wq7b_01_1 besthf wbfimmed wq7b_06nobreastneg wq7b_09 wnowaterhot exclusive_6month, treat(treat) gen(wkap_aind_ml) wave(wave) restd;
lab var wkap_aind_ml			"Woman knowledge index";
keep hh_id2 wave wkap_aind_ml ;
save "`ml'" ;
restore ;

merge 1:1 hh_id2 wave using "`ml'" ;
drop _merge ;

preserve;
tempfile el ;
drop if wave==2 ; 
aind wq7b_01_1 besthf wbfimmed wq7b_06nobreastneg wq7b_09 wnowaterhot exclusive_6month, treat(treat) gen(wkap_aind_el) wave(wave) restd;
lab var wkap_aind_el			"Woman knowledge index";
keep hh_id2 wave wkap_aind_el ;
save "`el'" ;
restore ;

merge 1:1 hh_id2 wave using "`el'" ;
drop _merge ;


gen wkap_aind = wkap_aind_ml if wave==2 ;
replace wkap_aind = wkap_aind_bl if wave==1 ; 
replace wkap_aind = wkap_aind_el if wave == 3 ; 
label var wkap_aind "Woman knowledge index";

						
/* water U6m */
recode wq7b_05c_1-wq7b_05c_96 (98=.) (2=0);
rename wq7b_05c_* watu6m*;
tabrrd, stub(watu6m) cut(.025);
drop watu6moth;
egen watumsum = rowtotal(watu6m* oth_watu6m) if wave==3, mi;
recode watumsum (1/max=0) (0=1);
lab var watumsum		"Never water to baby U6m";

gen wq7b_06bweeksdk = (wq7b_06bweeks==98) if wq7b_06bweeks!=.;
lab var wq7b_06bweeksdk	"Doesn't Know Weeks Baby Should Receive Only Breastmilk";
recode wq7b_06bweeks (98 = .);
lab var wq7b_06bweeks	"Weeks Baby Should Receive Only Breastmilk (w0)";
gen wq7b_06_6m = (wq7b_06bweeks==26) if wq7b_06bweeks!=.;
lab var wq7b_06_6m		"Baby should be exclus breasfted for 6m";

recode wq7b_07 wq7b_09 (2 = 0) (98=.);

******************************************************************
* man OUTCOMES 
******************************************************************


/* MAN KAPS ---------------------------------------------- */						
recode mq9b_01_1 mq9b_01_2 mq9b_01_3 mq9b_01_4 (2 98 = 0);
recode mq9b_05 (2/max=0), gen(mbfimmed);
recode mq9b_05 (3/max=0) (1 2=1), gen(mbf1h);
recode mq9b_02 (2 3 96=0) (98=.), gen(mbesthf);

recode mq9b_07 mq9b_09  (2 98 = 0);
gen mq9b_06nobreastneg = 1-mq9b_06nobreast;

/* generate a var for exclusive breastfeed man */
gen m_exclusive_6months = 0 ;
replace m_exclusive_6months = 1 if  mq9b_06time==3 & mq9b_06number==6 ; 
replace m_exclusive_6months = 1 if mq9b_06time==2 & mq9b_06number>=26 & mq9b_06number<=30 ;
label var  m_exclusive_6months "Exclusively Breastfeed in first 6 months" ;

recode mq9b_06bweeks (0/25 = 0) (34/86=0) (26/30=1) (98=.), gen(mexclbf6m);
													
lab var	mq9b_01_1			"for a check-up, even if healthy";
lab var	mq9b_01_3			"if about to give birth and travel cost is 2000NGN";
lab var	mq9b_01_4			"if about to give birth and no female staff available";
lab var mbesthf				"Best place to give birth is health facility";
lab var mbfimmed			"Best to start breastfeeding immediately";
lab var mq9b_06nobreastneg	"Baby should not receive other liquids on first day";
lab var mq9b_09				"Colostrum is good for the baby";
lab var mexclbf6m			"Best to breastfeed exclusively for 6-7 months";


/* water U6m */
recode mq9b_05c_1-mq9b_05c_96 (98=.) (2=0);
rename mq9b_05c_* mwatu6m*;
tabrrd, stub(mwatu6m) cut(.025);
drop mwatu6moth;
egen mwatumsum = rowtotal(mwatu6m* oth_mwatu6m) if wave==3, mi;
recode mwatumsum (1/max=0) (0=1);
lab var mwatumsum		"Never water to baby U6m";

gen mq9b_06bweeksdk = (mq9b_06bweeks==98) if mq9b_06bweeks!=.;
lab var mq9b_06bweeksdk	"Doesn't Know Weeks Baby Should Receive Only Breastmilk";
recode mq9b_06bweeks (98 = .);
lab var mq9b_06bweeks	"Weeks Baby Should Receive Only Breastmilk (w0)";
gen mq9b_06_6m = (mq9b_06bweeks==26) if mq9b_06bweeks!=.;
lab var mq9b_06_6m		"Baby should be exclus breasfted for 6m";

recode mq9b_07 mq9b_09 (2 = 0) (98=.);



/* for Anderson index */
global mkapvars 		mq9b_01_1
						mbesthf mbfimmed mq9b_06nobreastneg mq9b_09 mq9b_10neg;
						
/* husband KAP */

preserve;
tempfile ml ;
drop if wave==3 ; 
aind mq9b_01_1 mbesthf mbfimmed mq9b_06nobreastneg mq9b_09 mnowaterhot m_exclusive_6months, treat(treat) gen(mkap_aind_ml) wave(wave) restd;	
lab var mkap_aind_ml		"Husband knowledge index";
keep hh_id2 wave mkap_aind_ml ;
save "`ml'" ;
restore ;

merge 1:1 hh_id2 wave using "`ml'" ;
drop _merge ;

preserve;
tempfile el ;
drop if wave==2 ; 
aind mq9b_01_1 mbesthf mbfimmed mq9b_06nobreastneg mq9b_09 mnowaterhot m_exclusive_6months, treat(treat) gen(mkap_aind_el) wave(wave) restd;	
lab var mkap_aind_el		"Husband knowledge index";
keep hh_id2 wave mkap_aind_el ;
save "`el'" ;
restore ;

merge 1:1 hh_id2 wave using "`el'" ;
drop _merge ;

preserve;
tempfile bl ;
keep if wave==1 ; 
aind mq9b_01_1 mbesthf mbfimmed mq9b_06nobreastneg mq9b_09 mnowaterhot m_exclusive_6months, treat(treat) gen(mkap_aind_bl) wave(wave) restd;	
lab var mkap_aind_bl		"Husband knowledge index";
keep hh_id2 wave mkap_aind_bl ;
save "`bl'" ;
restore ;

merge 1:1 hh_id2 wave using "`bl'" ;
drop _merge ;

		gen mkap_aind = mkap_aind_ml if wave==2;
replace mkap_aind = mkap_aind_bl if wave==1;
replace mkap_aind = mkap_aind_el if wave == 3 ; 
label var mkap_aind "Husband knowledge index";		

******************************************************************
* PREGNANCY AND ANTENATAL CARE
******************************************************************
		

/* CURRENT PREGNANCY ANTENATAL CARE ----------------------------------------- */
recode pregml (2=0) (98=.);

recode wq4b_02 (2=0), gen(currac);
lab var currac				"Received antenatal care (current pregnancy)";

recode wq4b_09 (98=.), gen(currac_mpreg);
lab var currac_mpreg		"Months pregnant when first got antenatal care (current pregnancy)";

recode wq4b_07 (99999998=.), gen(currac_cost_trans);
lab var currac_cost_trans	"Transport cost for antenatal care (current pregnancy)";
recode wq4b_08 (99999998=.), gen(currac_cost_treat);
lab var currac_cost_treat	"Treatment cost for antenatal care (current pregnancy)";

recode wq4b_10 wq4b_11 wq4b_12 wq4b_13 wq4b_14 (2=0) (98=.);
lab var wq4b_10				"Received iron supplements";
lab var wq4b_11				"Received folic acid";
lab var wq4b_12				"Received tetanus shot";
lab var wq4b_13				"Received deworming drugs";
lab var wq4b_14				"Received malaria drugs";



/* NC ANTENATAL CARE AND DELIVERY ------------------------------------------- */

recode ncq2a_01 (2 8 98 = 0);
gen ncanyac = ncq2a_01 ;
replace ncanyac = 1 if ncq2a_01_c==1;
replace ncanyac = 0 if ncq2a_01_c==2;
lab var ncanyac				"Received antenatal care";

gen ncactimes = ncq2a_04;
replace ncactimes = ncq2a_04_c if ncq2a_04_c!=.;
replace ncactimes = 0 if ncanyac==0;
recode ncactimes (96 98=.);
lab var ncactimes			"Times received antenatal care";

recode ncq2b_03 (1 3 96 = 0) (2=1), gen(ncbhf);
replace ncbhf = 1 if ncq2b_03_c==2;
replace ncbhf = 0 if inlist(ncq2b_03_c,1,3,96);
lab var ncbhf				"Born at health facility";					

local bassvals "1 2 3 4 5 6 96 98";
foreach i of local bassvals {;
	rename ncbirthass`i' ncbass`i';
	replace ncbass`i'= ncbirthass_c`i' if ncbirthass_c`i'!=.;
};
lab var ncbass1				"Birth assisted by trained health worker";

/* why not attended antenatal care */
gen ncnoac_travel = ncnoante1;
replace ncnoac_travel = 1 if ncnoante_c1==1;
lab var ncnoac_travel		"Travel cost too high";

gen ncnoac_noperm = ncnoante4;
replace ncnoac_noperm = 1 if ncnoante_c4==1;
lab var ncnoac_noperm		"No permission";

gen ncnoac_noreas = ncnoante6;
replace ncnoac_noreas = 1 if ncnoante_c6==1;
lab var ncnoac_noreas		"Saw no reason to seek it";

gen ncnoac_oth = .;
replace ncnoac_oth = 1 if 	ncnoante2==1 | ncnoante3==1 | ncnoante5==1 | ncnoante7==1 | ncnoante96==1 |
							ncnoante_c2==1 | ncnoante_c3==1 | ncnoante_c5==1 | ncnoante_c96==1;
lab var ncnoac_oth			"Other reason";

local allnoac ncnoac_travel ncnoac_noperm ncnoac_noreas ncnoac_oth;
foreach x of local allnoac {;
	replace `x' = 0 if `x'==. & (ncnoante1!=. | ncnoante_c1!=.);
	replace `x' = 0 if ncanyac==1; /* if got AC */
};
							

/* NC IYCF PRACTICES ------------------------------------------- */
gen months_ebf = ncq1c_10;
lab var months_ebf			"Months Excl Breastfed (if stopped)";
gen ebf_6m = (inlist(months_ebf,6,7)) if months_ebf!=. & months_ebf!=98;
lab var ebf_6m				"Exclusively breastfed for 6-7 months";
recode ncq1c_dak (98=.) (2=0), gen(nccolostr);
replace nccolostr = 0 if 	inlist(ncq1c_11,2,3,98);
lab var nccolostr			"Fed colostrum in the first hour";

gen nctimesfed = ncq1c_20;
lab var nctimesfed			"Num. times fed yesterday";
gen ncfed4p = (nctimesfed>=4) if nctimesfed!=.;
lab var ncfed4p				"Fed 4+ times yesterday";

recode ncq1c_16a (98=.) (2=0) ;

/* gen did not give water yesterday if nc less than 6 months */
gen ncnowater = 1 - ncq1c_16a if NC_age <= 6 ;
lab var ncnowater "New Child under 6m not given water yesterday" ;
gen ecnowater = 1 - ecq1c_16a if EC_age <= 6 ;
lab var ncnowater "Under 6m not given water yesterday" ;  

/* new child practices index */
local ncpractvars		ncanyac ncbhf nciycf1 nccolostr ncnowater ebf_6m;
aind `ncpractvars', treat(treat) gen(ncpract_aind) restd;	
lab var ncpract_aind			"New Child practices index";

recode ecq1c_dak (98=.) (2=0), gen(eccolostr);
replace eccolostr = 0 if 	inlist(ecq1c_11,2,3,98);
lab var eccolostr			"Fed colostrum in the first hour";

gen ecbhf = 1 if ecq2b_03 == 2 ;
replace ecbhf = 0 if ecq2b_03 == 1 | ecq2b_03 == 3 | ecq2b_03 == 96 ;

local ecpractvars  ecq2a_01 ecbhf eciycf1 eccolostr ecnowater eciycf11;
aind `ecpractvars' if wave==3, treat(treatp) gen(ecpract_aind) restd;
lab var ecpract_aind			"End Child practices index";

/* drop and recreate variables */
drop nciycf1 nciycf1b;
gen nciycf1=.;
lab var nciycf1				"Put to the breast immediately";
replace nciycf1=0 if ncq1c_11!=.;
replace nciycf1=0 if ncq1c_01==2;	/* never breastfed also to no */
replace nciycf1=1 if ncq1c_11==1;
replace nciycf1=. if ncq1c_11==98; 	/* DKs */
gen nciycf1b=.;
lab var nciycf1b			"Put to the breast within 24 hours";
replace nciycf1b=0 if ncq1c_11!=.;
replace nciycf1b=0 if ncq1c_01==2;	/* never breastfed also to no */
replace nciycf1b=1 if (ncq1c_11==1 | ncq1c_11==2);
replace nciycf1b=. if ncq1c_11==98; /* DKs */

lab var nciycf2				"Fed only breast milk (under 6 months)";
lab var nciycf3				"Still breastfed (at 12-15 months)";
lab var nciycf10			"Still breastfed (at 20-23 months)";
lab var nciycf4				"Receiving solid/semisolid food (at 6-8 months)";
lab var nciycf5				"Receiving 4+ food groups (at 6-23 months)";
lab var nciycf6				"Receiving minimum feeding times (at 6-23 months)";
lab var nciycf7				"Receiving minimum acceptable diet (at 6-23 months)";
lab var nciycf8				"Consuming iron-rich/fortified foods (at 6-23 months)";
lab var nciycf9				"Ever breastfed";
lab var nciycf11			"Appropriately breastfed (at 0-23 months)";
lab var nciycf12			"Predominantly Breastfed (under 6 months)";
lab var nciycf15			"Receiving minimum milk feeding frequency (not breastfed at 6-23 months)";


******************************************************************
* HEALTH BEHAVIOURS
******************************************************************


local child "oc nc ec";
foreach c of local child {;

recode `c'q1a_02 `c'q1b_01 `c'q1b_05 `c'q1b_09 `c'q1b_10 (2=0) (98=.);
lab var `c'vacc_BCG 		"BCG";
lab var `c'vacc_polio 	"Any polio";
lab var `c'vacc_polio0 	"Polio at birth";
lab var `c'vacc_3polio 	"3+ Polio shots";
lab var `c'vacc_DPT 		"DPT";
lab var `c'vacc_3dpt 	"3+ DPT shots";
lab var `c'vacc_measles 	"Measles";
lab var `c'vacc_hepb 	"Hepatitis B";
lab var `c'vacc_yfev 	"Yellow fever";
lab var `c'vacc_allbasic "All basic vaccinations";
lab var `c'vacc_nobasic	"None basic vaccinations";

};

/* replace ML values for NC vaccinations */
local vvl	"BCG polio polio0 3polio DPT measles hepb yfev";
sort hh_id2 wave;
foreach x of local vvl {;
	gen ncvacc_`x'2 = ncvacc_`x' if wave==2;
	bysort hh_id2: carryforward ncvacc_`x'2, replace;
	replace ncvacc_`x' = 1 if ncvacc_`x'2==1 & wave==3 & NC_age!=.;
};

replace ncvacc_allbasic=1 if ncvacc_BCG==1 & ncvacc_3polio==1 & ncvacc_3dpt==1 & ncvacc_measles==1;
replace ncvacc_nobasic=1 if ncvacc_BCG==0 & ncvacc_polio==0 & ncvacc_DPT==0 & ncvacc_measles==0;


/****************************************************************************/
/* SAVING	and borrowing																*/
/****************************************************************************/

recode mq5c_01_* (98=.);
recode mq5c_03 (2=0) (8 98=.);

replace anysav=. if mq5c_01_1==.;
lab var anysav			"Any HH Member Saving Money at Institution";
replace anysav2 =1 if mq5c_03==1;
lab var anysav2			"Any HH Member Saving Money incl In Kind";

replace totsav2=0 if anysav2==0;
utrim totsav2;
lab var totsav20		"Tot Val Savings incl In Kind (trim p99, w0)";



recode mq5_totsav (99999998=.) (9999998=.), gen(totsav);
replace totsav=0 if anysav==0;
utrim totsav;
gen totsav0=totsav; 
lab var totsav0 "Total Savings (trim p99, w0)";



recode mq5c_04 (9999998/max=.), gen(totiksav);
replace totiksav=0 if mq5c_03==0;
utrim totiksav;
gen totiksav0=totiksav;
lab var totiksav0		"Total Value of Savings In Kind  (trim p99, w0)";

lab var mq5c_01_5 		"Any HH Member Saving at An informal savings group";



foreach v of varlist totsav totiksav totsav2 {;
	gen l`v'=log(`v');
};
lab var ltotsav 		"(log) Tot Val Savings excl In Kind (trim p99)";
lab var ltotiksav 		"(log) Tot Val In Kind Savings (trim p99)";
lab var ltotsav2		"(log) Tot Val Savings incl In Kind (trim p99)";


/* borrowing */

recode mq5b_01_? mq5b_01_??		(98=.);
recode anyborr (1/max=1);
replace anyborr=. if mq5b_01_1==.;
lab var anyborr			"Any HH Member Borrowing Money from Any Source";
lab var mq5b_01_6 		"Any HH Memb Borrowing - a shop on credit";

replace mq5b_01_6 = 0 if wave==3 & mq5b_01_6a!=.;
replace mq5b_01_6 = 1 if wave==3 & (mq5b_01_6a==1 | mq5b_01_6b==1);

recode totborr (99999998=.) (9999998=.);
replace totborr=0 if anyborr==0;
utrim totborr;
lab var totborr0			"Total Value of Borrowing '000NGN (trim p99, w0)";

gen ltotborr = log(totborr);
lab var ltotborr		"(log) Total Value of Borrowing (trimmed at p99)";

recode mq5b_03_*		(98=.);
egen anyfail=rowtotal(mq5b_03_1-mq5b_03_8) , mi;
recode anyfail (1/max=1);
replace anyfail=. if mq5b_01_1==.;
lab var anyfail			"Any HH Member Failed to Borrow Money from Any Source";

/* LOANING ------------------------------------------------------------------ */
#delimit ;
recode mq5b_06 			(2=0) (98=.);

recode mq5_totloan (99999998=.) (9999998=.), gen(totloan);
replace totloan=0 if mq5b_06==0;
utrim totloan;
gen totloan0=totloan;
lab var totloan0			"Total Value of Loans  (trim p99, w0)";

gen ltotloan = log(totloan);
lab var ltotloan		"(log) Total Value of Loans (trimmed at p99)";

gen totloan_usd = totloan*xr; 

/* ------------------------------------------------------------------ */
/* ANIMAL PRICES ------------------------------------------------------------------ */
/*  ------------------------------------------------------------------ */
#delimit cr

recode mq3_buyexp_01 mq3_buyexp_02 mq3_buyexp_03 mq3_buyexp_04 mq3_buyexp_05 mq3_buyexp_06 mq3_buyexp_07 mq3_buyexp_08 mq3_buyexp_09 mq3_buyexp_10 mq3_buyexp_11 mq3_buyexp_12 mq3_buyexp_13 ( 9999998=.)
recode mq3_buynum* (9998=.)
egen mq3_buyexp_any = rowtotal( mq3_buyexp_01 mq3_buyexp_02 mq3_buyexp_03 mq3_buyexp_04 mq3_buyexp_05 mq3_buyexp_06 mq3_buyexp_07 mq3_buyexp_08 mq3_buyexp_09 mq3_buyexp_10 mq3_buyexp_11 mq3_buyexp_12 mq3_buyexp_13), missing

local animalexp mq3_buyexp_any mq3_buyexp_01 mq3_buyexp_02 mq3_buyexp_03 mq3_buyexp_04 mq3_buyexp_05 mq3_buyexp_06 mq3_buyexp_07 mq3_buyexp_08 mq3_buyexp_09 mq3_buyexp_10 mq3_buyexp_11 mq3_buyexp_12 mq3_buyexp_13
foreach var of local animalexp {
replace `var' = `var'*xr
}

local animal _01 _02 _03 _04 _05 _06 _07 _08 _09 _10 _13 cowbull calf sheep goat camel donk
foreach var of local animal {
gen animal`var'_exppu = mq3_buyexp`var'/mq3_buynum`var'
egen animalexp`var' = xtile(animal`var'_exppu), nq(100)
replace animal`var'_exppu = . if animalexp`var' >= 95 & animalexp`var' !=.
drop animalexp`var'
}


local animalprice animal_01_exppu animal_02_exppu animal_03_exppu animal_04_exppu animal_05_exppu animal_06_exppu animal_07_exppu animal_08_exppu animal_09_exppu animal_10_exppu animal_13_exppu animalcowbull_exppu animalcalf_exppu animalsheep_exppu animalgoat_exppu animalcamel_exppu animaldonk_exppu


label var animal_01_exppu "Price spent per Cow"
label var animal_02_exppu "Price spent per Bull"
label var animal_03_exppu "Price spent per Female Calf"
label var animal_04_exppu "Price spent per Male Calf"
label var animal_05_exppu "Price spent per Female Sheep"
label var animal_06_exppu "Price spent per Male Sheep"
label var animal_07_exppu "Price spent per Female Goat"
label var animal_08_exppu "Price spent per Male Goat"
label var animal_09_exppu "Price spent per Female Camel"
label var animal_10_exppu "Price spent per Male Camel"
label var animalcowbull_exppu "Price spent per Cow"
label var animalcalf_exppu "Price spent per Calf (combo)"
label var animalgoat_exppu "Price spent per goat (combo)"
label var animalsheep_exppu "Price spent per sheep (combo)"
label var animaldonk_exppu "Price spent per donkey (combo)"
label var animalcamel_exppu "Price spent per camel (combo)"

/* ------------------------------------------------------------------ */
/*FOOD PRICES ------------------------------------------------------------------ */
/*  ------------------------------------------------------------------ */
/* make food expenditure match MDD groups */
#delimit;

local child oc nc ec;
foreach x of local child {;
gen `x'mddfgroup4and5  = `x'mddfgroup4 + `x'mddfgroup5 ;
replace `x'mddfgroup4and5 = 1 if `x'mddfgroup4and5==2;
gen `x'MDD4	= `x'MDD>=4 if `x'MDD!=.;

};


forvalues i=1(1)13 {;
	replace mq4_04_`i'=0 					if mq4_03_`i'==0;
};

recode mq4_04_* (99999998=.);

gen fgrexp_mdd1 = mq4_04_1 ;
gen fgrexp_mdd2 = mq4_04_3 + mq4_04_6 ;
gen fgrexp_mdd3 = mq4_04_9 ;
gen fgrexp_mdd4and5 = mq4_04_7 + mq4_04_8 ;
gen fgrexp_mdd6 = mq4_04_2  ;
gen fgrexp_mdd7 = mq4_04_4 + mq4_04_5;
gen fgrexp_oilsauce = mq4_04_10 + mq4_04_11 ;
gen fgrexp_sugardrink = mq4_04_12 + mq4_04_13 ;



recode wq10a_10 (2=0) ;
label var fgrexp_mdd1 "Grains, tubers, roots";
label var fgrexp_mdd2 "Legumes and nuts";
label var fgrexp_mdd3 "Dairy products";
label var fgrexp_mdd4and5 "Flesh foods and eggs";
label var fgrexp_mdd6 "Vitamin-A rich fruit and vegetables" ;
label var fgrexp_mdd7 "Other fruit and vegetables" ;
label var fgrexp_oilsauce "Oil, butter and condiments" ;
label var fgrexp_sugardrink "Sugary items, drinks" ;

* calculate a CPI type basket of goods

* first weighting by how common items are eaten at BL in OC group

#delimit;
local fgroup 1 2 3 4and5 6 7;
foreach x of local fgroup {;
sum ocmddfgroup`x' if wave==1;
gen weight`x' = r(mean);
gen weightedgr`x' = r(mean)* fgrexp_mdd`x' ;
};


/* SAVE ----------------------------------------------------------------------*/
#delimit;
save "$data/final_lk", replace ;

