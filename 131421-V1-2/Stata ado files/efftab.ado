
/*
********************************************************************************
// EFFTAB -  Table for effects computations - with weights
********************************************************************************
// Arguments:
// varlist		 						-  Outcomes to be tested across treatment groups
// title								-  Title of Table
// out									-  Path of file to save
// controls								-  Controls to add to regression
// options								-  Regression options
// ancova								-  whether to perform ancova
// meandig								-  digits after the comma for mean
********************************************************************************
*/

#delimit ;

cap program drop efftab;

program efftab, rclass;

syntax varlist (min=1) [if] [pw], 		out(string)
									title(string)
									[
									controls(varlist numeric ts fv)
									options(string)
									ANCova
									meandig(integer 2)
									]
									;

									
local outcomes = "`varlist'";
local controlsout  `controls';

/* post results to dataset */
tempname efftab;
tempfile effects;
postfile `efftab' 
    str100 varname 
    str100 varlab
	str100 numml	
	str100 cmeanml			
	str100 numel	
	str100 cmeanel			
	str100 effectpml			
	str100 effectpel			
	str100 pmlel			
	using "`effects'", replace;

	post `efftab' 	("varname") ("Variable")
							("N ML") ("C Mean ML") 
							("N EL") ("C Mean EL") 
							("Pooled Eff ML") ("Pooled Eff EL") ("p ML=EL")
							;
preserve;
foreach v of local outcomes {;

	local vlab: variable label `v';
	tereg `v' `if' , controls(`controls') options(`options') `ancova' meandig(`meandig');
	

	post `efftab' 	("`v'") ("`vlab'") 	
					("`r(numml)'") ("`r(cmeanml)'") 
					("`r(numel)'") ("`r(cmeanel)'") 
					("`r(bpml)'") ("`r(bpel)'") ("`r(pmlel)'");
	post `efftab' 	("") 	("") 	 
					("") ("`r(csdml)'") 
					("") ("`r(csdel)'") 
					("`r(spml)'") 	("`r(spel)'") ("");

};

post `efftab' ("") ("Controls for: `controlsout'") ("") ("") ("")    ("")  ("")  ("") ("") ;
post `efftab' ("") ("Options: `options'") ("") ("") ("")    ("")  ("")  ("") ("") ;
postclose `efftab';
use `effects', clear;

/* make excel sheet */
drop varname;

export excel varlab  numml cmeanml effectpml numel cmeanel effectpel pmlel using "`out'", sheet("`title'") replace ;

restore;

end;
