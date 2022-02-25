*--------------------------------------------------------------
* FA45 VACC FIGURE 
*--------------------------------------------------------------

set more off
set mem 800m
set matsize 11000

*** SET FOLDER PATH IF NEEDED 
/*
		if c(username)=="lucy_k"{
		global main "/Users/lucy_k/Dropbox/IFS/CDGP_analysis/15 paper_lk"
	}
	
	global data "$main/Data"
	global graphs "$main/Output/Graphs"
	global tables "$main/Output/Tables"
*/




use "$data/final_lk", clear

*--------------------------------------------------------------

#delimit;
local ncvacc ncvacc_BCG ncvacc_polio ncvacc_DPT  ncvacc_measles ncvacc_hepb ncvacc_yfev ;

effplot3 `ncvacc'
			if pregbl==1, out("$graphs/ncvacc_fig.eps")
			controls(i.lga_id i.tranche ) options(robust cluster(PSU))
			barxlab("Mean (%)") effxlab("ITT (PP)")
			ysize(10) xsize(9)
			;
