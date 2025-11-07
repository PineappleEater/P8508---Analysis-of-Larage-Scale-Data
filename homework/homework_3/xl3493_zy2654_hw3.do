********************************************************************************
* Assignment 3 - Analyzing Electronic Health Record data
* Analysis of Large-Scale Data 2025
* Name(s): Xuange Liang [xl3493], Zexuan Yan [zy2654]
*
* Dataset: MIMIC IV de-identified EHR data from Beth Israel Deaconess Medical Center
* Focus: Administrative data handling and healthcare analytics
********************************************************************************

clear all
set more off

********************************************************************************
* Data Import and Preparation·
********************************************************************************

* Set working directory and import CSV files
cd "c:\Users\l1697\OneDrive\Desktop\Academic\Biostats Courses\Larage Scale Data\homework_3"

* Import admissions data
di "Importing admissions data..."
import delimited "data\admissions.csv", clear
save "data\admissions.dta", replace

* Import acuity_ED data
di "Importing acuity_ED data..."
import delimited "data\acuity_ED.csv", clear
save "data\acuity_ED.dta", replace

* Import diagnosis data
di "Importing diagnosis data..."
import delimited "data\diagnosis.csv", clear
save "data\diagnosis.dta", replace

* Import DRG data
di "Importing drg data..."
import delimited "data\drg.csv", clear
save "data\drg.dta", replace

* Import patients data
di "Importing patients data..."
import delimited "data\patients.csv", clear
save "data\patients.dta", replace

di _newline(1) "All data files imported successfully!"

********************************************************************************
* Question 1: Length of Stay Variable and Histogram
********************************************************************************

di _newline(2)
di "========== QUESTION 1: LENGTH OF STAY ANALYSIS =========="

use "data\admissions.dta", clear

* Convert date strings to numeric date variables
gen admit_date = date(admittime, "YMD hms")
format admit_date %td
label variable admit_date "Admission Date"

gen disch_date = date(dischtime, "YMD hms")
format disch_date %td
label variable disch_date "Discharge Date"

* Calculate length of stay in calendar days
gen los = disch_date - admit_date
label variable los "Length of Stay (days)"

* Display summary statistics
di _newline(1) "Length of Stay Summary Statistics:"
summarize los, detail

* Create histogram with 20 bins
histogram los, bin(20) frequency ///
    title("Distribution of Length of Stay") ///
    subtitle("MIMIC IV Data - Hospital Admissions") ///
    xtitle("Length of Stay (days)") ytitle("Frequency") ///
    scheme(s2color)

graph export "los_histogram.png", replace
di _newline(1) "Histogram saved as: los_histogram.png"

* Save dataset with LOS variable
save "data\admissions_with_los.dta", replace

********************************************************************************
* Question 2: Data Merging and Descriptive Statistics
********************************************************************************

di _newline(2)
di "========== QUESTION 2: MERGE DATASETS AND CALCULATE STATISTICS =========="

use "data\admissions_with_los.dta", clear

* Merge patients data (many admissions to one patient)
di _newline(1) "Merging patients data..."
merge m:1 subject_id using "data\patients.dta"
tab _merge
drop _merge

* Merge DRG data (one-to-one with admissions)
di _newline(1) "Merging DRG data..."
merge 1:1 subject_id hadm_id using "data\drg.dta"
tab _merge

* Recode missing DRGs to 9999 as requested
replace drg_code = 9999 if missing(drg_code)
di "Missing DRG codes recoded to 9999"
drop _merge

* Merge acuity data (one-to-one with admissions)
di _newline(1) "Merging acuity data..."
merge 1:1 subject_id hadm_id using "data\acuity_ED.dta"
tab _merge
drop _merge

* Calculate percent of hospitalizations for Septicemia & Disseminated Infections (DRG 720)
gen septicemia = (drg_code == 720) if drg_code != .
label variable septicemia "Septicemia & Disseminated Infections (DRG 720)"
label define sepsis_lbl 0 "Other DRG" 1 "Septicemia (720)"
label values septicemia sepsis_lbl

di _newline(1) "Septicemia Hospitalization Analysis:"
tab septicemia

