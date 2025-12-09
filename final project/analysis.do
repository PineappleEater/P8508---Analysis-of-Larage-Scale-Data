********************************************************************************
* Final Project - Statistical Analysis (analysis.do)
* Analysis of Large-Scale Data 2025
* Name(s): Xuange Liang [xl3493], Zexuan Yan [zy2654]
*
* Replication of: Valvi et al. (2019)
*    "Current smoking and quit-attempts among US adults following
*     Medicaid expansion"
* Dataset: Processed BRFSS 2003-2015 (from proc.do)
* Purpose: Replicate Tables 1-5 and perform extension analysis
********************************************************************************

clear all
set more off

* Batch mode optimization settings
set rmsg off              // Suppress return message timing
set type double           // Use double precision
capture set matsize 11000 // Increase matrix size if needed
set maxvar 10000          // Increase max variables

********************************************************************************
* SETUP
********************************************************************************

* Set working directory
* Windows path:
global projdir "d:\OneDrive\Desktop\Academic\Biostats Courses\Larage Scale Data\final project"
* For Linux Stata, use: 
* global projdir "/home/liang/desktop/P8508---Analysis-of-Larage-Scale-Data/final project"
cd "$projdir"

* Log file for documentation
capture mkdir "log"
capture log close
log using "log/analysis.log", text replace

di "============================================================"
di "FINAL PROJECT: STATISTICAL ANALYSIS"
di "Replication of Valvi et al. (2019)"
di "============================================================"
di "Started at: $S_DATE $S_TIME"

* Load processed data
use "data/brfss_analysis.dta", clear

* --- NO AGE RESTRICTION (Paper includes all adults 18+) ---
* Paper Table 1 includes age groups: 18-34, 35-49, 50-64, 65-79, 80+
di "Sample includes all adults 18+..."

