********************************************************************************
* Final Project - Data Processing (proc.do)
* Analysis of Large-Scale Data 2025
* Name(s): Xuange Liang [xl3493], Zexuan Yan [zy2654]
*
* Replication of: Valvi et al. (2019)
*    "Current smoking and quit-attempts among US adults following 
*     Medicaid expansion"
* Dataset: BRFSS 2003-2015 from CDC
* Purpose: Download, import, clean and prepare BRFSS data for DiD analysis
********************************************************************************

clear all
set more off
set maxvar 10000

********************************************************************************
* SETUP - MODIFY THESE PATHS
********************************************************************************

* Set your working directory
* For Windows Stata accessing WSL files:
global projdir "\\wsl.localhost\Ubuntu-24.04\home\liang\desktop\P8508---Analysis-of-Larage-Scale-Data\final project"
* For Linux Stata, use: 
* global projdir "/home/liang/desktop/P8508---Analysis-of-Larage-Scale-Data/final project"
cd "$projdir"

* Create folders
capture mkdir "data"
capture mkdir "data/raw"
capture mkdir "log"

* Log file
capture log close
log using "log/proc_log.txt", text replace

di "============================================================"
di "FINAL PROJECT: BRFSS DATA PROCESSING"
di "============================================================"
di "Started at: $S_DATE $S_TIME"

********************************************************************************
* SECTION 1: DOWNLOAD INSTRUCTIONS
********************************************************************************
/*
=== MANUAL DOWNLOAD REQUIRED ===

Go to CDC BRFSS Annual Data page and download the following files:
https://www.cdc.gov/brfss/annual_data/annual_data.htm

For each year, download the "SAS Transport Format" (.XPT) file.

FILE NAMING CONVENTION:
- 2003-2010: CDBRFSXX.XPT (e.g., CDBRFS03.XPT, CDBRFS09.XPT)
- 2011-2015: LLCPXXXX.XPT (e.g., LLCP2011.XPT, LLCP2015.XPT)

DIRECT LINKS (copy to browser):

2003: https://www.cdc.gov/brfss/annual_data/2003/files/CDBRFS03XPT.zip
2004: https://www.cdc.gov/brfss/annual_data/2004/files/CDBRFS04XPT.zip
2005: https://www.cdc.gov/brfss/annual_data/2005/files/CDBRFS05XPT.zip
2006: https://www.cdc.gov/brfss/annual_data/2006/files/CDBRFS06XPT.zip
2007: https://www.cdc.gov/brfss/annual_data/2007/files/CDBRFS07XPT.zip
2008: https://www.cdc.gov/brfss/annual_data/2008/files/CDBRFS08XPT.zip
2009: https://www.cdc.gov/brfss/annual_data/2009/files/CDBRFS09XPT.zip
2010: https://www.cdc.gov/brfss/annual_data/2010/files/CDBRFS10XPT.zip  (excluded - washout)
2011: https://www.cdc.gov/brfss/annual_data/2011/files/LLCP2011XPT.zip
2012: https://www.cdc.gov/brfss/annual_data/2012/files/LLCP2012XPT.zip
2013: https://www.cdc.gov/brfss/annual_data/2013/files/LLCP2013XPT.zip
2014: https://www.cdc.gov/brfss/annual_data/2014/files/LLCP2014XPT.zip
2015: https://www.cdc.gov/brfss/annual_data/2015/files/LLCP2015XPT.zip

After downloading, unzip and place all .XPT files in: data/raw/

NOTE: Total download size is approximately 500 MB (zipped), 2-3 GB unzipped.
*/

********************************************************************************
* SECTION 2: IMPORT AND APPEND BRFSS DATA
********************************************************************************

di _newline(2)
di "========== SECTION 2: IMPORT BRFSS DATA =========="

* --- 2.1: Import Pre-Expansion Period (2003-2009) ---

di _newline(1) "Importing 2003 data..."
import sasxport5 "data/raw/cdbrfs03.xpt", clear
gen year = 2003
save "data/brfss_2003.dta", replace

di "Importing 2004 data..."
import sasxport5 "data/raw/CDBRFS04.XPT", clear
gen year = 2004
save "data/brfss_2004.dta", replace

di "Importing 2005 data..."
import sasxport5 "data/raw/CDBRFS05.XPT", clear
gen year = 2005
save "data/brfss_2005.dta", replace

di "Importing 2006 data..."
import sasxport5 "data/raw/CDBRFS06.XPT", clear
gen year = 2006
save "data/brfss_2006.dta", replace

di "Importing 2007 data..."
import sasxport5 "data/raw/CDBRFS07.XPT", clear
gen year = 2007
save "data/brfss_2007.dta", replace

