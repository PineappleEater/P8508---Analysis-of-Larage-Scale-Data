********************************************************************************
* Midterm
* Analysis of Large-Scale Data 2025
* Name(s): Xuange Liang [xl3493]
********************************************************************************

clear all
set more off

* Set working directory
cd "C:\Users\l1697\OneDrive\Desktop\Academic\Biostats Courses\Larage Scale Data\midterm_exam"

* Load the main dataset
use midtermLSD, clear

********************************************************************************
* Question 1
********************************************************************************

codebook AGE BMI DIABTYP1 DIABTYP2 DIABTYP0 A1C, compact

* Create binary flag for USPSTF inclusion criteria:
* - 35 years or older, AND
* - Overweight or obese (BMI >= 25), AND
* - Not already diagnosed with any form of diabetes (Type 1, Type 2, or Unknown)

gen uspstf_eligible = (AGE >= 35 & !missing(AGE) & BMI >= 25 & !missing(BMI) & BMI > 0 & DIABTYP1 == 0 & DIABTYP2 == 0 & DIABTYP0 == 0)

label variable uspstf_eligible "Meets USPSTF criteria for HbA1c screening"

* Create binary indicator for A1C test completion
gen a1c_tested = (A1C == 1) if !missing(A1C) & A1C > 0
label variable a1c_tested "HbA1c test completed during visit or within previous 12 months"

* Report results: A1C Testing Among Eligible Population
tab uspstf_eligible

di _newline(1) "Among USPSTF-eligible patients:"
tab a1c_tested if uspstf_eligible == 1

count if uspstf_eligible == 1
local total = r(N)
count if uspstf_eligible == 1 & a1c_tested == 1
local tested = r(N)
local pct = (`tested' / `total') * 100

di "Among " `total' " eligible patients, " `tested' ///
   " (" %5.2f `pct' "%) had an HbA1c test completed."


********************************************************************************
* Question 2
********************************************************************************

* Create female indicator (SEX: 1 = Female, 2 = Male)
gen female = (SEX == 1) if !missing(SEX)
label variable female "Female"
label define sex_lbl 0 "Male" 1 "Female"
label values female sex_lbl

* Create past visits variable (PASTVIS: -7 = New patient, 0-25 = visits, 26 = 26+)
gen past_visits = PASTVIS
replace past_visits = 0 if PASTVIS == -7
label variable past_visits "Number of past visits in last 12 months (top-coded at 26)"

* Convert RACE_ETH to numeric
gen race_eth_num = .
replace race_eth_num = 1 if regexm(RACE_ETH, "WHITE")
replace race_eth_num = 2 if regexm(RACE_ETH, "BLACK")
replace race_eth_num = 3 if regexm(RACE_ETH, "OTHER")
replace race_eth_num = 4 if regexm(RACE_ETH, "HISPANIC")
label define race_lbl 1 "White" 2 "Black" 3 "Other Race" 4 "Hispanic"
label values race_eth_num race_lbl
label variable race_eth_num "Race/Ethnicity"

* Report descriptive statistics for USPSTF-eligible population

* Sex
tab female if uspstf_eligible == 1

* Past visits (last 12 months):
sum past_visits if uspstf_eligible == 1, d

* Race/Ethnicity
tab race_eth_num if uspstf_eligible == 1


********************************************************************************
* Question 3
********************************************************************************

describe DIAG_1
list DIAG_1 in 1/10

* check CCSR key file
preserve
use ICD_CCSR_key_final, clear
describe
list in 1/10
restore

* Prepare CCSR file for merge
preserve
use ICD_CCSR_key_final, clear
rename ICD10_4digit merge_key
tempfile ccsr_temp
save `ccsr_temp', replace
restore

* Merge CCSR body system categories (I use the same merge key in both datasets)
rename DIAG_1 merge_key
merge m:1 merge_key using `ccsr_temp', keep(master match)
tab _merge
* keep all observations from master (both matched and unmatched)
rename merge_key DIAG_1
drop _merge

* Convert CCSR body system to numeric
encode CCSR_BodySys, gen(body_system_num)
label variable body_system_num "CCSR Body System"

* "Merge type: many-to-one (m:1), because Multiple visits can have the same diagnosis code (many), while the CCSR key has one row per unique diagnosis code (one). All observations from the master dataset are kept (both matched and unmatched),"

* CCSR Body System distribution (USPSTF-eligible):
tab body_system_num if uspstf_eligible == 1


********************************************************************************
* Question 4
********************************************************************************

* Use only the eligible population for regression
preserve
keep if uspstf_eligible == 1

* Set survey weights
svyset [pweight=PATWT]

* Logistic regression with odds ratios (using survey weights)
* "Logistic Regression with Survey Weights (Odds Ratios):"
svy: logit a1c_tested i.race_eth_num AGE past_visits female i.body_system_num, or

* Test joint significance of race/ethnicity
test 2.race_eth_num 3.race_eth_num 4.race_eth_num

* Interpretation:There are statistically significant racial/ethnic differences in HbA1c screening (Wald test p=0.0001). Controlling for age, prior visits, sex, and diagnosis:- Black patients: OR=3.04 (95% CI: 1.39-6.65, p=0.006) - Hispanic patients: OR=3.97 (95% CI: 2.12-7.43, p<0.001) - Other Race: OR=1.00 (95% CI: 0.25-4.09, p=0.999, not significant)"

restore
