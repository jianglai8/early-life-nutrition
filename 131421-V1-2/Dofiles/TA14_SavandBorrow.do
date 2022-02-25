***-------------------------------------------------------------------------------------------------------------
*** 	CDGP BMEL Finances additional
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

#delimit;


/****************************************************************************/
/* ADDITIONAL FINANCES																*/
/****************************************************************************/


#delimit;


local finance 		
					anysav2	anyborr  	anyfail 	mq5b_06 totloan_usd;



efftabbl `finance' if pregbl==1, out("$tables/financesd_p.xlsx") title("finance det, preg") 
				controls(i.lga_id i.tranche ) options(robust cluster(PSU)) ;

