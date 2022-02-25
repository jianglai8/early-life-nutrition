
*-----------------------------
* LASSO
*-----------------------------

/*
*** SET FOLDER PATH
		if c(username)=="lucy_k"{
		global main "/Users/lucy_k/Dropbox/IFS/CDGP_analysis/15 paper_lk"
	}
	
	global data "$main/data"
	global graphs "$main/Output/Graphs"
	global tables "$main/Output/Tables"
*/

use "$data/final_lk", clear

*-----------------------------
* PREPARE CONTROLS
*-----------------------------

keep if pregbl==1

local predictor hhsize nchild02_iw nchild02 nchild35_iw nchild35 nchild612 nchild1317 nadult nelderly aeq lastbirth_ym lastbirth_months PPI hrq1_07_iw hrq1_08_iw hrq1_13_iw hrq1_14_iw hrq1_15_iw qw_01_iw qw_02_iw qw_05_iw qw_06_iw qw_07_iw qw_09_iw qw_10_iw qw_11_iw qw_03_iw wq2_01 wq2_02 wq2_03 wq2_04 wq2_05 wq2_06 wq2_12 wq2_13  wq2_14 wq2_15 wq2_16 wq2_17 wq9_numcowbull wq9_numcalf wq9_numsheep wq9_numgoat wq9_numcamel wq9_numdonk wq9_04_02 wq9_04_01 wq9_04_04 wq9_04_03 wq9_04_06 wq9_04_05 wq9_04_08 wq9_04_07 wq9_04_10 wq9_04_09 wq9_04_11 wq9_04_12 wq9_04_13  wq9_16 wq9_11 wq4a_02 wq4b_02 wq4b_03 wq4b_03b  wq7a_01 wq7b_01_1 wq7b_01_2 wq7b_01z wq7b_02  wq7b_05   wq7b_06time wq7b_06number wq7b_06bweeks wq7b_06nobreast wq7b_07 wq7b_09 childadv_pr1 childadv_pr2 childadv_pr3 childadv_pr4 childadv_pr5 childadv_pr6 childadv_pr7 childadv_pr8 childadv_pr9 childadv_pr10 childadv_pr11 childadv_pr12 childadv_pr13 childadv_pr96 childadv_pr97 childadv_pr98  childadv_bf1 childadv_bf2 childadv_bf3 childadv_bf4 childadv_bf5 childadv_bf6 childadv_bf7 childadv_bf8 childadv_bf9 childadv_bf10 childadv_bf11 childadv_bf12 childadv_bf13 childadv_bf96 childadv_bf97 childadv_bf98 wq10a_04 wq10a_05 wq10a_06 wq10a_07 wq10a_08 wq10a_09 wq10a_10 wq10a_11 HHS HHSg  wq10bml_03_oth_1 wq10bml_03_oth_2 wq10bml_03_oth_3 wq10bml_03_oth_4 wq10bbl_01_1 wq10bbl_01_3 wq10bbl_01_4 nofood1bl_1 nofood1bl_2 nofood1bl_3 nofood1bl_4 nofood1bl_5 nofood1bl_6 nofood1bl_7 nofood1bl_8 nofood1bl_9 nofood1bl_10 nofood1bl_11 nofood1bl_12 nofood1bl_13 nofood1bl_15 nofood1bl_96 nofood1bl_97 nofood1bl_98 nofood1bl_mmade nofood1bl_natcaus nofood2bl_1 nofood2bl_2 nofood2bl_3 nofood2bl_4 nofood2bl_5 nofood2bl_6 nofood2bl_7 nofood2bl_8 nofood2bl_9 nofood2bl_10 nofood2bl_11 nofood2bl_12 nofood2bl_13 nofood2bl_15 nofood2bl_96 nofood2bl_97 nofood2bl_98 nofood2bl_mmade nofood2bl_natcaus nofood3bl_1 nofood3bl_2 nofood3bl_3 nofood3bl_4 nofood3bl_5 nofood3bl_6 nofood3bl_7 nofood3bl_8 nofood3bl_9 nofood3bl_10 nofood3bl_11 nofood3bl_12 nofood3bl_13 nofood3bl_15 nofood3bl_96 nofood3bl_97 nofood3bl_98 nofood3bl_mmade nofood3bl_natcaus nofood4bl_1 nofood4bl_2 nofood4bl_3 nofood4bl_4 nofood4bl_5 nofood4bl_6 nofood4bl_7 nofood4bl_8 nofood4bl_9 nofood4bl_10 nofood4bl_11 nofood4bl_12 nofood4bl_13 nofood4bl_15 nofood4bl_96 nofood4bl_97 nofood4bl_98 nofood4bl_mmade nofood4bl_natcaus cope1bl_1 cope1bl_2 cope1bl_3 cope1bl_4 cope1bl_5 cope1bl_6 cope1bl_7 cope1bl_8 cope1bl_9 cope1bl_10 cope1bl_11 cope1bl_12 cope1bl_13 cope1bl_14 cope1bl_15 cope1bl_16 cope1bl_17 cope1bl_18 cope1bl_19 cope1bl_20 cope1bl_22 cope1bl_23 cope1bl_96 cope1bl_98 cope2bl_1 cope2bl_2 cope2bl_3 cope2bl_4 cope2bl_5 cope2bl_6 cope2bl_7 cope2bl_8 cope2bl_9 cope2bl_10 cope2bl_11 cope2bl_12 cope2bl_13 cope2bl_14 cope2bl_15 cope2bl_16 cope2bl_17 cope2bl_18 cope2bl_19 cope2bl_20 cope2bl_22 cope2bl_23 cope2bl_96 cope2bl_98 cope3bl_1 cope3bl_2 cope3bl_3 cope3bl_4 cope3bl_5 cope3bl_6 cope3bl_7 cope3bl_8 cope3bl_9 cope3bl_10 cope3bl_11 cope3bl_12 cope3bl_13 cope3bl_14 cope3bl_15 cope3bl_16 cope3bl_17 cope3bl_18 cope3bl_19 cope3bl_20 cope3bl_22 cope3bl_23 cope3bl_96 cope3bl_98 cope4bl_1 cope4bl_2 cope4bl_3 cope4bl_4 cope4bl_5 cope4bl_6 cope4bl_7 cope4bl_8 cope4bl_9 cope4bl_10 cope4bl_11 cope4bl_12 cope4bl_13 cope4bl_14 cope4bl_15 cope4bl_16 cope4bl_17 cope4bl_18 cope4bl_19 cope4bl_20 cope4bl_22 cope4bl_23 cope4bl_96 cope4bl_98 husavl husaway huscons rpndtid rpndtwho rpndtnme IWH_ID hrq1_01_iwh hrq1_07_iwh hrq1_08_iwh hrq1_11_iwh hrq1_11_othr_iwh hrq1_12_iwh hrq1_13_iwh hrq1_14_iwh hrq1_15_iwh qm_01_iwh qm_02_iwh qm_03_iwh  msttme mq1_01 mq1_07_1 mq1_07_2 mq1_07_oth_1 mq1_07_oth_2 mq1_02 mq1_03 mq1_04 mq1_05 mq1_06 mcrop24 mcrop42 mcrop43 mcrop45 mcrop46 mcrop47 mcrop48 mcrop52 mcrop54 mcrop61 mcrop62 mcrop63 mcrop64 mcrop65 mcrop66 mcrop69 mcrop71 mcrop72 mcrop101 mcrop102 mcrop103 mcrop104 mcrop96 mcropoth  mq1_12 mq1_13 mq1_13b mq1_14 mq1_15 mq1_16 mq1_17 mq3_anycalf mq3_anycamel mq3_anychick mq3_anycowbull mq3_anydonk mq3_anygoat mq3_anyguinea mq3_anyowned_01 mq3_anyowned_02 mq3_anyowned_03 mq3_anyowned_04 mq3_anyowned_05 mq3_anyowned_06 mq3_anyowned_07 mq3_anyowned_08 mq3_anyowned_09 mq3_anyowned_10 mq3_anyowned_11 mq3_anyowned_12 mq3_anyowned_13 mq3_anysheep mq3_buyany_01 mq3_buyany_02 mq3_buyany_03 mq3_buyany_04 mq3_buyany_05 mq3_buyany_06 mq3_buyany_07 mq3_buyany_08 mq3_buyany_09 mq3_buyany_10 mq3_buyany_11 mq3_buyany_12 mq3_buyany_13 mq3_buyanycowbull mq3_buyanycalf mq3_buyanysheep mq3_buyanygoat mq3_buyanycamel mq3_buyanychick mq3_buyanyguinea mq3_buyanydonk mq3_buyexp_01 mq3_buyexp_02 mq3_buyexp_03 mq3_buyexp_04 mq3_buyexp_05 mq3_buyexp_06 mq3_buyexp_07 mq3_buyexp_08 mq3_buyexp_09 mq3_buyexp_10 mq3_buyexp_11 mq3_buyexp_12 mq3_buyexp_13 mq3_buyexpcowbull mq3_buyexpcalf mq3_buyexpsheep mq3_buyexpgoat mq3_buyexpcamel mq3_buyexpchick mq3_buyexpguinea mq3_buyexpdonk mq3_buynum_01 mq3_buynum_02 mq3_buynum_03 mq3_buynum_04 mq3_buynum_05 mq3_buynum_06 mq3_buynum_07 mq3_buynum_08 mq3_buynum_09 mq3_buynum_10 mq3_buynum_13 mq3_buynumcowbull mq3_buynumcalf mq3_buynumsheep mq3_buynumgoat mq3_buynumcamel mq3_buynumdonk mq3_numcalf mq3_numcamel mq3_numcowbull mq3_numdonk mq3_numgoat mq3_numowned_01 mq3_numowned_02 mq3_numowned_03 mq3_numowned_04 mq3_numowned_05 mq3_numowned_06 mq3_numowned_07 mq3_numowned_08 mq3_numowned_09 mq3_numowned_10 mq3_numowned_13 mq3_numsheep mq3_selany_01 mq3_selany_02 mq3_selany_03 mq3_selany_04 mq3_selany_05 mq3_selany_06 mq3_selany_07 mq3_selany_08 mq3_selany_09 mq3_selany_10 mq3_selany_11 mq3_selany_12 mq3_selany_13 mq3_selanycowbull mq3_selanycalf mq3_selanysheep mq3_selanygoat mq3_selanycamel mq3_selanychick mq3_selanyguinea mq3_selanydonk mq3_selnum_01 mq3_selnum_02 mq3_selnum_03 mq3_selnum_04 mq3_selnum_05 mq3_selnum_06 mq3_selnum_07 mq3_selnum_08 mq3_selnum_09 mq3_selnum_10 mq3_selnum_13 mq3_selnumcowbull mq3_selnumcalf mq3_selnumsheep mq3_selnumgoat mq3_selnumcamel mq3_selnumdonk mq3_selrev_01 mq3_selrev_02 mq3_selrev_03 mq3_selrev_04 mq3_selrev_05 mq3_selrev_06 mq3_selrev_07 mq3_selrev_08 mq3_selrev_09 mq3_selrev_10 mq3_selrev_11 mq3_selrev_12 mq3_selrev_13 mq3_selrevcowbull mq3_selrevcalf mq3_selrevsheep mq3_selrevgoat mq3_selrevcamel mq3_selrevchick mq3_selrevguinea mq3_selrevdonk mq3a_02_1 mq3a_02_2 mq3a_02_3 mq3a_02_4 mq3a_02_5 mq3a_02_6 mq3a_02_7 mq3a_02_8 mql_01_01 mql_01_02 mql_01_03 mql_01_04 mql_01_05 mql_01_06 mql_01_07 mql_01_08 mql_01_09 mql_01_10 mql_01_11 mql_01_12 mql_01_13 mq3a_06_1 mq3a_06_2 mq3a_06_3 mq3a_06_4 mq3a_06_5 mq3a_06_6 mq3a_06_7 mq3a_06_8 mq3a_07_01 mq3a_07_02 mq3a_07_03 mq3a_07_04 mq3a_07_05 mq3a_07_06 mq3a_07_07 mq3a_07_08 mq3a_07_09 mq3a_07_10 mq3a_07_11 mq3a_07_12 mq3a_07_13 mq3a_08_01 mq3a_08_02 mq3a_08_03 mq3a_08_04 mq3a_08_05 mq3a_08_06 mq3a_08_07 mq3a_08_08 mq3a_08_09 mq3a_08_10 mq3a_08_11 mq3a_08_12 mq3a_08_13 mq3a_32_1 mq3a_32_2 mq3a_32_3 mq3a_32_4 mq3a_32_5 mq3a_32_6 mq3a_32_7 mq3a_32_8 mql_05_01 mql_05_02 mql_05_03 mql_05_04 mql_05_05 mql_05_06 mql_05_07 mql_05_08 mql_05_09 mql_05_10 mql_05_11 mql_05_12 mql_05_13 mq3a_33_01 mq3a_33_02 mq3a_33_03 mq3a_33_04 mq3a_33_05 mq3a_33_06 mq3a_33_07 mq3a_33_08 mq3a_33_09 mq3a_33_10 mq3a_33_11 mq3a_33_12 mq3a_33_13 mq2a_01 allschool wcrop24 wcrop42 wcrop43 wcrop45 wcrop46 wcrop47 wcrop48 wcrop52 wcrop54 wcrop61 wcrop62 wcrop63 wcrop64 wcrop65 wcrop66 wcrop69 wcrop72 wcrop101 wcrop102 wcrop103 wcrop104 wcrop96 wcropsales wanyanim wq9_anycowbull wq9_anycalf wq9_anysheep wq9_anygoat wq9_anycamel wq9_anychick wq9_anyguinea wq9_anydonk mq6b_01 mq6b_01_oth mq6b_02 mq6b_02_oth mq6b_03 mq6bw_01 mq6bw_01_oth mq6bw_02 mq6bw_03 mq6bw_04_1 mq6bw_04_2 mq6bw_04_3 mq6bw_04_4 mq6bw_04_5 mq6bw_04_6 mq6bw_04_7 mq6bw_04_96  mq6bw_05 mq6bw_05_oth mq6bw_06 mq6_imprwater mq6_adeqtreat mq6_imprtoil mq6c_own_1 mq6c_own_2 mq6c_own_3 mq6c_own_4 mq6c_own_5 mq6c_own_6 mq6c_own_7 mq6c_own_8 mq6c_own_9 mq6c_own_10 mq6c_own_11 mq6c_own_12 mq6c_own_13 mq6c_own_14 mq6c_own_15 mq6c_own_16 mq6c_own_17 mq6c_own_18 mq6c_own_19 mq6c_own_20 mq6c_own_21 mq6c_own_22 mq6c_own_23 mq6c_own_24 mq6c_own_25 mq6c_own_26 mq6c_own_27 mq6c_own_28 mq6c_01_1 mq6c_01_2 mq6c_01_3 mq6c_01_4 mq6c_01_5 mq6c_01_6 mq6c_01_7 mq6c_01_8 mq6c_01_9 mq6c_01_10 mq6c_01_11 mq6c_01_12 mq6c_01_13 mq6c_01_14 mq6c_01_15 mq6c_01_16 mq6c_01_17 mq6c_01_18 mq6c_01_19 mq6c_01_20 mq6c_01_21 mq6c_01_22 mq6c_01_23 mq6c_01_24 mq6c_01_25 mq6c_01_26 mq6c_01_27 mq6c_01_28 mq6c_02_1 mq6c_02_2 mq6c_02_3 mq6c_02_4 mq6c_02_5 mq6c_02_6 mq6c_02_7 mq6c_02_8 mq6c_02_9 mq6c_02_10 mq6c_02_11 mq6c_02_12 mq6c_02_13 mq6c_02_14 mq6c_02_15 mq6c_02_16 mq6c_02_17 mq6c_02_18 mq6c_02_19 mq6c_02_20 mq6c_02_21 mq6c_02_22 mq6c_02_23 mq6c_02_24 mq6c_02_25 mq6c_02_26 mq6c_02_27 mq6c_02_28 mq6c_03_1 mq6c_03_2 mq6c_03_3 mq6c_03_4 mq6c_03_5 mq6c_03_6 mq6c_03_7 mq6c_03_8 mq6c_03_9 mq6c_03_10 mq6c_03_11 mq6c_03_12 mq6c_03_13 mq6c_03_14 mq6c_03_15 mq6c_03_16 mq6c_03_17 mq6c_03_18 mq6c_03_19 mq6c_03_20 mq6c_03_21 mq6c_03_22 mq6c_03_23 mq6c_03_24 mq6c_03_25 mq6c_03_26 mq6c_03_27 mq6c_03_28 mq4_01_1 mq4_01_2 mq4_01_3 mq4_01_4 mq4_01_5 mq4_01_6 mq4_01_7 mq4_01_8 mq4_01_9 mq4_01_10 mq4_01_11 mq4_02_1 mq4_02_2 mq4_02_3 mq4_02_4 mq4_02_5 mq4_02_6 mq4_02_7 mq4_02_8 mq4_02_9 mq4_02_10 mq4_02_11 mq4_03_1 mq4_03_2 mq4_03_3 mq4_03_4 mq4_03_5 mq4_03_6 mq4_03_7 mq4_03_8 mq4_03_9 mq4_03_10 mq4_03_11 mq4_03_12 mq4_03_13 mq4_04_1 mq4_04_2 mq4_04_3 mq4_04_4 mq4_04_5 mq4_04_6 mq4_04_7 mq4_04_8 mq4_04_9 mq4_04_10 mq4_04_11 mq4_04_12 mq4_04_13 mq4_05_1 mq4_05_2 mq4_05_3 mq4_05_4 mq4_05_5 mq4_05_6 mq4_05_7 mq4_05_8 mq4_05_9 mq4_05_10 mq4_06_1 mq4_06_2 mq4_06_3 mq4_06_4 mq4_06_5 mq4_06_6 mq4_06_7 mq4_06_8 mq4_06_9 mq4_06_10 mq4_07_1 mq4_07_2 mq4_07_3 mq4_07_4 mq4_07_5 mq4_07_6 mq4_07_7 mq4_07_8 mq4_07_9 mq4_07_96 mq4_07_oth mq4_07_oth_1 mq4_07_oth_2 mq4_07_oth_3 mq4_08_1 mq4_08_2 mq4_08_3 mq4_08_4 mq4_08_5 mq4_08_6 mq4_08_7 mq4_08_8 mq4_08_9 mq4_08_96 mq4_08_oth_1 mq4_08_oth_2 mq4_08_oth_3 nfexp_wy_1 nfexp_wy_2 nfexp_wy_3 nfexp_wy_4 nfexp_wy_5 nfexp_wy_6 nfexp_wy_7 nfexp_wy_8 nfexp_wy_9 nfexp_wy_10 nfexp_wy_11 nfexp_my_1 nfexp_my_2 nfexp_my_3 nfexp_my_4 nfexp_my_5 nfexp_my_6 nfexp_my_7 nfexp_my_8 nfexp_my_9 nfexp_my_10 nfexp_yy_1 nfexp_yy_2 nfexp_yy_3 nfexp_yy_4 nfexp_yy_5 nfexp_yy_6 nfexp_yy_7 nfexp_yy_8 nfexp_yy_9 fexp_wy_1 fexp_wy_2 fexp_wy_3 fexp_wy_4 fexp_wy_5 fexp_wy_6 fexp_wy_7 fexp_wy_8 fexp_wy_9 fexp_wy_10 fexp_wy_11 fexp_wy_12 fexp_wy_13 totwnfexp totfoodexp totmnfexp totynfexp_oth totynfexp totnfexp totdurexp totfoodexp_m totnfexp_m totdurexp_m mq5b_01_1 mq5b_01_2 mq5b_01_3 mq5b_01_4 mq5b_01_5 mq5b_01_6 mq5b_01_6a mq5b_01_6b mq5b_01_7 mq5b_01_8 mq5b_02_1 mq5b_02_2 mq5b_02_3 mq5b_02_4 mq5b_02_5 mq5b_02_6 mq5b_02_6a mq5b_02_6b mq5b_02_7 mq5b_02_8 mq5b_01_9 mq5b_01_9_1 mq5b_02_9_1 mq5b_03_1 mq5b_03_2 mq5b_03_3 mq5b_03_5 mq5b_03_6 mq5b_03_7 mq5b_03_8 mq5_totborr mq5b_03_9 mfnunlist_1 mq5b_06 mq5b_07_1 mq5b_07_2 mq5b_07_3 mq5b_07_4 mq5b_07_5 mq5b_07_6 mq5b_07_7 mq5b_07_8 mq5b_07_9 mq5b_07_10 mq5b_poly1_1 mq5b_poly1_2 mq5b_poly1_3 mq5b_poly1_4 mq5_totloan mq5b_poly1_5 mq5b_poly1_6 mq5b_poly1_7 mq5b_poly1_8 mq5b_poly1_9 mq5b_poly1_10 mq5c_03 mq5c_04 mq5_totsav2 mq5c_01_1 mq5c_01_2 mq5c_01_3 mq5c_01_4 mq5c_01_5 mq5c_02_1 mq5c_02_2 mq5c_02_3 mq5c_02_4 mq5c_02_5 mq5_totsav mq9b_01_1 mq9b_01_2 mq9b_01z mq9b_02  mq9b_05  mq9b_05b_1 mq9b_05b_2 mq9b_05b_3 mq9b_05b_4 mq9b_05b_5 mq9b_05b_6 mq9b_05b_7 mq9b_05b_8 mq9b_05b_9 mq9b_05b_10 mq9b_05b_11 mq9b_05b_12 mq9b_05b_13 mq9b_05b_14 mq9b_05b_15 mq9b_05b_16 mq9b_05b_96 mq9b_05b_98 mq9b_05b_oth  mq9b_06time mq9b_06number mq9b_06bweeks mq9b_06nobreast mq9b_07 mq9b_09 mchildadv_pr1 mchildadv_pr3 mchildadv_pr4 mchildadv_pr5 mchildadv_pr6 mchildadv_pr7 mchildadv_pr8 mchildadv_pr9 mchildadv_pr10 mchildadv_pr11 mchildadv_pr12 mchildadv_pr13 mchildadv_pr96 mchildadv_pr97 mchildadv_pr98  mchildadv_bf1 mchildadv_bf3 mchildadv_bf4 mchildadv_bf5 mchildadv_bf6 mchildadv_bf7 mchildadv_bf8 mchildadv_bf9 mchildadv_bf10 mchildadv_bf11 mchildadv_bf12 mchildadv_bf13 mchildadv_bf96 mchildadv_bf97 mchildadv_bf98 OC_gend OC_age OC_aged OC_bord OC_spacing OC_dob_m OC_dob_y OC_dob_d OC_dob_mdy OC_dob_ym ocq1a_02 ocq1a_03 ocq1a_03_oth ocq1a_04 ocq1a_05 ocq1a_06 ocq1a_07 ocvacc1 ocvacc2 ocvacc3 ocvacc4 ocvacc5 ocvacc25 ocvacc6 ocvacc7 ocvacc8 ocvacc9 ocvacc10 ocvacc11 ocvacc12 ocvacc13 ocvacc14 ocvacc15 ocvacc16 ocvacc17 ocvacc18 ocvacc19 ocvacc20 ocvacc21 ocvacc22 ocvacc23 ocvacc24  ocq1a_a ocq1a_09 ocq1a_10 ocq1a_11 ocq1a_12 ocq1a_13 ocq1a_14 ocq1a_15 ocq1a_16 ocq1a_17 ocq1a_18 ocq1a_19 ocq1a_20 ocvacc_oth ocvacc_card ocvacc_BCG ocvacc_polio ocvacc_polio0 ocvacc_3polio ocvacc_DPT ocvacc_3dpt ocvacc_measles ocvacc_hepb ocvacc_yfev ocvacc_allbasic ocvacc_nobasic ocq1b_01 ocq1b_02 ocq1b_03_1 ocq1b_03_2 ocq1b_03_3 ocq1b_03_4 ocq1b_03_5 ocq1b_03_6 ocq1b_03_7 ocq1b_03_96 ocq1b_03_98 ocq1b_03_oth ocwhynocons1 ocwhynocons2 ocwhynocons3 ocwhynocons4 ocwhynocons5 ocwhynocons96 ocwhynocons98 ocq1b_05 ocq1b_06 ocq1b_07 ocq1b_08 ocq1b_09 ocq1b_10 ocq1b_11 ocq1b_12 ocq1b_12_oth ocdmed1 ocdmed2 ocdmed3 ocdmed4 ocdmed5 ocdmed6 ocdmed96 ocdmed98 ocdmed_oth ocq1c_A ocq1c_B ocq1c_16a ocq1c_16b ocq1c_16c ocq1c_16d ocq1c_16e ocq1c_16f ocq1c_16g ocq1c_16h ocq1c_16i ocq1c_16j ocq1c_16j2 ocq1c_16k ocq1c_16k_oth ocq1c_19 ocq1c_20 ocingr1 ocingr2 ocingr3 ocingr4 ocingr5 ocingr6 ocingr7 ocingr8 ocingr9 ocingr10 ocingr11 ocingr12 ocingr13 ocingr14 ocingr15 ocingr16 ocingr17 ocingr96 ocmddfgroup1 ocmddfgroup2 ocmddfgroup3 ocmddfgroup4 ocmddfgroup5 ocmddfgroup6 ocmddfgroup7 ocMDD ociddsfgroup1 ociddsfgroup2 ociddsfgroup3 ociddsfgroup4 ociddsfgroup5 ociddsfgroup6 ociddsfgroup7 ociddsfgroup8 ociddsfgroup9 ocIDDS ocq1c_21 ocq1c_22 ocbfed ociycf1 ociycf1b ociycf2 ociycf3 ociycf4 ociycf5 ociycf5aa ociycf5a1 ociycf5a2 ociycf5a3 ociycf5a4 ociycf5a5 ociycf5a6 ociycf5a7 ociycf6 ociycf7 ociycf8 ociycf9 ociycf10 ociycf11 ociycf12 ociycf15 ocq1c_01 ocq1c_02 ocq1c_03 ocq1c_04 ocq1c_06 ocq1c_07 ocq1c_08 ocq1c_09_1 ocq1c_09_2 ocq1c_09_3 ocq1c_09_4 ocq1c_09_5 ocq1c_09_6 ocq1c_09_7 ocq1c_09_96 ocq1c_09_98  ocq1c_10 ocq1c_14 ocq1c_15 ocq1c_11 ocq1c_11_time ocq1c_12 ocq1c_13 ocothd1 ocothd2 ocothd3 ocothd4 ocothd5 ocothd6 ocothd7 ocothd8 ocothd9 ocothd10 ocothd96 ocothd98 ocq1c_13_oth ocq1d_01 ocq1d_02 info1 info2 info3 info4 info5 info6 info7 info8 info96 info98  ocq1e_02_mum ocq1e_03_mum octshh_any octshh octs_hhpr octp_hhpr ocq1e_01_1 ocq1e_01_2 ocq1e_01_3 ocq1e_01_name_1 ocq1e_01_name_2 ocq1e_01_name_3 ocq1e_02_1 ocq1e_02_2 ocq1e_02_3 ocq1e_03_1 ocq1e_03_2 ocq1e_03_3 ocq2a_01 ocq2a_02 ocnoante1 ocnoante2 ocnoante3 ocnoante4 ocnoante5 ocnoante6 ocnoante7 ocnoante96 ocnoante98  ocacpers1 ocacpers2 ocacpers3 ocacpers4 ocacpers96 ocacpers98   ocbirthass1 ocbirthass2 ocbirthass3 ocbirthass4 ocbirthass5 ocbirthass96 ocbirthass98 ocq2b_02 ocq2b_03 ocq2b_04 ocq2b_05 ocq2b_06 ocq2b_07hours ocq2b_07a ocq2b_07b ocq2b_08 ocASQage ocASQcomm ocASQmoto ocASQcommcat ocASQcommref ocASQmotocat ocASQmotoref ocintob ocentme wm_weight wm_height wm_muac wm_bmi wm_thin wm_norm wm_owt oc_weight oc_height oc_muac oc_stand oc_haz oc_waz oc_whz oc_bmiz ocanthromiss ocanthroout oc_haz_who oc_waz_who oc_whz_who oc_lost_who oc_haz_sm oc_waz_sm oc_whz_sm oc_lost_sm oc_wst_who oc_swst_who oc_stn_who oc_sstn_who oc_uwt_who oc_suwt_who oc_wst_sm oc_swst_sm oc_stn_sm oc_sstn_sm oc_uwt_sm oc_suwt_sm oc_maln oc_smaln

