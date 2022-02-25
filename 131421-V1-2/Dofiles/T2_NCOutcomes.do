
*-----------------------------
* NC OUTCOMES
*-----------------------------


*** SET FOLDER PATH IF NEEDED
/*
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

#delimit;

				
local vars  NC_dob_ym nc_haz_who nc_stn_who nc_sstn_who nc_waz_who nc_whz_who	nc_muac nc_maln nchealth_aind ncq1b_01 ncq1b_05 ;

				
*-----------------------------
* tables
*-----------------------------

#delimit;


efftab `vars' if pregbl==1, out("$tables/s9_ncanthro_p.xlsx") title("ML C Anthro, preg") 
				controls(i.lga_id i.tranche  ) options(robust cluster(PSU));
				
			
				
				