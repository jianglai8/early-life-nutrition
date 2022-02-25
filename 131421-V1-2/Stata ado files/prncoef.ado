/* PRNCOEF
Prints coefficients formatted for tables
*/

#delimit ;

cap program drop prncoef;

program prncoef, rclass ;
	syntax [anything], coef(real) serr(real) [dig(integer 3) oneline text par];
	
	local tstat = abs(`coef'/`serr');
		
	if "`text'" != "" {;
		if (inrange(`tstat',0,1.645)) 			local betaout 	= (strtrim("`: di %10.`dig'f `coef''"));
		else if (inrange(`tstat',1.645,1.96)) 	local betaout 	= (strtrim("`: di %10.`dig'f `coef''") + "*");
		else if (inrange(`tstat',1.96,2.58)) 	local betaout 	= (strtrim("`: di %10.`dig'f `coef''") + "**");
		else if (`tstat'>2.58) 					local betaout 	= (strtrim("`: di %10.`dig'f `coef''") + "***");
		local seout = strtrim("`: di %10.`dig'f `serr''");
		return local betaout = "`betaout'";
		return local seout = "`seout'";
		if "`par'" != "" {;
			return local seout = "(`seout')";
		};
		return local coefout = "`betaout'" 	+ (" (" + "`seout'" + ")");
	};
	if "`text'" == "" {;
		if (inrange(`tstat',0,1.645)) 			local betaout 	= ("$" + strtrim("`: di %10.`dig'f `coef''") + "$");
		else if (inrange(`tstat',1.645,1.96)) 	local betaout 	= ("$" + strtrim("`: di %10.`dig'f `coef''") + "^{*}$");
		else if (inrange(`tstat',1.96,2.58)) 	local betaout 	= ("$" + strtrim("`: di %10.`dig'f `coef''") + "^{**}$");
		else if (`tstat'>2.58) 					local betaout 	= ("$" + strtrim("`: di %10.`dig'f `coef''") + "^{***}$");
		if "`oneline'" != "" {;
			return local coefout = "`betaout'" 	+ (" ($" 	+ strtrim("`: di %10.`dig'f `serr''") + "$)");
		};
		else {;
			return local coefout = "`betaout'" 	+ ("\newline ($" 	+ strtrim("`: di %10.`dig'f `serr''") + "$)");
		};
	};

end;