di "Importing 2008 data..."
import sasxport5 "data/raw/CDBRFS08.XPT", clear
gen year = 2008
save "data/brfss_2008.dta", replace

di "Importing 2009 data..."
import sasxport5 "data/raw/CDBRFS09.XPT", clear
gen year = 2009
save "data/brfss_2009.dta", replace

* --- 2.2: Import Post-Expansion Period (2011-2015) ---
* NOTE: 2010 is excluded as washout period

di "Importing 2011 data..."
import sasxport5 "data/raw/LLCP2011.XPT", clear
gen year = 2011
save "data/brfss_2011.dta", replace

di "Importing 2012 data..."
import sasxport5 "data/raw/LLCP2012.XPT", clear
gen year = 2012
save "data/brfss_2012.dta", replace

di "Importing 2013 data..."
import sasxport5 "data/raw/LLCP2013.XPT", clear
gen year = 2013
save "data/brfss_2013.dta", replace

di "Importing 2014 data..."
import sasxport5 "data/raw/LLCP2014.XPT", clear
gen year = 2014
save "data/brfss_2014.dta", replace

di "Importing 2015 data..."
import sasxport5 "data/raw/LLCP2015.XPT", clear
gen year = 2015
save "data/brfss_2015.dta", replace

di _newline(1) "All years imported successfully!"

********************************************************************************
* SECTION 3: STANDARDIZE VARIABLE NAMES ACROSS YEARS
********************************************************************************

di _newline(2)
di "========== SECTION 3: STANDARDIZE VARIABLES =========="

* BRFSS variable names changed over time. We need to standardize them.
* This section creates a consistent set of variables across all years.

* Key variables and their names by period:
* 
* Variable          | 2003-2010          | 2011-2015
* ------------------|--------------------|-----------------
* State FIPS        | _STATE             | _STATE
* Smoking (100+)    | SMOKE100           | SMOKE100
* Days smoking      | SMOKDAY2           | SMOKDAY2
* Quit attempt      | STOPSMK2           | STOPSMK2
* Computed smoker   | _SMOKER3 or _RFSMOK3| _SMOKER3
* Age               | AGE                | _AGE80 or _AGEG5YR
* Sex               | SEX                | SEX
* Race              | _RACE or _RACEGR2  | _RACE
* Education         | EDUCA              | EDUCA
* Income            | INCOME2            | INCOME2
* Employment        | EMPLOY or EMPLOY1  | EMPLOY1
* Health coverage   | HLTHPLAN           | HLTHPLN1
* Personal doctor   | PERSDOC2           | PERSDOC2
* Weight            | _FINALWT           | _LLCPWT

* We will standardize in the append loop below

********************************************************************************
* SECTION 4: APPEND ALL YEARS
********************************************************************************

di _newline(2)
di "========== SECTION 4: APPEND ALL YEARS =========="

* Start with 2003 and append subsequent years
use "data/brfss_2003.dta", clear

* Keep only variables we need (reduces memory usage significantly)
* Note: Variable names may be lowercase after import

local keepvars year _state smoke100 smokday2 stopsmk2 ///
               age sex _race _racegr2 educa income2 employ employ1 ///
               hlthplan hlthpln1 persdoc2 _finalwt _llcpwt ///
               marital _smoker3 _rfsmok3 _ageg5yr

foreach var of local keepvars {
    capture confirm variable `var'
    if _rc != 0 {
        di "Note: Variable `var' not found in 2003, will be added as missing"
    }
}

* Keep available variables
ds
local allvars `r(varlist)'
keep year _state smoke100 smokday2 stopsmk2 sex educa income2 persdoc2 marital ///
     _finalwt _smoker3 _race employ hlthplan age

* Append remaining years
foreach yr in 2004 2005 2006 2007 2008 2009 2011 2012 2013 2014 2015 {
    di "Appending `yr'..."
    append using "data/brfss_`yr'.dta", force
}

di _newline(1) "Total observations after append: " _N

********************************************************************************
* SECTION 5: CREATE STATE EXPANSION CROSSWALK
********************************************************************************

di _newline(2)
di "========== SECTION 5: STATE MEDICAID EXPANSION STATUS =========="

* Create expansion indicator based on Kaiser Family Foundation data
* States that expanded Medicaid by December 31, 2015

gen expanded_state = 0

