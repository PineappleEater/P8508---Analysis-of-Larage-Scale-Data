********************************************************************************
* COMPLETE STATA TUTORIAL
* Based on Large-Scale Data Analysis Course (Sessions 1-7 & Homework 1-3)
*
* Description: This tutorial covers all important Stata techniques from basics to advanced
* Each section can be run independently, recommended to study in order
*
* Author: Based on P8508 Course Materials
* Date: 2025
********************************************************************************

* Table of Contents:
* Part 1: Basic Setup & Data Import
* Part 2: Data Inspection & Exploration
* Part 3: Variable Creation & Transformation
* Part 4: Data Merging
* Part 5: Data Reshaping
* Part 6: String Manipulation
* Part 7: Date/Time Handling
* Part 8: Descriptive Statistics
* Part 9: Regression Analysis
* Part 10: Visualization
* Part 11: Advanced Techniques


********************************************************************************
* PART 1: BASIC SETUP & DATA IMPORT
********************************************************************************

/*------------------------------------------------------------------------------
  1.1 Standard Setup - Should be included at the beginning of every do file
------------------------------------------------------------------------------*/

clear all                    // Clear all data from memory
set more off                // Disable output pause (important!)

* Set working directory to midterm folder
cd "C:\Users\l1697\OneDrive\Desktop\Academic\Biostats Courses\Larage Scale Data\midterm"

* Start log recording
capture log close           // Close any open log
log using tutorial_log.log, replace

di "=========================================="
di "  STATA COMPLETE TUTORIAL"
di "=========================================="
di ""

/*------------------------------------------------------------------------------
  1.2 Using Stata Built-in Dataset for Demonstration
------------------------------------------------------------------------------*/

* Stata's built-in automobile dataset
sysuse auto, clear
di "Dataset: auto (Stata built-in automobile data)"
di "Observations: " _N
di "Variables: " `: word count `: list _dta[names]''
di ""

/*------------------------------------------------------------------------------
  1.3 Data Import Commands Demonstration (syntax only, not executed)
------------------------------------------------------------------------------*/

di "Common data import commands:"
di ""
di "  // Import SAS data"
di "  import sasxport5 'filename.xpt', clear"
di ""
di "  // Import CSV data"
di "  import delimited 'filename.csv', clear"
di ""
di "  // Import Excel data"
di "  import excel 'filename.xlsx', clear firstrow"
di ""
di "  // Import Stata data"
di "  use filename.dta, clear"
di ""

* Save data (demonstration)
save auto_backup, replace
di "Data saved as: auto_backup.dta"
di ""


********************************************************************************
* PART 2: DATA INSPECTION & EXPLORATION
********************************************************************************

di "=========================================="
di "PART 2: DATA INSPECTION & EXPLORATION"
di "=========================================="
di ""

sysuse auto, clear

/*------------------------------------------------------------------------------
  2.1 Basic Viewing Commands
------------------------------------------------------------------------------*/

di "--- 2.1 View first 10 rows ---"
list make price mpg weight in 1/10
di ""

di "--- 2.2 Variable Information ---"
describe price mpg weight foreign
di ""

di "--- 2.3 Check Variable Types ---"
* Create a string variable for demonstration
gen make_str = make
describe make make_str
di ""

/*------------------------------------------------------------------------------
  2.2 Frequency Statistics
------------------------------------------------------------------------------*/

di "--- 2.4 Frequency Table (including missing) ---"
tab foreign, missing
di ""

di "--- 2.5 No labels (show numeric codes) ---"
tab foreign, nolabel
di ""

di "--- 2.6 Two-way Frequency Table (row percentages) ---"
tab foreign rep78, row missing
di ""

/*------------------------------------------------------------------------------
  2.3 Continuous Variable Statistics
------------------------------------------------------------------------------*/

di "--- 2.7 Basic Statistical Summary ---"
summarize price mpg weight
di ""