sum `predictor'


* these are conditional on working so we don't want to create a missing because then we can't estimate on the working variables
local work wq3a_01 wq3a_03_1 wq3a_04_1 wq3a_a2_1 wq3a_a3_1 wq3a_a4_1 wq3a_a5_1 wactfreq1  wactfreq3 wactfreq36   wpay1 wpaytot wtotinpexp wtotrevenue wpayanydk wact_num wact_mult whpayjobdays whpayjobweeks  wactelse mq2_a_1 mq2a_05_1 mq2a_07_1 mq2a_03_1 mq2a_04_1  mq2a_a2_1 mq2a_a3_1 mq2a_a5_1 mactfreq1 mactfreq2 mactfreq3 mactfreq36 mactfreq42  mactfreq61 mactfreq62 mactfreq63 mactfreq64 mactfreq65 mactfreq66 mactelse  mpay1 mpaytot mtotinpexp mtotrevenue manimsales_el mpayanydk mact_num mact_mult mhpayjobdays mhpayjobweeks 


foreach var in `work' {
recode `var' (99999998=.) (9999998=.) (999998=.) (98=.) (9998=.)
capture  assert mi(`var') if wave == 1
     if !_rc {
        drop `var'   
		}
capture gen `var'_sq = `var'^2 
capture qui su `var' 	/* check if dummy or not */
	if (inlist(r(max),0,1)) 	scalar dummy=1
	if (!inlist(r(max),0,1)) 	scalar dummy=0	
if dummy == 0 { /* standardize non-dummy vars */
capture egen `var'_lasso = std(`var') 
capture egen `var'_sq_lasso = std(`var'_sq)
capture replace `var'_sq_lasso = 0 if `var'_sq_lasso ==.
}
if dummy == 1 {
capture gen  `var'_lasso = `var'
}
}