* Expanded states (30 states + DC)
* Using state FIPS codes
replace expanded_state = 1 if inlist(_state, 4, 5, 6, 8, 9, 10, 11)     // AZ, AR, CA, CO, CT, DE, DC
replace expanded_state = 1 if inlist(_state, 15, 17, 18, 19, 21, 24, 25) // HI, IL, IN, IA, KY, MD, MA
replace expanded_state = 1 if inlist(_state, 26, 27, 30, 32, 33, 34, 35) // MI, MN, MT, NV, NH, NJ, NM
replace expanded_state = 1 if inlist(_state, 36, 38, 39, 41, 42, 44)    // NY, ND, OH, OR, PA, RI
replace expanded_state = 1 if inlist(_state, 50, 53, 54)                // VT, WA, WV

label variable expanded_state "Medicaid Expansion State (1=Yes, 0=No)"
label define expand_lbl 0 "Non-Expanded" 1 "Expanded"
label values expanded_state expand_lbl

di "Expansion status distribution:"
tab expanded_state, missing

********************************************************************************
* SECTION 6: CREATE ANALYSIS VARIABLES
********************************************************************************

di _newline(2)
di "========== SECTION 6: CREATE ANALYSIS VARIABLES =========="

* --- 6.1: Study Period ---
gen post = .
replace post = 0 if year >= 2003 & year <= 2009
replace post = 1 if year >= 2011 & year <= 2015
label variable post "Post-Expansion Period (1=2011-2015, 0=2003-2009)"
label define post_lbl 0 "Pre-Expansion" 1 "Post-Expansion"
label values post post_lbl

di "Study period distribution:"
tab year post, missing

* --- 6.2: Outcome 1 - Current Smoker ---
* Using _SMOKER3: 1=Every day, 2=Some days, 3=Former, 4=Never
* Or construct from SMOKE100 and SMOKDAY2

gen current_smoker = .
* Try _SMOKER3 first
capture confirm variable _smoker3
if _rc == 0 {
    replace current_smoker = 1 if inlist(_smoker3, 1, 2)
    replace current_smoker = 0 if inlist(_smoker3, 3, 4)
}
else {
    * Construct from SMOKE100 and SMOKDAY2
    * SMOKE100: 1=Yes, 2=No
    * SMOKDAY2: 1=Every day, 2=Some days, 3=Not at all
    replace current_smoker = 1 if smoke100 == 1 & inlist(smokday2, 1, 2)
    replace current_smoker = 0 if smoke100 == 2
    replace current_smoker = 0 if smoke100 == 1 & smokday2 == 3
}

label variable current_smoker "Current Smoker (1=Yes, 0=No)"
label define yesno 0 "No" 1 "Yes"
label values current_smoker yesno

di "Current smoking distribution:"
tab current_smoker, missing

* --- 6.3: Outcome 2 - Quit Attempt (among current smokers) ---
* STOPSMK2: 1=Yes, 2=No, 7=Don't know, 9=Refused

gen quit_attempt = .
replace quit_attempt = 1 if stopsmk2 == 1
replace quit_attempt = 0 if stopsmk2 == 2
label variable quit_attempt "Quit Attempt Past 12 Months"
label values quit_attempt yesno

di "Quit attempt distribution (all obs):"
tab quit_attempt, missing
di "Quit attempt distribution (current smokers only):"
tab quit_attempt if current_smoker == 1, missing

* --- 6.4: Age Categories ---
* Paper uses: 18-34, 35-49, 50-64, 65-79, 80+

gen age_cat = .
replace age_cat = 1 if age >= 18 & age <= 34
replace age_cat = 2 if age >= 35 & age <= 49
replace age_cat = 3 if age >= 50 & age <= 64
replace age_cat = 4 if age >= 65 & age <= 79
replace age_cat = 5 if age >= 80 & age < .
label variable age_cat "Age Category"
label define age_lbl 1 "18-34" 2 "35-49" 3 "50-64" 4 "65-79" 5 "80+"
label values age_cat age_lbl

* --- 6.5: Sex ---
gen female = (sex == 2) if sex != .
label variable female "Female"
label values female yesno

* --- 6.6: Race/Ethnicity ---
* _RACE: 1=White, 2=Black, 3=AI/AN, 4=Asian, 5=NH/PI, 6=Other, 7=Multi, 8=Hispanic

gen race = .
replace race = 1 if _race == 1                    // White
replace race = 2 if _race == 2                    // Black
replace race = 3 if _race == 8                    // Hispanic
replace race = 4 if inlist(_race, 3, 4, 5, 6, 7)  // Other
label variable race "Race/Ethnicity"
label define race_lbl 1 "White" 2 "Black" 3 "Hispanic" 4 "Other"
label values race race_lbl

* --- 6.7: Education ---
* EDUCA: 1=Never, 2=Elem, 3=Some HS, 4=HS grad, 5=Some college, 6=College grad