di "--- 2.8 Detailed Statistics (with percentiles) ---"
summarize price, detail
di ""


********************************************************************************
* PART 3: VARIABLE CREATION & TRANSFORMATION
********************************************************************************

di "=========================================="
di "PART 3: VARIABLE CREATION & TRANSFORMATION"
di "=========================================="
di ""

sysuse auto, clear

/*------------------------------------------------------------------------------
  3.1 Basic Variable Generation (gen)
------------------------------------------------------------------------------*/

di "--- 3.1 Creating New Variables ---"

* Create empty variable
gen price_category = .

* Conditional assignment
replace price_category = 1 if price < 5000 & price != .
replace price_category = 2 if price >= 5000 & price < 10000
replace price_category = 3 if price >= 10000 & price != .

* Add labels
label define price_lbl 1 "Low (<$5K)" 2 "Medium ($5-10K)" 3 "High (>$10K)"
label values price_category price_lbl
label variable price_category "Price Category"

tab price_category, missing
di ""

di "--- 3.2 One-line Dummy Variable Creation ---"
gen domestic = (foreign == 0) if foreign != .
label variable domestic "Domestic car (1=Yes, 0=No)"
tab domestic foreign, missing
di ""

/*------------------------------------------------------------------------------
  3.2 Using recode
------------------------------------------------------------------------------*/

di "--- 3.3 Using recode for Recoding ---"
recode rep78 (1/2 = 1 "Poor") (3 = 2 "Average") (4/5 = 3 "Good") ///
       (. = .), gen(repair_quality)
tab repair_quality rep78, missing
di ""

/*------------------------------------------------------------------------------
  3.3 Using egen (Extended Generation)
------------------------------------------------------------------------------*/

di "--- 3.4 EGEN: Row Operations ---"

* Create test variables
gen score1 = runiform() * 100
gen score2 = runiform() * 100
gen score3 = runiform() * 100

* Row total
egen total_score = rowtotal(score1 score2 score3)

* Row mean
egen avg_score = rowmean(score1 score2 score3)

* Row max/min
egen max_score = rowmax(score1 score2 score3)
egen min_score = rowmin(score1 score2 score3)

list score1 score2 score3 total_score avg_score in 1/5
di ""

di "--- 3.5 EGEN: Grouped Statistics ---"

* Calculate average price by origin
egen avg_price_by_origin = mean(price), by(foreign)

* Calculate average MPG by repair record
egen avg_mpg_by_repair = mean(mpg), by(rep78)

list foreign price avg_price_by_origin in 1/10
di ""

di "--- 3.6 EGEN: String Concatenation ---"
egen make_origin = concat(make foreign), punct(" | Origin:")
list make foreign make_origin in 1/5
di ""

/*------------------------------------------------------------------------------
  3.4 String to Numeric Conversion
------------------------------------------------------------------------------*/

di "--- 3.7 String to Numeric (destring) ---"

* Create string numeric variable
gen price_str = string(price)
describe price price_str

* Convert back to numeric
destring price_str, gen(price_num)
describe price_num

* Compare
list price price_str price_num in 1/5
di ""

/*------------------------------------------------------------------------------
  3.5 Numeric to Categorical (encode)
------------------------------------------------------------------------------*/

di "--- 3.8 Encode String to Numeric (encode) ---"
encode make, gen(make_numeric)
describe make make_numeric
tab make_numeric in 1/10
di ""


********************************************************************************
* PART 4: DATA MERGING
********************************************************************************

di "=========================================="
di "PART 4: DATA MERGING"
di "=========================================="
di ""

/*------------------------------------------------------------------------------
  4.1 Prepare Demonstration Data
------------------------------------------------------------------------------*/

di "--- 4.1 Create Demonstration Datasets ---"

* Main dataset: Basic car information
sysuse auto, clear
keep make price mpg
gen car_id = _n
save merge_demo_main, replace
di "Main dataset created (merge_demo_main.dta)"
di ""

