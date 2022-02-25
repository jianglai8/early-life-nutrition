***-------------------------------------------------------------------------------------------------------------
*** 	Diet diversity and food expenditure
*** 	
***-------------------------------------------------------------------------------------------------------------

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

/****************************************************************************/
* FOOD EXPENDITURE

#delimit;

global food fgrexp_mdd1 fgrexp_mdd2 fgrexp_mdd3 fgrexp_mdd4and5 fgrexp_mdd6 fgrexp_mdd7 fgrexp_oilsauce fgrexp_sugardrink  ;

foreach v in $food {;
	qui su `v', det;
	replace `v'=. if `v' > r(p99);		/* trim */
	replace `v'= `v' *xr; 				/* to USD */
	replace `v'= `v'/7*30; 			/* to monthly */
	gen l`v' = log(`v'); 	/*log so we have percentage*/

};

global lfood lfgrexp_mdd1 lfgrexp_mdd2 lfgrexp_mdd3 lfgrexp_mdd4and5 lfgrexp_mdd6 lfgrexp_mdd7 fgrexp_oilsauce fgrexp_sugardrink  ;

efftab	$food if pregbl==1, out("$tables/fexp_p.xlsx") title("Food exp, preg") 
				controls(i.lga_id i.tranche) options(robust cluster(PSU)) ;
				

/****************************************************************************/
* DIET DIVERSITY


lab var ncMDD4	"4+ Food groups";
lab var ncmddfgroup1	"Grains, roots, tubers";
lab var ncmddfgroup2	"Legumes and nuts";
lab var ncmddfgroup3	"Dairy products";
lab var ncmddfgroup4	"Flesh foods";
lab var ncmddfgroup5	"Eggs";
lab var ncmddfgroup6	"Vit-A rich fruit and veg";
lab var ncmddfgroup7	"Other fruit and veg";
lab var ncmddfgroup4and5 "Flesh foods and eggs";


local dvars		ncMDD ncMDD4 ncmddfgroup1 ncmddfgroup2 ncmddfgroup3 ncmddfgroup4 ncmddfgroup5 ncmddfgroup6 ncmddfgroup7  ;


efftab `dvars' if pregbl==1, out("$tables/ncdiet_p.xlsx") title("NC diet, preg") 
				controls(i.lga_id i.tranche `allXnc') options(robust cluster(PSU)) ancova;