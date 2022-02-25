*-----------------------------------------------------------------------------
*This is the MASTER do file 
*-----------------------------------------------------------------------------
*created by: lucy kraftman

*----------------------------------------------------------------------------*
* 									NOTES									 *
*----------------------------------------------------------------------------*

* ALL data used to build the clean data set is included. Running the data_prep do file produces the clean data set 'final_lk'

* MASTER runs all do files necessary to produce results, with 2 exceptions (that are noted in the master do)
	* 1. additional calculations are made in excel for the IRR calculations, spreadsheet is provided with replication files 
	* 2. STATA prepares data to be used in R for the romano wolf calculations, the R code for this provided with replication files


* ado files needed to run some of the do files are provided, store them in C:\ado :
* -> efftab, efftabbl, efftab_t1t2, t_bootstrap, tabrrd, prncoef, tereg_t1t2, teregbl

* necessary programs that need to be downloaded (the code to download them is included in MASTER.do)
* -> carryforward
* -> egenmore
* -> estadd
* -> listtab
* -> rlasso

* please add your username where currently it says 'lucy_k' and add the directory where the folder in use

* add the globals for where the do files are saved, for where data is saved, for where outputs want to be stored


* you can also run an individual do file and set the folder path in the same way within that do file 
	* - you will need to add the maxvar and clear all if you do this

*----------------------------------------------------------------------------*
* 								INSTALL NEC PROGRAMS
*----------------------------------------------------------------------------*

ssc install carryforward
capture ssc install egenmore
capture ssc install estadd
capture ssc install listtab
capture ssc install rlasso /* if does not work, it is in ado file also */

*----------------------------------------------------------------------------*
* 									SETUP									 *
*----------------------------------------------------------------------------*
clear all
set maxvar 30000
set mem 800m
set more off
set matsize 11000

if c(username)=="lucy_k"{
		global main "C:\Users\lucy_k\Dropbox\IFS\CDGP_analysis\15 paper_lk\Do Files\Replication Files"
	}

	
global do "$main/Dofiles"
global data "$main/data"
global graphs "$main/Output/Graphs"
global effects "$main/Output/Tables"
global tables "$main/Output/Tables"


*----------------------------------------------------------------------------*
* 	DO FILES: CLEAN															 *
*----------------------------------------------------------------------------*

do "$do/data_prep"

*----------------------------------------------------------------------------*
* 	DO FILES: TABLES														 *
*----------------------------------------------------------------------------*

do "$do/T1_Balance"
do "$do/T2_NCOutcomes"
do "$do/T3_Knowledge"
do "$do/T4_Fertility"
do "$do/T4_NCPracandHealth"
do "$do/T5_DietandSec"
do "$do/T6_Seasonality"
do "$do/T7_Labour"
do "$do/T8_ConsInvSav"
do "$do/T9_IRR" /* note: additional calculations are made in excel, spreadsheet is provided with replication files */


*----------------------------------------------------------------------------*
* 	DO FILES: FIGURES														 *
*----------------------------------------------------------------------------*

do "$do/F_HAZ"
do "$do/F3_LivestockDietFoodexp"
do "$do/F_Outcomes"


*----------------------------------------------------------------------------*
* 	DO FILES: APPENDIX TABLES												 *
*----------------------------------------------------------------------------*

do "$do/TA2_Attrition"
do "$do/TA3_Takeup"
do "$do/TA4_InfoExposure"
do "$do/TA5_Recall"
do "$do/TA6_AnthroRobust"
do "$do/TA7_AnthroGender"
do "$do/TA8_ASQandTime"
do "$do/TA9_Diet"
do "$do/T5_DietandSec" 
do "$do/TA11_Livestock"
do "$do/TA12_LivestockPrices"
do "$do/TA13_WAnthro"
do "$do/TA14_SavandBorrow"
do "$do/TA15_LASSO"
do "$do/TA16_RW" /* this prepares data to be used in R, code for this provided with replication files */
do "$do/TA17_T1T2"

*----------------------------------------------------------------------------*
* 	DO FILES: APPENDIX FIGURES												 *
*----------------------------------------------------------------------------*

do "$do/FA5_Vaccination"
do "$do/FA1_Motivation"

