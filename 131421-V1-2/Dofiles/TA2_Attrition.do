*-----------------------------------------------------------------------------
* Attrition
*-----------------------------------------------------------------------------

*created by: lucy kraftman
*first created: 04/03/19


*----------------------------------------------------------------------------*
* 									SETUP									 *
*----------------------------------------------------------------------------*

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

*---------------------------------------------------------------------------*
* NECESSARY CLEANING
*---------------------------------------------------------------------------*

bys hh_id2(wave): carryforward OC_age attr_ml_oc, replace 

*---------------------------------------------------------------------------*

global hh "hhsize  PPI pcexp_aeq_usd fprob nchild02 nchild35 wpolyg_blv hrq1_08_iw"

bys hh_id2 (wave): carryforward $hh, replace

/* create interactions */
local vrs "insec_ml insec_el hhsize  PPI fprob pcexp_aeq_usd nchild02 nchild35 wpolyg_blv hrq1_08_iw"
foreach v of local vrs {
gen tr_`v' = `v'*(treatp==1)
}


lab var tr_hhsize		"T * household size"
lab var tr_insec_ml	"T * insecure at ML"
lab var tr_insec_el	"T * insecure at EL"

*---------------------------------------------------------------------------*
* TABLES
*---------------------------------------------------------------------------*
keep if wave==3
keep if pregbl==1

global todrop "tr_hhsize  tr_PPI  tr_pcexp_aeq_usd  tr_nchild02 tr_wpolyg_blv tr_fprob tr_hrq1_08_iw "
global hh "hhsize  PPI pcexp_aeq_usd fprob nchild02 nchild35 wpolyg_blv hrq1_08_iw"

rename ml_attr attr_ml_hh 
rename el_attr attr_el_hh

 

#delimit;

/* INCLUDING INSECURE */
local wave 			"ml el";
local wave0 		"ml";
local wave1 		"el";
local attrobj		"hh hus";
local attroc		"oc";
local attrnc		"nc";



