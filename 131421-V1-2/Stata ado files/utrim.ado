#delimit ;
cap program drop utrim;

program define utrim, rclass;

	syntax varlist(max=1) [if], [level(integer 99)];

	local outc: word 1 of `varlist';
	qui _pctile wtotinpexp, n(100);
	tempvar ifvar;
	gen `ifvar' = 1 `if';
	replace `outc' =. if `ifvar' & `outc'>`r(r`level')' & `outc'!=.;
	
	local vlab: variable label `outc';
	lab var `outc'		"`vlab' (t99)";
	
end;