* Using dataset: Car weight information (partial records only)
sysuse auto, clear
keep make weight
gen car_id = _n
* Keep only first 60 records
keep if car_id <= 60
save merge_demo_using, replace
di "Using dataset created (merge_demo_using.dta)"
di ""

/*------------------------------------------------------------------------------
  4.2 One-to-One Merge (1:1)
------------------------------------------------------------------------------*/

di "--- 4.2 One-to-One Merge (1:1) ---"

use merge_demo_main, clear
merge 1:1 car_id using merge_demo_using

* Check merge results
di "Merge results:"
tab _merge
/*
  _merge values:
    1 = master only
    2 = using only
    3 = matched
*/

list make price weight _merge in 1/10
di ""

* Clean up
keep if _merge == 3
drop _merge

/*------------------------------------------------------------------------------
  4.3 Many-to-One Merge (m:1) Demonstration
------------------------------------------------------------------------------*/

di "--- 4.3 Many-to-One Merge (m:1) Demonstration ---"

* Create "many" dataset: Multiple purchase records
clear
input car_id purchase_id str20 purchase_date
1 1 "2020-01-15"
1 2 "2022-03-20"
2 1 "2021-06-10"
3 1 "2019-11-05"
3 2 "2020-05-15"
3 3 "2023-01-20"
end
save merge_demo_purchases, replace

* Create "one" dataset: Car information
clear
input car_id str20 car_name price
1 "Toyota Camry" 25000
2 "Honda Accord" 28000
3 "Ford Fusion" 24000
end
save merge_demo_cars, replace

* Perform m:1 merge
use merge_demo_purchases, clear
merge m:1 car_id using merge_demo_cars

di "m:1 Merge results:"
list car_id purchase_id car_name price _merge
drop _merge
di ""


********************************************************************************
* PART 5: DATA RESHAPING
********************************************************************************

di "=========================================="
di "PART 5: DATA RESHAPING"
di "=========================================="
di ""

/*------------------------------------------------------------------------------
  5.1 Wide to Long Format
------------------------------------------------------------------------------*/

di "--- 5.1 Wide to Long Format ---"

* Create wide format data
clear
input patient_id bp_round1 bp_round2 bp_round3 hr_round1 hr_round2 hr_round3
101 120 118 115 72 70 68
102 135 130 128 80 78 76
103 110 112 114 65 66 67
end

di "Original data (wide format):"
list
di ""

* Reshape to long format
reshape long bp_round hr_round, i(patient_id) j(round)

di "Reshaped data (long format):"
list, sepby(patient_id)
di ""

save reshape_long_demo, replace

/*------------------------------------------------------------------------------
  5.2 Long to Wide Format
------------------------------------------------------------------------------*/

di "--- 5.2 Long to Wide Format ---"

* Use the long format data from above
use reshape_long_demo, clear

di "Current data (long format):"
list in 1/6
di ""

* Reshape back to wide format
reshape wide bp_round hr_round, i(patient_id) j(round)

di "Reshaped data (wide format):"
list
di ""


********************************************************************************
* PART 6: STRING MANIPULATION
********************************************************************************

di "=========================================="
di "PART 6: STRING MANIPULATION"
di "=========================================="
di ""

sysuse auto, clear

/*------------------------------------------------------------------------------
  6.1 Case Conversion
------------------------------------------------------------------------------*/

di "--- 6.1 String Case Conversion ---"

gen make_upper = strupper(make)
gen make_lower = strlower(make)
gen make_proper = strproper(make)

list make make_upper make_lower make_proper in 1/5
di ""

/*------------------------------------------------------------------------------
  6.2 String Extraction (substr)
------------------------------------------------------------------------------*/

di "--- 6.2 String Extraction (substr) ---"
di "Important: Position starts from 1, not 0!"
di ""

* Extract first 5 characters
gen make_first5 = substr(make, 1, 5)

