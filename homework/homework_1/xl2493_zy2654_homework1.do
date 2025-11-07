********************************************************************************
* Assignment 1 - BMI in NHANES
* Analysis of Large-Scale Data 2025
* Name(s): Xuange Liang [xl3493], Zexuan Yan [zy2654]
********************************************************************************

clear all
set more off

********************************************************************************
* Import and merge NHANES 2017-2018 data
********************************************************************************
* Import body measures data
import sasxport5 "https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2017/DataFiles/BMX_J.xpt", clear
save NHANES2017_bmx, replace

* Import demographics data  
import sasxport5 "https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2017/DataFiles/DEMO_J.xpt", clear
save NHANES2017_demo, replace

* Merge the two datasets
use NHANES2017_demo, clear
merge 1:1 seqn using NHANES2017_bmx
drop _merge
save NHANES2017_bmx_demo, replace

********************************************************************************
* Question 1: Summary statistics on BMI by age group
********************************************************************************
* Create age group variable (20+ vs under 20)
gen age_group = .
replace age_group = 1 if ridageyr >= 20 & ridageyr != .
replace age_group = 0 if ridageyr < 20 & ridageyr != .

* Label the age groups for clarity
label define age_lbl 0 "Under 20 years" 1 "20 years or older"
label values age_group age_lbl

* Report summary statistics including range
tabstat bmxbmi, by(age_group) stat(n mean sd min p50 max) col(stat) format(%9.2f)

* Calculate range separately
preserve
collapse (min) min_bmi=bmxbmi (max) max_bmi=bmxbmi, by(age_group)
gen range_bmi = max_bmi - min_bmi
di _newline(1)
di "Range of BMI by age group:"
list age_group range_bmi
restore

********************************************************************************
* Question 2: Create obesity class variable
********************************************************************************
* Create obesity class variable for 20+ years old, non-pregnant individuals
gen obesity_class = .

* Apply CDC BMI categories only for eligible population
replace obesity_class = 0 if bmxbmi < 18.5 & ridageyr >= 20 & ridexprg != 1 & bmxbmi != .
replace obesity_class = 1 if bmxbmi >= 18.5 & bmxbmi < 25 & ridageyr >= 20 & ridexprg != 1
replace obesity_class = 2 if bmxbmi >= 25 & bmxbmi < 30 & ridageyr >= 20 & ridexprg != 1  
replace obesity_class = 3 if bmxbmi >= 30 & bmxbmi < 35 & ridageyr >= 20 & ridexprg != 1
replace obesity_class = 4 if bmxbmi >= 35 & bmxbmi < 40 & ridageyr >= 20 & ridexprg != 1
replace obesity_class = 5 if bmxbmi >= 40 & ridageyr >= 20 & ridexprg != 1 & bmxbmi != .

* Label obesity classes
label define obesity_lbl 0 "Underweight" 1 "Healthy Weight" 2 "Overweight" ///
    3 "Class 1 Obesity" 4 "Class 2 Obesity" 5 "Class 3 Obesity (Severe)"
label values obesity_class obesity_lbl

* Report shares including missing category
tab obesity_class, missing

********************************************************************************
* Question 3: Create poverty dummy variable
********************************************************************************
* Create dummy for at or below 200% FPL
gen below_200fpl = .
replace below_200fpl = 1 if indfmpir <= 2 & indfmpir != .
replace below_200fpl = 0 if indfmpir > 2 & indfmpir != .

* Label the variable
label define fpl_lbl 0 "Above 200% FPL" 1 "At or below 200% FPL"  
label values below_200fpl fpl_lbl

* Report shares - using all subjects as requested
tab below_200fpl

********************************************************************************
* Question 4: T-test of BMI by poverty status
********************************************************************************
* Focus on 20+ years old, non-pregnant individuals
preserve
keep if ridageyr >= 20 & ridexprg != 1

* Report mean BMI by poverty status
tabstat bmxbmi, by(below_200fpl) stat(n mean sd)

* Perform t-test
ttest bmxbmi, by(below_200fpl)

* Store and display results in 2 sentences
local diff = r(mu_2) - r(mu_1)
local pval = r(p)

di "ANSWER:"
di "The difference in mean BMI is " %5.3f `diff' " kg/m² (those at/below 200% FPL have higher BMI)."
if `pval' < 0.05 {
    di "This difference is statistically significant at α=0.05 (p=" %5.4f `pval' ")."
}
else {
    di "This difference is not statistically significant at α=0.05 (p=" %5.4f `pval' ")."
}

restore

********************************************************************************
* Question 5: Linear regression of BMI on poverty dummy
********************************************************************************
preserve
keep if ridageyr >= 20 & ridexprg != 1

* Run regression with 95% CI
reg bmxbmi below_200fpl, level(95)

