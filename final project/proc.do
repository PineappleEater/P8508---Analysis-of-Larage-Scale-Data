********************************************************************************
* Final Project - Data Processing (proc.do)
* Optimized for Memory Usage
********************************************************************************

clear all
set more off
set maxvar 10000
set varabbrev off

* Set working directory
* Windows path:
global projdir "d:\OneDrive\Desktop\Academic\Biostats Courses\Larage Scale Data\final project"
cd "$projdir"

capture mkdir "data/temp"
capture mkdir "log"

capture log close
log using "log/proc.log", text replace

di "============================================================"
di "Memory Optimization Run"
di "============================================================"

********************************************************************************
* STEP 1: Process each file individually to reduce size
********************************************************************************

* Define the list of variables we ULTIMATELY need
* We need to look for variations of these names

local years 2003 2004 2005 2006 2007 2008 2009 2011 2012 2013 2014 2015

foreach yr of local years {
    di _newline(1) "Processing `yr'..."
    
    * Load the raw imported file
    capture confirm file "data/brfss_`yr'.dta"
    if _rc != 0 {
        di "Error: data/brfss_`yr'.dta NOT FOUND. Please check imports."
        continue
    }
    
    use "data/brfss_`yr'.dta", clear
    
    * --- STANDARDIZE VARIABLES ---
    
    * State
    capture confirm variable _STATE
    if _rc == 0 rename _STATE _state
    
    * Weight (check variations)
    * 2004+ seems to have issues, possibly appearing as weight2 or _wt2 or _finalwt (lowercase)
    
    * Weight (check variations)
    * SEARCH AND RESCUE for weight variable
    
    local weight_candidates weight weight2 _FINALWT _finalwt _LLCPWT _llcpwt _WT2 _wt2 _POSTSTR _poststr
    local weight_found 0
    
    foreach wvar of local weight_candidates {
        capture confirm variable `wvar'
        if _rc == 0 {
            di "Found weight variable: `wvar'"
            if "`wvar'" != "weight" {
                capture rename `wvar' weight
                if _rc == 0 {
                     di "Successfully renamed `wvar' to weight"
                     local weight_found 1
                     continue, break 
                }
                else {
                     di "Failed to rename `wvar' to weight"
                }
            }
            else {
                local weight_found 1
                continue, break
            }
        }
    }
    
    if `weight_found' == 0 {
        di "WARNING: FATAL - No weight variable found for year `yr'!"
        describe
    }
    
    * Age
    capture confirm variable AGE
    if _rc == 0 rename AGE age
    capture confirm variable _AGE80
    if _rc == 0 rename _AGE80 age
    capture confirm variable _AGEG5YR
    if _rc == 0 rename _AGEG5YR age
    
    * Race
    capture confirm variable _RACE
    if _rc != 0 {
        capture confirm variable _RACEGR2
        if _rc == 0 rename _RACEGR2 _race
    }
    
    * Employment
    capture confirm variable EMPLOY1
    if _rc != 0 {
        capture confirm variable EMPLOY
        if _rc == 0 rename EMPLOY employ1
    }
    
    * Health Plan
    capture confirm variable HLTHPLN1
    if _rc != 0 {
        capture confirm variable HLTHPLAN
        if _rc == 0 rename HLTHPLAN hlthpln1
    }
    
    * Smoker3 (Calculated)
    capture confirm variable _SMOKER3
    if _rc != 0 {
        capture confirm variable _RFSMOK3
        if _rc == 0 rename _RFSMOK3 _smoker3
    }

    * --- KEEP ONLY RELEVANT VARIABLES ---
    * List of targets (after renaming)
    local targets year _state weight age sex _race educa income2 employ1 hlthpln1 persdoc2 smoke100 smokday2 stopsmk2 _smoker3
    
    local keep_cmd "keep"
    foreach var of local targets {
        capture confirm variable `var'
        if _rc == 0 {
            local keep_cmd "`keep_cmd' `var'"
        }
    }
    
    * Execute Keep
    `keep_cmd'
    
    * Compress to save space
    compress
    
    * Save small temporary file
    save "data/temp/small_`yr'.dta", replace
    di "Saved small_`yr'.dta"
}

********************************************************************************
* STEP 2: Append the small files
********************************************************************************

di _newline(2) "Appending small files..."
clear