* --- YEAR RESTRICTION (Match Paper's Primary Analysis N=5,311,872) ---
* Paper analysis is 2003-2015. (2011-2017 is supplemental only).
keep if year <= 2015

* Declare survey design (must do before any svy: commands)
capture confirm variable weight
if _rc != 0 {
    di "ERROR: Variable 'weight' is missing!"
}
svyset [pw=weight]

* Diagnose missing values
di _newline(1) "Checking for missing values in key variables:"
misstable patterns current_smoker post expanded_state weight

* Display sample size
di _newline(1)
di "Total observations: " _N

********************************************************************************
* TABLE 1: Baseline Characteristics by Medicaid Expansion Status
********************************************************************************

di _newline(2)
di "========== TABLE 1: BASELINE CHARACTERISTICS =========="
di "Comparing Expanded vs. Non-Expanded States"

* Overall sample sizes
di _newline(1) "Sample Size by Expansion Status:"
tab expanded_state, missing

* Age distribution
di _newline(1) "Age Category by Expansion Status:"
tab age_cat expanded_state, col chi2

* Sex distribution
di _newline(1) "Sex by Expansion Status:"
tab female expanded_state, col chi2

* Race/Ethnicity distribution
di _newline(1) "Race/Ethnicity by Expansion Status:"
tab race expanded_state, col chi2

* Education distribution
di _newline(1) "Education by Expansion Status:"
tab education expanded_state, col chi2

* Income distribution
di _newline(1) "Income by Expansion Status:"
tab income expanded_state, col chi2

* Employment distribution
di _newline(1) "Employment by Expansion Status:"
tab employed expanded_state, col chi2

* Healthcare coverage
di _newline(1) "Healthcare Coverage by Expansion Status:"
tab has_coverage expanded_state, col chi2

* Personal doctor
di _newline(1) "Has Personal Doctor by Expansion Status:"
tab has_doctor expanded_state, col chi2

********************************************************************************
* TABLE 2: Current Smoking and Quit Attempts by Expansion Status
********************************************************************************

di _newline(2)
di "========== TABLE 2: OUTCOMES BY EXPANSION STATUS =========="

* Current smoking prevalence
di _newline(1) "Current Smoking by Expansion Status:"
tab current_smoker expanded_state, row chi2

* Quit attempts (among current smokers only)
di _newline(1) "Quit Attempts by Expansion Status (Current Smokers Only):"
tab quit_attempt expanded_state if current_smoker == 1, row chi2

********************************************************************************
* FIGURE 1 & 2: Trends Over Time
********************************************************************************

di _newline(2)
di "========== FIGURES: TRENDS OVER TIME =========="

* Calculate yearly prevalence by expansion status
preserve


* Collapse to get weighted means by year and expansion status
collapse (mean) smoke_prev = current_smoker ///
         (mean) quit_prev = quit_attempt [pw=weight], ///
         by(year expanded_state)

* Figure 1: Current Smoking Trends
di _newline(1) "Creating Figure 1: Smoking Prevalence Trends..."
twoway (connected smoke_prev year if expanded_state == 1, ///
            lcolor(blue) mcolor(blue) msymbol(circle)) ///
       (connected smoke_prev year if expanded_state == 0, ///
            lcolor(red) mcolor(red) msymbol(square)), ///
       title("Figure 1: Current Smoking Prevalence by Expansion Status", size(medium)) ///
       subtitle("BRFSS 2003-2015", size(small)) ///
       xtitle("Year") ytitle("Prevalence of Current Smoking") ///
       xlabel(2003(2)2015) ylabel(0.10(0.05)0.30, format(%4.2f)) ///
       legend(order(1 "Expanded States" 2 "Non-Expanded States") rows(1)) ///
       note("Note: 2010 excluded as washout period") ///
       scheme(s2color) ///
       xline(2010.5, lpattern(dash) lcolor(gray))

graph export "output/figure1_smoking_trends.png", replace width(1000) height(600)
di "Figure 1 saved as: output/figure1_smoking_trends.png"

* Figure 2: Quit Attempt Trends
di _newline(1) "Creating Figure 2: Quit Attempt Trends..."
twoway (connected quit_prev year if expanded_state == 1, ///
            lcolor(blue) mcolor(blue) msymbol(circle)) ///
       (connected quit_prev year if expanded_state == 0, ///
            lcolor(red) mcolor(red) msymbol(square)), ///
       title("Figure 2: Quit Attempts in Past Year by Expansion Status", size(medium)) ///
       subtitle("BRFSS 2003-2015, Among Current Smokers", size(small)) ///
       xtitle("Year") ytitle("Prevalence of Quit Attempts") ///
       xlabel(2003(2)2015) ylabel(0.45(0.05)0.65, format(%4.2f)) ///
       legend(order(1 "Expanded States" 2 "Non-Expanded States") rows(1)) ///
       note("Note: 2010 excluded as washout period") ///
       scheme(s2color) ///
       xline(2010.5, lpattern(dash) lcolor(gray))

graph export "output/figure2_quit_trends.png", replace width(1000) height(600)
di "Figure 2 saved as: output/figure2_quit_trends.png"

restore

********************************************************************************
* TABLE 3: DIFFERENCE-IN-DIFFERENCES REGRESSION - CURRENT SMOKING
********************************************************************************

di _newline(2)
di "========== TABLE 3: DiD REGRESSION - CURRENT SMOKING =========="
di "Comparing Pre (2003-2009) vs Post (2011-2015) by Expansion Status"

* Model 1: Unadjusted (Using Poisson for Relative Risk, matching paper's GEE approach)
di _newline(1) "Model 1: Unadjusted (Poisson for RR, IRR ≈ Relative Risk)"
poisson current_smoker i.expanded_state##i.post [pw=weight], cluster(_state) irr
estimates store model1_unadj

* Model 2: Adjusted (with covariates)
di _newline(1) "Model 2: Adjusted (with demographic covariates)"
poisson current_smoker i.expanded_state##i.post ///
    i.age_cat i.female i.race i.education i.income i.employed ///
    [pw=weight], cluster(_state) irr
estimates store model2_adj

* Key coefficient interpretation
di _newline(1)
di "KEY COEFFICIENT INTERPRETATION:"
di "- expanded_state#post: This is the DiD estimator"
di "- It captures the differential change in smoking for expansion states"
di "  relative to non-expansion states after 2011"

********************************************************************************
* TABLE 4: DIFFERENCE-IN-DIFFERENCES REGRESSION - QUIT ATTEMPTS
********************************************************************************

di _newline(2)
di "========== TABLE 4: DiD REGRESSION - QUIT ATTEMPTS =========="
di "Among Current Smokers Only"

* Restrict to current smokers for quit attempt analysis
preserve
keep if current_smoker == 1

* Model 1: Unadjusted (Poisson for RR)
di _newline(1) "Model 1: Unadjusted (Current Smokers Only, IRR ≈ Relative Risk)"
poisson quit_attempt i.expanded_state##i.post [pw=weight], cluster(_state) irr
estimates store model3_unadj

* Model 2: Adjusted
di _newline(1) "Model 2: Adjusted (Current Smokers Only)"
poisson quit_attempt i.expanded_state##i.post ///
    i.age_cat i.female i.race i.education i.income i.employed ///
    [pw=weight], cluster(_state) irr
estimates store model4_adj

restore

********************************************************************************
* TABLE 3 EXTENDED: AGE-STRATIFIED ANALYSIS (Replicating Paper Table 3)
********************************************************************************

di _newline(2)
di "========== TABLE 3 EXTENDED: AGE-STRATIFIED ANALYSIS =========="
di "Replicating Paper's Table 3: Current Smoking and Quit Attempts by Age Group"

* Define age groups following paper's categories
* 1: 18-49 (combines 18-34 and 35-49)
* 2: 50-79 (combines 50-64 and 65-79)
* 3: 80+

gen age_group = .
replace age_group = 1 if inlist(age_cat, 1, 2)  // 18-49
replace age_group = 2 if inlist(age_cat, 3, 4)  // 50-79
replace age_group = 3 if age_cat == 5           // 80+
label define age_group_lbl 1 "18-49" 2 "50-79" 3 "80+"
label values age_group age_group_lbl

* Current Smoking by Age Group
foreach a in 1 2 3 {
    local aname: label (age_group) `a'
    di _newline(1) "=== CURRENT SMOKING: Age `aname' ==="
    capture noisily poisson current_smoker i.expanded_state##i.post ///
        i.female i.race i.education i.income i.employed ///
        if age_group == `a' [pw=weight], cluster(_state) irr
    capture estimates store smoke_age`a'
}

* Quit Attempts by Age Group (among smokers)
preserve
keep if current_smoker == 1

foreach a in 1 2 3 {
    local aname: label (age_group) `a'
    di _newline(1) "=== QUIT ATTEMPTS: Age `aname' (Smokers) ==="
    capture noisily poisson quit_attempt i.expanded_state##i.post ///
        i.female i.race i.education i.income i.employed ///
        if age_group == `a' [pw=weight], cluster(_state) irr
    capture estimates store quit_age`a'
}

restore

********************************************************************************
* TREND ANALYSIS: Linear and Quadratic Trends (Paper Table 3 Footnotes)
********************************************************************************

di _newline(2)
di "========== TREND ANALYSIS: TIME TRENDS =========="
di "Testing Linear and Quadratic Trends (Paper Table 3 Footnotes)"

* Create year-squared term for quadratic trend
gen year_sq = year^2

* PRE-EXPANSION PERIOD (2003-2009): Current Smoking
di _newline(1) "=== PRE-EXPANSION (2003-2009): Current Smoking Trends ==="
di "Testing linear (year) and quadratic (year^2) terms"
capture noisily poisson current_smoker c.year c.year_sq ///
    i.expanded_state i.age_cat i.female i.race i.education i.income i.employed ///
    if post == 0 [pw=weight], cluster(_state)
di "Note: Check p-values for 'year' (linear) and 'year_sq' (quadratic)"

* POST-EXPANSION PERIOD (2011-2015): Current Smoking
di _newline(1) "=== POST-EXPANSION (2011-2015): Current Smoking Trends ==="
capture noisily poisson current_smoker c.year c.year_sq ///
    i.expanded_state i.age_cat i.female i.race i.education i.income i.employed ///
    if post == 1 [pw=weight], cluster(_state)

* PRE-EXPANSION: Quit Attempts
preserve
keep if current_smoker == 1

di _newline(1) "=== PRE-EXPANSION (2003-2009): Quit Attempt Trends ==="
capture noisily poisson quit_attempt c.year c.year_sq ///
    i.expanded_state i.age_cat i.female i.race i.education i.income i.employed ///
    if post == 0 [pw=weight], cluster(_state)

* POST-EXPANSION: Quit Attempts
di _newline(1) "=== POST-EXPANSION (2011-2015): Quit Attempt Trends ==="
capture noisily poisson quit_attempt c.year c.year_sq ///
    i.expanded_state i.age_cat i.female i.race i.education i.income i.employed ///
    if post == 1 [pw=weight], cluster(_state)

restore

********************************************************************************
* EXTENSION ANALYSIS - STRATIFIED BY RACE/ETHNICITY
********************************************************************************

di _newline(2)
di "========== EXTENSION: STRATIFIED ANALYSIS BY RACE =========="
di "Does Medicaid Expansion have differential effects by race?"

* Stratified DiD for Current Smoking by Race
foreach r in 1 2 3 {
    local rname: label (race) `r'
    di _newline(1) "=== Current Smoking - `rname' ==="
    capture noisily poisson current_smoker i.expanded_state##i.post ///
        i.age_cat i.female i.education i.income i.employed ///
        if race == `r' [pw=weight], cluster(_state) irr
    capture estimates store smoke_race`r'
}

* Stratified DiD for Quit Attempts by Race (among smokers)
preserve
keep if current_smoker == 1

foreach r in 1 2 3 {
    local rname: label (race) `r'
    di _newline(1) "=== Quit Attempts - `rname' Smokers ==="
    capture noisily poisson quit_attempt i.expanded_state##i.post ///
        i.age_cat i.female i.education i.income i.employed ///
        if race == `r' [pw=weight], cluster(_state) irr
    capture estimates store quit_race`r'
}

restore

********************************************************************************
* EXTENSION ANALYSIS - STRATIFIED BY INCOME
********************************************************************************

di _newline(2)
di "========== EXTENSION: STRATIFIED ANALYSIS BY INCOME =========="
di "Does Medicaid Expansion have differential effects by income level?"

* Low income (< $20,000) - more likely to be Medicaid eligible
di _newline(1) "=== Current Smoking - LOW INCOME (<$20k) ==="
capture noisily poisson current_smoker i.expanded_state##i.post ///
    i.age_cat i.female i.race i.education i.employed ///
    if income <= 2 [pw=weight], cluster(_state) irr
capture estimates store smoke_lowinc

* Higher income (>= $20,000)
di _newline(1) "=== Current Smoking - HIGHER INCOME (>=$20k) ==="
capture noisily poisson current_smoker i.expanded_state##i.post ///
    i.age_cat i.female i.race i.education i.employed ///
    if income >= 3 & income != . [pw=weight], cluster(_state) irr
capture estimates store smoke_highinc

* Quit Attempts by Income (among smokers)
preserve
keep if current_smoker == 1

di _newline(1) "=== Quit Attempts - LOW INCOME (<$20k) ==="
capture noisily poisson quit_attempt i.expanded_state##i.post ///
    i.age_cat i.female i.race i.education i.employed ///
    if income <= 2 [pw=weight], cluster(_state) irr
capture estimates store quit_lowinc

di _newline(1) "=== Quit Attempts - HIGHER INCOME (>=$20k) ==="
capture noisily poisson quit_attempt i.expanded_state##i.post ///
    i.age_cat i.female i.race i.education i.employed ///
    if income >= 3 & income != . [pw=weight], cluster(_state) irr
capture estimates store quit_highinc

restore

********************************************************************************
* SUMMARY TABLE: COMPARE REPLICATION VS EXTENSION
********************************************************************************

di _newline(2)
di "========== SUMMARY: COMPARISON OF RESULTS =========="

* Create comparison table - Current Smoking
di _newline(1) "CURRENT SMOKING - DiD Coefficients (1.expanded#1.post):"
di "-----------------------------------------------------"
capture noisily estimates table model2_adj smoke_age1 smoke_age2 smoke_age3 ///
    smoke_race1 smoke_race2 smoke_race3 smoke_lowinc smoke_highinc, ///
    keep(1.expanded_state#1.post) b se stats(N) modelwidth(12)

* Create comparison table - Quit Attempts
di _newline(1) "QUIT ATTEMPTS - DiD Coefficients (1.expanded#1.post):"
di "-----------------------------------------------------"
capture noisily estimates table model4_adj quit_age1 quit_age2 quit_age3 ///
    quit_race1 quit_race2 quit_race3 quit_lowinc quit_highinc, ///
    keep(1.expanded_state#1.post) b se stats(N) modelwidth(12)

********************************************************************************
* SENSITIVITY ANALYSIS (Optional)
********************************************************************************

di _newline(2)
di "========== SENSITIVITY ANALYSIS =========="

* 1. Sensitivity Analysis: No Clustering (Test if this matches Paper's small p-values)
di _newline(1) "Sensitivity 1: Poisson GEE *WITHOUT* State Clustering (Naive SEs):"
capture noisily poisson current_smoker i.expanded_state##i.post ///
    i.age_cat i.female i.race i.education i.income i.employed ///
    [pw=weight], irr
capture estimates store sensitivity_no_cluster


* 2. Innovation: Logistic Regression (Methods Comparison)
di _newline(1) "Innovation 2: Logistic Regression (Odds Ratios) instead of RR:"
capture noisily logit current_smoker i.expanded_state##i.post ///
    i.age_cat i.female i.race i.education i.income i.employed ///
    [pw=weight], cluster(_state) or
capture estimates store innovation_logit

di _newline(1) "Interpretation: Odds Ratios (OR) will invariably be further from 1 than RR"
di "because smoking is a common outcome (>10%). This highlights why RR is preferred,"
di "but OR is often used in older studies."


* 3. Innovation: Handling Missing Data (Missing Indicator Method)
di _newline(2) "========== INNOVATION 3: HANDLING MISSING DATA (MISSING INDICATOR) =========="
di "Problem: Listwise deletion removed ~1.5 million people (mostly missing income)."
di "Solution: Recode missing income as 'Unknown' category to restore sample size."

* Create new imputed income variable
gen income_imp = income
replace income_imp = 5 if income == .
label define income_lbl 1 "<$10k" 2 "$10k-<$20k" 3 "$20k-<$50k" 4 "$50k+" 5 "Unknown"
label values income_imp income_lbl

di _newline(1) "Running Poisson Model with 'Unknown' Income Category:"
capture noisily poisson current_smoker i.expanded_state##i.post ///
    i.age_cat i.female i.race i.education i.income_imp i.employed ///
    [pw=weight], cluster(_state) irr
capture estimates store innovation_missing_ind

* Also run Low Income (imputed) if user wants? 
* Note: 'Unknown' group is distinct from 'Low Income'.
* But we can check if N is restored.

di _newline(2) "========== FINAL COMPARISON =========="
di "Comparing Adjusted RR (Clustered) vs Unclustered vs Logit vs Missing Indicator"
capture noisily estimates table model2_adj sensitivity_no_cluster innovation_logit innovation_missing_ind, ///
    keep(1.expanded_state#1.post) b se p stats(N) modelwidth(15)

********************************************************************************
* TABLE 5 & 6: ADMINISTRATIVE BARRIERS ANALYSIS
* Replicating Impact of Prior Authorization and Copayments (2010 state policies)
********************************************************************************

di _newline(2)
di "========== TABLES 5 & 6: ADMINISTRATIVE BARRIERS =========="
di "Analyzing impact of Prior Authorization and Copayment barriers on quit attempts"
di "Data source: Valvi et al. (2019) footnotes, 2010 state policies"

* FIPS Codes Reference:
* AL=01 AK=02 AZ=04 AR=05 CA=06 CO=08 CT=09 DE=10 DC=11 FL=12 GA=13 HI=15 ID=16
* IL=17 IN=18 IA=19 KS=20 KY=21 LA=22 ME=23 MD=24 MA=25 MI=26 MN=27 MS=28 MO=29
* MT=30 NE=31 NV=32 NH=33 NJ=34 NM=35 NY=36 NC=37 ND=38 OH=39 OK=40 OR=41 PA=42
* RI=44 SC=45 SD=46 TN=47 TX=48 UT=49 VT=50 VA=51 WA=53 WV=54 WI=55 WY=56

* A. PRIOR AUTHORIZATION (Table 5)
* States requiring prior authorization in 2010: AK, AL, AR, CO, DE, HI, IA, ID, MA, ME, MI, MO, MT, ND, NE, NV, OK, RI, TN, UT, VT, WA, WV (23 states)
gen prior_auth = 0
foreach st in 2 1 5 8 10 15 19 16 25 23 26 29 30 38 31 32 40 44 47 49 50 53 54 {
    replace prior_auth = 1 if _state == `st'
}
label variable prior_auth "Prior Authorization Required (2010)"

di _newline(1) "Cross-tabulation: Expansion State by Prior Authorization"
tab expanded_state prior_auth

* B. CO-PAYMENTS (Table 6)
* States requiring copayments in 2010: AK, CA, CO, DE, GA, IL, IN, KS, LA, MA, ME, MN, MS, MT, NC, ND, NE, NH, NV, OH, OK, OR, PA, SD, TX, UT, VA, VT, WI, WV, WY (31 states)
* Note: "OA" in paper assumed to be "GA" (Georgia, FIPS 13)
gen copay = 0
foreach st in 2 6 8 10 13 17 18 20 22 25 23 27 28 30 37 38 31 33 32 39 40 41 42 46 48 49 51 50 55 54 56 {
    replace copay = 1 if _state == `st'
}
label variable copay "Co-payment Required (2010)"

di _newline(1) "Cross-tabulation: Expansion State by Copayment"
tab expanded_state copay

* Barriers Analysis: Restrict to Current Smokers (quit attempts only defined for smokers)
preserve
keep if current_smoker == 1

* TABLE 5: PRIOR AUTHORIZATION
di _newline(2) "========== TABLE 5: PRIOR AUTHORIZATION BARRIERS =========="
di "Outcome: Quit Attempts (Among Current Smokers)"
di "Comparing Post vs Pre by Expansion Status, stratified by Prior Auth requirement"

di _newline(1) "--- STRATUM: Prior Authorization Required (YES) ---"
capture noisily poisson quit_attempt i.expanded_state##i.post ///
    i.age_cat i.female i.race i.education i.income i.employed ///
    if prior_auth == 1 [pw=weight], cluster(_state) irr
capture estimates store barrier_prior_yes

di _newline(1) "--- STRATUM: No Prior Authorization Required (NO) ---"
capture noisily poisson quit_attempt i.expanded_state##i.post ///
    i.age_cat i.female i.race i.education i.income i.employed ///
    if prior_auth == 0 [pw=weight], cluster(_state) irr
capture estimates store barrier_prior_no

* TABLE 6: CO-PAYMENTS
di _newline(2) "========== TABLE 6: CO-PAYMENT BARRIERS =========="
di "Outcome: Quit Attempts (Among Current Smokers)"
di "Comparing Post vs Pre by Expansion Status, stratified by Copayment requirement"

di _newline(1) "--- STRATUM: Copayment Required (YES) ---"
capture noisily poisson quit_attempt i.expanded_state##i.post ///
    i.age_cat i.female i.race i.education i.income i.employed ///
    if copay == 1 [pw=weight], cluster(_state) irr
capture estimates store barrier_copay_yes

di _newline(1) "--- STRATUM: No Copayment Required (NO) ---"
capture noisily poisson quit_attempt i.expanded_state##i.post ///
    i.age_cat i.female i.race i.education i.income i.employed ///
    if copay == 0 [pw=weight], cluster(_state) irr
capture estimates store barrier_copay_no

* Summary comparison
di _newline(2) "========== BARRIERS SUMMARY =========="
di "DiD Coefficients (1.expanded#1.post) by Barrier Status:"
capture noisily estimates table barrier_prior_yes barrier_prior_no barrier_copay_yes barrier_copay_no, ///
    keep(1.expanded_state#1.post) b se stats(N) modelwidth(15)

restore

********************************************************************************
* SENSITIVITY ANALYSES
********************************************************************************

di _newline(3)
di "=========================================================================="
di "SENSITIVITY ANALYSES: TESTING ROBUSTNESS ACROSS METHODS"
di "=========================================================================="
di "Purpose: Demonstrate that clustering is critical for correct inference"
di _newline(1)

* METHOD 1: UNCLUSTERED POISSON
di _newline(2)
di "========== METHOD 1: POISSON WITHOUT CLUSTERING =========="
di "WARNING: Ignores state-level clustering, will underestimate standard errors"
di _newline(1)

di "--- Current Smoking (Unclustered) ---"
poisson current_smoker i.expanded_state##i.post ///
    i.age_cat i.female i.race i.education i.income i.employed ///
    [pw=weight], vce(robust) irr
di _newline(1) "DiD Effect:"
lincom 1.expanded_state#1.post, irr

di _newline(1)
di "--- Quit Attempts (Unclustered) ---"
poisson quit_attempt i.expanded_state##i.post ///
    i.age_cat i.female i.race i.education i.income i.employed ///
    if current_smoker == 1 [pw=weight], vce(robust) irr
di _newline(1) "DiD Effect:"
lincom 1.expanded_state#1.post, irr

* METHOD 2: LOGISTIC REGRESSION
di _newline(2)
di "========== METHOD 2: LOGISTIC REGRESSION =========="
di "Using logistic regression instead of Poisson (with clustering)"
di _newline(1)

di "--- Current Smoking (Logistic) ---"
logistic current_smoker i.expanded_state##i.post ///
    i.age_cat i.female i.race i.education i.income i.employed ///
    [pw=weight], cluster(_state)
di _newline(1) "DiD Effect (Odds Ratio):"
lincom 1.expanded_state#1.post, or

di _newline(1)
di "--- Quit Attempts (Logistic) ---"
logistic quit_attempt i.expanded_state##i.post ///
    i.age_cat i.female i.race i.education i.income i.employed ///
    if current_smoker == 1 [pw=weight], cluster(_state)
di _newline(1) "DiD Effect (Odds Ratio):"
lincom 1.expanded_state#1.post, or

di _newline(2)
di "=========================================================================="
di "SENSITIVITY ANALYSIS SUMMARY"
di "=========================================================================="
di "Key findings:"
di "  - Point estimates stable across methods (≈0.98)"
di "  - Clustering by state is CRITICAL for correct inference"
di "  - Without clustering, standard errors severely underestimated"
di "  - All methods confirm: no evidence of increased quit attempts"
di _newline(1)


log close

********************************************************************************
* END OF ANALYSIS
********************************************************************************
