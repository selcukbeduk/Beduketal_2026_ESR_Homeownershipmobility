
/* 
Project: DECIPHE - Demographich change and intergenerational persistence of homeownership in Europe https://www.deciphe.eu 
	
Author: Enrico Benassi (University of Oxford)
		Selçuk Bedük (University of Oxford)

Date of code: 6 Aug 2025 

Purpose: Constructing key variables 

Inputs: EUSILC_0423_RPDH.dta (from DECIPHE_P1_D1_dataprep using data from EU-SILC 2004-2023)   

Reference to data: EU-SILC 2004-2023 Cross-sectional

Data access conditions: Details available at https://ec.europa.eu/eurostat/web/microdata/european-union-statistics-on-income-and-living-conditions 

Outputs: DCP_EUSILC_0423.dta 
*/



**************************************************
*** PROVIDE DIRECTORIES INPUT
clear all
// NB: data directories need to be defined using forward slash " / " 
	global data "C:\Users\selcuk.beduk\Dropbox\Research\Projects\DECIPHE\Data\EU-SILC"
	global cd "C:\Users\selcuk.beduk\Dropbox\Research\Projects\DECIPHE\Papers\Paper 3 - Intergenerational persistence\Data"

	
	
**************************************************
*** OUTCOME VARIABLES 
* Homeownership defined at different levels:
* Household (H): Living in an owner-occupied household
* Partner (P): HRP or their partner own the house 
* Individual (I): Individual own the house (either individually or shared with partner)

	use "${data}/EUSILC_0423_RPDH.dta", clear
	
	// Base label definitions for housing tenure: hh020 hh021 htenure
	label var hh020 "Housing tenure pre 2010"
	label var hh021 "Housing tenure post 2010"
	label var htenure "Tenure status"
	label define hh021_vl 1 "Outright owner" 2 "Owner paying mortgage" 3 "Tenant at market rate" 4 "Tenant at reduced rate" 5 "Free accomodation"
	label define hh020_vl 1 "Owner" 2 "Tenant at market rate" 3 "Tenant at reduced rate" 4 "Free accomodation" 
	label define hx070_vl 1 "When hh021 ownership or free" 2 "When hh021 rented"
	label values hh021 hh021_vl
	label values hh020 hh020_vl
	label values htenure hx070_vl
	
	// Constructing housing tenure using hh020 and hh021	
	// hh020 is the main variable until 2010
	// hh021 is a more detailed variable distinguishing mortgage-owners starting from 2010
	gen hh21=hh021 
	replace hh21=2 if hh021==1 // harmonizing hh021 with hh020 
	replace hh21=hh21-1 
	gen tenure = hh020			 
	replace tenure=hh21 if missing(hh020) & hh021!=. // In 2010 both hh020 and hh021 is collected, and the latter has less missing values
	label define ht 1 "Owner" 2 "Market rate tenant" 3 "Reduced rent" 4 "Free acc. or other"
	label value tenure ht 
	label variable tenure "Housing tenure"
	 
	// Household ownership (H) 
	gen ownerh=(tenure==1) if tenure!=. 
	label variable ownerh "Homeownership: H"
	label define own 1 "Owner" 0 "Non-owner"
	label value ownerh own 
	
	// Individual ownership (I) 	
	gen owneri=.
	label variable hrp1 "ID of 1st owner or responsible"
	label variable hrp2 "ID of 2nd owner or responsible"
	replace owneri=1 if ownerh==1 &  (pid==hrp1 | pid==hrp2) 	// Either HRP is the owner
	replace owneri=0 if ownerh==0 
	replace owneri=0 if ownerh==1 & pid!=hrp1 & pid!=hrp2 		// Live in owner-occupied home but not the HRP 1 or 2
	replace owneri=. if ownerh==. | year>2020
	label variable owneri "Homeownership: I"
	label value owneri own 

	// Partner/couple ownership (P) 	
	replace partnerid=0 if partnerid_f==2 	// these are singles without partners
	gen ownerp=. 
	replace ownerp=1 if ownerh==1 & (pid == hrp1 | pid == hrp2)			// hrp owner  
	replace ownerp=1 if ownerh==1 & (partnerid == hrp1 | partnerid == hrp2) & partnerid!=.	 // hrp partner owner 
	replace ownerp=0 if ownerh==1 & (pid != hrp1 & pid != hrp2 & partnerid != hrp1 & partnerid != hrp2) & partnerid_f!=.  // all others in the household  
	replace ownerp=0 if ownerh==0  	 // renters 
	replace ownerp=0 if owneri==0 & partnerid_f==-2 // singles who are not owners themselves should also not be owners in couple definition
	replace ownerp=. if ownerh==. | year>2020
	label variable ownerp "Homeownership: P"
	label value ownerp own 
	
	
	
