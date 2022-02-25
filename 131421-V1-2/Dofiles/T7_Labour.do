***-------------------------------------------------------------------------------------------------------------
*** 	CDGP BMEL Work
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
/* TABLES																	*/
/****************************************************************************/
#delimit;

recode wmaxdays mmaxdays (98=.);

local wovars 	wq3a_01 wact_mult whpayjobdays wwork_selfemp wactfreq36 wactfreq1 wtotinpexp wanyanim wearnings;
			

				
efftabbl `wovars' if pregbl==1, out("$tables/work_woman_p.xlsx") title("Woman work, preg") 
				controls(i.lga_id i.tranche) options(robust cluster(PSU));
				

local mvars 	mq2a_01 mact_mult mhpayjobdays mwork_selfemp mactfreq1 mtotinpexp mearnings
				mearnings;

efftabbl `mvars' if pregbl==1, out("$tables/work_husband_p.xlsx") title("Husband work, preg") 
				controls(i.lga_id i.tranche) options(robust cluster(PSU)) ;
