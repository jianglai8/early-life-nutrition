
*-----------------------------
* TIME ALLOCATION
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
label var nctimespent1 "Time spent < 2 hrs"
label var nctimespent2 "Time spent 2-5 hrs"
label var nctimespent3 "Time spent > 5 hrs"
label var nctimeplay1 "Time play < 2 hrs"
label var nctimeplay2 "Time play 2-5 hrs"
label var nctimeplay3 "Time play > 5 hrs"

label var ncASQcomm_agestd "Communication Skills (Standardised)"
label var ncASQmoto_agestd "Motor Skills (Standardised)"
label var ncASQpsoc_agestd "Personal-Social Skills (Standardised)"

local nctime nctimespent1 nctimespent2 nctimespent3  nctimeplay1 nctimeplay2 nctimeplay3  ncASQcomm_agestd ncASQcommref ncASQmoto_agestd ncASQmotoref ncASQpsoc_agestd ncASQpsocref
	
	
efftab `nctime' if pregbl==1, out("$tables/nctimeandasq_p.xlsx") title("time, preg") ///
				controls(i.lga_id i.tranche) options(robust cluster(PSU))
		