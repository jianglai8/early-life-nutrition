***-------------------------------------------------------------------------------------------------------------
*** 	CDGP BMEL Land
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

#delimit ;


/****************************************************************************/				
/* LIVESTOCK */
/****************************************************************************/

/****************************************************************************/
* household 
*------------------------

lab var hhownany		"HH Owns Any Animals";

recode mq3_numcowbull  mq3_numcalf mq3_numsheep mq3_numgoat mq3_numcamel mq3_numdonk (9998=.) ; 

local hhvars	hhownany	 mq3_anygoat mq3_anychick mq3_anysheep mq3_anycamel mq3_anycowbull mq3_anydonk  mq3_anyguinea mq3_anycalf ;
					
efftab `hhvars' if pregbl==1, out("$tables/livestock_hh_p.xlsx") title("LS owned, preg") 
				controls(i.lga_id i.tranche ) options(robust cluster(PSU));


			
*---------------------------
/* woman */
*-------------------------


recode wq9_num* (9998=.);
egen womownany = rowtotal(wq9_anycowbull wq9_anycalf wq9_anysheep wq9_anygoat wq9_anycamel wq9_anychick wq9_anyguinea wq9_anydonk), mi;
recode womownany (1/max=1);


local wvars 		womownany 
					wq9_anygoat wq9_anychick wq9_anysheep wq9_anycamel wq9_anycowbull wq9_anydonk  wq9_anyguinea wq9_anycalf
				 ;

efftab `wvars' if pregbl==1, out("$tables/ls_wom_p.xlsx") title("LS woman, preg") 
				controls(i.lga_id i.tranche ) options(robust cluster(PSU));
