
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

cap program drop effplot;

program effplot, rclass;

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
	double mean3		
	double mean4			
	double effp4			
	double effpl4			
	double effpu4				
	using "`effects'", replace;

foreach v of local outcomes {;

	local vlab: variable label `v';
	tereg `v' `if', controls(`controls') options(`options') `ancova';
	
	local eel = .; local eel_u = .; local eel_l = .; local ncmeanel = .; local ntmeanel = .; /* empty locals at EL */
	if `r(numel)'>0 {;
		local ncmeanel = real(r(ncmeanel));
		local ntmeanel = real(r(ntmeanel));
		local eel = real(r(bpgel));
		local eel_u = real(r(bpgel)) + 1.96*real(r(spgel));
		local eel_l = real(r(bpgel)) - 1.96*real(r(spgel));
	};
	post `efftab' 	("`v'") ("`vlab'")
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

/* group: 3 C EL, 4 T EL */
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

local urange = `noutc'*5-.5 ;

tw 		
		bar mean ow if group==3, horizontal color(maroon) fcolor(maroon) fintensity(50) barwidth(.75) ||
		bar mean ow if group==4, horizontal color(maroon) barwidth(.75) ||
		scatteri 1 1, msymbol(none) // to fix axis at zero
		ytitle("") ysc(reverse range(1 `urange') lwidth(none)) ylab(`outclabels', nogrid)
		xtitle("`barxlab'") xsca(lcolor(white)) xline(0, lcolor(black)) xlab(,labsize(small))
				size(tiny) margin(vsmall) bmargin(1 1 3 1) textwidth(2.5)
				symxsize(1.2) symysize(1.2) symplacement(9) keygap(.1) rowgap(0)
				region(fcolor(white) margin(1 4 .5 .5))
				)
		scheme(s2color)
		name(gbar) fxsize(60)
		;

tw	
		rspike effpl effpu ow2 if group==4, horizontal lcolor(maroon) ||
		scatter ow2 effp  if group==4, msymbol(S) mcolor(maroon) mlabel(effp2) mlabp(12) mlabc(maroon) mlabgap(1)
		ytitle("") ysc(reverse range(0.5 `urange') lwidth(none) lcolor(white)) ytick(`mltick' , grid glcolor(white) ) ymtick(`eltick', notick grid glcolor(white) )
		ylab(none, nogrid) /* ylab(`outclabels', nogrid) */
		xline(0, lcolor(black)) 
		xtitle("`effxlab'") xsca(lcolor(white)) xlab(,labsize(small))
		legend(	 label(4 "Endline")
				ring(0) position(5) rows(2)
				)
		scheme(s2color)
		name(geff) fxsize(40)

		;



grc1leg gbar geff, scheme(s2color) name(comb)
							iscale(`iscale')
							graphregion(margin(vsmall)) graphregion(color(white))
							ring(0) position(8);
graph display comb, ysize(`ysize') xsize(`xsize');
graph export "`out'", replace as(png) width(3000);

end;
