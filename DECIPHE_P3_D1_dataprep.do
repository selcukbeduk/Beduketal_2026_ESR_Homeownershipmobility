
/* 
Project: DECIPHE - Demographich change and intergenerational persistence of homeownership in Europe https://www.deciphe.eu 
	
Author: Enrico Benassi (University of Oxford)
		Selçuk Bedük (University of Oxford)

Date of code: 7 Feb 2025

Purpose: Merging all waves/countries, constructing data 

Inputs: EU-SILC 2004-2023 including cross sectional (R) Register, (P) Personal, (D) Design, and (H) Household files

Reference to data: EU-SILC 2004-2023 Cross-sectional

Data access conditions: Details available at https://ec.europa.eu/eurostat/web/microdata/european-union-statistics-on-income-and-living-conditions

Outputs: EUSILC_0423_RPDH.dta

Additional programs: filelist
*/
ssc install filelist, replace

***********************************************************************
* Provide key inputs

// Define main working directories
clear all
// NB: data directories need to be defined using forward slash " / " 
global base_dir "C:/Users/selcuk.beduk/Dropbox/Research/Projects/DECIPHE/Data/EU-SILC/Raw/_Cross_2004-2023_full_set" // directory where you have downloaded EU-SILC cross-sectional data
// NB: the dirdata directory folder should be empty when you run the code the first time
global dirdata "C:/Users/selcuk.beduk/Dropbox/Research/Projects/DECIPHE/Data/EU-SILC" // directory where you will save all datasets


// Select countries and years you are interested in
global countries "AT BE BG CH CY CZ DE DK EE EL ES FI FR HR HU IE IS IT LT LU LV NL NO PL PT RO RS SE SI SK UK"
global years "04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23"


// Select variables of interest for R, P, D, and H files
* REMARK: merging variables including year, country, pid/hid MUST be included
global selvarR "rb010 rb020 rb030 rx030 rb050 rb080 rx010 rx020 rb090 rb200 rb245 rb250 rb220 rb220_f rb230 rb230_f rb240 rb240_f rb211" 
global selvarP "pb010 pb020 pb030 px030 pb040 pb190 pb200 pe040 pe040_f pl030 pl031 pl032 px050 pl040 pl051 pl060 pl100 pl073 pl074 pl075 pl076 pl080 pt210 pt210_f pt110 pt120 pt130 pt160 pt140 pt170 pt150 pt180 pt190 pt200 py010g py010g_f py010n py010n_f py200g py200g_f pb210 pb220a"
global selvarD "db010 db020 db030 db040 db040_f db060 db062 db070 db090"
global selvarH "hb010 hb020 hb030 hb070 hb080 hb090 hh020 hh021 hy020 hx060 hx070 hx080" 


// Rename all variables 
* REMARK: year country pid and hid MUST be renamed to allow merging"
global oldnamesR "rb010 rb020 rb030 rx030 rb050 rb080 rb090 rb200 rb245 rb250 rb211 rb220 rb220_f rb230 rb230_f rb240 rb240_f rx010 rx020"
global newnamesR "year country pid hid cweight cohort sex res_status id_status data_status jbstat fatherid fatherid_f motherid motherid_f partnerid partnerid_f age_s age_yt"

global oldnamesP "pb010 pb020 pb030 px030 pb040 pb190 pb200 pe040 pe040_f pl030 pl031 pl032 px050 pl040 pl051 pl060 pl100 pl073 pl074 pl075 pl076 pl080 pt210 pt210_f pt110 pt120 pt130 pt160 pt140 pt170 pt150 pt180 pt190 pt200 py010g py010g_f py010n py010n_f py200g py200g_f pb210 pb220a"

global newnamesP "year country pid hid cweight_p marstat cohab isced isced_f jbstat1 jbstat2 jbstat3 jbstat selfemp occ jbhours_main jbhours_all monthsFT monthsPT monthsFTself monthsPTself monthsune tenure_par tenure_par_f edu_f edu_m emp_f emp_m man_f man_m occ_f occ_m fin ends grossinc grossinc_f netinc netinc_f grearn grearn_f migrant citizenship"

global oldnamesD "db010 db020 db030 db040 db040_f db060 db062 db070 db090"
global newnamesD "year country hid region region_f psu ssu su_selection_order hh_cweights"

global oldnamesH "hb010 hb020 hb030 hb070 hb080 hb090 hy020 hx060 hx070 hx080"
global newnamesH "year country hid hrp hrp1 hrp2 hhnetincome htype htenure pov"



***********************************************************************
* Move all individual datafiles to a unique reference directory - named dirdata

* Step 1: Identify data directories
local base_dir "${base_dir}"
local base_name "UDB_c"
local countries "${countries}"
local years "${years}"
local suffix "D H P R"
local save_dir "${dirdata}"

