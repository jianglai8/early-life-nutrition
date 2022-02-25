***-------------------------------------------------------------------------------------------------------------
*** 	CDGP BMEL Assets and Expenditures
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

/* define controls */

use "$data/final_lk", clear 





/****************************************************************************/
/* AGGREGATE EXPENDITURE													*/
/****************************************************************************/
#delimit ;


local expvars 	totfoodexp_m totnfexp_m totdurexp_m totexp_m;
foreach v of local expvars {;
	gen l`v' = log(`v');
	gen l`v'eq = log(`v'eq);
};


/* per capita equivalised food */

gen pcexp_aeq_food_usd = totfoodexp_mequsd/(hhsize*30) ; 


/* net resources */
gen net_resources_usd = totwmincome_grant  + totsav20 - totborr_usd ;

/* make ppi proportion rather than percent */
replace PPI = PPI/100;


lab var totfoodexp_musd 		"Monthly Food Exp USD PPP ";
lab var totnfexp_musd 		"Monthly Non-Food Exp USD PPP";
lab var totdurexp_musd 		"Monthly Durables Exp USD PPP";
lab var totexp_musd			"Total Monthly Exp USD PPP";
lab var totfoodexp_mequsd 		"Equivalised Monthly Food Exp USD ";
lab var totnfexp_mequsd 		"Equivalised Monthly Non-Food Exp USD ";
lab var totdurexp_mequsd 		"Equivalised Monthly Durables Exp USD ";
lab var totexp_mequsd			"Total Equivalised Monthly Exp USD ";
lab var pcexp_aeq_usd			"Per capita equivalised daily expenditure" ; 
lab var pcexp_aeq_food_usd			"Equalized daily per capita food expenditure" ; 
lab var net_resources_usd  		"Net Resources" ; 



local expvars	totfoodexp_musd totexp_musd foodshare totsav2_usd totborr_usd net_resources_usd PPI;

efftabbl `expvars' if pregbl==1, out("$tables/finances_p.xlsx") title("Finances, preg") 
				controls(i.lga_id i.tranche) options(robust cluster(PSU));

