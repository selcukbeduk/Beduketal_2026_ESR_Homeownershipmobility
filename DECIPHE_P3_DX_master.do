/* 
Project: DECIPHE - Demographich change and intergenerational persistence of homeownership in Europe https://www.deciphe.eu 
	
Paper: Are the children of homeowners increasingly advantaged? Trends in relative and absolute mobility of homeownership in Europe (ESR) 

Author: Selçuk Bedük (University of Oxford)
		Enrico Benassi (University of Oxford)
		
Date of code: June 2026

Purpose:  Master file 
		1. Merging and constructing data  
		2. Constructing key variables 
		3. Running analysis  
		4. Running supplementary 

Inputs: Do files 

Key Outputs: Figure 1-6.png & Figure S1-11.png 
*/

clear all
set more off
capture log close

*** Note: You need to change the directories within each do-file to specify the location of inputs(data) and outputs(figures)

global codedir "..." // Directory of the do-files

run "${codedir}\DECIPHE_P3_D1_dataprep.do"
run "${codedir}\DECIPHE_P3_D2_varprep.do"
run "${codedir}\DECIPHE_P3_D3_estimaton.do"
run "${codedir}\DECIPHE_P3_D4_results.do"
run "${codedir}\DECIPHE_P3_D5_supp.do"