* Extract 4 characters starting from position 3
gen make_mid = substr(make, 3, 4)

list make make_first5 make_mid in 1/10
di ""

di "Common mistake example:"
di "  Wrong: substr(string, 2, 1)  // Extracts 2nd character"
di "  Right: substr(string, 1, 2)  // Extracts first 2 characters"
di ""

/*------------------------------------------------------------------------------
  6.3 String Matching (regex)
------------------------------------------------------------------------------*/

di "--- 6.3 String Pattern Matching ---"

* Create categorical variable
gen car_type = ""
replace car_type = "Buick" if regexm(make, "Buick")
replace car_type = "Cadillac" if regexm(make, "Cad")
replace car_type = "Chevrolet" if regexm(make, "Chev")
replace car_type = "Ford" if regexm(make, "Ford")
replace car_type = "Other" if car_type == ""

tab car_type
di ""

/*------------------------------------------------------------------------------
  6.4 String Splitting (split)
------------------------------------------------------------------------------*/

di "--- 6.4 String Splitting ---"

* Create test string
gen test_string = "NY_2023_Jan"
split test_string, gen(part) parse("_")

list test_string part1 part2 part3 in 1/5
di ""


********************************************************************************
* PART 7: DATE/TIME HANDLING
********************************************************************************

di "=========================================="
di "PART 7: DATE/TIME HANDLING"
di "=========================================="
di ""

/*------------------------------------------------------------------------------
  7.1 Date Conversion
------------------------------------------------------------------------------*/

di "--- 7.1 String to Date Conversion ---"

clear
input str20 admit_date_str str20 discharge_date_str
"01/15/2023" "01/20/2023"
"02/10/2023" "02/15/2023"
"03/05/2023" "03/12/2023"
end

* Convert to date
gen admit_date = date(admit_date_str, "MDY")
gen discharge_date = date(discharge_date_str, "MDY")

* Format display
format admit_date %td
format discharge_date %td

list admit_date_str admit_date discharge_date
di ""

/*------------------------------------------------------------------------------
  7.2 Date Calculations
------------------------------------------------------------------------------*/

di "--- 7.2 Date Calculations (Length of Stay) ---"

gen length_of_stay = discharge_date - admit_date
label variable length_of_stay "Length of Stay (days)"

list admit_date discharge_date length_of_stay
di ""

/*------------------------------------------------------------------------------
  7.3 Date-Time (with hours/minutes/seconds)
------------------------------------------------------------------------------*/

di "--- 7.3 Date-Time Conversion ---"

clear
input str30 datetime_str
"2023-01-15 14:30:00"
"2023-02-20 09:15:30"
"2023-03-10 16:45:00"
end

* Convert to datetime
gen datetime = clock(datetime_str, "YMD hms")
format datetime %tc

list datetime_str datetime
di ""

/*------------------------------------------------------------------------------
  7.4 Extract Date Components
------------------------------------------------------------------------------*/

di "--- 7.4 Extract Year/Month/Day ---"

gen year_value = year(datetime)
gen month_value = month(datetime)
gen day_value = day(datetime)

list datetime year_value month_value day_value
di ""


********************************************************************************
* PART 8: DESCRIPTIVE STATISTICS
********************************************************************************

di "=========================================="
di "PART 8: DESCRIPTIVE STATISTICS"
di "=========================================="
di ""

sysuse auto, clear

/*------------------------------------------------------------------------------
  8.1 Tabstat - Flexible Statistical Tables
------------------------------------------------------------------------------*/

di "--- 8.1 Tabstat Basic Usage ---"
tabstat price mpg weight, stat(n mean sd min p50 max) col(stat) format(%9.2f)
di ""

di "--- 8.2 Grouped Statistics ---"
tabstat price mpg, by(foreign) stat(n mean sd) format(%9.2f)
di ""

/*------------------------------------------------------------------------------
  8.2 Grouped Operations
------------------------------------------------------------------------------*/

