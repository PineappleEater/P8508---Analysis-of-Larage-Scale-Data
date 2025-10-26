********************************************************************************
* Assignment 2 - Smoking Trends Analysis in NHIS 
* Analysis of Large-Scale Data 2025
* Name(s): Xuange Liang [xl3493], Zexuan Yan [zy2654]
* 
* Dataset: NHIS compressed data with demographics and smoking (no K6)
* Focus: Smoking trends over time with demographic controls
********************************************************************************

clear all
set more off

********************************************************************************
* Import NHIS multi-year data from compressed file
********************************************************************************
* Import compressed data with demographics and smoking (no K6 variables)
di "LOADING COMPRESSED NHIS DATA - nhis_00002.dat.gz"
do "Import_nhis_00002.do"

* Create demographic variables needed for analysis
* Female indicator variable (sex: 1=Male, 2=Female)
capture confirm variable sex
if _rc == 0 {
    gen female = (sex == 2) if sex != .
    label variable female "Female (1=Yes, 0=No)"
    label define yesno 0 "No" 1 "Yes"
    label values female yesno
    di "Female variable created from sex variable"
}
else {
    di "WARNING: Sex variable not found - creating missing female variable"
    gen female = .
    label variable female "Female (missing data)"
}

* Clean age variable if available
capture confirm variable age
if _rc == 0 {
    replace age = . if age > 120 | age < 0
    di "Age variable cleaned"
}

* Display data overview
di "Data loaded successfully with demographic variables"
summarize year age
tab year if year >= 2000, missing
tab sex female, missing

********************************************************************************
* Initial data exploration and filtering
********************************************************************************

* First check the year range in the dataset
summarize year
di "Dataset spans from " r(min) " to " r(max) " with " _N " total observations"

* Check smoking variable distribution
tab smokev, missing

* Check data availability for smoking variable - use summarize instead of cross-tab
* Count observations by smoking status
preserve
collapse (count) n = smokev, by(year smokev)
reshape wide n, i(year) j(smokev)

* Display first few years to understand structure
di "Sample of data availability by year (first 10 years):"
list year n* in 1/10, separator(5)

* Show overall pattern
restore

* Focus on extended time period for trend analysis - check what years have smoking data
* Keep years with valid smoking data (not NIU - code 0)
di "Before filtering: " _N " observations"
keep if smokev != 0

di "After removing NIU cases: " _N " observations"

* Check the year range after filtering
summarize year
di "Data with smoking info spans from " r(min) " to " r(max)

* Further filter to reasonable analysis period based on data availability
* Use a more conservative range to ensure good data quality
keep if year >= 1997 & year <= 2018

di "After filtering to 1997-2018: " _N " observations"

* Check final sample after filtering
di "Final sample for analysis:"
di "Sample size: " _N " observations"
summarize year
di "Years: " r(min) " to " r(max) " (N=" r(N) " year-observations)"

* Check smoking variable distribution in final sample
tab smokev, missing

* Quick check of key demographic variables
di "Age distribution:"
summarize age, detail

di "Sex distribution:"
tab sex, missing

********************************************************************************
* Clean and prepare variables
********************************************************************************

* Create smoking outcome variable
gen ever_smoked = .
replace ever_smoked = 0 if smokev == 1  // Never smoked
replace ever_smoked = 1 if smokev == 2  // Ever smoked 100+ cigarettes
label variable ever_smoked "Ever smoked 100+ cigarettes"
label values ever_smoked yesno

* Note: Health status variables not available in this dataset
* Analysis will focus on age, sex, and time trends

* First, explore the smoking variable
tab smokev ever_smoked, missing

********************************************************************************
* Question 1: Smoking Trends Over Time
********************************************************************************

di "========== QUESTION 1: SMOKING TRENDS ANALYSIS =========="

* Calculate smoking prevalence by year
preserve

* First check if we have reasonable sample sizes per year
bysort year: gen n_year = _N
di "Sample sizes by year:"
tabstat n_year, by(year) stat(n) format(%8.0f)

* Calculate smoking prevalence
collapse (mean) smoking_prev = ever_smoked (count) n = ever_smoked if ever_smoked != ., by(year)

