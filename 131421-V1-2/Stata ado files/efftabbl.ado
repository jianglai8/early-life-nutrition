/*
********************************************************************************
// EFFTAB -  Table for effects computations
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

cap program drop efftabbl;

program efftabbl, rclass;

syntax varlist (min=1) [if], 		out(string)
									title(string)
									[
									controls(varlist numeric ts fv)
									options(string)
									ANCova
									meandig(integer 1)
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
	str100 effect1ml		
	str100 effect2ml		
	str100 pt1t2ml			
	str100 numel	
	str100 cmeanel	
	str100 effect1el			
	str100 effect2el			
	str100 pt1t2el				
	str100 effectpml			
	str100 effectpel			
	str100 pmlel			
	using "`effects'", replace;

	post `efftab' 	("varname") ("Variable")
							("N ML") ("C Mean BL") ("T Eff ML") ("T2 Eff ML") ("p T1=T2 ML") 
							("N EL") ("C Mean BL") ("T1 Eff EL") ("T2 Eff EL") ("p T1=T2 EL") 
							("Pooled Eff ML") ("Pooled Eff EL") ("p ML=EL")
							;
preserve;
foreach v of local outcomes {;

	local vlab: variable label `v';
	teregbl `v' `if', controls(`controls') options(`options') `ancova' meandig(`meandig');
	

	post `efftab' 	("`v'") ("`vlab'") 	
					("`r(numml)'") ("`r(cmeanml)'") ("`r(bt1ml)'") 	("`r(bt2ml)'") 	("`r(p12ml)'") 	
					("`r(numel)'") ("`r(cmeanel)'") ("`r(bt1el)'") 	("`r(bt2el)'") 	("`r(p12el)'")
					("`r(bpml)'") ("`r(bpel)'") ("`r(pmlel)'");
	post `efftab' 	("") 	("") 	 
					("") ("`r(csdml)'") ("`r(st1ml)'") 	("`r(st2ml)'") 	("") 	
					("") ("`r(csdel)'") ("`r(st1el)'") 	("`r(st2el)'") 	("") 	
					("`r(spml)'") 	("`r(spel)'") ("");

};

post `efftab' ("") ("Controls for: `controlsout'") ("") ("") ("")  ("")  ("")  ("")  ("")  ("")  ("")  ("")  ("")  ("") ("") ;
post `efftab' ("") ("Options: `options'") ("")  ("")  ("") ("") ("")  ("")  ("")  ("")  ("")  ("")  ("")  ("") ("") ;
postclose `efftab';
use `effects', clear;

/* make excel sheet */
drop varname;

export excel varlab numml cmeanml effect1ml effect2ml pt1t2ml numel cmeanel effect1el effect2el pt1t2el using "`out'", sheet("`title'") replace ;
export excel varlab  numml cmeanml effectpml numel cmeanel effectpel pmlel using "`out'", sheet("`title' - pooled") ;

restore;

end;
