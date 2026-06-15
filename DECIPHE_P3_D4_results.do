
/* 
Project: DECIPHE - Demographich change and intergenerational persistence of homeownership in Europe https://www.deciphe.eu 
	
Author: Selçuk Bedük (University of Oxford)
		Enrico Benassi (University of Oxford)
		
Date of code: June 2026

Purpose: Main analysis  

Inputs: cohco.dta (from DECIPHE_P3_D3_estimation using data from EU-SILC 2004-2023)   

Reference to data: EU-SILC 2004-2023 Cross-sectional

Data access conditions: Details available at https://ec.europa.eu/eurostat/web/microdata/european-union-statistics-on-income-and-living-conditions 

Outputs: Figures 1 to 6 
*/
clear all
global data "C:\Users\selcuk.beduk\Dropbox\Research\Projects\DECIPHE\Papers\Paper 3 - Intergenerational persistence\Data"
global results "C:\Users\selcuk.beduk\Dropbox\Research\Projects\DECIPHE\Papers\Paper 3 - Intergenerational persistence\Submission\ESR\2nd revision\Results_r2"
cd "C:\Users\selcuk.beduk\Dropbox\Research\Projects\DECIPHE\Papers\Paper 3 - Intergenerational persistence\Data"	
	
	
	use cohco, clear 
	collapse (mean) IPHcoh IPHcohse IPHodd IPHoddse IPHmodd IPHmoddse owneri* parowner owners* up* down* renters* mob* immob* (sem) ownerise=owneri parownerse=parowner [aw=cweight_p], by(cohort_5)	
	foreach x in IPHcoh IPHodd IPHmodd ownerspr uppr renterspr downpr owneri parowner owneripr immobpr mobpr { 
		gen `x'll=`x'-1.96*`x'se
		gen `x'ul=`x'+1.96*`x'se
		}
		
	label var ownerspr "Owner-owner" 
	label var renterspr "Renter-renter"		
	label var uppr "Upward mobility"
	label var downpr "Downward mobility"
	label var owneri "Child homeowner"
	label var parowner "Parent homeowner"
	lab var immob "Total immobility"
	lab var mob "Total mobility"
		
		
		
	// FIGURE 1		
	// Homeownership of parents and children by cohort 
	twoway (line owneripr parowner cohort, lw(medthick medthick) lc(black gs5)) ///
		(rarea parownerll parownerul cohort, fcolor(gray%15) lw(vvthin)) ///
		(rarea owneriprll owneriprul cohort, fcolor(gray%15) lw(vvthin)), ///
			legend(order(2 "Homeowner parent" 1 "Homeowner children" ) pos(3)) ///
			ylabel(0 .2 "20%" .4 "40%" .6 "60%" .8 "80%" 1 "100%", grid gmin gmax glcolor(gs10) glp(dash)) ///
			xlabel(1950 "1951-54" 1955 "1955-59" 1960 "1960-64" 1965 "1965-69" ///
				1970 "1970-74" 1975 "1975-79" 1980 "1980-84", ///
				angle(45) grid gmin gmax glcolor(gs10) glp(dash)) ///
			ytitle(Prevalence) xtitle(Children's birth cohort) ///
			graphregion(margin(medlarge)) plotregion(margin(medlarge)) ///
			text( 0.75 1950.5 "70%" , size(small)) text( 0.39 1980 "44%" , size(small)) ///
			text( 0.57 1950.5 "62%" , c(gs5) size(small)) text( 0.79 1980 "74%" , c(gs5) size(small)) ///
			scheme(Lean2) ysize(2.5) xsize(4) scale(1.2) name(EUownercoh, replace)  
	graph save "${results}\F1_iph.eps", replace 
	graph save "${results}\F1_iph.gph", replace 
	graph export "${results}\F1_iph.png", replace 		
		
		
	
	// FIGURE 2
	// Relative mobility i.e., IPH 
	twoway (line IPHcoh cohort , lc(black) lw(medthick)) ///
		(rarea IPHcohll IPHcohul cohort, fcolor(gray%15) lw(vvthin)), ///
			ylabel(0(.05).30, grid gmin gmax glcolor(gs10) glp(dash)) ytitle(IPH) ///
			xlabel(1950 "1951-54" 1955 "1955-59" 1960 "1960-64" 1965 "1965-69" ///
				1970 "1970-74" 1975 "1975-79" 1980 "1980-84", angle(45) grid gmin gmax glcolor(gs10) glp(dash)) ///
			ytitle(IPH) xtitle(Cohort) title("A. IPH", pos(11)) legend(off) scheme(Lean2) name(EUiph, replace) 		
		
	// Marginal odds ratio 
	twoway (line IPHmodd cohort , lc(black) lw(medthick)) ///
		(rarea IPHmoddll IPHmoddul cohort, fcolor(gray%15) lw(vvthin)), ///
			ylabel(1(0.5)3, grid gmin gmax glcolor(gs10) glp(dash)) ytitle(IPH) ///
			xlabel(1950 "1950-54" 1955 "1955-59" 1960 "1960-64" 1965 "1965-69" ///
			1970 "1970-74" 1975 "1975-79" 1980 "1980-84", angle(45) grid gmin gmax glcolor(gs10) glp(dash)) ///
			ytitle(Marginal odds ratio) xtitle(Cohort) title("B. Marginal odds ratio", pos(11)) ///
			legend(off)  ysize(3) xsize(4.5) scheme(Lean2) name(EUmodd, replace)	
			
	// Pr(ownership) for owner vs. renter parents 
	gen poo=ownerspr/parowner 
	label var poo "Pr(ownership) with owner parents (p{subscript:oo}))"
	gen pro=uppr/(1-parowner) 
	label var pro "Pr(ownership) with renter parents (p{subscript:ro}))"
		
	twoway (line poo pro cohort, lw(medthick medthick) lp(longdash shortdash)), ///
		ylabel(0 .2 "20%" .4 "40%" .6 "60%" .8 "80%" 1 "100%", grid gmin gmax glcolor(gs10) glp(dash)) ///
			xlabel(1950 "1951-54" 1955 "1955-59" 1960 "1960-64" 1965 "1965-69" ///
			1970 "1970-74" 1975 "1975-79" 1980 "1980-84", angle(45) grid gmin gmax glcolor(gs10) glp(dash)) ///
			ytitle(Probability of homeownership) xtitle(Cohort) title("C. p{subscript:oo} and p{subscript:ro}", pos(11)) /// 
			text( 0.76 1964 "p{subscript:oo}" , size(medium)) ///
			text( 0.43 1967 "p{subscript:ro}" , size(medium)) ///
			legend(off) scheme(Lean2) name(EUpoopro, replace)
	
			
	graph combine EUiph EUmodd EUpoopro, xcommon cols(3) ysize(2.5) xsize(6.5) scale(*1.2)
	graph save "${results}\F2_iph.eps", replace 
	graph save "${results}\F2_iph.gph", replace 
	graph export "${results}\F2_iph.png", replace 
	
	
	
	// FIGURE 3
	// Absolute mobility by cohort 
	twoway (line mobpr downpr uppr cohort, lw(medthick medthick medthick) lc(stc1 stc4 stc2)) ///
		(rarea mobprll mobprul cohort, fcolor(stc1%15) lw(vvthin)) ///
		(rarea upprll upprul cohort, fcolor(stc2%15) lw(vvthin)) ///
		(rarea downprll downprul cohort, fcolor(stc4%15) lw(vvthin)), ///
			legend(order(1 "Total" 2 "Downward" 3 "Upward") cols(1) pos(3)) ///
			xlabel(1950 "1951-54" 1955 "1955-59" 1960 "1960-64" 1965 "1965-69" ///
					1970 "1970-74" 1975 "1975-79" 1980 "1980-84", angle(45) grid gmin gmax glcolor(gs12)) ///
			ylabel(0 .15 "15%" .3 "30%" .45 "45%" .6 "60%", grid gmin gmax glcolor(gs12)) ///
			ytitle(Mobility rate) xtitle(Cohort) graphregion(margin(medlarge)) plotregion(margin(medlarge)) ///
			text( 0.275 1950.5 "0.23" , c(stc2) size(small)) text( 0.045 1979.35 "0.08" , c(stc2) size(small)) ///
			text( 0.10 1950.5 "0.14" , c(stc4) size(small)) text( 0.4175 1979.35 "0.38" , c(stc4) size(small)) ///
			text( 0.42 1950.5 "0.37" , c(stc1) size(small)) text( 0.515 1979.35 "0.47" , c(stc1) size(small)) ///
			scheme(Lean2) ysize(2.5) xsize(4) scale(1.2) name(EUmobcoh, replace) 
	graph save "${results}\F3_iph.eps", replace 
	graph save "${results}\F3_iph.gph", replace 
	graph export "${results}\F3_iph.png", replace 
		
		
		
	// FIGURE 4 
	// Country variation in relative and absolute mobility 
	use cohco, clear 
	collapse (mean) IPHcoh_byc IPHcoh_bycse IPHmodd_byc IPHmodd_bycse parowner owneri* owners*byc* up*byc* down*byc* renters*byc* mob* immob* ///
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
		foreach x in IPHcoh_byc IPHmodd_byc ownerspr_byc uppr_byc renterspr_byc downpr_byc owneri owneripr parowner { 
			gen `x'll=`x'-1.96*`x'se
			gen `x'ul=`x'+1.96*`x'se
		}			
		
	replace cohort_5=1975 if cohort_5==1980
	//replace cohort_5=1950 if cohort_5==1955
	foreach x in 50 75 {
		gen parowner`x'=parowner if cohort_5==19`x'
		bysort country: egen parownert`x'=min(parowner`x')
		foreach y in IPHcoh IPHodd ownerspr uppr renterspr downpr { 
			gen `y'`x'=`y'_byc if cohort_5==19`x'
			bysort country: egen `y't`x'=min(`y'`x')
			}
		}
		
	foreach y in IPHcoh IPHodd ownerspr uppr renterspr downpr parowner	{
		gen dif`y'=`y't75-`y't50
		gen difr`y'=dif`y'/`y't50
	}	
		
	gen updown=downpr_byc+uppr_byc
	gen difupdown=difdownpr+difuppr
			
	graph bar difIPHcoh, over(country, axis(noline) sort(1)) bar(1, col(black)) hori blabel(total, format(%9.2f) pos(2) size(vsmall)) yline(0) ylabel(, grid gmin gmax) title(IPH {&Delta}) ytitle("") name(iphdif, replace)
	
	graph bar difupdown, over(country, axis(noline) sort(difIPHcoh)) bar(1, col(stc1))  hori blabel(total, format(%9.2f) pos(2) size(vsmall)) yline(0) ylabel(-.2(.1).2, grid gmin gmax) title(Total mobility {&Delta}) ytitle("") name(updowndif, replace)	
	
	graph bar difuppr, over(country, axis(noline) sort(difIPHcoh)) bar(1, col(stc2)) hori blabel(total, format(%9.2f) pos(2) size(vsmall)) yline(0) ylabel(0(-.1)-.3, grid gmin gmax) title(Upward {&Delta}) ytitle("") name(updif, replace)
	
	graph bar difdownpr, over(country, axis(noline) sort(difIPHcoh)) bar(1, col(stc4))  hori blabel(total, format(%9.2f) pos(2) size(vsmall)) yline(0) title(Downward {&Delta}) ytitle("") name(downdif, replace)
						
	graph combine iphdif updowndif updif downdif, cols(4) name(cohD, replace)		
		
	graph twoway (scatter difIPHcoh difupdown, mlabel(country)) (lfit difIPHcoh difupdown, lp(solid) lw(medthick)), ///
		yline(0, lp(dash)) xline(0, lp(dash)) ///
		ytitle(IPH {&Delta}) xtitle(Total mobility {&Delta}) ///
		ylabel(, grid gmin gmax glcolor(gs12)) xlabel(-.2(.1).2, grid gmin gmax glcolor(gs12)) ///
		legend(off) scheme(Lean2) name(rac, replace) fxsize(75)
	graph combine cohD rac,  ysize(3) xsize(6.5) scale(*1.2)
	graph save "${results}\F4_iph.eps", replace 
	graph save "${results}\F4_iph.gph", replace 
	graph export "${results}\F4_iph.png", replace				
				
	
	  			
	// FIGURE 5 
	// What explains the divergence? The role of origin distribution (parental homeownership)
	// Which absolute mobility components driving relative mobility? 
	// Poo and Pro - country-cohort pooled data
	gen poo=ownerspr_byc/parowner 
	label var poo "Pr(ownership) with owner parents (p{subscript:oo}))"
	gen pro=uppr_byc/(1-parowner) 
	label var pro "Pr(ownership) with renter parents (p{subscript:ro}))"
	
	foreach x in poo pro { 
		twoway (scatter IPHcoh_byc `x', mlabel(country_s)) (lfit IPHcoh_byc `x', lp(solid solid) lw(medthick medthick)), ///
			ytitle(IPH) name(`x', replace) ///
			ylabel(, grid gmin gmax glcolor(gs12)) xlabel(0(.2)1, grid gmin gmax glcolor(gs12)) ///
			legend(off) scheme(Lean2)
	}
	graph combine poo pro, name(po1, replace) title("A. Association between IPH and its components", size(medium) margin(medium))

	label var uppr_byc "Upward mobility"
	label var downpr_byc "Downward mobility"
	foreach x in up down { 
		replace `x'pr_byc=`x'pr_byc*100
	}	
	reg IPHcoh_byc c.uppr_byc##c.parowner##c.parowner ///
		c.downpr_byc##c.parowner##c.parowner i.country, vce(cluster country) 
	margins, dydx(c.uppr_byc c.downpr_byc) at(parowner=(.42(.05).92 .95)) post		
	marginsplot, ///	
		xlabel(0.42 "Min(42%)" 0.5 "50%" .63 "1stQ(65%)" 0.75 "Median(75%)" ///
			0.84 "3rdQ(84%)" .95 "Max(95%)", angle(45) grid gmin gmax glcolor(gs12)) ///
		ylabel(-.1(.02).01, grid gmin gmax glcolor(gs12)) yline(0) ///
		legend(order(3 "Upward mobility" 4 "Downward mobility") pos(6) cols(2)) ///
		ytitle(AME on IPH) xtitle(Parental homeownership level) title(" ") ///
		recast(line) plot1opts(lc(stc2) lp(dash)) plot2opts(lc(stc4) lp(longdash)) ///
		recastci(rarea) ci1opts(fcolor(stc2%15) lw(vvthin)) ci2opts(fcolor(stc4%15) lw(vvthin)) ///
		scheme(Lean2) name(uppr_bycw, replace) fxsize(75) scale(*.95) ///
		title("B. Effect of upward & downward mobility on IPH" "by parental homeownership distribution", size(medium) margin(medium))
			
	graph combine po1 uppr_bycw, imargin(medlarge) ysize(3) xsize(6.5) scale(*1.2)
	graph save "${results}\F5_iph.eps", replace 
	graph save "${results}\F5_iph.gph", replace 
	graph export "${results}\F5_iph.png", replace		
		
		
		
	// FIGURE 6  
	// What explains the divergence? The role of origin distribution (Structural change vs. parent effects)	
	use cohco, clear 
	collapse (mean) IPHcoh IPHcohse IPHodd IPHoddse IPHmodd IPHmoddse owneri* parowner owners* up* down* renters* mob* immob* (sem) ownerise=owneri parownerse=parowner [aw=cweight_p], by(cohort_5)	
		foreach x in IPHcoh IPHodd IPHmodd ownerspr uppr renterspr downpr owneri parowner owneripr immobpr mobpr { 
				gen `x'll=`x'-1.96*`x'se
				gen `x'ul=`x'+1.96*`x'se
			}
	gen renteri = 1-owneri
	gen parenter= 1-parowner		
	label var ownerspr "Owner-owner" 
	label var renterspr "Renter-renter"		
	label var uppr "Upward mobility"
	label var downpr "Downward mobility"
	label var owneri "Child homeowner"
	label var parowner "Parent homeowner"
	lab var immob "Total immobility"
	lab var mob "Total mobility"
					
					
	// Counterfactual - Europe average: If odds ratio is fixed to the rate of 1950s cohorts, what would be the mobility rates for later cohorts given observed margins 
	* Fix the base (1950s) odds ratio 
	gen obase = IPHodd if cohort_5==1950
	egen oddbase = min(obase)
	drop obase

	* Quadratic coefficients (A x^2 - B x + C = 0 with A = 1 - oddbase)
	gen A = 1 - oddbase
	gen B = (owneri + parenter) + oddbase*(parowner - owneri)
	gen C = owneri*parenter

	* Discriminant 
	gen disc = B^2 - 4*A*C
	replace disc = 0 if disc<0 & disc>-1e-12

	* Solve for x (counterfactual upward mobility)
	gen x1 = . 
	gen x2 = . 
	replace x1 = (B - sqrt(disc)) / (2*A) if oddbase!=1
	replace x2 = (B + sqrt(disc)) / (2*A) if oddbase!=1

	* Feasible interval for x: [max(0, owneri - parowner), min(owneri, parenter)]
	gen lower = max(0, owneri - parowner)
	gen upper = min(owneri, parenter)

	gen xcf = .
	replace xcf = x1 if oddbase!=1 & x1>=lower & x1<=upper
	replace xcf = x2 if oddbase!=1 & missing(xcf) & x2>=lower & x2<=upper

	* If odds ratio = 1 then x = parenter*owneri
	replace xcf = parenter*owneri if oddbase==1

	* Counterfactual mobility 
	gen up_cf = xcf                      	// upward (parent renter -> child owner)
	gen owners_cf = owneri - xcf            // owner-owner
	gen down_cf = parowner + xcf - owneri   // downward (parent owner -> child renter)
	gen renters_cf = parenter - xcf         // renter-renter

	line uppr up_cf cohort_5, lc(stc2 stc2) lp(solid dash) ///
		ytitle(Mobility rate) xtitle(Cohort) legend(off) ///
		xlabel(, grid gmin gmax glcolor(gs12)) ///
		ylabel(0 .1 "10%" .2 "20%" .3 "30%" .4 "40%", grid gmin gmax glcolor(gs12)) ///
		text(0.14 1973 "Observed", size(small)) ///
		text(0.068 1976.5 "Counterfactual", size(small)) ///
		name(cf2_avu, replace)  title(Upward mobility)  

	line downpr down_cf cohort_5, lc(stc4 stc4) lp(solid dash) ///
	ytitle(Mobility rate) xtitle(Cohort) legend(off) ///
	xlabel(, grid gmin gmax glcolor(gs12)) ///
	ylabel(0 .1 "10%" .2 "20%" .3 "30%" .4 "40%", grid gmin gmax glcolor(gs12)) ///
	text(0.37 1975.5 "Observed", size(small)) ///
	text(0.265 1974.5 "Counterfactual", size(small)) ///
	name(cf2_avd, replace)  title(Downward mobility) 

	graph combine cf2_avu cf2_avd, title(A. Average European across cohorts, size(medium) margin(medium)) name(cf2_av, replace) imargin(small)

			
	// Across countries: If odds ratio is fixed to the rate of 1950s cohorts, what would be the mobility rates for later cohorts given observed margins 		
	* Fix the base (1950s) odds ratio 
	use cohco, clear 
	collapse (mean) IPHcoh_byc IPHcoh_bycse IPHodd_byc IPHodd_bycse parowner owneri owners*byc* up*byc* down*byc* renters*byc* mob* immob* ///
		(sem) parownerse=parowner ownerise=owneri [aw=cweight_p], by(country_s country cohort_5)	
	gen renteri = 1-owneri
	gen parenter= 1-parowner
	label var IPHcoh_byc "IPH (by cohort)"
	label var ownerspr_byc "Owner-owner" 
	label var renterspr_byc "Renter-renter"		
	label var uppr_byc "Upward mobility"
	label var downpr_byc "Downward mobility"
	label var owneri "Child homeowner"
	label var renteri "Child renter"
	label var parowner "Parent homeowner"
	label var parenter "Parent renter"
	foreach x in IPHcoh_byc IPHodd_byc ownerspr_byc uppr_byc renterspr_byc downpr_byc owneri parowner { 
		gen `x'll=`x'-1.96*`x'se
		gen `x'ul=`x'+1.96*`x'se
	}		
	
	gen obase = IPHodd_byc if cohort_5==1950
	bysort country: egen oddbase = min(obase)
	drop obase

	* Quadratic coefficients (A x^2 - B x + C = 0 with A = 1 - oddbase)
	gen A = 1 - oddbase
	gen B = (owneri + parenter) + oddbase*(parowner - owneri)
	gen C = owneri*parenter

	* Discriminant 
	gen disc = B^2 - 4*A*C
	replace disc = 0 if disc<0 & disc>-1e-12

	* Solve for x (counterfactual upward mobility)
	gen x1 = . 
	gen x2 = . 
	replace x1 = (B - sqrt(disc)) / (2*A) if oddbase!=1
	replace x2 = (B + sqrt(disc)) / (2*A) if oddbase!=1

	* Feasible interval for x: [max(0, owneri - parowner), min(owneri, parenter)]
	gen lower = max(0, owneri - parowner)
	gen upper = min(owneri, parenter)

	gen xcf = .
	replace xcf = x1 if oddbase!=1 & x1>=lower & x1<=upper
	replace xcf = x2 if oddbase!=1 & missing(xcf) & x2>=lower & x2<=upper

	* If odds ratio = 1 then x = parenter*owneri
	replace xcf = parenter*owneri if oddbase==1

	* Counterfactual mobility 
	gen up_cf = xcf                      	// upward (parent renter -> child owner)
	gen owners_cf = owneri - xcf            // owner-owner
	gen down_cf = parowner + xcf - owneri   // downward (parent owner -> child renter)
	gen renters_cf = parenter - xcf         // renter-renter


	twoway (scatter uppr_byc up_cf, ml(country) mlabc(stc2) mc(stc2)) ///
		(function y=x, range(0 .4) lp(dash) lw(medthick)), ///
		ytitle(Observed) xtitle(Counterfactual) title(Upward mobility) legend(off) ///
		xlabel(0 .1 "10%" .2 "20%" .3 "30%" .4 "40%", grid gmin gmax glcolor(gs12)) ///
		ylabel(0 .1 "10%" .2 "20%" .3 "30%" .4 "40%", grid gmin gmax glcolor(gs12)) ///
		name(cf2_b1, replace)   

	twoway (scatter downpr_byc down_cf, ml(country) mlabc(stc4) mc(stc4)) ///
		(function y=x, range(0 .6) lp(dash) lw(medthick)), ///
		ytitle(Observed) xtitle(Counterfactual) title(Downward mobility) legend(off) ///
		xlabel(0 .15 "15%" .3 "30%" .45 "45%" .6 "60%", grid gmin gmax glcolor(gs12)) ///
		ylabel(0 .15 "15%" .3 "30%" .45 "45%" .6 "60%", grid gmin gmax glcolor(gs12)) ///
		name(cf2_b2, replace)  

	graph combine cf2_b1 cf2_b2, title(B. Across countries and cohorts, size(medium) margin(medium)) name(cf2_byc, replace) imargin(small)

	graph combine cf2_av cf2_byc, imargin(medium) ysize(3) xsize(6.5) scale(*1.2)
	graph save "${results}\F6_iph.eps", replace 
	graph save "${results}\F6_iph.gph", replace 
	graph export "${results}\F6_iph.png", replace	
	
	
/*	To check the absolute difference in observed-counterfactual across countries
	gen ugap=uppr - up_cf
	gen dgap=downpr - down_cf 
	graph bar ugap, over(country, sort(1)) bar(1, col(stc2)) hori blabel(total, format(%9.2f) pos(2) size(vsmall)) ytitle(Observed - Counterfactual) title(Upward mobility) name(ugap, replace)
	graph bar dgap, over(country, sort(1)) bar(1, col(stc4)) hori blabel(total, format(%9.2f) pos(2) size(vsmall)) ytitle(Observed - Counterfactual) title(Downward mobility) name(dgap, replace)
	 
	graph combine ugap dgap, ysize(3) xsize(6.5) name(cf2_ubyc_ap, replace)
*/
			
			
			
	