gen education = .
replace education = 1 if inlist(educa, 1, 2, 3)   // Less than HS
replace education = 2 if educa == 4                // HS graduate
replace education = 3 if inlist(educa, 5, 6)       // Some college+
label variable education "Education Level"
label define edu_lbl 1 "Less than HS" 2 "HS Graduate" 3 "Some College+"
label values education edu_lbl

* --- 6.8: Income ---
* INCOME2: 1=<$10k, 2=$10-15k, 3=$15-20k, 4=$20-25k, 5=$25-35k, 6=$35-50k, 7=$50-75k, 8=$75k+

gen income = .
replace income = 1 if income2 == 1                         // <$10k
replace income = 2 if inlist(income2, 2, 3)                // $10k-<$20k
replace income = 3 if inlist(income2, 4, 5, 6)             // $20k-<$50k
replace income = 4 if inlist(income2, 7, 8)                // $50k+
label variable income "Annual Household Income"
label define inc_lbl 1 "<$10,000" 2 "$10,000-<$20,000" 3 "$20,000-<$50,000" 4 "$50,000+"
label values income inc_lbl

* --- 6.9: Employment ---
* EMPLOY/EMPLOY1: 1=Employed, 2=Self-emp, 3=Out 1yr+, 4=Out <1yr, 5=Homemaker, 6=Student, 7=Retired, 8=Unable

capture confirm variable employ1
if _rc == 0 {
    gen employed = .
    replace employed = 1 if employ1 == 1
    replace employed = 2 if employ1 == 2
    replace employed = 3 if inlist(employ1, 3, 4)
    replace employed = 4 if inlist(employ1, 5, 6, 7)
    replace employed = 5 if employ1 == 8
}
else {
    gen employed = .
    replace employed = 1 if employ == 1
    replace employed = 2 if employ == 2
    replace employed = 3 if inlist(employ, 3, 4)
    replace employed = 4 if inlist(employ, 5, 6, 7)
    replace employed = 5 if employ == 8
}
label variable employed "Employment Status"
label define emp_lbl 1 "Employed" 2 "Self-Employed" 3 "Unemployed" 4 "Student/Homemaker/Retired" 5 "Unable to Work"
label values employed emp_lbl

* --- 6.10: Healthcare Coverage ---
* HLTHPLAN/HLTHPLN1: 1=Yes, 2=No

capture confirm variable hlthpln1
if _rc == 0 {
    gen has_coverage = (hlthpln1 == 1) if inlist(hlthpln1, 1, 2)
}
else {
    gen has_coverage = (hlthplan == 1) if inlist(hlthplan, 1, 2)
}
label variable has_coverage "Has Healthcare Coverage"
label values has_coverage yesno

* --- 6.11: Personal Doctor ---
gen has_doctor = (persdoc2 == 1) if inlist(persdoc2, 1, 2, 3)
label variable has_doctor "Has Personal Doctor"
label values has_doctor yesno

* --- 6.12: Survey Weight ---
* Pre-2011: _FINALWT, Post-2011: _LLCPWT

gen weight = .
replace weight = _finalwt if year <= 2009
replace weight = _llcpwt if year >= 2011
label variable weight "Survey Weight"

********************************************************************************
* SECTION 7: FINAL CLEANUP AND SAVE
********************************************************************************

di _newline(2)
di "========== SECTION 7: FINAL CLEANUP =========="

* Keep only analysis variables
keep year _state expanded_state post ///
     current_smoker quit_attempt ///
     age age_cat female race education income employed ///
     has_coverage has_doctor weight

* Drop observations with missing key variables
di "Observations before dropping missing:"
count
drop if missing(current_smoker)
drop if missing(post)
drop if missing(expanded_state)
di "Observations after dropping missing outcomes/treatment:"
count

* Declare survey design
svyset [pw=weight]

* Save final dataset
save "data/brfss_analysis.dta", replace
di "Analysis dataset saved to: data/brfss_analysis.dta"

********************************************************************************
* SECTION 8: DATA SUMMARY
********************************************************************************

di _newline(2)
di "========== DATA SUMMARY =========="

di _newline(1) "Overall sample size by period and expansion status:"
tab post expanded_state

di _newline(1) "Current smoking prevalence:"
tab current_smoker expanded_state, row

di _newline(1) "Variable summary:"
describe
summarize

********************************************************************************
* END OF DATA PROCESSING
********************************************************************************

di _newline(2)
di "============================================================"
di "DATA PROCESSING COMPLETE"
di "============================================================"
di "Next step: Run analysis.do"
di "Ended at: $S_DATE $S_TIME"

log close
