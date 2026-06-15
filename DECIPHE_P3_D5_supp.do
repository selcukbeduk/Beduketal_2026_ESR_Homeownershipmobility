/* 
Project: DECIPHE - Demographich change and intergenerational persistence of homeownership in Europe https://www.deciphe.eu 
	
Author: Selçuk Bedük (University of Oxford)
		Enrico Benassi (University of Oxford)
		
Date of code: June 2026 

Purpose: Supplementary Material   

Inputs: 
DCP_EUSILC_0423.dta (from DECIPHE_P3_D1_dataprep using data from EU-SILC 2004-2023)   
cohco.dta (from DECIPHE_P3_D3_estimation using DCP_EUSILC_0423.dta)

Reference to data: EU-SILC 2004-2023 Cross-sectional

Data access conditions: Details available at https://ec.europa.eu/eurostat/web/microdata/european-union-statistics-on-income-and-living-conditions 

Outputs: Figure S1-S11 
*/
clear all
global data "C:\Users\selcuk.beduk\Dropbox\Research\Projects\DECIPHE\Papers\Paper 3 - Intergenerational persistence\Data"
global results "C:\Users\selcuk.beduk\Dropbox\Research\Projects\DECIPHE\Papers\Paper 3 - Intergenerational persistence\Submission\ESR\2nd revision\Results_r2\Supplementary"
cd "C:\Users\selcuk.beduk\Dropbox\Research\Projects\DECIPHE\Papers\Paper 3 - Intergenerational persistence\Data"	

	// FIGURE S1
	// IPH sensitivity to upward and downward mobility across origin distribution 
	// Simulation 
	 clear
	set scheme lean2

	set obs 1001
	gen x = (_n - 1) / 1000
	gen y1 = -1/x/100 // downward
	gen y2 = -1/(1-x)/100 // upward
	gen ry2y1 = y2/y1 // ratio 		

	gen oparents = 0.73 // observed oparents
	gen fd_mobility1 = -1/oparents/100 // obs downward 
	gen fd_mobility2 = -1/(1-oparents)/100 // obs upward
	gen obs_ratio = fd_mobility2 /fd_mobility1 // obs ratio
	 
	 
	gen op_min = 0.36
	gen op_50 = 0.5
	gen op_1q = 0.63
	gen op_2q = 0.74
	gen op_3q = 0.83
	gen op_4q = 0.95

	foreach x in op_min op_50 op_1q op_2q op_3q op_4q {
		gen fd1_`x' = -1/`x'/100
		gen fd2_`x' = -1/(1-`x')/100	
		gen ry2y1_`x' = fd2_`x' / fd1_`x'
	}

  
	// IPH sensitivity
	twoway ///
		(line y1 x if x>0.05 & x<0.95, lcolor("204 153 0") lpattern(solid solid) lw(medthick medthick)) ///
		(line y2 x if x>0.05 & x<0.95, lcolor("139 0 0") lpattern(solid solid) lw(medthick medthick)) ///
		(scatter fd1_op_min op_min, msize(small) mcolor(green) msymbol(circle)) ///
		(scatter fd1_op_50 op_50, msize(small) mcolor(green) msymbol(circle)) ///
		(scatter fd1_op_1q op_1q, msize(small) mcolor(green) msymbol(circle)) ///
		(scatter fd1_op_2q op_2q, msize(small) mcolor(green) msymbol(circle)) ///
		(scatter fd1_op_3q op_3q, msize(small) mcolor(green) msymbol(circle)) ///
		(scatter fd1_op_4q op_4q, msize(small) mcolor(green) msymbol(circle)) ///
		(scatter fd2_op_min op_min, msize(small) mcolor(green) msymbol(circle)) ///
		(scatter fd2_op_50 op_50, msize(small) mcolor(green) msymbol(circle)) ///
		(scatter fd2_op_1q op_1q, msize(small) mcolor(green) msymbol(circle)) ///
		(scatter fd2_op_2q op_2q, msize(small) mcolor(green) msymbol(circle)) ///
		(scatter fd2_op_3q op_3q, msize(small) mcolor(green) msymbol(circle)) ///
		(scatter fd2_op_4q op_4q, msize(small) mcolor(green) msymbol(circle)) ///
		, ///
		text(`=fd1_op_min[1]-0.005' 0.36 "Min(36%)", place(s) size(small)) ///
		text(`=fd1_op_50[1]-0.005' 0.5 "50%", place(s) size(small)) ///
		text(`=fd2_op_1q[1]-0.005' 0.62 "1stQ(63%)", place(s) size(small)) ///
		text(`=fd2_op_2q[1]-0.005' 0.70 "Med(74%)", place(s) size(small)) ///
		text(`=fd2_op_3q[1]-0.005' 0.77 "3rdQ(83%)", place(s) size(small)) ///
		text(`=fd2_op_4q[1]-0.005' 0.94 "Max(95%)", place(s) size(small)) ///
		ylabel(-0.22(.02)0.01, gstyle(minor) angle(horizontal) format(%9.2f)) ///
		xlabel(0(0.1)1, gstyle(minor) angle(horizontal) format(%9.1f)) ///
		yline(0, lpattern(dot)) ///
		legend(order(1 2 3) label(1 "Downward") label(2 "Upward") label(3 "Observed") ///
		pos(6) rows(1)) ///
		ytitle("IPH sensitivity to 1 p.p. mobility change") xtitle("Parental Ownership Levels") ///
		name(mobility_fd, replace) ///
		title("IPH sensitivity") scale(0.9)		

	// IPH sensistivity ratio		
	twoway ///
		(line ry2y1 x if x<0.95, lcolor(darkgreen) lpattern(longdash)) ///
		(scatter ry2y1_op_min op_min, msize(small) mcolor(green) msymbol(circle)) ///
		(scatter ry2y1_op_50 op_50, msize(small) mcolor(green) msymbol(circle)) ///
		(scatter ry2y1_op_1q op_1q, msize(small) mcolor(green) msymbol(circle)) ///
		(scatter ry2y1_op_2q op_2q, msize(small) mcolor(green) msymbol(circle)) ///
		(scatter ry2y1_op_3q op_3q, msize(small) mcolor(green) msymbol(circle)) ///
		(scatter ry2y1_op_4q op_4q, msize(small) mcolor(green) msymbol(circle)) ///
		,  ///
		text(`=ry2y1_op_min[1]+0.5' 0.36 "Min(36%)", place(n) size(small)) ///
		text(`=ry2y1_op_50[1]+0.5' 0.5 "50%", place(n) size(small)) ///
		text(`=ry2y1_op_1q[1]+0.5' 0.62 "1stQ(63%)", place(n) size(small)) ///
		text(`=ry2y1_op_2q[1]+0.5' 0.71 "Med(74%)", place(n) size(small)) ///
		text(`=ry2y1_op_3q[1]+0.5' 0.77 "3rdQ(83%)", place(n) size(small)) ///
		text(`=ry2y1_op_4q[1]+0.5' 0.95 "Max(95%)", place(n) size(small)) ///
		ylabel(0(2)20, gstyle(minor) angle(horizontal) format(%9.0f)) ///
		xlabel(0(0.1)1, gstyle(minor) angle(horizontal) format(%9.1f)) ///
		ytitle("IPH sensitivity ratio: upward to downward") xtitle("Parental Ownership Levels") ///
		legend(off) ///
		name(ratio_fd, replace) ///
		title("IPH sensitivity ratio") ///
		scale(0.9)		
	
	// Combined	
	graph combine mobility_fd ratio_fd, scale(0.9)
	graph save "${results}\S1_iph.gph", replace 
	graph export "${results}\S1_iph.png", replace
	
	
	
	// FIGURE S2
	// Life-cycle bias 
	use "${data}\DCP_EUSILC_0423.dta", clear
	
	// Sample selection 
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
			
	foreach x in 2 3 5 10 { 
		gen cohort_`x' = floor(cohort/`x') * `x' // `x' years interval birth cohorts
		gen age_`x' = floor(age/`x') * `x' // `x' years interval age groups 
	}	
	replace age_2=26 if age_2==24
	replace age_3=age_3+1 	

	reg owneri i.parowner##i.age_2 i.parowner##i.cohort_2  [aw=cweight_p]
	margins, over(parowner) at(age_2=(26(2)58))
	marginsplot, ///
		recast(line) plot1opts(lc(stc2)) plot2opts(lc(stc1)) ///
		recastci(rarea) ci1opts(fcolor(stc2%15) lw(vvthin)) ci2opts(fcolor(stc1%15) lw(vvthin)) ///
		legend(order(4 "Owner parent" 3 "Renter parent") pos(6) cols(2)) ///
		xlabel(25(5)60) ylabel(0 0.2 "20%" 0.4 "40%" 0.6 "60%" 0.8 "80%") ///
		xtitle(Age) ytitle(Homeownership prevalence) title(" ") ///
		scheme(stcolor_alt) name(ageown, replace)			
	margins, dydx(parowner) at(age_2=(26(2)58))
	marginsplot, ///
		recast(line) plotopts(lc(stc3)) ///
		recastci(rarea) ciopts(fcolor(stc3%15) lw(vvthin)) /// 	
		legend(on order(2 "IPH")) ///
		xlabel(25(5)60) ylabel(0 0.05 "5%" 0.1 "10%" 0.15 "15%" 0.2 "20%" 0.25 "25%") ///
		xtitle(Age) ytitle(AME of parental homeownership (IPH)) title(" ") ///
		scheme(stcolor_alt) name(ageown_dif, replace)
	graph combine ageown ageown_dif
	graph display, ysize(3) xsize(6.5)
	graph save "${results}\S2_iph.gph", replace 
	graph export "${results}\S2_iph.png", replace	
	
	
	
	// FIGURE S3
	foreach a in 31 35 40 {
		use cohco, clear 
		drop if age==40 & cohort_5==1980 // only 47 cases		
		keep if age>=`a'
		foreach x in coh { 
			gen IPH`x'`a'=. 
			gen IPH`x'`a'se=. 
		}	
	 
		// By cohort - Europe average  
		levelsof cohort_5, local(coh)
		foreach b of local coh { 
			// Relative mobility
			* IPH
			reg owneri parowner i.age [pw=cweight_p] if cohort_5==`b'  
			replace IPHcoh`a' = _b[parowner] if cohort_5==`b'
			replace IPHcoh`a'se = _se[parowner] if cohort_5==`b'
		}
		collapse (mean) IPHcoh IPHcohse [aw=cweight_p], by(cohort_5)	
			foreach x in IPHcoh { 
				gen `x'll=`x'-1.96*`x'se
				gen `x'ul=`x'+1.96*`x'se
				}
								
		twoway (line IPHcoh cohort , lc(black) lw(medthick)) ///
			(rarea IPHcohll IPHcohul cohort, fcolor(gray%15) lw(vvthin)), ///
				ylabel(0(.05).30, grid gmin gmax glcolor(gs10) glp(dash)) ytitle(IPH) ///
				xlabel(1950 "1951-54" 1955 "1955-59" 1960 "1960-64" 1965 "1965-69" ///
					1970 "1970-74" 1975 "1975-79" 1980 "1980-84", angle(45) grid gmin gmax glcolor(gs10) glp(dash)) ///
				ytitle(IPH) xtitle(Cohort) legend(off) scheme(Lean2) title("Age >=`a'") name(EUiph`a', replace) 					
		}
	
	graph combine EUiph31 EUiph35 EUiph40, cols(3) ysize(2.5) xsize(6.5) scale(1.2)
	graph save "${results}\S3_iph.gph", replace 
	graph export "${results}\S3_iph.png", replace	
	

	
	// FIGURE S4
	// Simulation II: Counterfactual mobility under intergenerational independence (odds ratio = 1)
	// Cross-cohort change (1980-84 minus 1951-54) decomposed into parent- and child-margin contributions
	use cohco, clear
	collapse (mean) IPHcoh_byc IPHcoh_bycse IPHodd_byc IPHodd_bycse parowner owneri owners*byc* up*byc* down*byc* renters*byc* ///
			(sem) parownerse=parowner ownerise=owneri [aw=cweight_p], by(country_s country cohort_5)
	gen renteri  = 1 - owneri
	gen parenter = 1 - parowner
	label var IPHcoh_byc   "IPH (by cohort)"
	label var ownerspr_byc "Owner-owner"
	label var renterspr_byc "Renter-renter"
	label var uppr_byc     "Upward mobility"
	label var downpr_byc   "Downward mobility"
	label var owneri       "Child homeowner"
	label var renteri      "Child renter"
	label var parowner     "Parent homeowner"
	label var parenter     "Parent renter"
		
	drop if country==5 // Cyprus is distorting the visual

	* Counterfactual mobility rates under independence (Or=1):
	* up_cf   = nro/N = parenter * owneri
	* down_cf = nor/N = parowner * renteri
	gen up_cf      = parenter * owneri
	gen down_cf    = parowner * renteri
	gen owners_cf  = parowner * owneri
	gen renters_cf = parenter * renteri

	* Keep only the earliest (1951-54) and latest (1980-84) cohorts and reshape wide
	keep if inlist(cohort_5, 1950, 1980)
	gen byte tag = cond(cohort_5==1950, 0, 1)        // 0 = base, 1 = end
	keep country country_s tag uppr_byc downpr_byc up_cf down_cf parowner parenter owneri renteri
	reshape wide uppr_byc downpr_byc up_cf down_cf parowner parenter owneri renteri, i(country country_s) j(tag)

	* Observed cross-cohort change (Delta)
	gen d_up_obs   = uppr_byc1   - uppr_byc0
	gen d_down_obs = downpr_byc1 - downpr_byc0

	* Counterfactual cross-cohort change
	gen d_up_cf   = up_cf1   - up_cf0
	gen d_down_cf = down_cf1 - down_cf0

	* Symmetric (Shapley) decomposition with equal weighting between margins
	* up_cf = parenter * owneri:
	*   parent contribution = 0.5 * (parenter1 - parenter0) * (owneri0 + owneri1)
	*   child  contribution = 0.5 * (owneri1  - owneri0)  * (parenter0 + parenter1)
	gen up_par_eff   = 0.5 * (parenter1 - parenter0) * (owneri0   + owneri1)
	gen up_chi_eff   = 0.5 * (owneri1   - owneri0)   * (parenter0 + parenter1)

	* down_cf = parowner * renteri:
	gen down_par_eff = 0.5 * (parowner1 - parowner0) * (renteri0  + renteri1)
	gen down_chi_eff = 0.5 * (renteri1  - renteri0)  * (parowner0 + parowner1)

	* Express each margin contribution as % of the observed cross-cohort change
	gen up_par_pct   = 100 * up_par_eff   / d_up_obs
	gen up_chi_pct   = 100 * up_chi_eff   / d_up_obs
	gen down_par_pct = 100 * down_par_eff / d_down_obs
	gen down_chi_pct = 100 * down_chi_eff / d_down_obs

	* Totals (parent + child) as % of observed change
	gen up_tot_pct   = up_par_pct   + up_chi_pct
	gen down_tot_pct = down_par_pct + down_chi_pct

	* EU (simple cross-country mean) added as an extra row in bold
	preserve
		collapse (mean) up_par_pct up_chi_pct up_tot_pct down_par_pct down_chi_pct down_tot_pct ///
			d_up_obs d_down_obs d_up_cf d_down_cf
		gen country_s = "EU"
		tempfile eu
		save `eu'
	restore
	append using `eu'

	* Bar chart: Upward mobility Delta, sorted ascending by parent margin contribution
	preserve
		gsort -up_par_pct
		gen order = _n
		labmask order, values(country_s)
		twoway (bar up_tot_pct order, horizontal barw(0.7) fcolor("250 200 215") lcolor("250 200 215")) ///
			   (bar up_par_pct order, horizontal barw(0.7) fcolor("199 21 91") lcolor("199 21 91")) ///
			   (scatter order up_par_pct, msymbol(none) mlabel(up_par_pct) mlabpos(3) mlabsize(vsmall) ///
					mlabcolor(black) mlabformat(%9.0f)) ///
			   (scatter order up_tot_pct, msymbol(none) mlabel(up_tot_pct) mlabpos(3) mlabsize(vsmall) ///
					mlabcolor(black) mlabformat(%9.0f)), ///
			ytitle("") xtitle("% of observed upward mobility change") title("Upward mobility {&Delta}") ///
			ylabel(1(1)`=_N', valuelabel angle(0) labsize(vsmall) nogrid) ///
			xlabel(0(20)120, grid glcolor(gs14)) xline(100, lp(dash) lcolor(black)) ///
			legend(order(2 "Parent margin {&Delta}" 1 "Child margin {&Delta}") rows(1) position(6) region(lcolor(white))) ///
			name(sim2_up, replace)
	restore

	* Bar chart: Downward mobility Delta, sorted ascending by parent margin contribution
	preserve
		gsort -down_par_pct
		gen order = _n
		labmask order, values(country_s)
		twoway (bar down_tot_pct order, horizontal barw(0.7) fcolor("253 240 180") lcolor("253 240 180")) ///
			   (bar down_par_pct order, horizontal barw(0.7) fcolor("240 190 30") lcolor("240 190 30")) ///
			   (scatter order down_par_pct, msymbol(none) mlabel(down_par_pct) mlabpos(3) mlabsize(vsmall) ///
					mlabcolor(black) mlabformat(%9.0f)) ///
			   (scatter order down_tot_pct, msymbol(none) mlabel(down_tot_pct) mlabpos(3) mlabsize(vsmall) ///
					mlabcolor(black) mlabformat(%9.0f)), ///
			ytitle("") xtitle("% of observed downward mobility change") title("Downward mobility {&Delta}") ///
			ylabel(1(1)`=_N', valuelabel angle(0) labsize(vsmall) nogrid) ///
			xlabel(0(20)120, grid glcolor(gs14)) xline(100, lp(dash) lcolor(black)) ///
			legend(order(2 "Parent margin {&Delta}" 1 "Child margin {&Delta}") rows(1) position(6) region(lcolor(white))) ///
			name(sim2_down, replace)
	restore

	graph combine sim2_up sim2_down, imargin(medium) ysize(3) xsize(6.5) scale(*1.2) name(S4_iph, replace)		
	graph save   "${results}\S4_iph.gph", replace
	graph export "${results}\S4_iph.png", replace
	

	
	// FIGURE S5 & S6
	// Effect of other parental characteristics
	use cohco, clear 
	
	foreach x in m f { 
		replace emp_`x'=3 if emp_`x'>3 & emp_`x'!=. 
		gen nssec8_`x' = .
		replace nssec8_`x' = 1 if (emp_`x'==1 | emp_`x'==2) & man_`x'==1 & inlist(occ_`x',1,2)
		replace nssec8_`x' = 2 if emp_`x'==1 & man_`x'==0 & inlist(occ_`x',2,3)
		replace nssec8_`x' = 3 if emp_`x'==1 & inlist(occ_`x',4,5)
		replace nssec8_`x' = 4 if emp_`x'==2 & inrange(occ_`x',3,9)
		replace nssec8_`x' = 5 if emp_`x'==1 & man_`x'==1 & inrange(occ_`x',7,9)
		replace nssec8_`x' = 6 if emp_`x'==1 & man_`x'==0 & inrange(occ_`x',6,8)
		replace nssec8_`x' = 7 if emp_`x'==1 & man_`x'==0 & occ_`x'==9
		replace nssec8_`x' = 9 if occ_`x'==0
		replace nssec8_`x' = 8 if emp_`x'==3
		replace nssec8_`x' = 8 if nssec8_`x'==.
	}
	label define nssec8 1 "Higher professional" 2 "Lower professional" 3 "Intermediate" 4 "Self-employed" 5 "Lower supervisory" 6 "Semi-routine" 7 "Routine" 8 "Non-employed" 9 "Armed forces"
	label values nssec8_f nssec8	
	label values nssec8_m nssec8	
	
	gen parnssec8=. 
	replace parnssec8=nssec8_f if nssec8_f!=. & nssec8_m==.
	replace parnssec8=nssec8_m if nssec8_m!=. & nssec8_f==.
	replace parnssec8=min(nssec8_f, nssec8_m) if !missing(nssec8_f, nssec8_m)
	label values parnssec8 nssec8	
	drop if parnssec8==9 // only 102 cases for Armed Forces 
	label var parnssec8 "Parental Social Class"
	
	gen paredu=. 
	replace paredu=edu_f if edu_f!=. & edu_m==. 
	replace paredu=edu_m if edu_m!=. & edu_f==. 
	replace paredu=max(edu_f, edu_m) if !missing(edu_f, edu_m)
	replace paredu=1 if paredu<1 
	label define paredu 1 "Lower secondary or lower" 2 "Upper Secondary" 3 "Tertiary"	
	label value paredu paredu
	label variable paredu "Parental education"
	
	global pch i.parnssec8 i.paredu 
	gen pmiss=(parnssec8==. | paredu==.)
	eststo clear 
	eststo: reg owneri parowner i.age [pw=cweight_p] if pmiss==0 
	eststo: reg owneri parowner i.age $pch [pw=cweight_p] if pmiss==0
	esttab using par.rtf, keep(parowner) compress c(b(f(3)) ci(par f(2))) ///
		mtitles("Base" "With parental controls") replace coef(parowner "Pooled") long
	
	gen IPHbase=. 
	gen IPHbasese=. 
	gen IPHpar=. 
	gen IPHparse=. 	
	
	levelsof cohort_5, local(coh)
	foreach b of local coh { 
		reg owneri parowner i.age [pw=cweight_p] if cohort_5==`b' & pmiss==0
		replace IPHbase = _b[parowner] if cohort_5==`b' & pmiss==0
		replace IPHbasese = _se[parowner] if cohort_5==`b' & pmiss==0
		reg owneri parowner i.age $pch [pw=cweight_p] if cohort_5==`b' & pmiss==0
		replace IPHpar = _b[parowner] if cohort_5==`b'
		replace IPHparse = _se[parowner] if cohort_5==`b'		
	}
	save temp_IPHpar.dta, replace 
	
	label var parowner "Parental homeownership"
	label var owneri "Child homeownership"
	ciplot parowner owneri [aw=cweight_p], by(parnssec8) xlabel(, angle(45)) ///
		ylabel(.5 "50%" .6 "60%" .7 "70%" .8 "80%" .9 "90%", grid gmin gmax glcolor(gs12)) ytitle(Homeownership prevalence) ///
		name(parns, replace) note(" ") recast(line)	
	ciplot parowner owneri [aw=cweight_p], by(paredu) xlabel(, angle(45)) ///
		ylabel(.5 "50%" .6 "60%" .7 "70%" .8 "80%" .9 "90%", grid gmin gmax glcolor(gs12)) ytitle(Homeownership prevalence) ///
		name(paredu, replace) note(" ") recast(line)	
	grc1leg parns paredu 
	graph save "${results}\S6_iph.gph", replace 
	graph export "${results}\S6_iph.png", replace
	
	collapse (mean) IPHbase IPHbasese IPHpar IPHparse, by(cohort_5)	
	foreach x in IPHbase IPHpar { 
		gen `x'll=`x'-1.96*`x'se
		gen `x'ul=`x'+1.96*`x'se
		}
	twoway (line IPHbase IPHpar cohort , lc(black) lp(solid dash)) ///
		(rarea IPHbasell IPHbaseul cohort, fcolor(gray%15) lw(vvthin)) ///
		(rarea IPHparll IPHparul cohort, fcolor(gray%15) lw(vvthin)), ///
			ylabel(0(.05).30, grid gmin gmax glcolor(gs10) glp(dash)) ytitle(IPH) ///
			xlabel(1950 "1951-54" 1955 "1955-59" 1960 "1960-64" 1965 "1965-69" ///
				1970 "1970-74" 1975 "1975-79" 1980 "1980-84", angle(45) grid gmin gmax glcolor(gs10) glp(dash)) ///
			ytitle(IPH) xtitle(Cohort) legend(order(1 "Base" 2 "Controlling for parental education and social class") pos(6) cols(1)) ///
			ysize(3) xsize(4.5) scheme(Lean2) name(EUiphpar, replace) 				
	graph save "${results}\S5_iph.gph", replace 
	graph export "${results}\S5_iph.png", replace		
		

	
	// FIGURE S7 
	// MOR against absolute mobility 
	use cohco, clear 
	collapse (mean) IPHcoh_byc IPHcoh_bycse IPHmodd_byc IPHmodd_bycse parowner owneri* owners*byc* up*byc* down*byc* renters*byc* mob* immob* ///
		(sem) parownerse=parowner ownerise=owneri [aw=cweight_p], by(country_s country cohort_5)	
	gen parenter=1-parowner 
	label var IPHcoh_byc "IPH (by cohort)"
	label var IPHmodd_byc "Marginal odds ratio (by cohort)"
	label var ownerspr_byc "Owner-owner" 
	label var renterspr_byc "Renter-renter"		
	label var uppr_byc "Upward mobility"
	label var downpr_byc "Downward mobility"
	label var owneri "Child homeowner"
	label var parowner "Parent homeowner"
	label var parenter "Parent renter"
	foreach x in IPHcoh_byc IPHmodd_byc ownerspr_byc uppr_byc renterspr_byc downpr_byc owneri owneripr parowner { 
			gen `x'll=`x'-1.96*`x'se
			gen `x'ul=`x'+1.96*`x'se
		}			
		
	replace cohort_5=1975 if cohort_5==1980
	//replace cohort_5=1950 if cohort_5==1955
	foreach x in 50 75 {
		gen parowner`x'=parowner if cohort_5==19`x'
		bysort country: egen parownert`x'=min(parowner`x')
		foreach y in IPHcoh IPHmodd ownerspr uppr renterspr downpr { 
			gen `y'`x'=`y'_byc if cohort_5==19`x'
			bysort country: egen `y't`x'=min(`y'`x')
			}
		}
		
	foreach y in IPHcoh ownerspr uppr renterspr downpr parowner	{
		gen dif`y'=`y't75-`y't50
		gen difr`y'=dif`y'/`y't50
	}	
	
	foreach y in IPHmodd {
		gen dif`y'=log(`y't75)-log(`y't50)
	}		
		
	gen updown=downpr_byc+uppr_byc
	gen difupdown=difdownpr+difuppr
			
	graph bar difIPHmodd, over(country, axis(noline) sort(1)) bar(1, col(black)) hori blabel(total, format(%9.2f) pos(2) size(vsmall)) ///
		yline(0) ylabel(, grid gmin gmax) title(MOR {&Delta}) ytitle("") name(iphdif, replace)
	
	graph bar difupdown, over(country, axis(noline) sort(difIPHmodd)) bar(1, col(stc1))  hori blabel(total, format(%9.2f) pos(2) size(vsmall)) ///
		yline(0) ylabel(-.2(.1).2, grid gmin gmax) title(Total mobility {&Delta}) ytitle("") name(updowndif, replace)	
	
	graph bar difuppr, over(country, axis(noline) sort(difIPHmodd)) bar(1, col(stc2)) hori blabel(total, format(%9.2f) pos(2) size(vsmall)) ///
		yline(0) ylabel(0(-.1)-.3, grid gmin gmax) title(Upward {&Delta}) ytitle("") name(updif, replace)
	
	graph bar difdownpr, over(country, axis(noline) sort(difIPHmodd)) bar(1, col(stc4))  hori blabel(total, format(%9.2f) pos(2) size(vsmall)) ///
		yline(0) title(Downward {&Delta}) ytitle("") name(downdif, replace)
						
	graph combine iphdif updowndif updif downdif, cols(4) name(cohD, replace)		
		
	graph twoway (scatter difIPHmodd difupdown, mlabel(country)) (lfit difIPHmodd difupdown, lp(solid) lw(medthick)), ///
		yline(0, lp(dash)) xline(0, lp(dash)) ///
		ytitle(MOR {&Delta}) xtitle(Total mobility {&Delta}) ///
		ylabel(, grid gmin gmax glcolor(gs12)) xlabel(-.2(.1).2, grid gmin gmax glcolor(gs12)) ///
		legend(off) scheme(Lean2) name(rac, replace) fxsize(75)
	graph combine cohD rac, ysize(3) xsize(6.5) scale(*1.2)	
	graph save "${results}\S7_iph.gph", replace 
	graph export "${results}\S7_iph.png", replace			
	
	
	
	// FIGURE S8
	// Illustrative cases - Spain and Germany
	use cohco, clear 
		collapse (mean) IPHcoh_byc IPHcoh_bycse IPHodd_byc IPHodd_bycse parowner owneri owners*byc* up*byc* down*byc* renters*byc* ///
		(sem) parownerse=parowner ownerise=owneri [aw=cweight_p], by(country_s country cohort_5)	
		
		gen parenter=1-parowner 	
		foreach x in IPHcoh_byc IPHodd_byc ownerspr_byc uppr_byc renterspr_byc downpr_byc owneri parowner { 
			gen `x'll=`x'-1.96*`x'se
			gen `x'ul=`x'+1.96*`x'se
		}	
			
	foreach x in ES DE  {
		twoway (line IPHcoh_byc cohort if country_s=="`x'", lc(black)) ///
			(rarea IPHcoh_bycll IPHcoh_bycul cohort if country_s=="`x'", fcolor(gray%15) lw(vvthin)), ///
			ylabel(0(.1).4) ytitle(IPH) ///
			xlabel(1950 "1950-54" 1955 "1955-59" 1960 "1960-64" 1965 "1965-69" ///
				1970 "1970-74" 1975 "1975-79" 1980 "1980-84", angle(45)) ///
			xtitle(Cohort) legend(order (1 "IPH")) ///
			title(`x') scheme(stcolor_alt) name(`x'iphcoh, replace)
			
		// Stability/mobility by cohort 
		twoway (line ownerspr_byc uppr_byc renterspr_byc downpr_byc cohort if country_s=="`x'", lc(stc1 stc2 stc3 stc4)) ///
			(rarea ownerspr_bycll ownerspr_bycul cohort if country_s=="`x'", fcolor(stc1%15) lw(vvthin)) ///
			(rarea uppr_bycll uppr_bycul cohort if country_s=="`x'", fcolor(stc2%15) lw(vvthin)) ///
			(rarea renterspr_bycll renterspr_bycul cohort if country_s=="`x'", fcolor(stc3%15) lw(vvthin)) ///
			(rarea downpr_bycll downpr_bycul cohort if country_s=="`x'", fcolor(stc4%15) lw(vvthin)), ///
				legend(order(1 "Owner-owner" 2 "Upward mobility" 3 "Renter-renter" 4 "Downward mobility") cols(2) pos(6)) ///
				xlabel(1950 "1950-54" 1955 "1955-59" 1960 "1960-64" 1965 "1965-69" ///
					1970 "1970-74" 1975 "1975-79" 1980 "1980-84", angle(45) grid gmin gmax glcolor(12) glp(dash)) ///
				ylabel(0 .15 "15%" .3 "30%" .45 "45%" .6 "60%" .75 "75%", grid gmin gmax glcolor(gs12) glp(dash)) ///
				ytitle(Prevalence) xtitle(Cohort) ///
				title(`x') scheme(Lean2) name(`x'mobcoh, replace)
		}
						
		grc1leg DEiphcoh ESiphcoh, cols(1) name(iph, replace)
		grc1leg DEmobcoh ESmobcoh, cols(1) name(mob, replace)
		graph combine iph mob
		graph save "${results}\S8_iph.gph", replace 
		graph export "${results}\S8_iph.png", replace		
		
	
	
	// FIGURE S9
	use cohco, clear 
	collapse (mean) IPHcoh_byc IPHcoh_bycse IPHmodd_byc IPHmodd_bycse parowner owneri* owners*byc* up*byc* down*byc* renters*byc* mob* immob* ///
		(sem) parownerse=parowner ownerise=owneri [aw=cweight_p], by(country_s country cohort_5)	
	gen parenter=1-parowner 
	label var IPHcoh_byc "IPH (by cohort)"
	label var IPHmodd_byc "Marginal odds ratio (by cohort)"
	label var ownerspr_byc "Owner-owner" 
	label var renterspr_byc "Renter-renter"		
	label var uppr_byc "Upward mobility"
	label var downpr_byc "Downward mobility"
	label var owneri "Child homeowner"
	label var parowner "Parent homeowner"
	label var parenter "Parent renter"
		foreach x in IPHcoh_byc IPHmodd_byc ownerspr_byc uppr_byc renterspr_byc downpr_byc owneri owneripr parowner { 
			gen `x'll=`x'-1.96*`x'se
			gen `x'ul=`x'+1.96*`x'se
		}			
		
	gen poo=ownerspr_byc/parowner 
	label var poo "Pr(ownership) with owner parents (p{subscript:oo}))"
	gen pro=uppr_byc/(1-parowner) 
	label var pro "Pr(ownership) with renter parents (p{subscript:ro}))"
	
	foreach x in poo pro { 
		twoway (scatter IPHmodd_byc `x', mlabel(country_s)) (lfit IPHmodd_byc `x', lp(solid solid) lw(medthick medthick)), ///
			ytitle(MOR) name(`x', replace) ///
			ylabel(, grid gmin gmax glcolor(gs12)) xlabel(0(.2)1, grid gmin gmax glcolor(gs12)) ///
			legend(off) scheme(Lean2)
	}
	graph combine poo pro, name(po1, replace) title("A. Association between IPH and its components", size(medium) margin(medium))

	label var uppr_byc "Upward mobility"
	label var downpr_byc "Downward mobility"
	foreach x in up down { 
		replace `x'pr_byc=`x'pr_byc*100
	}
	reg IPHmodd_byc c.uppr_byc##c.parowner##c.parowner ///
		c.downpr_byc##c.parowner##c.parowner i.country, vce(cluster country) 
	margins, dydx(c.uppr_byc c.downpr_byc) at(parowner=(.42(.05).92 .95)) post		
	marginsplot, ///	
		xlabel(0.42 "Min(42%)" 0.5 "50%" .63 "1stQ(65%)" 0.75 "Median(75%)" ///
			0.84 "3rdQ(84%)" .95 "Max(95%)", angle(45) grid gmin gmax glcolor(gs12)) ///
		ylabel(, grid gmin gmax glcolor(gs12)) yline(0) ///
		legend(order(3 "Upward mobility" 4 "Downward mobility") pos(6) cols(2)) ///
		ytitle(AME on MOR) xtitle(Parental homeownership level) title(" ") ///
		recast(line) plot1opts(lc(stc2) lp(dash)) plot2opts(lc(stc4) lp(longdash)) ///
		recastci(rarea) ci1opts(fcolor(stc2%15) lw(vvthin)) ci2opts(fcolor(stc4%15) lw(vvthin)) ///
		scheme(Lean2) name(uppr_bycw, replace) fxsize(75) scale(*.95) ///
		title("B. Effect of upward & downward mobility on MOR" "by parental homeownership distribution", size(medium) margin(medium))
			
	graph combine po1 uppr_bycw, imargin(medlarge) ysize(3) xsize(6.5) scale(*1.2)
	graph save "${results}\S9_iph.gph", replace 
	graph export "${results}\S9_iph.png", replace		
	
	
	
	// FIGURE S10
	// Which mobility components explain IPH: Relative mobility | absolute mobility across country-cohort; between & within 
	// Between-within country analysis 
	use cohco, clear 
		collapse (mean) IPHcoh_byc IPHcoh_bycse IPHodd_byc IPHodd_bycse parowner owneri owners*byc* up*byc* down*byc* renters*byc* ///
		(sem) parownerse=parowner ownerise=owneri [aw=cweight_p], by(country_s country cohort_5)	
			gen parenter=1-parowner 
			label var IPHcoh_byc "IPH (by cohort)"
			label var ownerspr_byc "Owner-owner" 
			label var renterspr_byc "Renter-renter"		
			label var uppr_byc "Upward mobility"
			label var downpr_byc "Downward mobility"
			label var owneri "Child homeowner"
			label var parowner "Parent homeowner"
			label var parenter "Parent renter"
			foreach x in IPHcoh_byc IPHodd_byc ownerspr_byc uppr_byc renterspr_byc downpr_byc owneri parowner { 
				gen `x'll=`x'-1.96*`x'se
				gen `x'ul=`x'+1.96*`x'se
			}			
		
		// Within-between models 
		eststo clear
		foreach x in owners up renters down {
			eststo p`x': reg IPHcoh_byc `x'pr_byc, vce(cluster country) 
			eststo w`x': reg IPHcoh_byc `x'pr_byc i.country, vce(cluster country)
			eststo b`x': reg IPHcoh_byc `x'pr_byc i.cohort, vce(cluster country)
		}
		esttab using wb.rtf, mti keep(ownerspr_byc renterspr_byc uppr_byc downpr_byc) compress replace
		
		coefplot (bowners, m(O) msiz(med) mc(stc1) label("")) ///
			(bup, m(O) msiz(med) mc(stc2) label("")) ///
			(brenters, m(O) msiz(med) mc(stc3) label("")) ///
			(bdown, m(O) msiz(med) mc(stc4) label("")), bylabel("Between-country") || ///
			(wowners, m(O) msiz(med) mc(stc1) label("")) ///
			(wup, m(O) msiz(med) mc(stc2) label("")) ///
			(wrenters, m(O) msiz(med) mc(stc3) label("")) ///
			(wdown, m(O) msiz(med) mc(stc4) label("")), bylabel("Within-country") ||, ///
				drop(*country *cohort_5 _cons) nokey ///
				xline(0) xtitle(Coefficients) mlab mlabformat(%9.2f) mlabpos(2) ///
				name(wbw, replace) scale(1.3) scheme(stcolor)
		graph save "${results}\S10_iph.gph", replace 
		graph export "${results}\S10_iph.png", replace		
	
	
	
	// FIGURE S11
	// Variation by welfare state regime 
	use cohco, clear 
	recode country (8 12 16 17 23 = 1 "Social-Democratic") ///
		(7 1 2 13 20 4 = 2 "Conservative") /// 
		(18 11 25 10 5 = 3 "Mediterranean") ///
		(6 30 24 15 9 21 19 29 26 = 4 "Post-Socialist"), into(regime) lab(reg)
		drop if country==23
	collapse (mean) IPHcoh_byc IPHcoh_bycse IPHmodd_byc IPHmodd_bycse parowner owneri* owners*byc* up*byc* down*byc* renters*byc* mob* immob* ///
		(sem) parownerse=parowner ownerise=owneri [aw=cweight_p], by(regime cohort_5)
			foreach x in IPHcoh_byc IPHmodd_byc ownerspr_byc uppr_byc renterspr_byc downpr_byc owneri owneripr parowner mobpr_byc immobpr_byc { 
			gen `x'll=`x'-1.96*`x'se
			gen `x'ul=`x'+1.96*`x'se
		}
		
	/*twoway (line owneri parowner cohort, lw(medthick medthick) lc(black gs5)) ///
		(rarea parownerll parownerul cohort, fcolor(gray%15) lw(vvthin)) ///
		(rarea ownerill owneriul cohort, fcolor(gray%15) lw(vvthin)), ///
			by(regime,  cols(4) note(" ")) ///
			legend(order(2 "Homeowner parent" 1 "Homeowner children" ) pos(3)) ///
			ylabel(0 .2 "20%" .4 "40%" .6 "60%" .8 "80%" 1 "100%", grid gmin gmax glcolor(gs10) glp(dash)) ///
			xlabel(1950(10)1980, angle(45) grid gmin gmax glcolor(gs10) glp(dash)) ///
			ytitle(Prevalence) xtitle(Cohort) ///
			name(EUownercoh_byr, replace) scheme(Lean2) 
	*/			
				
	twoway (line IPHcoh_byc cohort , lc(black) lw(medthick)) ///
		(rarea IPHcoh_bycll IPHcoh_bycul cohort, fcolor(gray%15) lw(vvthin)), ///
			by(regime, legend(off) cols(4) note(" ")) ///
			ylabel(0(.1).40, grid gmin gmax glcolor(gs10) glp(dash)) ytitle(IPH) ///
			xlabel(1950 "1950s" 1960 "1960s" 1970 "1970s" 1980 "1980s", angle(45) grid gmin gmax glcolor(gs12) glp(dash)) ///
			ytitle(IPH) xtitle(Cohort) scheme(Lean2) name(EUiph_byr, replace) 
			
	twoway (line IPHmodd_byc cohort , lc(black) lw(medthick)) ///
		(rarea IPHmodd_bycll IPHmodd_bycul cohort, fcolor(gray%15) lw(vvthin)), ///
			by(regime, legend(off) cols(4) note(" ")) ///
			ylabel(1(1)6, grid gmin gmax glcolor(gs10) glp(dash)) ytitle(IPH) ///
			xlabel(1950 "1950s" 1960 "1960s" 1970 "1970s" 1980 "1980s", angle(45) grid gmin gmax glcolor(gs12) glp(dash)) ///
			ytitle(MOR) xtitle(Cohort) scheme(Lean2) name(EUodd_byr, replace) ysize(3)				
	
	twoway (line mobpr_byc downpr_byc uppr_byc cohort, lw(medthick medthick medthick) lc(stc1 stc4 stc2)) ///
		(rarea mobpr_bycll mobpr_bycul cohort, fcolor(stc1%15) lw(vvthin)) ///
		(rarea uppr_bycll uppr_bycul cohort, fcolor(stc2%15) lw(vvthin)) ///
		(rarea downpr_bycll downpr_bycul cohort, fcolor(stc4%15) lw(vvthin)), ///
			by(regime, cols(4) note(" ")) ///
			legend(order(1 "Total" 2 "Downward" 3 "Upward") cols(3) pos(6)) ///
			xlabel(1950 "1950s" 1960 "1960s" 1970 "1970s" 1980 "1980s", angle(45) grid gmin gmax glcolor(gs12) glp(dash)) ///
			ylabel(0 .2 "20%" .4 "40%" .6 "60%" .8 "80%", grid gmin gmax glcolor(gs12)) ///
			ytitle(Prevalence) xtitle(Cohort) ///
			scheme(Lean2) name(EUmobcoh_byr, replace)	

	graph combine EUiph_byr EUodd_byr EUmobcoh_byr, cols(1) imargin(vsmall) ysize(6.5) xsize(4.5)
	graph save "${results}\S11_iph.gph", replace 
	graph export "${results}\S11_iph.png", replace
	
	

	
	