**************************************************	
*** EXPLANATORY VARIABLES  
	// Country
	rename country country_s
	encode country_s, gen(country) 
	label var country "Country"
	label var country_s "Country string"
	
	// Gender
	gen female=sex-1 
	label define fem 1 "Women" 0 "Men"
	label value female fem
	label variable female "Female"
	drop sex // not needed anymore

	// Age-related 
	label var age_yt "Age at the end of the income period"
	label var age_s "Age at the end of the survey"

	gen age_c = year - cohort - 1 // age self computed - avoid error such as no MT computation and mising
	label variable age_c "Age computed"
	replace age_c=0 if age_c<0 		// Measurement error related to year of birth of newborns 
	replace age_c=80 if age_c>80 & age_c!=. 
	
	replace age_s=age_c if country_s=="DE"  // For Germany, the age was perturbated, so just using our approximate age instead
	
	recode age_s (20/30=1 "Age 20-30") (31/40=2 "Age 31-40") (41/80=3 "Age 41+"), into(age3) // Age groups
	replace age3=. if age3>4 | age3<1 
	
	recode age_s (25/34=1 "Age 25-34") (35/44=2 "Age 35-44") (45/80=3 "Age 45+"), into(age3y) 
	replace age3y=. if age3y>4 | age3y<1 
	
	gen age = age_s // use adjusted age at the end of survey to compute following demographic variables
	gen kids=(age<16) if age!=. 
	label var kids "Younger than 16"
	gen young=(age<=35)
	label var young "Younger than 36"
	gen old=(age>=65)
	label var old "Older than 65"
	gen age1630=(age>15 & age<31)
	label var age1630 "Between 16 and 30 years old"
	gen age3145=(age>30 & age<46)
	label var age3145 "Between 31 and 45 years old"
	
	// Demographics 
	gen x=1
	bysort year country hid: egen hhsize=total(x)
	label var hhsize "N. of people in the household"

	gen single=(hhsize==1) if hhsize!=. 
	label var single "One person household"

	gen partner=(partnerid_f==1) if partnerid_f!=-1 & partnerid_f!=.  
	label var partner "Lives with partner"

	bysort hid year country: egen nkids=total(kids)
	label var nkids "Number of kids"	

	gen childless=(nkids==0 & partner==1 & age>19 & age<46)
	label var childless "No kids in a young-partner household"

	gen livwpar=(fatherid_f==1 | motherid_f==1) if fatherid_f!=. & motherid_f!=.
	replace livwpar=0 if age3==3
	label var livwpar "Living with parents (age<41)"

	// HH Income 
	label variable hhnetincome "Household net income"
	