foreach x of local attroc {;
foreach w of local wave0 {;
local interactions " tr_insec_`w' tr_hhsize  tr_PPI  tr_pcexp_aeq_usd  tr_nchild02  tr_wpolyg_blv  tr_fprob  tr_hrq1_08_iw ";

	/* plain */
	qui reg attr_`w'_`x'		i.treatp i.tranche				, robust cluster(PSU);
	estimates store		`w'_`x'0;
	qui su attr_`w'_`x'; /* mean of outcome */
	local meanoutc	= strtrim("`: di %10.3f r(mean)'");
	estadd local meanoutc "`meanoutc'";
	
	
	/* plain with insecurity */
	qui reg attr_`w'_`x'		i.treatp i.tranche insec_ml		, robust cluster(PSU);
	estimates store		`w'_`x'0i;
	qui su attr_`w'_`x'; /* mean of outcome */
	local meanoutc	= strtrim("`: di %10.3f r(mean)'");
	qui estadd local meanoutc "`meanoutc'";
	
	
	/* with controls */
	 reg attr_`w'_`x'		i.treatp i.tranche insec_ml  $hh	, robust cluster(PSU);
	estimates store		`w'_`x'1;
	qui test $hh ;	/* pvalue of controls */
	local pval_ctr	= strtrim("`: di %10.3f r(p)'");
	qui estadd local pctr "`pval_ctr'";
	qui su attr_`w'_`x'; /* mean of outcome */
	local meanoutc	= strtrim("`: di %10.3f r(mean)'");
	qui estadd local meanoutc "`meanoutc'";
	
	/* with controls + interactions */
	qui reg attr_`w'_`x'		i.treatp i.tranche insec_ml `interactions' $hh	, robust cluster(PSU);
	estimates store		`w'_`x'2;
	qui test $hh ;	/* pvalue of controls */
	local pval_ctr	= strtrim("`: di %10.3f r(p)'");
	qui estadd local pctr "`pval_ctr'";	
	qui test `interactions';	/* pvalue of interactions */
	local pval_int	= strtrim("`: di %10.3f r(p)'");
	qui estadd local pint "`pval_int'";	
	qui su attr_`w'_`x'; /* mean of outcome */
	local meanoutc	= strtrim("`: di %10.3f r(mean)'");
	qui estadd local meanoutc "`meanoutc'";
	};
	};
	
	
	
	foreach x of local attrnc {;
	foreach w of local wave1 {;
	local interactions "tr_insec_`w' tr_hhsize  tr_PPI  tr_pcexp_aeq_usd  tr_nchild02  tr_wpolyg_blv  tr_fprob  tr_hrq1_08_iw ";

	/* plain */
	qui reg attr_`w'_`x'		i.treatp i.tranche				, robust cluster(PSU);
	estimates store		`w'_`x'0;
	qui su attr_`w'_`x'; /* mean of outcome */
	local meanoutc	= strtrim("`: di %10.3f r(mean)'");
	estadd local meanoutc "`meanoutc'";
	
	
	/* plain with insecurity */
	qui reg attr_`w'_`x'		i.treatp i.tranche insec_`w'	insec_ml	, robust cluster(PSU);
	estimates store		`w'_`x'0i;
	qui su attr_`w'_`x'; /* mean of outcome */
	local meanoutc	= strtrim("`: di %10.3f r(mean)'");
	qui estadd local meanoutc "`meanoutc'";
	
	
	/* with controls */
	 reg attr_`w'_`x'		i.treatp i.tranche insec_`w' insec_ml $hh	, robust cluster(PSU);
	estimates store		`w'_`x'1;
	qui test $hh ;	/* pvalue of controls */
	local pval_ctr	= strtrim("`: di %10.3f r(p)'");
	qui estadd local pctr "`pval_ctr'";
	qui su attr_`w'_`x'; /* mean of outcome */
	local meanoutc	= strtrim("`: di %10.3f r(mean)'");
	qui estadd local meanoutc "`meanoutc'";
	
	/* with controls + interactions */
	qui reg attr_`w'_`x'		i.treatp i.tranche insec_`w' insec_ml `interactions' $hh	, robust cluster(PSU);
	estimates store		`w'_`x'2;
	qui test $hh ;	/* pvalue of controls */
	local pval_ctr	= strtrim("`: di %10.3f r(p)'");
	qui estadd local pctr "`pval_ctr'";	
	qui test `interactions';	/* pvalue of interactions */
	local pval_int	= strtrim("`: di %10.3f r(p)'");
	qui estadd local pint "`pval_int'";	
	qui su attr_`w'_`x'; /* mean of outcome */
	local meanoutc	= strtrim("`: di %10.3f r(mean)'");
	qui estadd local meanoutc "`meanoutc'";
	};
	};
	
	
	
	foreach x of local attrobj {; 
		foreach w of local wave {;
	local interactions "tr_insec_`w' tr_hhsize  tr_PPI  tr_pcexp_aeq_usd  tr_nchild02  tr_wpolyg_blv  tr_fprob  tr_hrq1_08_iw ";

	/* plain */
	qui reg attr_`w'_`x'		i.treatp i.tranche				, robust cluster(PSU);
	estimates store		`w'_`x'0;
	qui su attr_`w'_`x'; /* mean of outcome */
	local meanoutc	= strtrim("`: di %10.3f r(mean)'");
	estadd local meanoutc "`meanoutc'";
	
	
	/* plain with insecurity */
	qui reg attr_`w'_`x'		i.treatp i.tranche insec_`w' insec_ml		, robust cluster(PSU);
	estimates store		`w'_`x'0i;
	qui su attr_`w'_`x'; /* mean of outcome */
	local meanoutc	= strtrim("`: di %10.3f r(mean)'");
	qui estadd local meanoutc "`meanoutc'";
	
	
	/* with controls */
	 reg attr_`w'_`x'		i.treatp i.tranche insec_`w' insec_ml  $hh	, robust cluster(PSU);
	estimates store		`w'_`x'1;
	qui test $hh ;	/* pvalue of controls */
	local pval_ctr	= strtrim("`: di %10.3f r(p)'");
	qui estadd local pctr "`pval_ctr'";
	qui su attr_`w'_`x'; /* mean of outcome */
	local meanoutc	= strtrim("`: di %10.3f r(mean)'");
	qui estadd local meanoutc "`meanoutc'";
	
	/* with controls + interactions */
	qui reg attr_`w'_`x'		i.treatp i.tranche insec_`w' insec_ml `interactions' $hh	, robust cluster(PSU);
	estimates store		`w'_`x'2;
	qui test $hh ;	/* pvalue of controls */
	local pval_ctr	= strtrim("`: di %10.3f r(p)'");
	qui estadd local pctr "`pval_ctr'";	
	qui test `interactions';	/* pvalue of interactions */
	local pval_int	= strtrim("`: di %10.3f r(p)'");
	qui estadd local pint "`pval_int'";	
	qui su attr_`w'_`x'; /* mean of outcome */
	local meanoutc	= strtrim("`: di %10.3f r(mean)'");
	qui estadd local meanoutc "`meanoutc'";
	};
};


global todrop "tr_hhsize  tr_PPI  tr_pcexp_aeq_usd  tr_nchild02  tr_wpolyg_blv  tr_fprob  tr_hrq1_08_iw ";


/* export table */
esttab   el_hh0i el_hh1 el_hh2 el_hus2 ml_oc2 el_nc2 
		using "$tables/attrition_p.csv", replace
		b(3) se label noabbrev nobaselevels nonotes nogaps
		order(1.treatp insec_ml insec_el  `inter_ml' `inter_el')
		drop(_cons nchild02 nchild35 PPI wpolyg_blv $hh $todrop) 
		indicate("Rand. Strata = *tranche")
		scalars("meanoutc Attrition rate" "pctr Joint p of covars" "pint Joint p of interactions")
		note("Controls are: `controls'. Interactions are between Treatment indicator and: `intvrs'")
		;


*----- lee bounds
		
		
		