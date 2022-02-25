/*
********************************************************************************
// EFFPLOT -  Table for effects computations
********************************************************************************
// Arguments:
// varlist		 						-  Outcomes to be tested across treatment groups
// title								-  Title of Table
// out									-  Path of file to save
// controls								-  Controls to add to regression
// options								-  Regression options
// dig									-  Digits for graph effects
********************************************************************************
*/

#delimit ;

cap program drop effplot3;

program effplot3, rclass;

syntax varlist (min=1) [if], 		out(string)
									[
									title(string)
									controls(varlist numeric ts fv)
									options(string)
									iscale(real .6) ysize(real 10) xsize(real 10)
									effxlab(string)
									barxlab(string)
									dig(integer 1)
									ancova
									]
									;

local noutcomes: word count `varlist';			
local outcomes = "`varlist'";
local controlsout  `controls';

/* defaults */
if ("`effxlab'" == "") local effxlab "Effect of CDGP";
if ("`barxlab'" == "") local barxlab "Mean";

cap graph drop _all;

/* post results to dataset */
tempname efftab;
tempfile effects;
postfile `efftab' 
    str80 varname 
    str80 varlab		
	double mean1		
	double mean2			
	double effp2		
	double effpl2			
	double effpu2
	double mean3		
	double mean4			
	double effp4			
	double effpl4			
	double effpu4				
	using "`effects'", replace;

foreach v of local outcomes {;

	local vlab: variable label `v';
	tereg `v' `if', controls(`controls') options(`options') `ancova';
	
	local eml = .; local eml_u = .; local eml_l = .; local ncmeanml = .; local ntmeanml = .;  /* empty locals at ML */
	if `r(numml)'>0 {;
		local ncmeanml = real(r(ncmeanml));
		local ntmeanml = real(r(ntmeanml));
		local eml = real(r(bpgml));
		local eml_u = real(r(bpgml)) + 1.96*real(r(spgml));
		local eml_l = real(r(bpgml)) - 1.96*real(r(spgml));
	};
	local eel = .; local eel_u = .; local eel_l = .; local ncmeanel = .; local ntmeanel = .; /* empty locals at EL */
	if `r(numel)'>0 {;
		local ncmeanel = real(r(ncmeanel));
		local ntmeanel = real(r(ntmeanel));
		local eel = real(r(bpgel));
		local eel_u = real(r(bpgel)) + 1.96*real(r(spgel));
		local eel_l = real(r(bpgel)) - 1.96*real(r(spgel));
	};
	post `efftab' 	("`v'") ("`vlab'")
					(`ncmeanml') (`ntmeanml') (`eml') (`eml_l') (`eml_u') 
					(`ncmeanel') (`ntmeanel') (`eel') (`eel_l') (`eel_u') 
					;
};
postclose `efftab';
use `effects', clear;

/* encode outcomes */
tempvar sorted;
gen `sorted' = _n;
egen outcome = axis(`sorted'), label(varlab);
/* encode varlab, gen(outcome);*/

/* group: 1 C ML, 2 T ML, 3 C EL, 4 T EL */
reshape long mean effp effpl effpu, i(outcome) j(group);

/* round labels */
gen effp2 = effp;
format effp2 %12.`dig'f;

/* jitter for bar */
gen ow = .;
replace ow = (outcome-1)*5 + group;
/* jitter for effects (to center) */
gen ow2 = ow - .5;

/* position of gridlines */
levelsof ow2 if group==4, local(eltick);
levelsof ow2 if group==2, local(mltick);

/* outcome labels */
distinct outcome;
local noutc = r(ndistinct);
local onum = 1;
local outclabels "";
foreach i of local mltick {;
	local i2 = `i' + 1; /* shift down to center */
	local labl: label outcome `onum';
	local outclabels `"`outclabels' `i2' "`labl'" "';
	local onum = `onum' + 1;
};



tw	
		bar effp ow if group==2, horizontal color(navy) fcolor(navy) fintensity(50)   ||
		bar effp ow if group==4, horizontal color(maroon) fcolor(maroon) fintensity(50)  ||
		rcap effpl effpu ow if group==2, horizontal color(navy) ||
		rcap effpl effpu ow if group==4, horizontal color(maroon) 
ytitle("") ysc(reverse range(0.7 `urange') lwidth(none) lcolor(white)) ytick(`mltick' , notick grid glcolor(white) ) ymtick(`eltick', notick grid glcolor(white) )
		ylab(`outclabels', nogrid labsize(Vsmall)) /* ylab(`outclabels', nogrid) */
		xline(0, lcolor(black)) 
		xtitle("`effxlab'") xsca(lcolor(white)) xlab(,labsize(small))
		legend(	
				order(1 2) label(1 "Midline") label(2 "Endline")
				  rows(1)
				)
			graphregion(color(white)) bgcolor(white)
		name(geff) 
		;

graph export "`out'", replace as(png) width(3000);

end;
