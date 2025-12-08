********************************************************************************
* MULTIPLE IMPUTATION SCRIPT (analysis_mi.do)
* WARNING: This script handles 5.3+ million observations with complex survey weights.
* Execution time may be EXTREMELY LONG (Hours or Days).
* Recommended: Run on a high-performance cluster or subset data for testing.
********************************************************************************

clear all
set more off
set maxvar 10000

* Set working directory
global projdir "d:\OneDrive\Desktop\Academic\Biostats Courses\Larage Scale Data\final project"
cd "$projdir"

capture log close
log using "log/analysis_mi.log", text replace

* Load data
use "data/brfss_analysis.dta", clear
keep if year <= 2015

di "============================================================"
di "MULTIPLE IMPUTATION ANALYSIS"
di "Target: Impute missing INCOME, RACE, EDUCATION"
di "============================================================"

* 1. Register variables
* 'regular' variables are complete or not imputed
mi set wide
mi register regular expanded_state post age_cat female employed year _state weight
* 'imputed' variables have missing values we want to fill
mi register imputed income race education


* Check if imputed data already exists to save time
capture confirm file "data/brfss_mi_imputed.dta"

if _rc == 0 {
    di _newline(1) "Found existing imputed data: data/brfss_mi_imputed.dta"
    di "Loading data and skipping imputation step..."
    use "data/brfss_mi_imputed.dta", clear
    mi set wide 
}
else {
    di _newline(1) "No imputed data found. Starting MICE Imputation (M=5)..."
    di "Imputing: income, race, education (iterative method)"

    * 2. Imputation Model: MICE (Multivariate Imputation by Chained Equations)
    * This is the "Gold Standard" method likely used in the paper.
    * It imputes Income, Race, and Education simultaneously, using each other as predictors.

    * use 'augment' to handle perfect prediction issues in categorical variables
    * 'force' is needed because we ignore survey weights during the imputation step (standard practice)
    mi impute chained ///
        (mlogit) income race education ///
        = i.female i.employed i.age_cat i.expanded_state i.post, ///
        add(5) rseed(2025) force augment

    di "Imputation Complete. Saving data..."
    save "data/brfss_mi_imputed.dta", replace
}

* 3. Analysis on Imputed Data
* We use 'mi estimate: svy: poisson'
di _newline(1) "Running Pooled Analysis..."

* Fix: Define clustering in svyset, not in the command
mi svyset _state [pw=weight]

di _newline(1) "Model: MI Poisson GEE"
* Fix: Remove cluster(_state) option as it is handled by svyset
* Use 'eform' for exponentiated coefficients (RR)
mi estimate, eform: svy: poisson current_smoker i.expanded_state##i.post ///
    i.age_cat i.female i.race i.education i.income i.employed

di "MI Analysis Complete."
log close
