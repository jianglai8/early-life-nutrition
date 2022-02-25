
*-----------------------------
* NC OUTCOMES BY T1 T2
*-----------------------------

/*
*** SET FOLDER PATH
		if c(username)=="lucy_k"{
		global main "/Users/lucy_k/Dropbox/IFS/CDGP_analysis/15 paper_lk"
	}
	
	global data "$main/data"
	global graphs "$main/Output/Graphs"
	global tables "$main/Output/Tables"
*/

use "$data/final_lk", clear


*CLEAN* 

#delimit;

lab var wq10bml_01_1r	"Not Enough Food during Kaka 2015 (MidOct to Dec)";		
lab var wq10bml_01_2r	"Not Enough Food during Sanyi (Dec to Feb)";		
lab var wq10bml_01_3r	"Not Enough Food during Rani (Mar to May)";		
lab var wq10bml_01_4r	"Not Enough Food during Damuna (Jun to MidOct)";


tabrrd, stub(copeall) cut(0.01);
tabrrd, stub(nofoodall) cut(0.03);


recode wmaxdays mmaxdays (98=.);
			

foreach v of local expvars {;
	gen l`v' = log(`v');
	gen l`v'eq = log(`v'eq);
	replace `v' = `v'/1000;
	replace `v'eq = `v'eq/1000;

};

/* share of budget on food */
gen foodexp_share = totfoodexp_musd/ totexp_musd ;

/* per capita equivalised food */

gen pcexp_aeq_food_usd = totfoodexp_mequsd/(hhsize*30) ; 


/* net resources */
gen net_resources_usd = totwmincome_grant  + totsav20 - totborr_usd ;

/* make ppi proportion rather than percent */
replace PPI = PPI/100;


lab var totfoodexp_musd 		"Monthly Food Exp USD PPP ";
lab var totnfexp_musd 		"Monthly Non-Food Exp USD PPP";
lab var foodexp_share		"Monthly Food Expenditure Share of Total";
lab var totdurexp_musd 		"Monthly Durables Exp USD PPP";
lab var totexp_musd			"Total Monthly Exp USD PPP";
lab var totfoodexp_mequsd 		"Equivalised Monthly Food Exp USD ";
lab var totnfexp_mequsd 		"Equivalised Monthly Non-Food Exp USD ";
lab var totdurexp_mequsd 		"Equivalised Monthly Durables Exp USD ";
lab var totexp_mequsd			"Total Equivalised Monthly Exp USD ";
lab var pcexp_aeq_usd			"Per capita equivalised daily expenditure" ; 
lab var pcexp_aeq_food_usd			"Equalized daily per capita food expenditure" ; 
lab var net_resources_usd  		"Net Resources" ; 



*-----------------------------
* tables
*-----------------------------

#delimit;

local vars NC_dob_ym  nc_haz_who nc_stn_who nc_sstn_who  nc_waz_who nc_whz_who 	nc_muac nc_maln nchealth_aind ncq1b_01 ncq1b_05 ncq1b_09 ncq1b_10 wkap_aind mkap_aind ncpract_aind ncanyac nccolostr ncbhf nciycf1  ebf_6m nchealthbe_aind ncq1a_02 ncvacc_allbasic ncMDD wq10a_04 wq10a_08 wq10a_06 fprob wq3a_01 wact_mult whpayjobdays wwork_selfemp wactfreq36 wactfreq1 wtotinpexp wanyanim wearnings mq2a_01 mact_mult mhpayjobdays mwork_selfemp mactfreq1 mtotinpexp mearnings  totfoodexp_musd totexp_musd foodexp_share totsav2_usd totborr_usd net_resources_usd PPI;



efftab_t1t2 `vars' if pregbl==1, out("$tables/ncoutcomes_t1t2.xlsx") title("All, preg") 	controls(i.lga_id i.tranche) options(robust cluster(PSU));
				
			