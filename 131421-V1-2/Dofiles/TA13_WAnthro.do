
*-----------------------------
* WOMEN ANTHRO
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

/* keep only CDGP child pregnant at baseline */
 use "$data/final_lk.dta", clear
keep if pregbl == 1


*-----------------------------
* CLEAN
*-----------------------------
#delimit;

local wmanvars	 		wm_weight wm_height wm_bmi wm_thin wm_norm wm_owt wm_muac mmaln1 smaln1;		
sum `wmanvars';



efftab	`wmanvars' if  pregml==0 & pregel==0, out("$tables/womanthro_p.xlsx") title("W anthro") 
				controls(i.lga_id i.tranche ) options(robust cluster(PSU)) ;

		