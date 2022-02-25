

/****************************************************************************/
/* KAPS																	*/
/****************************************************************************/



*** SET FOLDER PATH IF NEEDED 
/*
		if c(username)=="lucy_k"{
		global main "/Users/lucy_k/Dropbox/IFS/CDGP_analysis/15 paper_lk"
		}
	
	
	global data "$main/Data"
	global graphs "$main/Output/Graphs"
	global tables "$main/Output/Tables"
*/

use "$data/final_lk", clear


#delimit ;

/****************************************************************************/
/* CLEAN																	*/
/****************************************************************************/

/* add control for child gender */
global baseX nchild02_blv nchild35_blv nchild612_blv nchild1317_blv nadult_blv nelderly_blv hrq1_08_iw_blv everatt_iw_blv;
gen NC_fem = NC_gend==2 if NC_gend!=.;

/* labels */
label var m_hf "HF is best place to deliver Baby";
label var w_hf "HF is best place to deliver Baby";
label var exclusive_6months "Breastfeed exclusively for 6 months";
label var w_immediate "Breastfeed Immediately";
label var m_immediate "Breastfeed Immediately";



global wkapvars 		wq7b_01_1
						besthf wbfimmed wq7b_06nobreastneg wq7b_09 wnowaterhot watumsum exclusive_6months 
						;
global mkapvars 		mq9b_01_1
						mbesthf mbfimmed mq9b_06nobreastneg mq9b_09 mnowaterhot mwatumsum m_exclusive_6months
						;
						


keep hh_id2 pregbl wave PSU treat tranche treat treatp lga_id NC_gend `allX' $wkapvars $mkapvars mexclbf6m wkap_aind mkap_aind;


/* women = 1 */

rename 	wkap_aind			kap1_1;	
rename wq7b_09				kap2_1;
rename 	wq7b_01_1			kap1b_1;			
rename 	besthf				kap4_1;		
rename 	wbfimmed			kap3_1;		
rename 	wq7b_06nobreastneg	kap5_1;		
rename 	wnowaterhot			kap6_1;	
rename watumsum 			kap7_1 ;
rename 	exclusive_6months	kap8_1;	

/* husbands = 2 */	

rename 	mkap_aind			kap1_2;	
rename mq9b_09				kap2_2;
rename 	mq9b_01_1			kap1b_2;			
rename 	mbesthf				kap4_2;		
rename 	mbfimmed			kap3_2;		
rename 	mq9b_06nobreastneg	kap5_2;		
rename mnowaterhot			kap6_2;	
rename mwatumsum 			kap7_2 ;
rename 	m_exclusive_6months	kap8_2;



/****************************************************************************/
/* TABLES																	*/
/****************************************************************************/

local mkapvars kap1_2 kap1b_2 kap2_2 kap3_2 kap4_2 kap5_2 kap6_2 kap7_2 kap8_2  ;
						
efftabbl `mkapvars' if pregbl==1, out("$tables/mkaps_p.xlsx") title("Husband KAP, preg") controls(i.lga_id i.tranche) options(robust cluster(PSU)) ;

local kapvars kap1_1 kap1b_1 kap2_1 kap3_1 kap4_1 kap5_1 kap6_1 kap7_1 kap8_1 ;
						
efftabbl `kapvars' if pregbl==1, out("$tables/wkaps_p.xlsx") title("Woman KAP, preg") 
				controls(i.lga_id i.tranche ) options(robust cluster(PSU)) ancova;

* ---- 
* test equality between w and h 
* ----

#delimit;


quietly foreach v in  pmlfm pelfm  { ;
gen double `v' = . ;
} ;

quietly foreach v in varname varlabel { ;
gen `v' = "" ;
} ;


reshape long  kap1_ kap1b_ kap2_ kap3_ kap4_ kap5_ kap6_ kap7_ kap8_, i(hh_id2 wave) j(person);
lab def pid 1 "Woman" 2 "Husband";
lab val person pid;

local vars  kap1_  kap1b_  kap2_  kap3_ kap4_ kap5_ kap6_ kap7_ kap8_ ;

local i = 1 ; 
foreach v of local vars { ;				/* loop for variables */
reg `v' i.treatp##i.person##i.wave i.lga_id i.tranche , robust cluster(PSU);
replace varname = "`v´" in `i' ;
replace varlabel =  `"`: var label `v''"' in `i' ;
*lincom 1.treatp + 1.treatp#3.wave + 1.treatp#1.person + 1.treatp#3.wave#1.person; 
test 1.treatp#2.person = 0; /* test at ml */
 replace pmlfm = r(p) in `i';
test 1.treatp#2.person + 1.treatp#3.wave#2.person = 0; /* test at el */
 replace pelfm = r(p)  in `i';
local i = `i' + 2 ;
	};
	
	format pmlfm %10.3f ;
	format pelfm %10.3f ;
	
	
export excel varlabel pmlfm pelfm using "$tables/wkaps_test.xlsx", sheet("Kaps Gen test adj - pooled") replace ;