* Start with first processed file
use "data/temp/small_2003.dta", clear

foreach yr in 2004 2005 2006 2007 2008 2009 2011 2012 2013 2014 2015 {
    di "Appending `yr'..."
    append using "data/temp/small_`yr'.dta", force
}

di "Total observations: " _N

********************************************************************************
* STEP 3: Create Analysis Variables & Final Save
* (Same logic as before)
********************************************************************************

* ... [Logic from original Section 5, 6, 7] ...

* Expansion Status
gen expanded_state = 0
replace expanded_state = 1 if inlist(_state, 4, 5, 6, 8, 9, 10, 11)     
replace expanded_state = 1 if inlist(_state, 15, 17, 18, 19, 21, 24, 25) 
replace expanded_state = 1 if inlist(_state, 26, 27, 30, 32, 33, 34, 35) 
replace expanded_state = 1 if inlist(_state, 36, 38, 39, 41, 42, 44)    
replace expanded_state = 1 if inlist(_state, 50, 53, 54)                

label variable expanded_state "Medicaid Expansion State"

* Post Period
gen post = .
replace post = 0 if year >= 2003 & year <= 2009
replace post = 1 if year >= 2011 & year <= 2015
label variable post "Post-Expansion Period"

* Outcomes
gen current_smoker = .
capture confirm variable _smoker3
if _rc == 0 {
    replace current_smoker = 1 if inlist(_smoker3, 1, 2)
    replace current_smoker = 0 if inlist(_smoker3, 3, 4)
}

gen quit_attempt = .
capture confirm variable stopsmk2
if _rc == 0 {
    replace quit_attempt = 1 if stopsmk2 == 1
    replace quit_attempt = 0 if stopsmk2 == 2
}

* Covariates
gen female = (sex == 2) if sex != .

* Age Categories (18-34, 35-49, 50-64, 65-79, 80+)
gen age_cat = .
replace age_cat = 1 if age >= 18 & age <= 34
replace age_cat = 2 if age >= 35 & age <= 49
replace age_cat = 3 if age >= 50 & age <= 64
replace age_cat = 4 if age >= 65 & age <= 79
replace age_cat = 5 if age >= 80 & age < .
label variable age_cat "Age Category"

* Race/Ethnicity
gen race = .
replace race = 1 if _race == 1                    // White
replace race = 2 if _race == 2                    // Black
replace race = 3 if _race == 8                    // Hispanic
replace race = 4 if inlist(_race, 3, 4, 5, 6, 7)  // Other
label variable race "Race/Ethnicity"

* Education
gen education = .
replace education = 1 if inlist(educa, 1, 2, 3)   // Less than HS
replace education = 2 if educa == 4                // HS graduate
replace education = 3 if inlist(educa, 5, 6)       // Some college+
label variable education "Education Level"

* Income
gen income = .
replace income = 1 if income2 == 1                         // <$10k
replace income = 2 if inlist(income2, 2, 3)                // $10k-<$20k
replace income = 3 if inlist(income2, 4, 5, 6)             // $20k-<$50k
replace income = 4 if inlist(income2, 7, 8)                // $50k+
label variable income "Annual Household Income"

* Employment
gen employed = .
capture confirm variable employ1
if _rc == 0 {
    replace employed = 1 if employ1 == 1
    replace employed = 2 if employ1 == 2
    replace employed = 3 if inlist(employ1, 3, 4)
    replace employed = 4 if inlist(employ1, 5, 6, 7)
    replace employed = 5 if employ1 == 8
}
else {
    * Logic for older EMPLOY variable not strictly needed if we standardized, 
    * but good for safety if standardize failed for some reason.
    * In optimized step 1 we tried to rename EMPLOY -> employ1
}
label variable employed "Employment Status"

* Healthcare Coverage
gen has_coverage = .
capture confirm variable hlthpln1
if _rc == 0 {
    replace has_coverage = 1 if hlthpln1 == 1
    replace has_coverage = 0 if hlthpln1 == 2
}
label variable has_coverage "Has Healthcare Coverage"

* Personal Doctor
gen has_doctor = (persdoc2 == 1) if inlist(persdoc2, 1, 2, 3)
label variable has_doctor "Has Personal Doctor"

* Save
compress
save "data/brfss_analysis.dta", replace

di "DONE."
log close