foreach var in `predictor' {
capture  assert mi(`var') if wave == 1
     if !_rc {
        drop `var'   
		}
gen `var'_missing = .
capture replace `var'_missing = 1 if `var'==.
capture replace `var'_missing = 0 if `var' !=.
capture gen `var'_sq = `var'^2
capture qui su `var' 	/* check if dummy or not */
	if (inlist(r(max),0,1)) 	scalar dummy=1
	if (!inlist(r(max),0,1)) 	scalar dummy=0
if dummy == 0 { /* standardize non-dummy vars */
capture egen `var'_lasso = std(`var')
capture egen `var'_sq_lasso = std(`var'_sq)
capture replace `var'_sq_lasso = 0 if `var'_sq_lasso ==.
}
if dummy == 1 {
capture gen  `var'_lasso = `var' 
}
capture replace `var'_lasso = 0 if `var'_missing == 1
}


missings dropvars, force

/* variables in all specs (not in LASSO) */
tab lga_id, gen(lga)
tab tranche, gen(tranche)
tab wave, gen(wave)

drop NC_age_sq
local fixed tranche2 tranche3 lga2 lga3 lga4 lga5 
local predictor  *_lasso *_missing 


*-----------------------------
* outcome vars
*-----------------------------
*  NC_dob_ym  nc_haz_who nc_stn_who nc_sstn_who  nc_waz_who nc_whz_who 	nc_muac nc_maln nchealth_aind ncq1b_01 ncq1b_05 ncq1b_09 ncq1b_10 wkap_aind mkap_aind ncpract_aind nchealthbe_aind ncq1a_02 ncvacc_allbasic ncMDD fprob wq3a_01 wact_mult whpayjobdays wwork_selfemp wactfreq36  wanyanim