* Step 2: Loop over the countries, years, and suffixes
foreach country in `countries' {
    foreach year in `years' {
        foreach l in `suffix' {
            local file_name = "`base_dir'/`country'/20`year'/UDB_c`country'`year'`l'.csv"
			
			* Use capture to avoid loop interruption if file is not found
            capture {
                import delimited "`file_name'", clear

                * Step 3: Save each imported file as a .dta file in the save_dir
                local save_name = "`save_dir'/UDB_c`country'`year'_`l'.dta"
                save "`save_name'", replace
            }
			
			* Optionally: check if the file was successfully imported and log if it wasn't
            if (_rc != 0) {
                display as error "File `file_name' not found or could not be imported."
			}
        }
    }
}
clear



***********************************************************************
* R- Registry file

foreach x of global countries {
	
	foreach y of global years {
		
		capture {
			use "${dirdata}/UDB_c`x'`y'_R.dta", clear
			
			* define vars of interest	
			local vars ${selvarR}
			* Initialize an empty list of existing variables
			local existing_vars
			* Loop through each variable and check if it exists
			foreach var of local vars {
				capture confirm variable `var'
				if !_rc {  // If the variable exists, add it to the list
				local existing_vars `existing_vars' `var'
				}
				}
				
				* Keep only the variables that exist
				if "`existing_vars'" != "" {
					keep `existing_vars'
					}
				
				* use only selected variables
				use `existing_vars' using "${dirdata}/UDB_c`x'`y'_R.dta", clear 
				save "${dirdata}/UDB_c`x'`y'_Rtemp.dta", replace 
		}
		
	}
	
}

clear 
* use file list to create a dataset including the directory and the name of each file ending with _Ptemp.dta
filelist, dir("${dirdata}/") pattern("*_Rtemp.dta") save("filelist_SILC_Rtemp.dta") replace
use "filelist_SILC_Rtemp.dta", clear
local fn1 = filename[1]
local dn1 = dirname[1]
global first_file = "`dn1'`fn1'"

* create local variables including the directory and name of all files identified from 1 to N
use "filelist_SILC_Rtemp.dta", clear
local obs = _N
forvalues i=2/`obs' {
	local fni = filename[`i']
	local dni = dirname[`i']
	local filenumber`i' = "`dni'`fni'"
	}
	
use "$first_file", clear
         forvalues i=2/`obs' {
            append using `filenumber`i'', force 
         }	
save "${dirdata}/UDB_c_Rsel.dta", replace

* rename key variables and save
use "${dirdata}/UDB_c_Rsel.dta", clear
rename (${oldnamesR}) (${newnamesR})
save "${dirdata}/UDB_c_Rsel.dta", replace
clear



*****************************************************************
* P - Personal file 

foreach x of global countries  {
	foreach y of global years {
		
		capture {
			use "${dirdata}/UDB_c`x'`y'_P.dta", clear
			
			* define vars of interest	
			local vars ${selvarP}
			* Initialize an empty list of existing variables
			local existing_vars
			* Loop through each variable and check if it exists
			foreach var of local vars {
				capture confirm variable `var'
				if !_rc {  // If the variable exists, add it to the list
				local existing_vars `existing_vars' `var'
				}
				}
				
				* Keep only the variables that exist
				if "`existing_vars'" != "" {
					keep `existing_vars'
					}
				
				* use only selected variables
				use `existing_vars' using "${dirdata}/UDB_c`x'`y'_P.dta", clear 
				
				* transform pb020 format to allow for append
				
				save "${dirdata}/UDB_c`x'`y'_Ptemp.dta", replace 
		}
		
	}
}

clear 
* use file list to create a dataset including the directory and the name of each file ending with _Ptemp.dta
filelist, dir("${dirdata}/") pattern("*_Ptemp.dta") save("filelist_SILC_Ptemp.dta") replace
use "filelist_SILC_Ptemp.dta", clear
local fn1 = filename[1]
local dn1 = dirname[1]
global first_file = "`dn1'`fn1'"

* create local variables including the directory and name of all files identified from 1 to N
use "filelist_SILC_Ptemp.dta", clear
local obs = _N
forvalues i=2/`obs' {
	local fni = filename[`i']
	local dni = dirname[`i']
	local filenumber`i' = "`dni'`fni'"
	}
	
use "$first_file", clear
         forvalues i=2/`obs' {
            append using `filenumber`i'', force 
         }	
save "${dirdata}/UDB_c_Psel.dta", replace

* rename key variables
use "${dirdata}/UDB_c_Psel.dta", clear
rename (${oldnamesP}) (${newnamesP})
save "${dirdata}/UDB_c_Psel.dta", replace
clear



