
/****************************************************************************/
/*P - VALUE CORRECTIONS	RW wolfs											*/
/****************************************************************************/

/*
*** SET FOLDER PATH
		if c(username)=="lucy_k"{
		global main "/Users/lucy_k/Dropbox/IFS/CDGP_analysis/15 paper_lk"
		}
	
	
	global data "$main/data"
	global graphs "$main/Output/Graphs"
	global rw "$main/Output/Tables"
*/

use "$data/final_lk", clear


/******************************************************************************/
* MAKE WIDE SO CAN TEST ML AND EL

/* anthroprometrics */


preserve
keep wave treatp hh_id2 lga_id tranche  PSU nc_haz_who nc_stn_who nc_sstn_who nc_waz_who nc_whz_who nc_wst_who nc_swst_who nc_muac nc_maln
reshape wide nc_haz_who nc_stn_who nc_sstn_who nc_waz_who nc_whz_who nc_wst_who nc_swst_who nc_muac nc_maln, i(hh_id2) j(wave)
local vars nc_haz_who2 nc_stn_who2 nc_sstn_who2 nc_haz_who3 nc_stn_who3 nc_sstn_who3 nc_waz_who2 nc_waz_who3 nc_whz_who2 nc_whz_who3  nc_muac2 nc_muac3 nc_maln2 nc_maln3
t_bootstrap `vars' , strata(tranche) controls( lga_id ) b(1000) cluster(PSU) setname(rw_anthrop) treatment(treatp) sided(2)
restore

 
/* health */
preserve
keep wave treatp  hh_id2 lga_id tranche PSU ncq1b_01 ncq1b_05
reshape wide ncq1b_01 ncq1b_05, i(hh_id2) j(wave)
local vars ncq1b_012 ncq1b_052 ncq1b_013 ncq1b_053
t_bootstrap `vars' , strata(tranche) controls( lga_id ) b(1000) cluster(PSU) setname(rw_health) treatment(treatp) sided(2)
restore
*/

/* labour activities */

preserve
keep wave treatp  hh_id2 lga_id tranche PSU   wq3a_01 wact_mult whpayjobdays mq2a_01 mact_mult mhpayjobdays
reshape wide   wq3a_01 wact_mult whpayjobdays mq2a_01 mact_mult mhpayjobdays, i(hh_id2) j(wave)
local vars  wq3a_012 wact_mult2 whpayjobdays2 mq2a_012 mact_mult2 mhpayjobdays2  wq3a_013 wact_mult3 whpayjobdays3 mq2a_013 mact_mult3 mhpayjobdays3
t_bootstrap `vars' , strata(tranche) controls( lga_id ) b(1000) cluster(PSU) setname(rw_labouracts) treatment(treatp) sided(2)
restore

/* activity type */

preserve 
keep wave treatp  hh_id2 lga_id tranche PSU  wwork_selfemp wactfreq36 mwork_selfemp mactfreq1
reshape wide  wwork_selfemp wactfreq36 mwork_selfemp mactfreq1, i(hh_id2) j(wave)
local vars wwork_selfemp2 wactfreq362 mwork_selfemp2 mactfreq12 wwork_selfemp3 wactfreq363 mwork_selfemp3 mactfreq13
t_bootstrap `vars' , strata(tranche) controls( lga_id ) b(1000) cluster(PSU) setname(rw_acttype) treatment(treatp) sided(2)
restore


/* investments */
preserve
keep wave treatp  hh_id2 lga_id tranche PSU wtotinpexp wanyanim mtotinpexp 
reshape wide  wtotinpexp wanyanim mtotinpexp , i(hh_id2) j(wave)
local vars  wanyanim2  wtotinpexp3 wanyanim3 mtotinpexp3
t_bootstrap `vars' , strata(tranche) controls( lga_id ) b(1000) cluster(PSU) setname(rw_invest) treatment(treatp) sided(2)
restore




*CLEAN* 
/* share of budget on food */
gen foodexp_share = totfoodexp_musd/ totexp_musd
replace foodexp_share = foodexp_share*10

/* per capita equivalised food */

gen pcexp_aeq_food_usd = totfoodexp_mequsd/(hhsize*30) 


/* net resources */

gen net_resources_usd = totwmincome_grant  + totsav20 - totborr_usd 

/* exp */
preserve
keep wave treatp  hh_id2 lga_id tranche PSU totfoodexp_musd totexp_musd foodexp_share
reshape wide  totfoodexp_musd totexp_musd foodexp_share , i(hh_id2) j(wave)
local vars totfoodexp_musd2 totexp_musd2 foodexp_share2 totfoodexp_musd3 totexp_musd3 foodexp_share3
t_bootstrap `vars' , strata(tranche) controls( lga_id ) b(1000) cluster(PSU) setname(rw_exp) treatment(treatp) sided(2)
restore 

/* saving and borrowing */
preserve
keep wave treatp  hh_id2 lga_id tranche PSU totsav2_usd totborr_usd 
reshape wide totsav2_usd totborr_usd  , i(hh_id2) j(wave)
local vars totsav2_usd2 totborr_usd2  totsav2_usd3 totborr_usd3
t_bootstrap `vars' , strata(tranche) controls( lga_id ) b(1000) cluster(PSU) setname(rw_sav) treatment(treatp) sided(2)
restore

/* resources */
preserve
keep wave treatp  hh_id2 lga_id tranche PSU net_resources_usd PPI
reshape wide  net_resources_usd PPI , i(hh_id2) j(wave)
local vars net_resources_usd2 PPI2 net_resources_usd3 PPI3
t_bootstrap `vars' , strata(tranche) controls( lga_id ) b(1000) cluster(PSU) setname(rw_resources) treatment(treatp) sided(2)
restore
*/

******* 
* WITH LASSO CONTROLS
*******

/* anthroprometrics */


preserve
keep wave treatp hh_id2 lga_id tranche  PSU nc_haz_who nc_stn_who nc_sstn_who nc_waz_who nc_whz_who nc_wst_who nc_swst_who nc_muac nc_maln $baseX
reshape wide nc_haz_who nc_stn_who nc_sstn_who nc_waz_who nc_whz_who nc_wst_who nc_swst_who nc_muac nc_maln, i(hh_id2) j(wave)
local vars nc_haz_who2 nc_stn_who2 nc_sstn_who2 nc_haz_who3 nc_stn_who3 nc_sstn_who3 nc_waz_who2 nc_waz_who3 nc_whz_who2 nc_whz_who3  nc_muac2 nc_muac3 nc_maln2 nc_maln3
t_bootstrap `vars' , strata(tranche) controls( lga_id $baseX ) b(1000) cluster(PSU) setname(rw_anthrop_c) treatment(treatp) sided(2)
restore

 
/* health */
preserve
keep wave treatp  hh_id2 lga_id tranche PSU ncq1b_01 ncq1b_05 $baseX
reshape wide ncq1b_01 ncq1b_05, i(hh_id2) j(wave)
local vars ncq1b_012 ncq1b_052 ncq1b_013 ncq1b_053
t_bootstrap `vars' , strata(tranche) controls( lga_id $baseX ) b(1000) cluster(PSU) setname(rw_health_c) treatment(treatp) sided(2)
restore
