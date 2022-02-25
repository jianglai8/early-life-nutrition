*--------------------------------------------------------------
* Figure OUTCOMES ITT
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

/* net resources */
gen net_resources_usd = totwmincome_grant  + totsav20 - totborr_usd ;


local var wtotinpexp wearnings totfoodexp_musd net_resources_usd   ;

lab var wtotinpexp "Woman's Monthly expenditure on wife's business inputs";
lab var mtotinpexp "Husband's Input Expenditure";
lab var wearnings "Woman's Total monthly earnings from employed and self-employed activities";
lab var mearnings "Husband's Earnings";
lab var net_resources_usd "Change in Net Resources";
lab var totfoodexp_musd "Monthly Food Expenditure";

effplot3 `var'
			if pregbl==1, out("$graphs/resources_fig.eps")
			controls(i.lga_id i.tranche) options(robust cluster(PSU))
			barxlab("Mean (%)") effxlab("ITT (USD)") 
			ysize(15) xsize(9) 
			;

			save "$graphs/fig4.gph", replace