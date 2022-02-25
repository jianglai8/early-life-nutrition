
*-----------------------------
* SEASONAL FLUCTUATION
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

keep if pregbl==1

#delimit;



/* SEASONS ------------------------------------------------------------------ */


lab var wq10bml_01_1r	"Not Enough Food during Kaka 2015 (MidOct to Dec)";		
lab var wq10bml_01_2r	"Not Enough Food during Sanyi (Dec to Feb)";		
lab var wq10bml_01_3r	"Not Enough Food during Rani (Mar to May)";		
lab var wq10bml_01_4r	"Not Enough Food during Damuna (Jun to MidOct)";

lab var copeall21		"Reduced Condiment/Sauce in Meals";	


tabrrd, stub(copeall) cut(0.01);
tabrrd, stub(nofoodall) cut(0.03);



local fsvars 	fprob wq10bml_01_1r wq10bml_01_2r wq10bml_01_3r wq10bml_01_4r
						nofoodall8 oth_nofoodall nofoodall4 nofoodall5
						copeall11 copeall9 copeall21 copeall12 copeall10 copeall1 copeall23
						;


efftab	`fsvars' if pregbl==1, out("$tables/foodsec_p.xlsx") title("Food sec, preg") 
				controls(i.lga_id i.tranche) options(robust cluster(PSU)) ;

				
