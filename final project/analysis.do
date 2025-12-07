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
di _newline(1) "Model 1: Unadjusted (Poisson for RR)"
poisson current_smoker i.expanded_state##i.post [pw=weight], cluster(_state) irr
estimates store model1_unadj

di _newline(1) "Incidence Rate Ratios (≈ Relative Risk):"
poisson current_smoker i.expanded_state##i.post [pw=weight], cluster(_state) irr

* Model 2: Adjusted (with covariates)
di _newline(1) "Model 2: Adjusted (with demographic covariates)"
poisson current_smoker i.expanded_state##i.post ///
    i.age_cat i.female i.race i.education i.income i.employed ///
    [pw=weight], cluster(_state) irr

estimates store model2_adj

di _newline(1) "Adjusted Relative Risks:"
poisson current_smoker i.expanded_state##i.post ///
    i.age_cat i.female i.race i.education i.income i.employed ///
    [pw=weight], cluster(_state) irr

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
di _newline(1) "Model 1: Unadjusted (Current Smokers Only)"
poisson quit_attempt i.expanded_state##i.post [pw=weight], cluster(_state) irr

estimates store model3_unadj

di _newline(1) "Relative Risk:"
poisson quit_attempt i.expanded_state##i.post [pw=weight], cluster(_state) irr

* Model 2: Adjusted
di _newline(1) "Model 2: Adjusted (Current Smokers Only)"
poisson quit_attempt i.expanded_state##i.post ///
    i.age_cat i.female i.race i.education i.income i.employed ///
    [pw=weight], cluster(_state) irr

estimates store model4_adj

di _newline(1) "Adjusted Relative Risks:"
poisson quit_attempt i.expanded_state##i.post ///
    i.age_cat i.female i.race i.education i.income i.employed ///
    [pw=weight], cluster(_state) irr

restore

********************************************************************************
* EXTENSION ANALYSIS - STRATIFIED BY RACE/ETHNICITY
********************************************************************************

di _newline(2)
di "========== EXTENSION: STRATIFIED ANALYSIS BY RACE =========="
di "Does Medicaid Expansion have differential effects by race?"

* Stratified DiD for Current Smoking

di _newline(1) "RR for Current Smoking - WHITE POPULATION:"
capture noisily poisson current_smoker i.expanded_state##i.post ///
    i.age_cat i.female i.education i.income i.employed ///
    if race == 1 [pw=weight], cluster(_state) irr
capture estimates store smoke_white

di _newline(1) "RR for Current Smoking - BLACK POPULATION:"
capture noisily poisson current_smoker i.expanded_state##i.post ///
    i.age_cat i.female i.education i.income i.employed ///
    if race == 2 [pw=weight], cluster(_state) irr
capture estimates store smoke_black

di _newline(1) "RR for Current Smoking - HISPANIC POPULATION:"
capture noisily poisson current_smoker i.expanded_state##i.post ///
    i.age_cat i.female i.education i.income i.employed ///
    if race == 3 [pw=weight], cluster(_state) irr
capture estimates store smoke_hispanic

* Stratified DiD for Quit Attempts (among smokers)
preserve
keep if current_smoker == 1

di _newline(1) "RR for Quit Attempts - WHITE SMOKERS:"
capture noisily poisson quit_attempt i.expanded_state##i.post ///
    i.age_cat i.female i.education i.income i.employed ///
    if race == 1 [pw=weight], cluster(_state) irr
capture estimates store quit_white

di _newline(1) "RR for Quit Attempts - BLACK SMOKERS:"
capture noisily poisson quit_attempt i.expanded_state##i.post ///
    i.age_cat i.female i.education i.income i.employed ///
    if race == 2 [pw=weight], cluster(_state) irr
capture estimates store quit_black

di _newline(1) "RR for Quit Attempts - HISPANIC SMOKERS:"
capture noisily poisson quit_attempt i.expanded_state##i.post ///
    i.age_cat i.female i.education i.income i.employed ///
    if race == 3 [pw=weight], cluster(_state) irr
capture estimates store quit_hispanic

restore

********************************************************************************
* EXTENSION ANALYSIS - STRATIFIED BY INCOME
********************************************************************************

di _newline(2)
di "========== EXTENSION: STRATIFIED ANALYSIS BY INCOME =========="
di "Does Medicaid Expansion have differential effects by income level?"

* Low income (< $20,000) - more likely to be Medicaid eligible
di _newline(1) "RR for Current Smoking - LOW INCOME (<$20k):"
capture noisily poisson current_smoker i.expanded_state##i.post ///
    i.age_cat i.female i.race i.education i.employed ///
    if income <= 2 [pw=weight], cluster(_state) irr
capture estimates store smoke_lowinc

* Higher income (>= $20,000)
di _newline(1) "RR for Current Smoking - HIGHER INCOME (>=$20k):"
capture noisily poisson current_smoker i.expanded_state##i.post ///
    i.age_cat i.female i.race i.education i.employed ///
    if income >= 3 & income != . [pw=weight], cluster(_state) irr
capture estimates store smoke_highinc

********************************************************************************
* SUMMARY TABLE: COMPARE REPLICATION VS EXTENSION
********************************************************************************

di _newline(2)
di "========== SUMMARY: COMPARISON OF RESULTS =========="

* Create comparison table
di _newline(1) "CURRENT SMOKING - DiD COEFFICIENTS (Relative Risks):"
di "-----------------------------------------------------"
capture noisily estimates table model2_adj smoke_white smoke_black smoke_hispanic, ///
    keep(1.expanded_state#1.post) b se stats(N)

di _newline(1) "QUIT ATTEMPTS - DiD COEFFICIENTS (Relative Risks):"
di "-----------------------------------------------------"
capture noisily estimates table model4_adj quit_white quit_black quit_hispanic, ///
    keep(1.expanded_state#1.post) b se stats(N)

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

di _newline(2) "========== FINAL COMPARISON =========="
di "Comparing Adjusted RR (Clustered) vs RR (Unclustered) vs OR (Logit)"
capture noisily estimates table model2_adj sensitivity_no_cluster innovation_logit, ///
    keep(1.expanded_state#1.post) b se p stats(N) modelwidth(20)


log close

********************************************************************************
* END OF ANALYSIS
********************************************************************************
