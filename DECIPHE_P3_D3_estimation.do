
/* 
Project: DECIPHE - Demographich change and intergenerational persistence of homeownership in Europe https://www.deciphe.eu 
	
Author: Selçuk Bedük (University of Oxford)
		Enrico Benassi (University of Oxford)
		
Date of code: June 2026 

Purpose: Main analysis  

Inputs: DCP_EUSILC_0423.dta (from DECIPHE_P3_D2_varprep using data from EU-SILC 2004-2023)   

Reference to data: EU-SILC 2004-2023 Cross-sectional

Data access conditions: Details available at https://ec.europa.eu/eurostat/web/microdata/european-union-statistics-on-income-and-living-conditions 

Outputs:  cohco.dta

Programs:  ssc install moremata
*/
clear all
global data "C:\Users\selcuk.beduk\Dropbox\Research\Projects\DECIPHE\Papers\Paper 3 - Intergenerational persistence\Data"
global results "C:\Users\selcuk.beduk\Dropbox\Research\Projects\DECIPHE\Papers\Paper 3 - Intergenerational persistence\Results"
cd "C:\Users\selcuk.beduk\Dropbox\Research\Projects\DECIPHE\Papers\Paper 3 - Intergenerational persistence\Data"	
	
	
	
	// Sample selection 
	use "${data}\DCP_EUSILC_0423.dta", clear
	drop if country_s=="HR" | country_s=="SE" | country_s=="MT" | country_s=="BG" | country_s=="RS" // EU countries with missing owneri in some years
	drop if country_s=="NL" // owneri does not work well and household composition is biased when selected on parental info availability 
	drop if country_s=="UK" // No info in year 2019
	drop if country_s=="IS" // Sample size is too small 
	
	gen parowner=(tenure_par==1) if tenure_par!=. 
	
	keep if year==2011 | year==2019
	keep if inrange(age, 25, 59)
	
	gen miss=(parowner==.)
	tab country miss, m 
	tab country miss, m row

	gen mi=(owneri==. | parowner==.)
	drop if mi			

	drop if age<31  | cohort>1984 	// to reduce life-cycle bias; those who born after 1983 are aged 30-32			
	gen age2=age*age 	

	foreach x in 2 3 5 10 { 
		gen cohort_`x' = floor(cohort/`x') * `x' // `x' years interval birth cohorts
		gen age_`x' = floor(age/`x') * `x' // `x' years interval age groups 
	}	
	
	
	
	// Estimation of IPH
	foreach x in coh odd modd { 
		gen IPH`x'=. 
		gen IPH`x'se=. 
		gen IPH`x'_byc=. 
		gen IPH`x'_bycse=. 
	}
	
	gen hmob=.
	replace hmob=1 if parowner==1 & owneri==1 
	replace hmob=2 if parowner==0 & owneri==1 
	replace hmob=3 if parowner==1 & owneri==0 
	replace hmob=4 if parowner==0 & owneri==0 
	label define hm 1 "Owner-owner" 2 "Upward mobility" 3 "Downward mobility" 4 "Renter-renter"
	label value hmob hm
	
	gen owners=(hmob==1) if hmob!=.
	gen up=(hmob==2) if hmob!=.
	gen down=(hmob==3) if hmob!=. 
	gen renters=(hmob==4) if hmob!=. 	
	
	gen mob=(hmob==2 | hmob==3) if hmob!=. 
	gen immob=(hmob==1 | hmob==4) if hmob!=.
	
	foreach x in owneri owners up down renters mob immob { 
		gen `x'pr=. 
		gen `x'prse=. 
		gen `x'pr_byc=. 
		gen `x'pr_bycse=. 		
	}
 
 
 
	// By cohort - Europe average  
	levelsof cohort_5, local(coh)
	foreach b of local coh { 
		// Relative mobility
		* IPH
		reg owneri i.parowner i.age i.year [pw=cweight_p] if cohort_5==`b'  
		replace IPHcoh = _b[1.parowner] if cohort_5==`b'
		replace IPHcohse = _se[1.parowner] if cohort_5==`b'
		* Odds ratio
		logit owneri i.parowner i.age i.year if cohort_5==`b' [pw=cweight_p]
		replace IPHodd = exp(_b[1.parowner]) if cohort_5==`b'		
		replace IPHoddse = exp(_b[1.parowner]) * _se[1.parowner] if cohort_5==`b'	
		* Marginal odds ratio  
		lnmor i.parowner, or post
		replace IPHmodd = exp(_b[1.parowner]) if cohort_5==`b'		
		replace IPHmoddse = exp(_b[1.parowner]) * _se[1.parowner] if cohort_5==`b'
		// Absolute mobility 
		foreach y in owneri owners renters up down mob immob {
			reg `y' i.year i.age [pw=cweight_p] if cohort_5==`b'  
				predict `y'`b' if cohort_5==`b'  
				predict `y'se`b' if cohort_5==`b', stdp
				replace `y'pr = `y'`b' if cohort_5==`b'  
				replace `y'prse = `y'se`b' if cohort_5==`b'  
				drop `y'`b' `y'se`b'
				}
	}
	
	
	
	// By country-cohort 
	levelsof country, local(countries) 	// get unique country codes
	foreach c of local countries {
		levelsof cohort_5 if country == `c' , local(coh)
			foreach b of local coh {
				// Relative mobility
				* IPH
				reg owneri i.parowner i.age i.year [pw=cweight_p] if country == `c' & cohort_5==`b'  
				replace IPHcoh_byc = _b[1.parowner] if country == `c' & cohort_5==`b' 
				replace IPHcoh_bycse = _se[1.parowner] if country == `c' & cohort_5==`b'
				* Odds ratio
				logit owneri i.parowner i.age i.year if country == `c' & cohort_5==`b' [pw=cweight_p]
				replace IPHodd_byc = exp(_b[1.parowner]) if country == `c' & cohort_5==`b'		
				replace IPHodd_bycse = exp(_b[1.parowner]) * _se[1.parowner] if country == `c' & cohort_5==`b'
				* Marginal odds ratio
				lnmor i.parowner, or post
				replace IPHmodd_byc = exp(_b[1.parowner]) if country == `c' & cohort_5==`b'		
				replace IPHmodd_bycse = exp(_b[1.parowner]) * _se[1.parowner] if country == `c' & cohort_5==`b'			
				// Absolute mobility
				foreach y in owners renters up down mob immob {
					reg `y' i.year i.age [pw=cweight_p] if country == `c' & cohort_5==`b'
						predict `y'byc`c'`b' if country == `c' & cohort_5==`b'
						predict `y'bycse`c'`b' if country == `c' & cohort_5==`b', stdp
						replace `y'pr_byc = `y'byc`c'`b' if country == `c' & cohort_5==`b' 
						replace `y'pr_bycse = `y'bycse`c'`b' if country == `c' & cohort_5==`b'  
						drop `y'byc`c'`b' `y'bycse`c'`b' 
						}
			}
		}
	

	save cohco, replace 