
/* MATA routine to get index from covariance matrix */
cap mata: mata drop getindex()

mata

function getindex(data, icov) 
{
ni = rows(data)
nv = cols(data)
ones = J(nv,1,1)
index = J(ni,1,.)					/* generate index */
	for (i=1; i<=ni; i++) {
		index[i,1] = invsym((ones'*icov*ones))*(ones'*icov*data[i,1..nv]')
	}
return(index)
}
end



/*
********************************************************************************
// AIND -  Anderson (2008) index
********************************************************************************
- varlist			Variables to aggregate into index
- treat				Treatment indicator (0 must be Control)
- gen				Name of output index variable
- wave				Wave variable to use for standardisation (optional)
						if supplied, uses weights from wave 1 only
- restd				Whether to restandardise index using Control mean
						if wave supplied, Control mean from wave 1
- complete			Whether to use only complete data
*/

#delimit ;

cap program drop aind;

program aind, rclass;

syntax varlist [if], 
					treat(varlist min=1 max=1)
					gen(string)
					[
					wave(varlist min=1 max=1)
					restd
					complete
					]
					;

local nv: word count `varlist';					/* count number of outcomes		 */
local nd: word count `treat';				/* count number of treatments supplied (for errors)	*/						
local nn: word count `gen';					/* count number of new names supplied (for errors)	*/	

/* ERRORS --------------------------------------------------------------------*/
if (`nd' !=1 ) {;
	di as error "Only 1 treatment indicator can be supplied";
	exit 111;
};
if (`nn' !=1 ) {;
	di as error "Only 1 name for new variable can be supplied";
	exit 111;
};

qui {;
tempvar mrg;
gen `mrg' = _n;
tempfile hold;
save `hold';

/* keep only relevant subsample */
if ("`if'" != "") 	keep `if';

/* keep only non totally missing obs */
tempvar nmiss;
egen `nmiss' 	= rownonmiss(`varlist');
keep if `nmiss'>0;
qui count;
local ni = r(N);

/* standardise variable to effect size */
local allsd;
foreach v of local varlist {;
	qui su `v';
	local mn = r(mean);
	
	/* if wave supplied, standardise using first wave C group */
	if ("`wave'" != "") qui su `v' if `treat'==0 & `wave'==1;
	else qui su `v' if `treat'==0;
	
	local csd = r(sd);
	tempvar `v'_sd;
	gen ``v'_sd' = (`v'-`mn')/`csd';
	local allsd		`allsd' ``v'_sd';
};

/* compute covariance matrix (using BL wave only if ANCOVA) */
if ("`wave'" != "") {;
	corr `allsd' if wave==1, covariance;
};
else {;
	corr `allsd', covariance;
};
mat covmat = r(C);
mat icovmat = syminv(covmat);		/* invert */

/* replace missings with zeros if complete data not required */
/* (zeros don't affect the index) */
if ("`complete'" == "") recode `allsd' (.=0);

/* move matrices to mata and compute index */
mkmat `allsd', matrix(alldata);
mata: alldatam = st_matrix("alldata");
mata: icovmatm = st_matrix("icovmat");
mata: index = getindex(alldatam, icovmatm);
mata: st_matrix("index", index);

/* merge index back with data */
tempname tempind;
svmat index, name(`tempind');
rename `tempind'1 `gen';
keep `mrg' `gen';
tempfile add;
save `add';
use `hold', clear;
merge 1:1 `mrg' using `add', nogen;

/* restandardise with mean/SD from BL control group */
if ("`restd'" != "" & "`wave'" != "") {;		/* if wave specified */
	su `gen' if `wave'==1 & `treat'==0;
	replace `gen' = (`gen'-r(mean))/r(sd);
	};
if ("`restd'" != "" & "`wave'" == "") {;		/* if only midline */
	su `gen' if `treat'==0;
	replace `gen' = (`gen'-r(mean))/r(sd);
	};
	
}; /* qui */

end;




