*----------------------------------------------------------------------------*
*							CONTEXTUAL STATS								 *
*----------------------------------------------------------------------------*


*----------------------------------------------------------------------------*
* 									SETUP									 *
*----------------------------------------------------------------------------*

/*
set more off
set mem 800m
set maxvar 8000

*** SET FOLDER PATH
		if c(username)=="lucy_k"{
		global main "/Users/lucy_k/Dropbox/IFS/CDGP_analysis/15 paper_lk"
	}
	
	global data "$main/Data"
	global tables "$main/Output/Tables"
	global graphs "$main/Output/Graphs"
*/

*----------------------------------------------------------------------------*
*make data set																*
*----------------------------------------------------------------------------*
clear
import excel "$data/IMR_mortality_rate_2018.xlsx", firstrow

drop if Uncertaintybounds == "Lower" | Uncertaintybounds == "Upper"

keep ISOCode CountryName BO BP BQ BR BS

rename BO year2013
rename BP year2014
rename BQ year2015
rename BR year2016
rename BS year2017

reshape long year, i(ISOCode CountryName) j(mortality)

drop if year ==.

rename year imr
rename mortality year

save "$data/imr.dta", replace 

import excel "$data/Exclusive-BF.xlsx", firstrow clear

keep ISO Countriesandareas National DataSourceYear

rename National ebf
rename DataSourceYear year
drop if year==.
rename ISO ISOCode
rename Countriesandareas CountryName

save "$data/ebf.dta", replace

import excel "$data/Stunt.xlsx", firstrow clear

keep ISO Countriesandareas Year National

drop if Year==.

rename Year year
rename ISO ISOCode
rename National stunting
rename Countriesandareas CountryName
bys ISOCode year: gen count = _n
keep if count==1
drop count

save "$data/stunting.dta", replace

import excel "$data/wasting.xlsx", firstrow clear

rename Country CountryName
rename Bothsexes wasting
gen year = substr(Year,1,4)
destring year, replace
drop Year 
bys CountryName year: gen count = _n
drop if count == 2
drop count

merge 1:1 CountryName year using "$data/stunting.dta"

drop _merge
drop if ISOCode==""

merge 1:1 ISOCode year using "$data/imr.dta"

drop _merge

merge 1:1 ISOCode year using "$data/ebf.dta"

drop _merge

destring stunting, replace
destring ebf, replace

gen c = 1 if stunting !=. & ebf !=. & imr !=.

keep if year >= 2013

/* add in northern nigeria from census (reference Nigeria Demo and health survey 2013) */
set obs 978
replace CountryName = "North-west Nigeria" in 978
replace year = 2013 in 978
replace stunting = 54.8 in 978
replace imr = 89 in 978
replace wasting = 27.1 in 978

/* add in sub saharan africa from world bank */
set obs 979
replace CountryName = "SSA" in 979
replace year = 2013 in 979
replace stunting = 36.2 in 979
replace imr = 58.5 in 979
replace wasting = 2.5 in 979


save "$data/stats.dta", replace


*----------------------------------------------------------------------------*
*make graph			  														 *
*----------------------------------------------------------------------------*
preserve
keep if stunting !=.
keep if stunting >= 36.2 
sort CountryName year
bys CountryName: gen count = _N
bys CountryName: gen count2 = _n
keep if count2 == 1 /* as close to 2013 as pos */
sort stunting
gen sorting = _n
labmask sorting, values(CountryName)
separate stunting, by (CountryName == "SSA" | CountryName == "North-west Nigeria" | CountryName == "Nigeria")
 graph hbar stunting0 stunting1  , over(sorting)  graphregion(color(white)) bgcolor(white) ///
legend(off)  ///
bar(1, bfcolor(navy)) plotregion(color(white)) blabel(size(tiny))  ytitle("Under 5 Stunting (%)")  

restore


preserve
keep if imr !=.
keep if imr >= 58.5 
sort CountryName year
bys CountryName: gen count = _N
bys CountryName: gen count2 = _n
keep if count == count2
sort imr
gen sorting = _n
labmask sorting, values(CountryName)
separate imr, by (CountryName == "SSA" | CountryName == "North-west Nigeria" | CountryName == "Nigeria")
graph hbar  imr0 imr1 , over(sorting, relabel(1 "SSA" 2 " " 3 " " 4 " " 5 " " 6 " " 7 " " 8 " " 9 " " 10 " " 11 " " 12 " " 13 " Nigeria " 14 " " 15  " " 16 " " 17 " " 18 " " 19 " " 20 " " 21 "Central African Republic" 22 "North-West Nigeria"))  graphregion(color(white)) bgcolor(white) ///
legend(off)  ///
bar(1, bfcolor(navy)) plotregion(color(white)) blabel(size(tiny))  ytitle("Infant Mortality Rate (Per 1,000)")  
restore

preserve
keep if wasting !=.
keep if year==2013 
sum wasting if CountryName=="SSA"
local mean = r(mean)
keep if wasting >= `mean' 
drop if CountryName=="South Africa"
sort CountryName year
bys CountryName: gen count = _N
bys CountryName: gen count2 = _n
keep if count == count2
sort wasting
gen sorting = _n
labmask sorting, values(CountryName)
separate wasting, by (CountryName == "SSA" | CountryName == "North-west Nigeria" | CountryName == "Nigeria")
graph hbar  wasting0 wasting1 , over(sorting, relabel(1 "SSA" 2 " " 3 " " 4 " " 5 " " 6 " " 7 " " 8 " " 9 " " 10 " " 11 " " 12 " " 13 " " 14 " " 15  " " 16 " " 17 " " 18 " " 19 "Nigeria" 20 "Bangladesh" 21 "North-West Nigeria"))  graphregion(color(white)) bgcolor(white) ///
legend(off)  ///
bar(1, bfcolor(navy)) plotregion(color(white)) blabel(size(tiny))  ytitle("Under 5 Wasting (%)")  
restore