/*	Remove these if you'd like to construct an earnings group variable based on country*year earnings distribution 
	We made this optional as it slows down the code significantly. 
*/	
	// Earnings in three groups 
	gen xearn4=. 
	label var xearn4 "Earnings quartile groups"
	levelsof country, local(clevels) 
		foreach c of local clevels { 
			levelsof year, local(yl)
				foreach y of local yl { 
					capture {
					xtile xearn4`c'`y'=grossinc if grossinc>0 & year==`y' & country==`c', n(4)
					replace xearn4=xearn4`c'`y' if year==`y' & country==`c'
					drop xearn4`c'`y'
				}
				* Optionally: check if the file was successfully imported and log if it wasn't
            if (_rc != 0) {
                display as error "Gross income for country `c' `y' could not be classified into earning groups"
			}
			}
		}
	replace xearn4=5-xearn4
	label define ea 1 "Q4(High)" 2 "Q3" 3 "Q2" 4 "Q1(Low)" 
	label value xearn4 ea

	gen xinc4=. 
	label var xinc4 "Income quartile groups"
	levelsof country, local(clevels) 
		foreach c of local clevels { 
			levelsof year, local(yl)
				foreach y of local yl { 
					capture {
					xtile xinc4`c'`y'=hhnetincome if year==`y' & country==`c', n(4)
					replace xinc4=xinc4`c'`y' if year==`y' & country==`c'
					drop xinc4`c'`y'
				}
				* Optionally: check if the file was successfully imported and log if it wasn't
            if (_rc != 0) {
                display as error "Household income for country `c' `y' could not be classified into earning groups"
			}
			}
		}
	label define inx 1 "Q1(Low)" 2 "Q2" 3 "Q3" 4 "Q4(High)"
	label value xinc4 inx	
	
	// Employment 
	replace jbstat=jbstat1 if year<2011
	replace jbstat2=jbstat2-2 if jbstat2>2 & jbstat2!=. & inrange(year, 2008, 2020) // harmonising across years 
	replace jbstat3=3 if jbstat3>2 & jbstat3!=. 
	replace jbstat=jbstat2 if jbstat==. & jbstat2!=. 
	replace jbstat=. if jbstat>2020
	label variable jbstat "Main employment activity status"
	label define ms 1 "FT employed" 2 "PT employed" 3"Unemployed" 4 "Retired" 5 "Disability" 6 "Student" 7 "Domestic tasks" 8 "Military service" 9 "Other inactive"
	label values jbstat ms	
	recode jbstat (1 2 = 1 "Employed") (3=2 "Unemployed") (4/9 = 3 "Non-employed"), into(empstat)
	replace empstat=jbstat3 if year>2020
	drop jbstat1 jbstat2 jbstat3 
	
	// Education
	gen edu=.
	replace edu=3 if isced==0 | isced_f==-2 
	replace edu=1 if isced==5 | (isced>=500 & isced!=.) 
	replace edu=2 if edu==. & isced!=. 
	label define edx 1 "Degree" 2 "No degree, but some qual" 3 "No qual" 
	label value edu edx
	
	// Migrant and citizen 
	label var migrant "Country of birth"
	label var citizenship "Citizenship status"
	
	foreach x in migrant citizen { 
		encode `x', gen(`x'e) 
		replace `x'e=1 if `x'e==3 
	}
	gen mig=. 
	replace mig=1 if migrante==2 & citizene==2  // native citizen 
	replace mig=2 if migrante==1 & citizene==2  // migrant citizen 
	replace mig=3 if migrante==1 & citizene==1  // migrant non-citizen 
	label define mig 1 "Native citizen" 2 "Migrant citizen" 3 "Migrant non-citizen"
	label value mig mig 
	

	
