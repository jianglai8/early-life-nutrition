/*
********************************************************************************
// TABRRD -  Reorder and Trim Categorical Variables
********************************************************************************
// Arguments:
// stub			 						-  Stub of the set of variables to be reordered
// cut									-  Minimum frequency under which not to report
// othercode							-  Integer Code associated with (other)
// dkcode								-  Integer Code associated with Don't Know
********************************************************************************
*/

#delimit ;

cap program drop tabrrd;

program tabrrd, rclass;

syntax [if], 		stub(string)
					cut(real)
					[
					othercode(real 96)
					dkcode(real 98)
					]
					;

confirm integer number `othercode';
confirm integer number `dkcode';

capture confirm variable `stub'`othercode';
if !_rc {;
                       rename `stub'`othercode' oth_`stub';
               };
               else {;
                       gen oth_`stub' = 0 if `stub'1!=.;
					   di "Generated oth_`stub'";
               };

capture confirm variable `stub'`dkcode';
if !_rc {;
                       rename `stub'`dkcode' dk_`stub';
               };

/* drop if frequency is less than cut */
qui {;
ds `stub'*, has(type numeric);
nois di "Reorder and Trim: `r(varlist)'";
local vlst1 = r(varlist);
foreach v of local vlst1 {;			
		qui su `v';
		if `r(mean)'<`cut' {;
			replace oth_`stub'=1 if `v'==1;
			drop `v';
		};
};

/* reorder decreasing */

ds `stub'*, has(type numeric);			/* to exclude "other specify" strings */
local vlst2 = r(varlist);

preserve;
collapse (mean) `vlst2';

local i = 1;
foreach v of local vlst2 {;
    gen name`i' = "`v'";
    rename `v' mean`i';
    local ++i;
};
gen _i = 1;
reshape long mean name, i(_i) j(_j);
sort mean;
replace _j = _n;
replace name = name + " " + name[_n-1] if _n > 1;
local ordered_vlist = name[_N];
restore;
order `ordered_vlist', before(oth_`stub');
}; /* qui */

end;