gen net_resources_usd = totwmincome_grant  + totsav20 - totborr_usd 
replace PPI = PPI/100		

local ncvars NC_dob_ym  nc_haz_who nc_stn_who   nc_waz_who nc_whz_who 	nc_muac nc_maln nchealth_aind ncq1b_01 ncq1b_05   wkap_aind mkap_aind ncpract_aind nchealthbe_aind ncq1a_02 ncvacc_allbasic ncMDD fprob wq3a_01  whpayjobdays wwork_selfemp wactfreq36  wanyanim wearnings mq2a_01  mhpayjobdays mwork_selfemp mactfreq1 mearnings  totfoodexp_musd totexp_musd totsav2_usd totborr_usd net_resources_usd PPI
				
		
*-----------------------------
* tables
*-----------------------------

local fixed tranche2 tranche3 lga2 lga3 lga4 lga5 
local predictor *_lasso *_missing 

keep `predictor' treatp `fixed' PSU `ncvars' wave  wave3 hh_id2
ds  treatp `fixed' PSU `ncvars' wave  wave3 hh_id2, not
foreach x of var `r(varlist)' {
gen `x'_w1 = `x' if wave == 1
bys hh_id2: egen `x'_bl = mean(`x'_w1)
drop `x'
rename `x'_bl `x'
}