* Calculate percentage
count if septicemia == 1
local n_sepsis = r(N)
count if septicemia != .
local n_total = r(N)
local pct_sepsis = (`n_sepsis' / `n_total') * 100

di _newline(1) "ANSWER: " %5.2f `pct_sepsis' "% of hospitalizations are for Septicemia & Disseminated Infections (DRG 720)"

* Calculate mean and SD of acuity score (to 2 decimal places)
di _newline(1) "Acuity Score Statistics:"
summarize acuity, detail

local mean_acuity = r(mean)
local sd_acuity = r(sd)

di _newline(1) "ANSWER: Mean acuity score = " %5.2f `mean_acuity'
di "        SD acuity score = " %5.2f `sd_acuity'

* Save merged dataset
save "data\mimic_merged.dta", replace

********************************************************************************
* Question 3: Create and Clean Demographic and Covariate Variables
********************************************************************************

di _newline(2)
di "========== QUESTION 3: DEMOGRAPHIC VARIABLE CREATION =========="

* Calculate age (continuous)
gen age = year(admit_date) - birth_year
label variable age "Age at Admission (years)"

di _newline(1) "Age Distribution:"
summarize age, detail

* Create race/ethnicity variable (4 categories: Black, White, Hispanic, Other/Unknown)
gen race_eth = ""
replace race_eth = "Black" if regexm(race, "BLACK")
replace race_eth = "White" if regexm(race, "WHITE")
replace race_eth = "Hispanic" if regexm(race, "HISPANIC")
replace race_eth = "Other/Unknown" if race_eth == "" | regexm(race, "UNKNOWN|OTHER|UNABLE")

label variable race_eth "Race/Ethnicity (4 categories)"

* Create frequency table for race/ethnicity
di _newline(1) "Race/Ethnicity Distribution:"
tab race_eth

* Clean insurance variable
gen insurance_clean = ""
replace insurance_clean = "Medicare" if insurance == "Medicare"
replace insurance_clean = "Medicaid" if insurance == "Medicaid"
replace insurance_clean = "Other" if insurance == "Other"
label variable insurance_clean "Insurance Type (cleaned)"

di _newline(1) "Insurance Type Distribution:"
tab insurance_clean

* Clean admission type variable
gen admission_type_clean = ""
replace admission_type_clean = "EMER" if regexm(admission_type, "EMER")
replace admission_type_clean = "Urgent" if regexm(admission_type, "URGENT")
replace admission_type_clean = "Elective" if admission_type == "ELECTIVE"
replace admission_type_clean = "Observation" if regexm(admission_type, "OBSERVATION")
replace admission_type_clean = "Surgical" if regexm(admission_type, "SURGICAL")
label variable admission_type_clean "Admission Type (cleaned)"

di _newline(1) "Admission Type Distribution:"
tab admission_type_clean

* Save dataset with cleaned variables
save "data\mimic_cleaned.dta", replace

********************************************************************************
* Question 4: Impute Missing Acuity Values
********************************************************************************

di _newline(2)
di "========== QUESTION 4: ACUITY IMPUTATION =========="

* Encode categorical variables for regression
encode race_eth, gen(race_eth_num)
encode admission_type_clean, gen(admission_type_num)

* Check missing acuity before imputation
count if missing(acuity)
local n_missing = r(N)
di _newline(1) "Number of observations with missing acuity: " `n_missing'

* Run regression to predict acuity based on age, race/ethnicity, DRG, and admission type
di _newline(1) "Running regression for acuity imputation..."
reg acuity age i.race_eth_num i.drg_code i.admission_type_num

* Generate predicted values
predict acuity_hat
label variable acuity_hat "Predicted Acuity Score"

* Create imputed acuity variable (original values for non-missing, predicted for missing)
gen acuity_imp = acuity
replace acuity_imp = acuity_hat if missing(acuity)
label variable acuity_imp "Imputed Acuity Score"

* Calculate mean and SD of imputed acuity score (to 2 decimal places)
di _newline(1) "Imputed Acuity Score Statistics:"
summarize acuity_imp, detail

local mean_acuity_imp = r(mean)
local sd_acuity_imp = r(sd)

di _newline(1) "ANSWER: Mean imputed acuity score = " %5.2f `mean_acuity_imp'
di "        SD imputed acuity score = " %5.2f `sd_acuity_imp'

* Save dataset with imputed acuity
save "data\mimic_with_imputation.dta", replace

********************************************************************************
* Question 5: Provider Group Analysis - Unadjusted Length of Stay
********************************************************************************

di _newline(2)
di "========== QUESTION 5: PROVIDER GROUP UNADJUSTED ANALYSIS =========="

* Extract provider group ID (first two characters, e.g., "P0", "P1", etc.)
* FIXED: Changed from substr(admit_provider_id, 2, 1) to substr(admit_provider_id, 1, 2)
gen provider_group = substr(admit_provider_id, 1, 2)
label variable provider_group "Provider Group ID"

di _newline(1) "Provider Group Distribution:"
tab provider_group

* Encode provider group for regression
encode provider_group, gen(provider_group_num)

* Run regression to calculate unadjusted mean LOS by provider group
di _newline(1) "Unadjusted Regression: LOS by Provider Group"
regress los i.provider_group_num

* Calculate and display unadjusted means
di _newline(1) "Unadjusted Mean Length of Stay by Provider Group:"
margins provider_group_num

* Determine which group has the shortest mean LOS
preserve
collapse (mean) mean_los = los, by(provider_group)
gsort mean_los
list provider_group mean_los in 1
local shortest_group = provider_group[1]
local shortest_los = mean_los[1]
restore

di _newline(1) "ANSWER: Provider group `shortest_group' has the shortest unadjusted mean length of stay (" %5.2f `shortest_los' " days)"

* Test whether any groups are significantly different from P0 (reference group)
di _newline(1) "Testing Significance vs Reference Group (P0):"
di "Testing if each provider group differs significantly from P0..."

quietly regress los i.provider_group_num

* Test each group against reference
forvalues i = 2/10 {
    capture test `i'.provider_group_num = 0
    if _rc == 0 {
        local pval = r(p)
        if `pval' < 0.05 {
            di "  Provider group `i' vs P0: p = " %6.4f `pval' " (SIGNIFICANT)"
        }
        else {
            di "  Provider group `i' vs P0: p = " %6.4f `pval' " (not significant)"
        }
    }
}

********************************************************************************
* Question 6: Provider Group Analysis - Risk-Adjusted Length of Stay
********************************************************************************

di _newline(2)
di "========== QUESTION 6: PROVIDER GROUP RISK-ADJUSTED ANALYSIS =========="

* Create binary variable flagging whether acuity was missing
gen acuity_missing = (missing(acuity))
label variable acuity_missing "Acuity Score Was Missing"
label define missing_lbl 0 "Acuity Available" 1 "Acuity Missing"
label values acuity_missing missing_lbl

di _newline(1) "Acuity Missingness:"
tab acuity_missing

* Encode insurance for regression
encode insurance_clean, gen(insurance_num)

* Run risk-adjusted regression
di _newline(1) "Risk-Adjusted Regression: LOS by Provider Group"
di "Adjusting for: age, insurance, DRG, imputed acuity, acuity missingness"
regress los i.provider_group_num age i.insurance_num i.drg_code acuity_imp i.acuity_missing

* Calculate and display adjusted means
di _newline(1) "Risk-Adjusted Mean Length of Stay by Provider Group:"
margins provider_group_num

* Test whether any groups are significantly different from P0 after adjustment
di _newline(1) "Testing Significance vs Reference Group (P0) - ADJUSTED:"

forvalues i = 2/10 {
    capture test `i'.provider_group_num = 0
    if _rc == 0 {
        local pval = r(p)
        if `pval' < 0.05 {
            di "  Provider group `i' vs P0: p = " %6.4f `pval' " (SIGNIFICANT)"
        }
        else {
            di "  Provider group `i' vs P0: p = " %6.4f `pval' " (not significant)"
        }
    }
}

* Interpretation
di _newline(2)
di "INTERPRETATION:"
di "After risk adjustment, more provider groups show statistically significant"
di "differences from P0 compared to the unadjusted analysis. The relative ranking"
di "of means has also changed. This occurs because risk adjustment eliminates"
di "case selection bias by controlling for patient characteristics (age, insurance,"
di "disease severity, acuity) that are outside the providers' control. This provides"
di "a fairer baseline for comparing provider performance, revealing true differences"
di "in efficiency rather than differences due to patient case mix."

* Save final analysis dataset
save "data\mimic_final_analysis.dta", replace

********************************************************************************
* Question 7: Total Diagnoses Per Person
********************************************************************************

di _newline(2)
di "========== QUESTION 7: DIAGNOSIS COUNT ANALYSIS =========="

* Open diagnosis file
use "data\diagnosis.dta", clear

* Remove duplicate diagnosis codes within each subject
di _newline(1) "Removing duplicate diagnoses per subject..."
bysort subject_id icd_code: keep if _n == 1

* Calculate total number of unique diagnoses per person
bysort subject_id: gen total_dx = _N
label variable total_dx "Total Unique Diagnoses"

* Find maximum number of diagnoses per person
summarize total_dx, detail

local max_dx = r(max)

di _newline(1) "Diagnosis Count Statistics:"
di "  Mean diagnoses per person: " %6.2f r(mean)
di "  Median diagnoses per person: " %6.0f r(p50)
di "  Maximum diagnoses per person: " %6.0f `max_dx'

di _newline(1) "ANSWER: The maximum number of total diagnoses observed per person is " `max_dx'

********************************************************************************
* Question 8: Reshaping Diagnosis Data to Wide Format
********************************************************************************

di _newline(2)
di "========== QUESTION 8: RESHAPE DIAGNOSIS DATA =========="
di "Creating example code to reshape diagnosis data from long to wide format"
di "Goal: One row per patient with diagnoses in columns"

* Reload diagnosis data for reshaping
use "data\diagnosis.dta", clear

* Create sequential diagnosis ID within each patient
* Note: Not removing duplicates here as assignment says "don't need to get it 100% right"
bysort subject_id: generate dx_id = _n
label variable dx_id "Diagnosis Sequence Number"

* Keep only essential variables for reshaping
keep subject_id dx_id icd_code icd_title

* Reshape from long to wide format
* After reshape: one row per patient, with icd_code1, icd_code2, etc.
di _newline(1) "Reshaping data..."
reshape wide icd_code icd_title, i(subject_id) j(dx_id)

* Display results
di _newline(1) "Data structure after reshape:"
describe icd_code1 icd_code2 icd_code3

di _newline(1) "Example data (first 5 subjects):"
list subject_id icd_code1 icd_code2 icd_code3 icd_title2 in 1/5, abbreviate(20)

di _newline(1) "EXPLANATION:"
di "The reshape wide command converts the diagnosis data from long format"
di "(multiple rows per patient) to wide format (one row per patient with"
di "diagnoses spread across columns). Each patient's diagnoses are now in"
di "variables named icd_code1, icd_code2, icd_code3, etc."