* Check if we have data for all years
di _newline(1)
di "Years with smoking prevalence data:"
count
di "Number of years with data: " r(N)

* Display the trend data (limit to manageable output)
di _newline(1)
di "Smoking prevalence by year:"
list year smoking_prev n, separator(5)

* Create trend plot
twoway (scatter smoking_prev year, mcolor(red) msize(medium)) ///
       (line smoking_prev year, lcolor(red) lwidth(medium)) ///
       (lfit smoking_prev year, lcolor(blue) lpattern(dash)), ///
       title("Smoking Trends: Ever Smoked 100+ Cigarettes", size(medium)) ///
       subtitle("NHIS Data, Extended Time Period", size(small)) ///
       xtitle("Year") ytitle("Proportion Ever Smoked") ///
       ylabel(0(0.05)0.7, format(%4.2f)) ///
       legend(order(1 "Data Points" 2 "Trend Line" 3 "Linear Fit")) ///
       note("Data: NHIS IPUMS Extract, Adults with non-missing smoking status") ///
       scheme(s2color)

graph export "smoking_trend_plot.png", replace width(800) height(600)
di _newline(1) "Smoking trend plot saved as: smoking_trend_plot.png"

restore

********************************************************************************
* Question 2: Statistical Tests of Trends
********************************************************************************

di _newline(3)
di "========== QUESTION 2: STATISTICAL TREND TESTS =========="

* Test 1: Linear time trend
di _newline(1) "Test 1: Linear time trend regression"
gen year_centered = year - 1997
reg ever_smoked year_centered

local linear_coef = _b[year_centered]
local linear_p = 2*ttail(e(df_r), abs(_b[year_centered]/_se[year_centered]))

di _newline(1) "Linear trend coefficient: " %8.5f `linear_coef' " per year"
di "Linear trend p-value: " %6.4f `linear_p'

if `linear_p' < 0.05 {
    if `linear_coef' < 0 {
        di "Interpretation: Significant declining trend in smoking prevalence over time."
    }
    else {
        di "Interpretation: Significant increasing trend in smoking prevalence over time."
    }
}
else {
    di "Interpretation: No significant linear trend in smoking prevalence over time."
}

********************************************************************************
* Question 3: Demographic Analysis
********************************************************************************

di _newline(3)
di "========== QUESTION 3: DEMOGRAPHIC ANALYSIS =========="

* Smoking by sex
di _newline(1) "Smoking prevalence by sex:"
tab female ever_smoked, row

* Smoking by age groups
gen age_group = .
replace age_group = 1 if age >= 18 & age <= 34
replace age_group = 2 if age >= 35 & age <= 54  
replace age_group = 3 if age >= 55 & age <= 74
replace age_group = 4 if age >= 75

label define age_lbl 1 "18-34" 2 "35-54" 3 "55-74" 4 "75+"
label values age_group age_lbl

di _newline(1) "Smoking prevalence by age group:"
tab age_group ever_smoked, row

* Multiple regression with demographic controls
di _newline(1) "Regression with demographic controls:"
reg ever_smoked year_centered age female

* Test for gender differences in trends
gen female_x_year = female * year_centered
reg ever_smoked year_centered age female female_x_year

di _newline(1) "Testing gender differences in smoking trends:"
test female_x_year

********************************************************************************
* Summary and Conclusions  
********************************************************************************

di "========== SUMMARY AND CONCLUSIONS =========="
di _newline(1)
di "KEY FINDINGS:"
di "1. Smoking trends analyzed over extended time period"
di "2. Linear trend test provides evidence for temporal changes"
di "3. Demographic differences in smoking patterns identified"
di "4. Gender differences in trends tested"
di _newline(1)
di "ANALYSIS NOTES:"
di "- Dataset contains demographics (age, sex) and smoking status"
di "- No K6 psychological variables available in this dataset"
di "- Focus on basic smoking epidemiology and trends"

* Save final dataset
save "nhis_smoking_trends_analysis.dta", replace

di _newline(1)
di "Analysis complete. Dataset saved as nhis_smoking_trends_analysis.dta"