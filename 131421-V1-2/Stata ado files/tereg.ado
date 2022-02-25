
/*
********************************************************************************
// TEREG -  inner function to compute CDGP effects
********************************************************************************
// Arguments:
// controls 						-  controls to be used in effects regression
// options 							-  options to be used in effects regression
// balanced 						-  balanced or unbalanced panel
// ancova	 						-  ANCOVA specification
// meandig							-  digits after the comma for mean
********************************************************************************
*/



/* to add ANCOVA (controlling for BL level) 
use carryforward by generating new BL variable 
and then add to controls 
*/



#delimit ;

cap program drop tereg;
	
program define tereg, rclass;
	
	syntax varlist(max=1)  [if], 
								controls(varlist numeric ts fv) 
								[
								options(string)
								BALanced
								ANCova
								meandig(integer 2)
								];
	
	marksample touse;
	local outc: word 1 of `varlist';
	
	qui {;
	
	if "`ancova'" != "" {;
	gen `outc'_bl = `outc' if wave==1;
	count if `outc'_bl!=.; local numanc = r(N);
	if (`numanc'>0) {;
		bysort hh_id2: carryforward `outc'_bl , replace;
		local controls `outc'_bl `controls';
		};
	};
	
	if "`balanced'" != "" {;
	/* CARRY EL/ML MISSINGNESS */
	tempvar nonmissel nonmissml;
	gen `nonmissel' = `outc'!=. if wave==3;
	gsort hh_id2 -wave;
	bysort hh_id2: carryforward `nonmissel' , replace;
	gsort hh_id2 wave;
	gen `nonmissml' = `outc'!=. if wave==2;
	bysort hh_id2: carryforward `nonmissml' , replace;
	tempvar tousef ; /* final touse sample */
	gen `tousef' = `touse' & `nonmissel' & `nonmissml' & inlist(wave,2,3);
	};
	else {;
		tempvar tousef ; /* final touse sample */
		gen `tousef' = `touse' & inlist(wave,2,3);
	};
	
	/* COUNT ----------------------------- */
	/* observations at both waves */
	qui count if `outc'!=. & wave==2 & `tousef'; 
	local numml		= r(N);
	return local numml = `numml';
	/* observations at EL only */
	qui count if `outc'!=. & wave==3 & `touse';
	local numel		= r(N);
	return local numel = `numel';

	qui su `outc';		/* check if dummy to report SD */
	if (inlist(r(max),0,1)) 	scalar dummy=1;
	if (!inlist(r(max),0,1)) 	scalar dummy=0;

	/*******************************************************************************
	**** ML + EL EFFECTS			************************************************
	*******************************************************************************/

	if (`numml' > 0 & `numel'>0) {;
		return local num = `numml';
		return local numml = `numml';
		
		/* C mean at ML */	
		return local csdml		= "";
		qui su `outc' if treat==0 & wave==2 & `tousef';
		return local cmeanml		= strtrim("`: di %9.3g r(mean)'");
		if (dummy==0) return local csdml	= "(" + strtrim("`: di %9.3g r(sd)'") + ")";
		return local ncmeanml		= r(mean);
		
		/* C mean at EL */	
		return local csdel		= "";
		qui su `outc' if treat==0 & wave==3 & `tousef';
		return local cmeanel		= strtrim("`: di %9.3g r(mean)'");
		if (dummy==0) return local csdel	= "(" + strtrim("`: di %9.3g r(sd)'") + ")";		
		return local ncmeanel		= r(mean);
		
		/* T mean  */
		qui su `outc' if inlist(treat,1,2) & wave==2 & `tousef';	
		return local ntmeanml		= strtrim("`: di %9.3g r(mean)'");
		qui su `outc' if inlist(treat,1,2) & wave==3 & `tousef';
		return local ntmeanel 		= strtrim("`: di %9.3g r(mean)'");
		
		/* POOLED EFFECTS --------------------------------- */
		local wt [`weight' `exp'];
		reg `outc' 	i.treatp##i.wave `controls' `wt' if `tousef', `options';
		local b = _b[1.treatp]; local b = "`: di %9.3g `b''"; local s = _se[1.treatp]; local s = "`: di %9.3g `s''"; prncoef, coef(`b') serr(`s') text par;
		return local bpgml = _b[1.treatp]; return local spgml = _se[1.treatp]; /* return for graph */
		return local bpml = "`:di %9.3g r(betaout)'" ; return local spml = "`:di %9.3g r(seout)'";
		lincom 1.treatp + 1.treatp#3.wave;
		return local bpgel = r(estimate); return local spgel = r(se); /* return for graph */
		local b = r(estimate); local b = "`: di %9.3g `b''"; local s = r(se); local s = "`: di %9.3g `s''";  prncoef, coef(`b') serr(`s') text par;
		return local bpel = "`:di %9.3g r(betaout)'"; return local spel = "`:di %9.3g r(seout)'";
		test 1.treatp#3.wave = 0;
		return local pmlel = "[" +(strtrim("`: di %10.3f r(p)'")) + "]";
		
		
	};
	
	/*******************************************************************************
	**** ML ONLY EFFECTS			************************************************
	*******************************************************************************/
	
	if (`numel' == 0 & `numml'>0) {;
		return local num = `numml';
		return local numml = `numml';
		
		/* T and C mean at BL */	
		return local csdml		= "";
		qui su `outc' if treat==0 & wave==1 ;
		return local cmeanml		= strtrim("`: di %10.`meandig'f r(mean)'");
		if (dummy==0) return local csdml	= "(" + strtrim("`: di %10.`meandig'f r(sd)'") + ")";
		return local ncmeanml		= r(mean);
		qui su `outc' if inlist(treat,1,2) & wave==1 ;	
		return local ntmeanml		= r(mean);
		
		/* SEPARATE EFFECTS ------------------------------- */
		reg `outc' 	i.treat `controls' if `touse' & wave==2, `options';
		return local numreg = e(N);
		
		/* EL effects */
		local b = _b[1.treat]; local s = _se[1.treat]; prncoef, coef(`b') serr(`s') text par;
		return local bt1ml = r(betaout); return local st1ml = r(seout);
		local b = _b[2.treat]; local s = _se[2.treat]; prncoef, coef(`b') serr(`s') text par;
		return local bt2ml = r(betaout); return local st2ml = r(seout);
		test 1.treat = 2.treat;
		return local p12ml = "[" +(strtrim("`: di %10.3f r(p)'"))  + "]";
		
		/* POOLED EFFECTS --------------------------------- */
		reg `outc' 	i.treatp `controls' if `touse' & wave==2, `options';
		local b = _b[1.treatp]; local s = _se[1.treatp]; prncoef, coef(`b') serr(`s') text par;
		return local bpml = r(betaout); return local spml = r(seout);
		return local bpgml = `b'; return local spgml = `s'; /* return for graph */

	};
	/*******************************************************************************
	**** EL ONLY EFFECTS			************************************************
	*******************************************************************************/
	
	if (`numml' == 0 & `numel'>0) {;
		return local num = `numel';
		return local numel = `numel';
		
		/* T and C mean at BL */	
		return local csdel		= "";
		qui su `outc' if treat==0 & wave==1 ;
		return local cmeanel		= strtrim("`: di %10.`meandig'f r(mean)'");
		if (dummy==0) return local csdel	= "(" + strtrim("`: di %10.`meandig'f r(sd)'") + ")";
		return local ncmeanel		= r(mean);
		qui su `outc' if inlist(treat,1,2) & wave==1 ;	
		return local ntmeanel		= r(mean);
		
		/* SEPARATE EFFECTS ------------------------------- */
		reg `outc' 	i.treat `controls' if `touse' & wave==3, `options';
		return local numreg = e(N);
		
		/* EL effects */
		local b = _b[1.treat]; local s = _se[1.treat]; prncoef, coef(`b') serr(`s') text par;
		return local bt1el = r(betaout); return local st1el = r(seout);
		local b = _b[2.treat]; local s = _se[2.treat]; prncoef, coef(`b') serr(`s') text par;
		return local bt2el = r(betaout); return local st2el = r(seout);
		test 1.treat = 2.treat;
		return local p12el = "[" + (strtrim("`: di %10.3f r(p)'"))  + "]";
		
		/* POOLED EFFECTS --------------------------------- */
		reg `outc' 	i.treatp `controls' if `touse' & wave==3, `options';
		local b = _b[1.treatp]; local s = _se[1.treatp]; prncoef, coef(`b') serr(`s') text par;
		return local bpel = r(betaout); return local spel = r(seout);
		return local bpgel = `b'; return local spgel = `s'; /* return for graph */

	};
	
};
	
end;
