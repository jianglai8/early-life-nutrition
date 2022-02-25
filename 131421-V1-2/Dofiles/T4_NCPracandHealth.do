

/****************************************************************************/
/* NC PRACTICES																*/
/****************************************************************************/

set maxvar 10000

*** SET FOLDER PATH IF NEEDED 
		if c(username)=="lucy_k"{
		global main "/Users/lucy_k/Dropbox/IFS/CDGP_analysis/15 paper_lk"
		}
	
	
	global data "$main/data"
	global graphs "$main/Output/Graphs"
	global tables "$main/Output/Tables"


use "$data/final_lk", clear


#delimit ;



/****************************************************************************/
/* regs																	*/
/****************************************************************************/


local vars			ncpract_aind ncq2a_01 nccolostr ncbhf nciycf1  ebf_6m nchealthbe_aind ncq1a_02 ncvacc_allbasic ncq1b_09 ncq1b_10 ;
					


										
efftab `vars' if pregbl==1, out("$tables/ncpractices_p.xlsx") title("NC practices, preg") 
				controls(i.lga_id i.tranche) options(robust cluster(PSU));