**************************************************	
*** PARENTAL VARIABLES  
	// Homeownership 
	label var tenure_par "Parental housing tenure"
	label var tenure_par_f "Flag parental housing tenure"
	mvdecode tenure_par, mv(-1, )
	label value tenure_par ht 
	gen ownerh_par=(tenure_par==1) if tenure_par!=. 
	label variable ownerh_par "Parental homeownership at age 14"
	label define ho 1 "Owner" 0 "Non-owner"
	label value ownerh_par ho 

	// Education 
	label variable edu_f "Father education"
	label variable edu_m "Mother education"
	label define edup -1 "Don't know" 0 "No read or write (2011 only)" 1 "Primary/Lower secondary" 2 "Upper Secondary" 3 "Tertiary", replace
	label values edu_f edup
	label values edu_m edup

	// Activity status, managerial position and occupation 
	label define emp 1 "Employed" 2 "Self-Employed" 3 "Unemployed" 4 "Retirement" 5 "Domestic tasks" 6 "Other inactive"
	label define mn 1 "Yes" 0 "No"
	label define occ 0 "Armed Forces" 1 "Managers" 2 "Professionals" 3 "Technicians" 4 "Clerical" 5 "Service & sales" 6 "Skilled agri." 7 "Craft & trade" 8 "Plant workers" 9 "Elementary occ"
	
	mvdecode emp_f emp_m man_f man_m occ_f occ_m, mv(-1, )
	
	foreach x in f m {  // harmonizing 2011 and 2019 
		// Activity status
		replace emp_`x' = emp_`x'-1 if year == 2019 & inrange(emp_`x', 2, 5)
		replace emp_`x' = emp_`x'-2 if year == 2019 & inrange(emp_`x', 7, 8)
		label value emp_`x' emp
		// Managerial position
		replace man_`x' = 0 if man_`x'==2
		label value man_`x' mn		
		}
	label variable emp_f "Father's main activity status"
	label variable emp_m "Mother's main activity status"
	label variable man_f "Father had managerial position?"
	label variable man_m "Mother had managerial position?"
	label variable occ_f "Father's occupation"
	label variable occ_m "Mother's occupation"
	label values occ_f occ
	label values occ_m occ

	// Financial situation 
	mvdecode fin ends, mv(-1, )
	label variable fin "Household financial situation when kid"
	label define fin 1 "Very bad" 2 "Bad" 3 "Moderately bad" 4 "Moderately good" 5 "Good" 6 "Very good"
	label values fin fin 
	
	label variable ends "Ability to make ends meet when kid"
	label define ends 1 "With great difficulty" 2 "With difficulty" 3 "With some difficulty" 4 "Fairly easily" 5 "Easily" 6 "Very easily"
	label values ends ends 
	
	
	
**************************************************	
*** OTHER KEY VARIABLES 
	// Weights 
	label variable cweight_p 	"Respondent cross sectional weight interviewed people"
	label variable cweight  	"Personal cross sectional weight for each country"
	label variable hh_cweights  "Household cross sectional weights"
	
	
	// Sample re-weighting
	gen cweight_n_eqw = .
	gen cweight_pn_eqw = .
	levelsof(country), local(countries)
	levelsof(year), local(years)
	foreach x of local countries {
		foreach y of local years {
		summarize cweight_pn if country == `x' & year == `y'
		local total = r(sum)
		replace cweight_pn_eqw = cweight_pn/`total' if country == `x' & year == `y'
		}
	}
	
	gen cweight_pn_pop = .
	gen cweight_n_pop = . 
	levelsof(country), local(countries)
	levelsof(year), local(years)
	foreach x of local countries {
		foreach y of local years {
		replace cweight_n_pop = cweight_n*pop if country == `x' & year == `y'
		replace cweight_pn_pop = cweight_pn*pop if country == `x' & year == `y'
		}
	}		

	
	// Various data/survey status vars 
	// Residence status
	label var res_status "Person status of residence with household"
	label define rs 1 "Lives with household" 2 "Temporarily Absent" 3 "Other"
	label values res_status rs

	label var id_status "Status of respondent"
	label define ps 1 "Current household member 16+ y.o." 2 "Selected respondent" 3 "Not selected respondent" 4 "Not eligible person (<16 y.o.)"
	label values id_status ps

	label variable data_status "Information source and availability"
	label define ds 11 "From interview" 12 "From registers" 13 "From both" 21 "Unable to respond" 23 "No cooperation" 31 "Temporarily away" 32 "No contact" 33 "NA"
	label values data_status ds

	label variable psu "Primary sampling unit"
	label variable ssu "Secondary sampling unit"
	label variable su_selection_order "Sampling units selection order"
	
	label variable region "NUTS level region for each country"
	label variable region_f "Flag for region variable"

	// indidivual ids labels
	label var hrp "Household respondent person"
	label var hrp1 "First person financially responsible for accomodation"
	label var hrp2 "Second person financially responsible for accomodation"
	label var pid "Indidivual identification number"
	label var hid "Household identification number"
	label var partnerid "Partner identification number"
	label var motherid "Mother identification number"
	label var fatherid "Father identification number"

	label define otherid_f 1 "Filled" -1 "Missing" -2 "Not Applicable"
	label values partnerid_f otherid_f
	label values motherid_f otherid_f
	label values fatherid_f otherid_f 

	// Other personal characteristics
	// marital status
	label var marstat "Marital status"
	label define pb190_vl 1 "Never married" 2 "Married" 3 "Separated,MT:3,5=3" 4 "Widowed" 5 "Divorced"
	label values marstat pb190_vl
	
	// cohabitation status
	label var cohab "Consensual union"
	label define pb200_vl 1 "Yes, on a legal basis" 2 "Yes, without a legal basis" 3 "No"
	label values cohab pb200_vl
	
	// selfempl 
	label var selfemp "Status in employment"
	label define pl040_vl 1 "Self-employed with employees" 2 "Self-employed without employees" 3 "Employee" 4 "Family worker"
	label values selfemp pl040_vl
	
	// jbhours_main and all
	label var jbhours_main "Hours per week in main job"
	label var jbhours_all "Hours per week in other jobs"
	
	// monthune and empl status
	label var monthsune "Number of months spent in unemployment"
	label var monthsFT "Months in full time employment"
	label var monthsPT "Months in part time employment"
	label var monthsFTself "Months in full time self employment incl. family worker"
	label var monthsPTself "Months in part time self employment incl. family worker"
	
	// netinc gross inc and earnings
	label var netinc "Employee cash or near cash net income"
	label var netinc_f "Flag for employee cash or near cash net income"
	label var grossinc "Employee cash or near cash income"
	label var grossinc_f "Flag for employee cash or near cash gross income"
	label var grearn "Gross monthly earnings for employee"
	label var grearn_f "Flag for ind. gross earnings"
	
	// edu ISCED
	label var isced "Educational attainment (ISCED)"
	label var isced_f "Flag for edu. attainment (ISCED)"
	label define pe041_vl 0 "IE: ISCED 0 No formal education or below ISCED 1" 1 "IE: ISCED 1 Primary education" 2 "IE: ISCED 2 Lower secondary education" 3 "IE: ISCED 3 Upper secondary education" 4 "IE: ISCED 4 Post-secondary non-tertiary education" 5 "IE: ISCED 5 Short-cycle tertiary education" 6 "IE: ISCED 6 Bachelor's or equivalent" 7 "IE: ISCED 7 Master's or equivalent" 8 "IE: Doctoral or equivalent level" 100 "ISCED 1 Primary education" 200 "ISCED 2 Lower secondary education (PB010>=2021, SI: 0,100,200->200)" 300 "Upper secondary education (not further specified) (IT: 300-399->300)" 340 "ISCED 3 Upper secondary education- general/ only for persons (age 35+) (IT 340-399->340)" 342 "ISCED 3 Upper secondary education (general) - partial level completion, w/o direct access to tertiary educ (age 16-34)" 343 "ISCED 3 Upper secondary education (general) - partial level completion, w/o direct access to tertiary educ (age 16-34)" 344 "ISCED 3 Upper secondary education (general) - level completion, w/ direct access to tertiary educ (age 16-34)" 349 "ISCED 3 Upper secondary education (general) - w/o possible distinction of access to tertiary educ (age 16-34)" 350 "ISCED 3 Upper secondary education- vocational (age 35+)" 352 "ISCED 3 Upper secondary education (vocational) - partial lvl compl, w/o direct access to tertiary educ (age 16-34)" 353 "ISCED 3 Upper secondary education (vocational) - level completion, w/o direct access to tertiary educ (age 16-34)" 354 "ISCED 3 Upper secondary education (vocational) - level completion, w/ direct access to tertiary educ (age 16-34)" 359 "ISCED 3 Upper secondary education (vocational) - w/o possible distinction of access to tertiary educ (age 16-34)" 390 "ISCED 3 Upper secondary education- orientation unknown (age 35+)" 392 "ISCED 3 Upper secondary education (orient unknown) - partial lvl compl, w/o direct access to tertiary educ (age 16-34)" 393 "ISCED 3 Upper secondary education (orient unknown) - level completion, w/o direct access to tertiary educ (age 16-34)" 394 "ISCED 3 Upper secondary education (orient unknown) - level compl, w/ direct access to tertiary educ (age 16-34)" 399 "ISCED 3 Upper secondary education (orient unknown) - w/o possible distinction tertiary educ access (age 16-34)" 400 "Post-secondary non tertiary education (not further specified) (IT 400-490->400)" 440 "ISCED 4 Post-secondary non-tertiary education - general (age 16-34)" 450 "ISCED 4 Post-secondary non-tertiary education - vocational (age 16-34)" 490 "ISCED 4 Post-secondary non-tertiary education - orientation unknown" 500 "ISCED 5-8 (top coding, IT 500-590->500)" 550 "ISCED 5 Short-cycle tertiary education - vocational" 600 "ISCED 6 Bachelor's or equivalent level" 700 "ISCED 7 Master's or equivalent level" 800 "ISCED 8 Doctoral or equivalent level" 
	label values isced pe041_vl
	
	// occ ISCO 08
	label var occ "Occupational (ISCO-08)"
	label define pl051_vl 0 "DE: 01-03; SI: Armed Forces"1 "Commissioned armed forces officers (DE, MT, SI: 11-14 Legislators,senior officials & managers)"2 "Non-commissioned armed forces officers (DE, MT, SI: 21-26 Professionals)"3 "Armed forces occupations, other ranks (DE, MT, SI:31-35 Technicians & associate professionals)"4 "DE, MT, SI: 41-44 Clerks"5 "DE, MT, SI: 51-54 Service workers and shop and market sales workers"6 "DE, MT, SI: 61-63 Skilled agricultural and fishery workers"7 "DE, MT, SI: 71-75 Craft and related trades workers"8 "DE, MT, SI: 81-83 Plant and machine operators and assemblers"9 "DE, MT, SI: 91-96 Elementary occupations"10 "MT:01 Armed forces"11 "Chief executives, senior officials and legislators"12 "Administrative and commercial managers"13 "Production and specialised services managers"14 "Hospitality, retail and other services managers (PT:11-13 = 14)"21 "Science and engineering professionals"22 "Health professionals"23 "Teaching professionals"24 "Business and administration professionals"25 "Information and communications technology professionals"26 "Legal, social and cultural professionals"31 "Science and engineering associate professionals"32 "Health associate professionals"33 "Business and administration associate professionals"34 "Legal, social, cultural and related associate professionals"35 "Information and communications technicians"41 "General and keyboard clerks"42 "Customer services clerks"43 "Numerical and material recording clerks"44 "Other clerical support workers"51 "Personal service workers"52 "Sales workers"53 "Personal care workers"54 "Protective services workers"61 "Market-oriented skilled agricultural workers"62 "Market-oriented skilled forestry, fishery and hunting workers"63 "Subsistence farmers, fishers, hunters and gatherers"71 "Building and related trades workers, excluding electricians"72 "Metal, machinery and related trades workers"73 "Handicraft and printing workers"74 "Electrical and electronic trades workers"75 "Food processing, wood working, garment and other craft and related trades workers"81 "Stationary plant and machine operators"82 "Assemblers"83 "Drivers and mobile plant operators"91 "Cleaners and helpers"92 "Agricultural, forestry and fishery labourers"93 "Labourers in mining, construction, manufacturing and transport"94 "Food preparation assistants"95 "Street and related sales and service workers"96 "Refuse workers and other elementary workers"
	label values occ pl051_vl
	
	// pov
	label var pov "Poverty indicator"
	label define hx080_vl 1 "At risk of poverty" 0 "Not at risk of poverty"
	label values pov hx080_vl
	
	// htype
	label var htype "Household type"
	label define hx060_vl 5 "One person household" 6 "2 adults, no dependent children, both adults under 65 years" 7 "2 adults, no dependent children, at least one adult >=65 years" 8 "Other households without dependent children" 9 "Single parent household, one or more dependent children" 10 "2 adults, one dependent child" 11 "2 adults, two dependent children" 12 "2 adults, three or more dependent children" 13 "Other households with dependent children" 16 "Other (these household are excluded from Laeken indicators calculation)"
	label values htype hx060_vl
	
	// Drop merging details 
	drop merge_RtoP merge_RtoD merge_RtoH // drop merging details	

save DCP_EUSILC_0423.dta, replace