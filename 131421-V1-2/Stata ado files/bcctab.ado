/*
********************************************************************************
// BCCTAB -  Table for BCC participation
********************************************************************************
// Arguments:
// varlist		 						-  Outcomes to be tested across treatment groups
// title								-  Title of Table
// out									-  Path of file to save
// number								-  Write number nonmissing for each variable
// repl									-  Whether to replace or modify excel file
// perc									-  Report dummies in percentages
// controls								-  Additional controls to add to regression
********************************************************************************
*/

#delimit ;

cap program drop bcctab;

program bcctab, rclass;

syntax varlist(min=1) [if], 		out(string)
									title(string)
									[
									controls(varlist numeric ts fv)
									number
									repl
									perc
									compact
									dig(integer 1)
									treatonly
									]
									;

qui {;
/* EXTRACT INPUTS */
tempvar touse;
gen `touse' = 0;
replace `touse' = 1 `if';
local outcomes = "`varlist'";

/* post results to dataset */
tempname tabl;
tempfile tfile;
postfile `tabl' 
    str100 varname 
    str100 varlab
	str100 numml				/* sample size */
	str100 msd0ml				
	str100 msd1ml				
	str100 msd2ml				
	str100 p12ml				
	str100 p01ml				
	str100 p02ml				
	str100 pcvillml				
	str100 numel				/* sample size */
	str100 msd0el				
	str100 msd1el				
	str100 msd2el				
	str100 p12el				
	str100 p01el				
	str100 p02el
	str100 pcvillel				
	using "`tfile'", replace;
	
post `tabl'	("") ("`title'") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("");
post `tabl' 	("") ("") ("Midline") ("") ("") ("") ("") ("") ("") ("") ("Endline") ("") ("") ("") ("") ("") ("") ("");
post `tabl' 	("varname") ("Variable")
							("N") ("C Mean") ("T1 Mean") ("T2 Mean") ("p T1=T2") ("p C=T1") ("p C=T2") ("% expl vill") 
							("N") ("C Mean") ("T1 Mean") ("T2 Mean") ("p T1=T2") ("p C=T1") ("p C=T2") ("% expl vill")
							;
							
preserve;									

							
foreach v of local outcomes {; 

	local vlab: variable label `v';
	
	su `v';		/* check if dummy to report SD */
	if (inlist(r(max),0,1)) 	scalar dummy=1;
	if (!inlist(r(max),0,1)) 	scalar dummy=0;
	if (dummy==1) recode `v' (1=100);
	
	/* WAVE LOOP */
	forvalues w = 2(1)3 {;
		
		/* OBSERVATIONS */
		count if `v'!=. & wave==`w' & `touse';
		local num_`w' = r(N);
		
		/* if there are observations */
		if (`num_`w'' > 0) {;
		
			/* MEAN/SD */
			forvalues t = 0/2 {;
				su `v' if wave==`w' & treat==`t' & `touse';
				local m`w'_t`t'		= strtrim("`: di %10.`dig'f r(mean)'");
				local s`w'_t`t';
				if (dummy==0) local s`w'_t`t'		= "(" + strtrim("`: di %10.`dig'f r(sd)'") + ")";
			};
			
			/* PVALUE OF DIFFERENCE */
			if (`num_`w'' > 20) {; /* only 20+ obs */
			
				reg `v' i.treat `controls' if wave==`w' & `touse', cluster(PSU) robust;
				cap test 1.treat = 2.treat;
				if _rc==0 {;
					local p`w'_t12 = (strtrim("`: di %10.2f r(p)'"));
				};
				else {;
					local p`w'_t12;
				};
				cap test 0.treat = 1.treat;
				if _rc==0 {;
					local p`w'_t01 = (strtrim("`: di %10.2f r(p)'"));
				};
				else {;
					local p`w'_t01;
				};
				cap test 0.treat = 2.treat;
				if _rc==0 {;
					local p`w'_t02 = (strtrim("`: di %10.2f r(p)'"));
				};
				else {;
					local p`w'_t01;
				};
				
				/* proportion explained by village */
				local pc = .;
				if (dummy==1) {;
					cap {;
					logit `v' i.vill_id if wave==`w' & `touse';
					fitstat;
					local pc = 100*r(r2_mf);
					};
				};
				if (dummy==0) {;
					cap reg `v' i.vill_id if wave==`w' & `touse';
					local pc = 100*e(r2);
				};
				if (`pc'!=.) {;
					local pcvill`w' = (strtrim("`: di %10.1f `pc'' %"));
				};
				else {;
					local pcvill`w' = "";
				};
			};
			else {; /* less than 20 obs */
				local p`w'_t12; local p`w'_t01; local p`w'_t02; local pcvill`w' = "";
			};

		};
		
		else {; /* if no obs, empty locals */
			local m`w'_t0; local m`w'_t1; local m`w'_t2;
			local s`w'_t0; local s`w'_t1; local s`w'_t2;
			local p`w'_t12; local p`w'_t01; local p`w'_t02; 
			
		};
		

		
	}; /* wave */
	
	post `tabl' 		("`v'") ("`vlab'")
				("`num_2'") ("`m2_t0'") ("`m2_t1'") ("`m2_t2'") ("`p2_t12'") ("`p2_t01'") ("`p2_t02'") ("`pcvill2'")
				("`num_3'") ("`m3_t0'") ("`m3_t1'") ("`m3_t2'") ("`p3_t12'") ("`p3_t01'") ("`p3_t02'") ("`pcvill3'")
				;
	if (dummy==0) {;
		post `tabl' 		("") ("")
				("") ("`s2_t0'") ("`s2_t1'") ("`s2_t2'") ("") ("") ("") ("")
				("") ("`s3_t0'") ("`s3_t1'") ("`s3_t2'") ("") ("") ("") ("")
				;			
	};
	
}; /* variable */

}; /* qui */

postclose `tabl';

use `tfile', clear;
drop varname;
if ("`treatonly'"!="") drop msd0ml p01ml p02ml pcvillml msd0el p01el p02el pcvillel;

if ("`repl'"!="") export excel using "`out'", sheet("`title'") replace;
if ("`repl'"=="") export excel using "`out'", sheet("`title'") sheetreplace;

restore;
end;
