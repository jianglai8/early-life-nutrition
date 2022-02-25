
*-----------------------------
* ANTRHO  by gender
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
* clean
*-----------------------------

	#delimit;

local ncvars 	
				nc_haz_who nc_stn_who nc_sstn_who 
				nc_waz_who
				nc_whz_who 
				nc_muac nc_maln;
				

/* GENDER OPTIONS */
	#delimit;
efftab `ncvars' if pregbl==1 & NC_gend==1, out("$tables/ncanthro_m_p.xlsx") title("ML C Anthro M, preg") 
				controls(i.lga_id i.tranche NC_gend) options(robust cluster(PSU)) ;
efftab `ncvars' if pregbl==1 & NC_gend==2, out("$tables/ncanthro_f_p.xlsx") title("ML C Anthro F, preg") 
				controls(i.lga_id i.tranche 
				NC_gend) options(robust cluster(PSU)) ;

	
recode NC_gend (2=0) ;

*-----------------------------
* test difference in gender
*-----------------------------

**********************************************************************/

#delimit;
quietly foreach v in n_ml mean_ml effect_ml p_val_ml n_el mean_el effect_el pvml pvel { ;
gen double `v' = .;
};

quietly foreach v in vlab { ;
gen `v' = "";
};

local i = 1;
foreach v of local ncvars {;
replace vlab = "`v'" in `i' ;

reg `v' i.treatp##i.wave##NC_gend i.lga_id i.tranche if `v'!=., robust cluster(PSU);
test 1.treatp#1.NC_gend = 0  ; /* test at ml */
replace pvml =  r(p) in `i' ;
test 1.treatp#1.NC_gend + 1.treatp#3.wave#1.NC_gend = 0; /* test at el */
replace pvel =  r(p) in `i'  ;
local i = `i' + 1;
} ; 

format pv* %9.3g;
	#delimit;
listtab vlab pvml pvel  in  1/`i' using "$tables/ncanthro_gendertest.csv", delimit(",") replace ;