di "--- 8.3 Bysort to Create Within-Group Sequence ---"

* Sort by origin and create sequence number
bysort foreign: gen obs_num = _n
bysort foreign: gen total_obs = _N

list foreign make obs_num total_obs in 1/10
di ""

/*------------------------------------------------------------------------------
  8.3 Duplicates Removal
------------------------------------------------------------------------------*/

di "--- 8.4 Check Duplicates ---"

* Create some duplicate values for demonstration
gen price_rounded = round(price, 1000)

duplicates report price_rounded
di ""

di "--- 8.5 Tag Duplicates ---"
duplicates tag price_rounded, gen(is_duplicate)
tab is_duplicate
di ""


********************************************************************************
* PART 9: REGRESSION ANALYSIS
********************************************************************************

di "=========================================="
di "PART 9: REGRESSION ANALYSIS"
di "=========================================="
di ""

sysuse auto, clear

/*------------------------------------------------------------------------------
  9.1 Simple Linear Regression
------------------------------------------------------------------------------*/

di "--- 9.1 Simple Linear Regression ---"
reg price mpg
di ""

di "--- 9.2 Regression with Robust Standard Errors ---"
reg price mpg, robust
di ""

/*------------------------------------------------------------------------------
  9.2 Multiple Regression
------------------------------------------------------------------------------*/

di "--- 9.3 Multiple Linear Regression ---"
reg price mpg weight length
di ""

di "--- 9.4 Include Categorical Variable (i. prefix) ---"
reg price mpg weight i.foreign
di ""

di "--- 9.5 Include Multi-category Variable ---"
reg price mpg i.rep78 i.foreign
di ""

/*------------------------------------------------------------------------------
  9.3 Interaction Effects
------------------------------------------------------------------------------*/

di "--- 9.6 Categorical Interaction (foreign × rep78) ---"
reg price mpg i.foreign##i.rep78, robust
di ""

di "--- 9.7 Categorical × Continuous Interaction (foreign × weight) ---"
di "Important: Continuous variable must use c. prefix!"
reg price i.foreign##c.weight mpg, robust
di ""

/*------------------------------------------------------------------------------
  9.4 Margins - Predicted Values
------------------------------------------------------------------------------*/

di "--- 9.8 Calculate Marginal Effects ---"
reg price mpg weight i.foreign
margins foreign
di ""

/*------------------------------------------------------------------------------
  9.5 Logistic Regression
------------------------------------------------------------------------------*/

di "--- 9.9 Logistic Regression ---"

* Create binary outcome variable
gen expensive = (price > 6000) if price != .

* Logistic regression (report odds ratios)
logistic expensive mpg weight i.foreign
di ""

di "--- 9.10 Predicted Probabilities from Logistic Regression ---"
margins foreign
di ""

/*------------------------------------------------------------------------------
  9.6 Hypothesis Testing
------------------------------------------------------------------------------*/

di "--- 9.11 Hypothesis Testing ---"
reg price mpg weight i.foreign
test mpg weight
di ""


********************************************************************************
* PART 10: VISUALIZATION
********************************************************************************

di "=========================================="
di "PART 10: VISUALIZATION"
di "=========================================="
di ""

sysuse auto, clear

/*------------------------------------------------------------------------------
  10.1 Histograms
------------------------------------------------------------------------------*/

di "--- 10.1 Create Histogram ---"

histogram price, bin(20) frequency ///
    title("Price Distribution") ///
    subtitle("1978 Automobile Data") ///
    xtitle("Price (USD)") ytitle("Frequency") ///
    scheme(s2color)

graph export "tutorial_histogram.png", replace
di "Histogram saved: tutorial_histogram.png"
di ""

di "--- 10.2 Overlaid Histogram (Compare Domestic vs Import) ---"

histogram price, by(foreign) ///
    title("Price by Origin") ///
    scheme(s2color)