*********************************************************
* D - Household Registry file - survey Design variables 

foreach x of global countries {
	foreach y of global years {
		
		capture {
			use "${dirdata}/UDB_c`x'`y'_D.dta", clear
			
			* define vars of interest	
			local vars ${selvarD}
			* Initialize an empty list of existing variables
			local existing_vars
			* Loop through each variable and check if it exists
			foreach var of local vars {
				capture confirm variable `var'
				if !_rc {  // If the variable exists, add it to the list
				local existing_vars `existing_vars' `var'
				}
				}
				
				* Keep only the variables that exist
				if "`existing_vars'" != "" {
					keep `existing_vars'
					}
				
				* use only selected variables
				use `existing_vars' using "${dirdata}/UDB_c`x'`y'_D.dta", clear 
				save "${dirdata}/UDB_c`x'`y'_Dtemp.dta", replace 
		}
	}
}

clear
* use file list to create a dataset including the directory and the name of each file ending with _Ptemp.dta
filelist, dir("${dirdata}/") pattern("*_Dtemp.dta") save("filelist_SILC_Dtemp.dta") replace
use "filelist_SILC_Dtemp.dta", clear
local fn1 = filename[1]
local dn1 = dirname[1]
global first_file = "`dn1'`fn1'"

* create local variables including the directory and name of all files identified from 1 to N
use "filelist_SILC_Dtemp.dta", clear
local obs = _N
forvalues i=2/`obs' {
	local fni = filename[`i']
	local dni = dirname[`i']
	local filenumber`i' = "`dni'`fni'"
	}
	
use "$first_file", clear
         forvalues i=2/`obs' {
            append using `filenumber`i'', force 
         }	
save "${dirdata}/UDB_c_Dsel.dta", replace

* rename key variables and save
use "${dirdata}/UDB_c_Dsel.dta", clear
rename (${oldnamesD}) (${newnamesD})
save "${dirdata}/UDB_c_Dsel.dta", replace
clear



*********************************************************
* H - Household Response file 

foreach x of global countries {
	foreach y of global years{
		
		capture {
			use "${dirdata}/UDB_c`x'`y'_H.dta", clear
			
			* define vars of interest	
			local vars ${selvarH}
			* Initialize an empty list of existing variables
			local existing_vars
			* Loop through each variable and check if it exists
			foreach var of local vars {
				capture confirm variable `var'
				if !_rc {  // If the variable exists, add it to the list
				local existing_vars `existing_vars' `var'
				}
				}
				
				* Keep only the variables that exist
				if "`existing_vars'" != "" {
					keep `existing_vars'
					}
				
				* use only selected variables
				use `existing_vars' using "${dirdata}/UDB_c`x'`y'_H.dta", clear 
				save "${dirdata}/UDB_c`x'`y'_Htemp.dta", replace 
		}
		
	}
}

clear
* use file list to create a dataset including the directory and the name of each file ending with _Ptemp.dta
filelist, dir("${dirdata}/") pattern("*_Htemp.dta") save("filelist_SILC_Htemp.dta") replace
use "filelist_SILC_Htemp.dta", clear
local fn1 = filename[1]
local dn1 = dirname[1]
global first_file = "`dn1'`fn1'"

* create local variables including the directory and name of all files identified from 1 to N
use "filelist_SILC_Htemp.dta", clear
local obs = _N
forvalues i=2/`obs' {
	local fni = filename[`i']
	local dni = dirname[`i']
	local filenumber`i' = "`dni'`fni'"
	}
	
use "$first_file", clear
         forvalues i=2/`obs' {
            append using `filenumber`i'', force 
         }	
save "${dirdata}/UDB_c_Hsel.dta", replace

* rename key vars
use "${dirdata}/UDB_c_Hsel.dta", clear
rename (${oldnamesH}) (${newnamesH})
save "${dirdata}/UDB_c_Hsel.dta", replace
clear



**************************************************
* MERGE R - P - D - H

use "${dirdata}/UDB_c_Rsel.dta", clear
merge 1:1 year country pid using "${dirdata}/UDB_c_Psel.dta"
rename _merge merge_RtoP

merge m:1 year country hid using "${dirdata}/UDB_c_Hsel.dta", force
rename _merge merge_RtoH

merge m:1 year country hid using "${dirdata}/UDB_c_Dsel.dta", force
drop if _merge==2 
rename _merge merge_RtoD

save "${dirdata}/EUSILC_0423_RPDH.dta", replace



**************************************************
* CLEANING (if you don't need individual country files)

!del filelist_SILC_*temp.dta

cd "${dirdata}"
!del *temp*.dta
!del *_D.dta
!del *_H.dta
!del *_R.dta
!del *_P.dta