* Get confidence intervals properly
local coef = _b[below_200fpl]
local se = _se[below_200fpl]
local pval = 2*ttail(e(df_r), abs(_b[below_200fpl]/_se[below_200fpl]))
local ci_lower = `coef' - invttail(e(df_r), 0.025)*`se'
local ci_upper = `coef' + invttail(e(df_r), 0.025)*`se'

di _newline(2)
di "Coefficient: " %5.3f `coef'
di "P-value: " %5.4f `pval'
di "95% CI: [" %5.3f `ci_lower' ", " %5.3f `ci_upper' "]"

di _newline(1)
di "Comparison: The coefficient (" %5.3f `coef' ") equals the t-test difference."
di "Both p-values equal " %5.4f `pval' " because t-test = regression with binary predictor."

restore

********************************************************************************
* Question 6: Multiple regression with additional covariates
********************************************************************************
* Create additional variables needed for regression
gen female = .
replace female = 1 if riagendr == 2
replace female = 0 if riagendr == 1

gen us_born = .
replace us_born = 1 if dmdborn4 == 1 
replace us_born = 0 if dmdborn4 == 2
* Note: excludes refused(77), don't know(99), missing(.)

* Clean education variable - recode refused/don't know as missing
gen education = dmdeduc2
replace education = . if inlist(dmdeduc2, 7, 9, .)

preserve
* Keep only eligible subjects for this analysis
keep if ridageyr >= 20 & ridexprg != 1

* Run multiple regression
reg bmxbmi below_200fpl female us_born i.education ridageyr, level(95)

di _newline(1)
di "Multiple regression results with 95% confidence intervals reported above."
di "Note: Education categories - 1: <9th grade, 2: 9-11th grade, 3: HS grad/GED,"
di "4: Some college/AA, 5: College graduate or above"

restore

********************************************************************************
* Question 7: Logistic regression for obesity
********************************************************************************
preserve
keep if ridageyr >= 20 & ridexprg != 1

* Create obesity dummy (obese vs not obese)
gen obese = .
replace obese = 0 if inlist(obesity_class, 0, 1, 2)  // Not obese
replace obese = 1 if inlist(obesity_class, 3, 4, 5)  // Obese

* Create variables as in Q6
gen female_q7 = (riagendr == 2) if riagendr != .
gen us_born_q7 = (dmdborn4 == 1) if inlist(dmdborn4, 1, 2)
gen education_q7 = dmdeduc2
replace education_q7 = . if inlist(dmdeduc2, 7, 9, .)

* Run logistic regression
logit obese below_200fpl female_q7 us_born_q7 i.education_q7 ridageyr

* Display with odds ratios for interpretation
di _newline(1)
di "Logistic Regression with Odds Ratios:"
logit obese below_200fpl female_q7 us_born_q7 i.education_q7 ridageyr, or

* Get the OR for education level 5 vs 1 (reference)
local or_edu5 = exp(_b[5.education_q7])

di _newline(1)
di "INTERPRETATION (1 sentence):"
di "Individuals with college degree or above have " %5.3f `or_edu5' " times the odds of being obese"
di "compared to those with less than 9th grade education, controlling for other factors."

restore

********************************************************************************
* Question 8: Top-coding analysis
********************************************************************************

di "========== QUESTION 8: Top-coding Analysis =========="

* Check for top-coding in age and income-to-poverty ratio
sum ridageyr, detail
local age_max = r(max)
sum indfmpir, detail
local fpl_max = r(max)

di "ANSWERS (1 sentence each):"
di "(1) Variables with top-coding: ridageyr at " `age_max' " years, indfmpir at " `fpl_max' "."
di "(2) NHANES uses top-coding to protect participant privacy and prevent identification."
di "(3) Top-coding biases mean estimates downward and reduces variance in the affected variables."
di "(4) Alternative method: interval censoring or multiple imputation for censored values."

********************************************************************************
* Question 9: Waist circumference vs BMI availability
********************************************************************************

di "========== QUESTION 9: Waist Circumference vs BMI Availability =========="

* Count valid data for all subjects
count if bmxwaist != .
local waist_n = r(N)
count if bmxbmi != .
local bmi_n = r(N)

di "Number of subjects with valid waist circumference: " `waist_n'
di "Number of subjects with valid BMI: " `bmi_n'

* Check correlation where both available
pwcorr bmxwaist bmxbmi if bmxwaist != . & bmxbmi != ., sig

di _newline(1)
di "ANSWER (questions to ask when deciding whether to use waist circumference):"
di "(1) Is missingness random or systematic (e.g., related to obesity/age/gender)?"
di "(2) Does waist circumference correlate strongly with BMI and health outcomes?"
di "(3) Are there measurement protocol differences affecting data availability?"
di "(4) Would using waist circumference instead of BMI change our study conclusions about obesity patterns?"

* Save final dataset
save NHANES2017_final, replace