graph export "tutorial_histogram_by_group.png", replace
di "Grouped histogram saved"
di ""

/*------------------------------------------------------------------------------
  10.2 Scatter Plots
------------------------------------------------------------------------------*/

di "--- 10.3 Scatter Plot ---"

scatter price mpg, ///
    mcolor(navy) msize(medium) ///
    title("Price vs MPG") ///
    xtitle("Miles per Gallon") ytitle("Price (USD)") ///
    scheme(s2color)

graph export "tutorial_scatter.png", replace
di "Scatter plot saved"
di ""

/*------------------------------------------------------------------------------
  10.3 Line Graphs
------------------------------------------------------------------------------*/

di "--- 10.4 Line Graph (Create Trend Data First) ---"

* Create average price by weight
egen avg_price_by_weight = mean(price), by(weight)
sort weight

twoway line avg_price_by_weight weight, ///
    lcolor(red) lwidth(medium) ///
    title("Average Price by Weight") ///
    xtitle("Weight (lbs)") ytitle("Average Price") ///
    scheme(s2color)

graph export "tutorial_line.png", replace
di "Line graph saved"
di ""

/*------------------------------------------------------------------------------
  10.4 Combined Charts
------------------------------------------------------------------------------*/

di "--- 10.5 Scatter Plot + Fitted Line ---"

twoway (scatter price mpg, mcolor(navy%50)) ///
       (lfit price mpg, lcolor(red) lwidth(thick)), ///
       title("Price vs MPG with Fitted Line") ///
       legend(order(1 "Observed" 2 "Linear Fit")) ///
       scheme(s2color)

graph export "tutorial_combined.png", replace
di "Combined chart saved"
di ""


********************************************************************************
* PART 11: ADVANCED TECHNIQUES
********************************************************************************

di "=========================================="
di "PART 11: ADVANCED TECHNIQUES"
di "=========================================="
di ""

sysuse auto, clear

/*------------------------------------------------------------------------------
  11.1 Local Macros
------------------------------------------------------------------------------*/

di "--- 11.1 Using Local Macros ---"

local mean_price = 6165
local sd_price = 2949

di "Average car price: $" %9.2f `mean_price'
di "Standard deviation: $" %9.2f `sd_price'
di ""

* Extract results from regression
reg price mpg
local coef_mpg = _b[mpg]
local se_mpg = _se[mpg]
local ci_lower = `coef_mpg' - 1.96*`se_mpg'
local ci_upper = `coef_mpg' + 1.96*`se_mpg'

di "MPG coefficient: " %8.2f `coef_mpg'
di "95% CI: [" %8.2f `ci_lower' ", " %8.2f `ci_upper' "]"
di ""

/*------------------------------------------------------------------------------
  11.2 Loops
------------------------------------------------------------------------------*/

di "--- 11.2 Forvalues Loop ---"

forvalues i = 1/5 {
    di "This is iteration `i'"
}
di ""

di "--- 11.3 Foreach Loop (Iterate Through Variables) ---"

foreach var in price mpg weight length {
    quietly summarize `var'
    di "Mean of `var': " %10.2f r(mean)
}
di ""

/*------------------------------------------------------------------------------
  11.3 Conditional Execution
------------------------------------------------------------------------------*/

di "--- 11.4 Conditional Statements ---"

local sample_size = _N

if `sample_size' > 50 {
    di "Sample size is large enough (N = `sample_size')"
}
else {
    di "Sample size is small (N = `sample_size')"
}
di ""

/*------------------------------------------------------------------------------
  11.4 Preserve & Restore
------------------------------------------------------------------------------*/

di "--- 11.5 Preserve & Restore ---"

* Save current data state
preserve

* Perform temporary analysis
keep if foreign == 1
di "Keeping only imported cars: " _N " observations"

* Restore original data
restore

di "After restore, observations: " _N
di ""

/*------------------------------------------------------------------------------
  11.5 Quietly & Capture
------------------------------------------------------------------------------*/

