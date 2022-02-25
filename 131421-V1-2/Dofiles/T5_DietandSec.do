
*-----------------------------
* DIET
*-----------------------------
/*
*** SET FOLDER PATH IF NEEDED 
		if c(username)=="lucy_k"{
		global main "/Users/lucy_k/Dropbox/IFS/CDGP_analysis/15 paper_lk"
		}
	
	
	global data "$main/data"
	global graphs "$main/Output/Graphs"
	global tables "$main/Output/Tables"
*/

#delimit ;


use "$data/final_lk", clear;

/****************************************************************************/
/* CLEAN														*/
/****************************************************************************/


tab HHSg, gen(hunger);
recode wq10a_04 wq10a_08 wq10a_06  (2=0);



lab var ncMDD4	"4+ Food groups";
lab var ncmddfgroup1	"Grains, roots, tubers";
lab var ncmddfgroup2	"Legumes and nuts";
lab var ncmddfgroup3	"Dairy products";
lab var ncmddfgroup4	"Flesh foods";
lab var ncmddfgroup5	"Eggs";
lab var ncmddfgroup6	"Vit-A rich fruit and veg";
lab var ncmddfgroup7	"Other fruit and veg";
lab var ncmddfgroup4and5 "Flesh foods and eggs";


local dvars		ncMDD ncMDD4  wq10a_04 wq10a_08 wq10a_06;


efftab `dvars' if pregbl==1, out("$tables/s6_ncdiet_p.xlsx") title("NC diet, preg") 
				controls(i.lga_id i.tranche) options(robust cluster(PSU)) ancova;
