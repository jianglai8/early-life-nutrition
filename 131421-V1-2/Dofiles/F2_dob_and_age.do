
*-----------------------------
* FIGURE 2: DIST OF DOB AND AGE
*-----------------------------


clear all
macro drop _all // reset globals

set more off
set mem 800m
set maxvar 8000

*** SET FOLDER PATH
		if c(username)=="lucy_k"{
		global main "/Users/lucy_k/Dropbox/IFS/CDGP_analysis/15 paper_lk"
	}
	
	global data "$main/Data"
	global graphs "$main/Output/Graphs"
	global tables "$main/Output/Tables/Effects"
	global do "$main/Do Files"

do "$do/Globals.do"

#delimit ;


/* define controls */
local allXnc 			$baseX NC_age NC_gend;
local allXec 			$baseX EC_age EC_gend;

use "$data/final_lk", clear;


/****************************************************************************/
/* FIGURE																	*/
/****************************************************************************/


preserve ; 

/* keep only CDGP child pregnant at baseline */
keep if pregbl == 1 ;

sum NC_dob_ym if pregbl==1, detail;


bys hh_id2: gen count= _n ;
twoway 	(histogram NC_dob_ym if count==1 & treatp==0, discrete fcolor(none) lpattern(dash) lcolor(red)  ) 
		(histogram NC_dob_ym if count==1 & treatp==1, discrete fcolor(none) lcolor(navy)) ,
		legend(label(1 "Control") label(2 "Treated") region(lwidth(none)) tstyle(body) ring(0) position(10) rows(1))
		graphregion(color(white)) bgcolor(white)
		xtitle("Date of birth") xline(673, lpattern(dash)) xlab(655 "Aug 2014" 667 "Aug 2015"  679 "Aug 2016" ) ;
		graph export "$graphs/dob.png", replace ;
	
cdfplot NC_dob_ym if count==1, by(treatp) 
		opt1(lpattern(dash))
		legend(label(1 "Control") label(2 "Treated") region(lwidth(none)) tstyle(body) ring(0) position(10) rows(1))
		graphregion(color(white)) bgcolor(white)
		xtitle("Date of birth") xlab(655 "Aug 2014" 667 "Aug 2015"  679 "Aug 2016" ) ;
		graph export "$graphs/dob_cdf.png", replace ;
					
restore ; 


*----------------------------------------
* GRAPH FOR NON-PREG *
*----------------------------------------
preserve ; 

/* keep only CDGP child pregnant at baseline */
keep if pregbl == 0 ;

bys hh_id2: gen count= _n ;
xtset hh_id2 wave;
replace count=1 if wave==3 & [L.NC_dob_ym==.];

gen update_ym = ym(year_birth_elnc, month_birth_elnc);
replace NC_dob_ym = update_ym if pregbl==0 & NC_dob_ym==. ;

twoway 	(histogram NC_dob_ym if count==1 & treatp==0, discrete fcolor(none) lpattern(dash) lcolor(red)  ) 
		(histogram NC_dob_ym if count==1 & treatp==1, discrete fcolor(none) lcolor(navy)) ,
		legend(label(1 "Control") label(2 "Treated") region(lwidth(none)) tstyle(body) ring(0) position(10) rows(1))
		graphregion(color(white)) bgcolor(white)
		xtitle("Date of birth") xlab(655 "Aug 2014" 667 "Aug 2015"  679 "Aug 2016" 691 "Aug 2017" 703 "Aug 2018") ;
		graph export "$graphs/dob_nonpreg.png", replace ;
	
cdfplot NC_dob_ym if count==1, by(treatp) 
		opt1(lpattern(dash))
		legend(label(1 "Control") label(2 "Treated") region(lwidth(none)) tstyle(body) ring(0) position(10) rows(1))
		graphregion(color(white)) bgcolor(white)
		xtitle("Date of birth") xlab(655 "Aug 2014" 667 "Aug 2015"  679 "Aug 2016" ) ;
		graph export "$graphs/dob_cdf_nonpreg.png", replace ;
					
restore ; 