local predictor *_lasso *_missing 

rlasso treatp `predictor' `fixed' if wave == 1, cluster(PSU) partial(`fixed')

local treatsel `e(selected)'  


quietly foreach v in bpgml bpgel  pmlel num {
gen double `v' = .
}
quietly foreach v in varname varlabel {
gen `v' = ""
}



local fixed tranche2 tranche3 lga2 lga3 lga4 lga5
local predictor  *_lasso *_missing *_sq_lasso
local ncvars NC_dob_ym  nc_haz_who nc_stn_who   nc_waz_who nc_whz_who 	nc_muac nc_maln nchealth_aind ncq1b_01 ncq1b_05   wkap_aind mkap_aind ncpract_aind nchealthbe_aind ncq1a_02 ncvacc_allbasic ncMDD fprob wq3a_01  whpayjobdays wwork_selfemp wactfreq36  wanyanim wearnings mq2a_01  mhpayjobdays mwork_selfemp mactfreq1 mearnings  totfoodexp_musd totexp_musd totsav2_usd totborr_usd net_resources_usd PPI
local i = 0

pause on

foreach var in `ncvars' { 
unab predictor: `predictor'
unab exclude: `var'
local predictor: list predictor - exclude
capture rlasso `var' `predictor'  `fixed' , cluster(PSU) partial(`fixed') 
local outsel `e(selected)'
local lasso : list outsel | treatsel
local number_controls : list sizeof local(lasso)
local i = `i' + 1 
replace num = `number_controls' in `i'
estadd scalar controls = `number_controls' 
reg `var' i.treatp##i.wave  `fixed', robust cluster(PSU)
reg `var' i.treatp##i.wave `lasso' `fixed', robust cluster(PSU)
replace varname = "`var´" in `i'
replace varlabel =  `"`: var label `var''"' in `i'
lincom 1.treatp + 1.treatp#2.wave
replace bpgml = r(estimate) in `i'
reg `var' i.treatp##i.wave `lasso' `fixed', robust cluster(PSU)
lincom 1.treatp + 1.treatp#3.wave
replace bpgel = r(estimate) in `i'
test 1.treatp#3.wave = 1.treatp#2.wave
replace pmlel = r(p) in `i'
local i = `i' + 1
reg `var' i.treatp##i.wave `lasso' `fixed', robust cluster(PSU)
lincom 1.treatp + 1.treatp#2.wave
replace bpgml = r(se) in `i'
reg `var' i.treatp##i.wave `lasso' `fixed', robust cluster(PSU)
lincom 1.treatp + 1.treatp#3.wave 
replace bpgel = r(se) in `i'
}

format bpg* %9.3f
format pmlel %9.3f
char varlabel[varname] " "
list varlabel bpgml bpgel pmlel in 1/`i' , noobs sep(0) subvarname table

listtab varlabel varlabel bpgml bpgel pmlel num in 1/`i' using "$tables/LASSO.csv" , ///
delimit(",") replace ///
head(,ML,EL,P,num) 		