di "--- 11.6 Quietly (Suppress Output) ---"

quietly summarize price
local mean_price = r(mean)
di "Mean price calculated using quietly: $" %9.2f `mean_price'
di ""

di "--- 11.7 Capture (Catch Errors) ---"

capture confirm variable nonexistent_var
if _rc != 0 {
    di "Variable does not exist, creating new variable"
    gen nonexistent_var = .
}
else {
    di "Variable already exists"
}
di ""


********************************************************************************
* PART 12: COMPLETE WORKFLOW EXAMPLE
********************************************************************************

di "=========================================="
di "PART 12: COMPLETE ANALYSIS WORKFLOW EXAMPLE"
di "=========================================="
di ""

/*------------------------------------------------------------------------------
  Research Question: Analyze factors affecting car prices
------------------------------------------------------------------------------*/

sysuse auto, clear

di "--- STEP 1: Data Check ---"
describe
summarize
di ""

di "--- STEP 2: Create Analysis Variables ---"

* Create price category
gen price_high = (price > 6000) if price != .
label variable price_high "High Price (>$6000)"

* Create efficiency category
gen efficient = (mpg > 20) if mpg != .
label variable efficient "Fuel Efficient (>20 MPG)"

* Create weight category
gen heavy = (weight > 3000) if weight != .
label variable heavy "Heavy Car (>3000 lbs)"

di "--- STEP 3: Descriptive Statistics ---"
tabstat price mpg weight, by(foreign) stat(n mean sd) col(stat) format(%9.2f)
di ""

di "--- STEP 4: Bivariate Analysis ---"
tab foreign price_high, row chi2
di ""

di "--- STEP 5: Multiple Regression ---"
reg price mpg weight i.foreign, robust
di ""

di "--- STEP 6: Test Specific Coefficients ---"
test mpg weight
di ""

di "--- STEP 7: Predict Marginal Effects ---"
margins foreign
di ""

di "--- STEP 8: Visualization ---"
scatter price mpg, by(foreign) ///
    mcolor(navy) ///
    title("Price vs MPG by Origin") ///
    scheme(s2color)

graph export "tutorial_final_analysis.png", replace
di "Final analysis chart saved"
di ""


********************************************************************************
* SUMMARY & COMMON MISTAKES REMINDER
********************************************************************************

di "=========================================="
di "  TUTORIAL COMPLETED!"
di "=========================================="
di ""

di "Key Points Review:"
di ""
di "1. Missing Value Handling:"
di "   - Always use: if var != ."
di "   - Missing value . is treated as infinity in Stata"
di ""
di "2. substr() Position:"
di "   - substr(string, 1, 2) extracts first 2 characters"
di "   - substr(string, 2, 1) extracts 2nd character"
di "   - Position starts from 1, not 0!"
di ""
di "3. Interactions:"
di "   - Categorical × Categorical: i.var1#i.var2"
di "   - Categorical × Continuous: i.var1#c.var2 (c. prefix is important!)"
di ""
di "4. Merge Checking:"
di "   - Always check _merge"
di "   - tab _merge"
di ""
di "5. Collapse Warning:"
di "   - collapse permanently changes data"
di "   - Use save or preserve before collapsing"
di ""
di "6. Date Formatting:"
di "   - Must format after conversion"
di "   - format date_var %td"
di "   - format datetime_var %tc"
di ""

di "Generated files:"
di "  - tutorial_log.log (log file)"
di "  - tutorial_histogram.png"
di "  - tutorial_scatter.png"
di "  - tutorial_line.png"
di "  - tutorial_combined.png"
di "  - tutorial_final_analysis.png"
di ""

di "Recommended next steps:"
di "  1. Re-run this tutorial and understand each command"
di "  2. Modify parameters and observe changes in results"
di "  3. Apply these techniques to your own data"
di ""

* Close log
log close

di "Tutorial completed. Log file saved."
