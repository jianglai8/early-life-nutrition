
*-----------------------------
* ANTRHO age adjusted
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

local ncvars 	nc_haz_who nc_stn_who nc_sstn_who nc_waz_who	nc_whz_who 	nc_muac nc_maln
								
*-----------------------------
* tables
*-----------------------------
		
/* adjustment options */

** non para

efftab `ncvars' if pregbl==1, out("$tables/ncanthro_age_p.xlsx") title("ML C Anthro, preg") controls(i.lga_id i.tranche i.NC_age_a) options(robust cluster(PSU)) 
				
** cubic

efftab `ncvars' if pregbl==1, out("$tables/s9_ncanthro_append_agecube_p.xlsx") title("ML C Anthro, preg") controls(i.lga_id i.tranche NC_age NC_age_sq NC_age_cub) options(robust cluster(PSU)) 
				
				
** CF 


* sum stats on dates of intereview
drop month_int
gen month_int = .

gen date_int_temp = date_int 
bys wave: egen first_int = min(date_int_temp) /* first interview */
bys wave: replace month_int = 1 if date_int_temp <= first_int + 30 & date_int_temp !=.
bys wave: replace month_int = 2 if date_int_temp <= first_int + 60 & date_int_temp !=. & date_int_temp > first_int + 30
bys wave: replace month_int = 3 if date_int_temp <= first_int + 90 & date_int_temp !=. & date_int_temp > first_int + 60

	
/* bootstrap repetitions ****************************************************/
local numboot = 1000
/****************************************************************************/
#delimit;

tempname efftab;
tempfile effects;
postfile `efftab' 
    str100 varname 
    str100 varlab
	str100 effectadjmlcf
	str100 semlcf 
	str100 effectadjelcf 
	str100 seelcf

	using "`effects'", replace;

	 #delimit cr
	 
local wave ml el
local nvars nc_haz_who nc_stn_who nc_sstn_who nc_waz_who  nc_whz_who nc_muac nc_maln 

gen treatXwave = treatp*wave

foreach var of local nvars {

 local vlab: variable label `var'
 
preserve

	reg NC_age i.treatp date_int  i.lga_id i.tranche, robust cluster(PSU)
	predict cfres, r
	gen cfres2 = cfres^2
	gen cfres3 = cfres^3
	
	/* age adjusted effect */
	reg `var' i.treatp##i.wave i.NC_age_a  i.lga_id i.tranche cfres cfres2 cfres3, robust cluster(PSU)
	test cfres cfres2 cfres3
	local eacfml = _b[1.treatp]  
	lincom 1.treatp + 1.treatp#3.wave
	local eacfel =  r(estimate) 
	 
restore

	
	
	/* BOOTSTRAP EFFECTS */
	mat effsml_cf = J(`numboot', 1, .)
	mat effsel_cf = J(`numboot', 1, .)
	mat effsel_1 = J(`numboot', 1, .)
	mat effsel_2 = J(`numboot', 1, .)
	forvalues b=1(1)`numboot' {
		preserve	
			bsample, cluster(PSU) 
			qui {
				reg NC_age i.treatp date_int 	 i.lga_id i.tranche, robust cluster(PSU)
				eststo s1
				predict cfres, r
				gen cfres2 = cfres^2
				gen cfres3 = cfres^3
				esttab s1 using "$tables/cf_firststage.csv", replace
				
				/* age adjusted effect */
				reg  `var' i.treatp##i.wave i.NC_age_a 	 i.lga_id i.tranche cfres cfres2 cfres3, robust cluster(PSU)
				margins, dydx(treatp) post
				mat marg_R2 = r(table)
				mat effsml_cf[`b',1] = marg_R2[1,2]
				
				reg `var' i.treatp i.wave treatXwave i.NC_age_a  i.lga_id i.tranche cfres cfres2 cfres3, robust cluster(PSU)
				margins, dydx(treatp treatXwave wave) post
				mat marg_R2 = r(table)
				mat effsel_cf[`b',1] = marg_R2[1,2] + marg_R2[1,5]
				mat effsel_1[`b',1] = marg_R2[1,2]
				mat effsel_2[`b',1] = marg_R2[1,5]
			
			}
		restore
	}
	
	
	
	
	
	/* standard errors */
	
	foreach x of local wave {
		mata: effsm`x'_cf = st_matrix("effs`x'_cf"); 					/* get matrix of effects into mata */
		mata: sdseffsm`x'cf = sqrt(variance(effsm`x'_cf))			/* compute standard error and get back to stata */
		mata: st_matrix("sdseffs`x'cf", sdseffsm`x'cf)
		local seff`x'cf = sdseffs`x'cf[1,1]

	}	
	

	post `efftab' 	("`var'") ("`vlab'")  ("`eacfml'") ("`seffmlcf'") ("`eacfel'") ("`seffelcf'")

	}

	
postclose `efftab'
use `effects', clear
save "$tables/res_ncanthro_ageg_cf.dta", replace
list


/****************************************************************************/
/* MAKE TABLES																*/
/****************************************************************************/
#delimit ;
use "$tables/res_ncanthro_ageg_cf.dta", clear;

destring semlcf seelcf effectadjml effectadjel, replace;
gen var_ml = semlcf^2;
gen var_el = seelcf^2;

gen test_mlel = (effectadjml-effectadjel)/sqrt(var_ml+var_el);
gen p_mlel =  2*normal(-abs(test_mlel));

listtab varlab  effectadjmlcf semlcf  effectadjelcf seelcf test_mlel  using "$tables/cf_output.csv", replace delimit(",") head(,"Age-adjusted + CF ITT, Midline","SE ML","Age-adjusted + CF ITT, Endline","SE EL","ML=EL") ;


 



