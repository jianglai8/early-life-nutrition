
*-----------------------------
* Expenditure and consumption figures
*-----------------------------


set more off
set mem 800m
set matsize 11000

*** SET FOLDER PATH IF NEEDED 
/*
		if c(username)=="lucy_k"{
		global main "/Users/lucy_k/Dropbox/IFS/CDGP_analysis/15 paper_lk"
	}
	
	global data "$main/Data"
	global graphs "$main/Output/Graphs"
	global tables "$main/Output/Tables"
*/




#delimit ;


use "$data/final_lk", clear;

*** FOOD PRODUCING LIVESTOCK


/* recode number owned */
recode mq3_numowned_* (9998=.);

/* owns female cow, goat, sheep */
gen hhanim_milk = 0 if mq3_anycowbull !=.;
replace hhanim_milk = 1 if mq3_anyowned_01==1 | mq3_anyowned_05==1 | mq3_anyowned_07==1;
/* number */
egen hhanimnum_milk = rowtotal(mq3_numowned_01 mq3_numowned_05 mq3_numowned_07), mi;

/* owns chicken or guinea fowl */
gen hhanim_eggs = 0 if mq3_anyowned_11 !=.;
replace hhanim_eggs = 1 if mq3_anyowned_11==1 | mq3_anyowned_12==1;

/* owns cow, calf, sheep, goat */
gen hhanim_meat = 0 if mq3_anycowbull !=.;
replace hhanim_meat = 1 if mq3_anycowbull==1 |  mq3_anycalf==1 |  mq3_anygoat==1 |  mq3_anysheep==1;


egen hhanimnum_meat = rowtotal(mq3_numowned_01 mq3_numowned_02 mq3_numowned_03 mq3_numowned_04 mq3_numowned_05 mq3_numowned_06 mq3_numowned_07 mq3_numowned_08), mi;

lab var hhanim_milk				"Any milk-producing animal (female cow, goat, or sheep)";
lab var hhanim_eggs				"Any egg-producing animal (chicken, guinea fowl) ";
lab var hhanim_meat				"Any commonly eaten animal (cow/bull, calf, goat, sheep)";

foreach var in  hhanim_eggs hhanim_meat hhanim_milk { ; 
replace `var' = `var' * 100 ;
} ; 

local hhvars	hhanim_milk  hhanim_eggs hhanim_meat ;

efftab `hhvars' if pregbl==1, out("$tables/producing_livestock_p.xlsx") title("LS owned, preg") 
				controls(i.lga_id i.tranche) options(robust cluster(PSU)) ancova;

*** CONSUMPTION AND EXPENDITURE


lab var ncmddfgroup1	"Grains, roots, tubers";
lab var ncmddfgroup2	"Legumes and nuts";
lab var ncmddfgroup3	"Dairy products";
lab var ncmddfgroup4	"Flesh foods";
lab var ncmddfgroup5	"Eggs";
lab var ncmddfgroup6	"Vit-A rich fruit and veg";
lab var ncmddfgroup7	"Other fruit and veg";
lab var ncmddfgroup4and5 "Flesh foods and eggs";


global food fgrexp_mdd1 fgrexp_mdd2 fgrexp_mdd3 fgrexp_mdd4and5 fgrexp_mdd6 fgrexp_mdd7 fgrexp_oilsauce fgrexp_sugardrink  ;

foreach v in $food {;
	qui su `v', det;
	replace `v'=. if `v' > r(p99);		/* trim */
	replace `v'= `v' *xr; 				/* to USD */
	replace `v'= `v'/7*30; 			/* to monthly */
	gen l`v' = log(`v'); 	/*log so we have percentage*/

};

/* percent */
replace fprob = fprob * 100; 
replace wq10a_10 = wq10a_10 * 100;

local dvars		ncMDD4 ncmddfgroup1 ncmddfgroup2 ncmddfgroup3 ncmddfgroup4 ncmddfgroup5 ncmddfgroup6 ncmddfgroup7 ncmddfgroup4and5   ;
foreach var of local dvars {;
replace `var' = `var'*100;
};

local dvars	 ncmddfgroup1 ncmddfgroup2 ncmddfgroup3 ncmddfgroup4and5  ncmddfgroup6 ncmddfgroup7 lfgrexp_mdd1 lfgrexp_mdd2 lfgrexp_mdd3 lfgrexp_mdd4and5 lfgrexp_mdd6 lfgrexp_mdd7;


efftab `dvars' if pregbl==1, out("$tables/diet_p.xlsx") title("NC diet, preg") 
				controls(i.lga_id i.tranche) options(robust cluster(PSU)) ancova;
				
