# Stata Cheat Sheet for Midterm - Part 2 Reference

**Large Scale Data Analysis | Complete Reference Guide**

---

## Table of Contents

1. [Basic Setup & Data Import](#1-basic-setup--data-import)
2. [Data Exploration](#2-data-exploration)
3. [Variable Creation](#3-variable-creation)
4. [Missing Values](#4-missing-values)
5. [String Variables](#5-string-variables)
6. [Data Merging](#6-data-merging)
7. [Data Reshaping](#7-data-reshaping)
8. [Regression Analysis](#8-regression-analysis)
9. [Verification & Validation](#9-verification--validation)
10. [Common Workflows](#10-common-workflows)
11. [Important Reminders](#11-important-reminders)

---

## 1. Basic Setup & Data Import

### Standard Setup
```stata
// Clear memory and set options
clear all
set more off

// Set working directory
cd "path/to/folder"

// Start logging
capture log close
log using "analysis.log", replace
```

### Import Data
```stata
// Import CSV
import delimited "file.csv", clear

// Import Excel (with first row as variable names)
import excel "file.xlsx", sheet("Sheet1") firstrow clear

// Import SAS XPT
import sasxport5 "file.xpt", clear

// Load Stata file
use "file.dta", clear

// Save data
save "filename.dta", replace
```

> ⚠️ **IMPORTANT**: Always use `clear` or `, clear` option when loading new data to avoid "no; data in memory would be lost" error.

---

## 2. Data Exploration

### Basic Viewing
```stata
// View first 10 rows
list var1 var2 var3 in 1/10

// View specific observations
list if condition

// Browse data (opens data viewer)
browse

// Describe variables
describe
describe var1 var2

// View variable details
codebook varname
```

### Summary Statistics
```stata
// Basic summary
summ varname

// Detailed summary with percentiles
summ varname, d
// Shows: p1, p5, p10, p25, p50, p75, p90, p95, p99

// Multiple variables
summ var1 var2 var3, d
```

### Frequency Tables
```stata
// Frequency table (include missing)
tab varname, m

// Show numeric codes (not labels)
tab varname, nolabel

// Two-way table with row percentages
tab var1 var2, row m

// Two-way table with column percentages
tab var1 var2, col m

// Both row and column percentages
tab var1 var2, row col
```

### Check Data Size
```stata
// Number of observations
display _N

// Number of variables
describe, short
```

---

## 3. Variable Creation

### Generate New Variable
```stata
// Create empty variable
gen newvar = .

// Create with calculation
gen age_squared = age^2

// Create constant
gen constant = 1
```

### Replace Values
```stata
// Replace all values
replace varname = new_value

// Conditional replace
replace var = value if condition
```

> ⚠️ **CRITICAL**: Always protect missing values!
> Use: `if var != .` in conditions
> Missing (.) is treated as **infinity** in Stata.

### Binary Variables (0/1 Flags)

**Most Common in Midterm!**

```stata
// Method 1: Standard approach
gen flag = 1 if condition
replace flag = 0 if !condition

// Method 2: One-liner (if var has no missing)
gen flag = (condition) if var != .

// Example 1: Age >= 18
gen adult = 1 if age >= 18 & age != .
replace adult = 0 if age < 18

// Example 2: High cost (>$50,000)
gen expensive = 1 if cost > 50000 & cost != .
replace expensive = 0 if cost <= 50000

// Example 3: Emergency Department indicator
gen ED_flag = 1 if ed_indicator == "Y"
replace ED_flag = 0 if ed_indicator == "N"

// ✅ VERIFY binary variable (ALWAYS DO THIS!)
summ flag
// Check: mean should be 0-1, min=0, max=1
tab flag, m
```

### Categorical Variables
```stata
// Method 1: Manual creation
gen category = .
replace category = 1 if condition1
replace category = 2 if condition2
replace category = 3 if condition3

// Add value labels
label define cat_lbl 1 "Low" 2 "Medium" 3 "High"
label values category cat_lbl
label variable category "Category description"

// Method 2: recode (more concise)
recode age (0/29=1 "Young") (30/49=2 "Middle") ///
    (50/max=3 "Senior"), gen(age_group)

// Method 3: encode string variable
encode string_var, gen(numeric_var)
// This is VERY useful for admission types, etc.
```

### Top-coding (Capping Outliers)

**Common in cost/spending data!**

```stata
// Step 1: Create clean version
gen cost_clean = cost

// Step 2: Top-code at $1,000,000
replace cost_clean = 1000000 if cost > 1000000 & cost != .

// Step 3: Verify
summ cost, d
summ cost_clean, d
// Check: max of clean version should equal cap
```

### Logarithmic Transformation

**For right-skewed data (costs, income, etc.)**

```stata
// Method 1: Add 1 to avoid log(0)
gen cost_plus1 = cost + 1
gen log_cost = log(cost_plus1)

// Method 2: Only for positive values
gen log_cost = log(cost) if cost > 0
replace log_cost = 0 if cost == 0

// Verify transformation
histogram cost  // Should be right-skewed
histogram log_cost  // Should be more normal
```

### EGEN - Extended Generation

**Very powerful for grouped operations!**

```stata
// Row operations
egen total = rowtotal(var1 var2 var3)
egen mean = rowmean(var1 var2 var3)
egen max = rowmax(var1 var2 var3)
egen min = rowmin(var1 var2 var3)

// Grouped statistics (VERY USEFUL!)
egen mean_by_group = mean(var), by(group_var)

// Example: Average income by county
egen avg_income_county = mean(income), by(county_name)

// Example: Average cost by age group
egen avg_cost_age = mean(totalcosts), by(agegroup)

// Count non-missing in group
egen count_nonmiss = count(var), by(group)

// String concatenation
egen fullname = concat(first last), punct(" ")
```

---

## 4. Missing Values

### Identify Missing Values
```stata
// Count missing
count if varname == .

// Summary shows N
summ varname
// Compare total N vs variable N

// Show missing in frequency table
tab varname, m
```

### Recode Missing Values

**Common in survey data!**

```stata
// Set specific values to missing
replace var = . if var == 99
replace var = . if var == 999
replace var = . if var == -9
replace var = . if var < 0

// Example from BRFSS (common codes)
replace height = . if height == 7777  // Don't know
replace height = . if height == 9999  // Refused
replace weight = . if weight == 7777
replace weight = . if weight == 9999
```

> ⚠️ **Common Mistake**:
> **Wrong**: `replace var = 100 if var > 100`
> This will set missing to 100 because missing (.) > 100!
>
> **Correct**: `replace var = 100 if var > 100 & var != .`

### Create Missing Indicator
```stata
// Flag for missing (one-liner)
gen miss_flag = (varname == .)

// Or explicitly
gen miss_flag = 0
replace miss_flag = 1 if varname == .
```

---

## 5. String Variables

### String to Numeric

**Very common operation!**

```stata
// Basic conversion (force ignores errors)
destring string_var, gen(num_var) force

// Check what couldn't be converted
tab string_var if num_var == .

// Example: Handle "120 +" in length of stay
destring lengthofstay, gen(los_num) force
replace los_num = 120 if lengthofstay == "120 +"

// Verify
tab lengthofstay los_num
summ los_num, d
```

### Numeric to String
```stata
// Convert number to string
gen str_var = string(numeric_var)

// With formatting (2 decimal places)
gen str_var = string(num_var, "%9.2f")
```

### String to Categorical (encode)

**VERY USEFUL for regression!**

```stata
// Create numeric variable with labels
encode string_var, gen(categorical_var)

// Example: Admission type
encode typeofadmission, gen(admission_type_num)

// Example: Age group
encode agegroup, gen(agegroup_num)

// Verify the encoding
tab typeofadmission admission_type_num
```

### String Manipulation
```stata
// Case conversion
gen upper = strupper(string_var)
gen lower = strlower(string_var)
gen proper = strproper(string_var)  // Title Case

// Extract substring (position starts at 1!)
gen first5 = substr(string_var, 1, 5)
gen char2to4 = substr(string_var, 2, 3)

// Find substring position
gen pos = strpos(string_var, "keyword")
// Returns 0 if not found, position if found

// String length
gen length = strlen(string_var)

// Replace text within string
gen new = subinstr(string_var, "old", "new", .)
// Last argument: . = replace all occurrences

// Split string by delimiter
split string_var, gen(part) parse("_")
// Creates: part1, part2, part3, ...
```

> ⚠️ **substr() position starts at 1, not 0!**
> `substr(str, 1, 2)` = first 2 characters
> `substr(str, 2, 1)` = 2nd character only

---

## 6. Data Merging

### Merge Types - Decision Guide

**How to choose the right merge type:**

Ask: "How many rows per ID in each dataset?"

- **Master**: Many rows per ID, **Using**: One row per ID → **M:1**
- **Master**: One row per ID, **Using**: Many rows per ID → **1:M**
- **Master**: One row per ID, **Using**: One row per ID → **1:1**

### Merge Syntax
```stata
// 1:1 - Both datasets have 1 row per ID
merge 1:1 id_var using "file.dta"

// 1:M - Master has 1 row/ID, Using has many rows/ID
merge 1:m id_var using "file.dta"

// M:1 - Master has many rows/ID, Using has 1 row/ID
merge m:1 id_var using "file.dta"
```

### M:1 Merge Example (MOST COMMON!)

**Scenario**: Merge county-level data to individual hospital records

```stata
// Main dataset: Individual hospitalizations
//   (many records per county)
// Using dataset: County characteristics
//   (one record per county)

use "hospital_data.dta", clear

// Step 1: Ensure variable names match
// If county variable has different name, rename it
rename hospitalcounty County_Name

// Step 2: Perform M:1 merge
merge m:1 County_Name using "county_data.dta"

// Step 3: CHECK merge results (ALWAYS DO THIS!)
tab _merge
/*
_merge values:
  1 = master only (hospital records with no county match)
  2 = using only (counties with no hospital records)
  3 = matched successfully
*/

// Step 4: Decide what to keep
keep if _merge == 1 | _merge == 3
// This keeps all hospital records (even if no match)

// Alternative: Only keep matched records
keep if _merge == 3

// Step 5: Clean up
drop _merge

// Step 6: Verify merged variable
summ County_Income, d
// Should have valid values, report min and max
```

### Complete Merge Workflow
```stata
// ========== BEFORE MERGING ==========

// 1. Check merge variable exists in both datasets
use "main_data.dta", clear
describe merge_var

use "second_data.dta", clear
describe merge_var

// 2. Check if variable is unique (for "1" side)
use "second_data.dta", clear
duplicates report merge_var
// Should show: 0 duplicates

// 3. Ensure variable names match
// If not, rename in one dataset
rename old_name new_name

// 4. Check variable types match
describe merge_var
// Both should be numeric OR both should be string

// ========== PERFORM MERGE ==========

use "main_data.dta", clear
merge m:1 merge_var using "second_data.dta"

// ========== AFTER MERGING ==========

// 5. ALWAYS check _merge!
tab _merge
list merge_var if _merge == 1, sep(0)  // Unmatched from master
list merge_var if _merge == 2, sep(0)  // Unmatched from using

// 6. Keep desired records
keep if _merge == 1 | _merge == 3  // Keep all from master
// OR
keep if _merge == 3  // Keep only matched

// 7. Drop _merge variable
drop _merge

// 8. Verify merged variables
summ merged_variable, d
```

### Append (Stack Datasets)

**Combine datasets with same structure**

```stata
// Use when you want to combine rows
// (e.g., data from multiple years)

use "data2020.dta", clear
append using "data2021.dta"
append using "data2022.dta"

// All rows are kept, stacked vertically
// Make sure variables have same names!
```

---

## 7. Data Reshaping

### Wide to Long Format
```stata
// BEFORE (Wide format):
// id  bp1  bp2  bp3  hr1  hr2  hr3
// 1   120  118  115  72   70   68
// 2   130  128  125  80   78   76

reshape long bp hr, i(id) j(round)

// AFTER (Long format):
// id  round  bp   hr
// 1   1      120  72
// 1   2      118  70
// 1   3      115  68
// 2   1      130  80
// 2   2      128  78
// 2   3      125  76
```

### Long to Wide Format
```stata
// BEFORE (Long format):
// id  round  bp   hr
// 1   1      120  72
// 1   2      118  70
// 2   1      130  80

reshape wide bp hr, i(id) j(round)

// AFTER (Wide format):
// id  bp1  bp2  hr1  hr2
// 1   120  118  72   70
// 2   130  .    80   .
```

> ⚠️ **WARNING**: `reshape` permanently changes data structure.
> Always `save` your data before reshaping!

---

## 8. Regression Analysis

### Linear Regression

**For continuous outcomes**

```stata
// Simple regression
reg outcome predictor

// Multiple regression
reg y x1 x2 x3

// With robust standard errors (recommended!)
reg y x1 x2, robust
// or shorthand:
reg y x1 x2, r
```

### Categorical Variables in Regression

**Use `i.` prefix - Stata creates dummy variables automatically**

```stata
// Include categorical variable
reg outcome continuous_var i.category

// Example from midterm practice
reg totalcosts lengthofstay i.agegroup i.admission_type

// Stata automatically:
// - Creates dummy variables for each category
// - Omits first category as reference group
// - Shows coefficient for each category vs reference
```

### Continuous Variables in Regression
```stata
// Default: treat as continuous
reg y x1 x2

// Explicit: use c. prefix (optional but clear)
reg y c.x1 c.x2
```

### Interaction Terms

**Test if relationship between X and Y varies by Z**

```stata
// Categorical × Categorical interaction
reg y i.var1##i.var2
// ## includes main effects + interaction

// Categorical × Continuous interaction
// ⚠️ IMPORTANT: Use c. for continuous variable!
reg y i.category##c.continuous

// Example: Does income effect vary by sex?
reg health i.sex##c.income age

// Only interaction (no main effects)
reg y i.var1#i.var2
```

> ⚠️ **CRITICAL for interactions with continuous variables**:
> **Wrong**: `reg y i.sex##age`
> **Right**: `reg y i.sex##c.age`
> Must use `c.` prefix!

### Logistic Regression

**For binary outcomes (0/1)**

```stata
// Logistic regression (reports Odds Ratios)
logistic binary_y x1 x2 i.category

// Alternative: logit (reports log-odds)
logit binary_y x1 x2 i.category

// Example from midterm practice
logistic expensive_stay County_Income lengthofstay ///
    i.agegroup i.ED_flag i.admission_type
```

### Linear vs Logistic Interpretation

**Both can be used for binary outcomes!**

```stata
// ===== LINEAR regression on binary outcome =====
reg expensive_stay County_Income, r

// Coefficient interpretation: PERCENTAGE POINT difference
// Example: coefficient = 0.04
// Interpretation: "County income increase of $1000 is
// associated with a 4 percentage point increase in the
// probability of expensive stay (e.g., from 10% to 14%)"

// ===== LOGISTIC regression =====
logistic expensive_stay County_Income

// Coefficient interpretation: ODDS RATIO
// Example: OR = 1.02
// Interpretation: "County income increase of $1000 is
// associated with a 2% increase in the odds of
// expensive stay (OR = 1.02)"
```

### Survey Weights

**Make results representative of population**

```stata
// Step 1: Set survey design
svyset [pweight = weight_var]

// Step 2: Use svy: prefix for analysis
svy: reg y x1 x2 i.category

// Logistic with weights
svy: logistic binary_y x1 x2

// Why use survey weights?
// - Make sample representative of population
// - Account for complex survey design
// - Adjust for non-response bias
// - Over-sampling of certain groups
```

### Post-Regression Commands
```stata
// Test joint significance
reg y x1 x2 x3
test x1 x2
// Tests null hypothesis: x1 = x2 = 0

// Predicted values
predict yhat

// Residuals
predict resid, residuals

// Margins (adjusted predictions)
reg y x1 i.group
margins group
// Shows predicted y for each group, holding other vars constant
```

### Individual Fixed Effects

**For longitudinal/panel data**

```stata
// Controls for all time-invariant individual characteristics

// Step 1: Set panel structure
xtset person_id time_var

// Step 2: Fixed effects regression
xtreg y x1 x2, fe

// Why use fixed effects?
// - Within-person analysis (compare same person over time)
// - Controls for all unmeasured time-invariant confounders
// - Stronger causal inference
// - Example: Does retirement improve mental health?
//   Controls for personality, genetics, etc.
```

---

## 9. Verification & Validation

### Verify Binary Variables

**ALWAYS verify after creating binary flags!**

```stata
// Create binary flag
gen flag = 1 if cost > 50000 & cost != .
replace flag = 0 if cost <= 50000

// ✅ CHECK 1: Summary statistics
summ flag
// Verify: mean between 0-1, min=0, max=1, N correct?

// ✅ CHECK 2: Frequency table
tab flag, m
// Should show only: 0, 1, and possibly .

// ✅ CHECK 3: Verify cutoff values
summ cost if flag == 1
// min should be > 50000
summ cost if flag == 0
// max should be <= 50000

// ✅ CHECK 4: Cross-tabulation if from another variable
tab original_var flag, m
```

### Verify Categorical Variables
```stata
// After encoding or recoding
tab old_var new_var
// Check that mapping is correct

// With percentages
tab old_var new_var, row col

// Check all categories present
tab new_var, m
```

### Verify Continuous Variables
```stata
// After transformation/cleaning
summ original_var, d
summ clean_var, d
// Compare: mean, min, max, N, percentiles

// Grouped summary
bysort group: summ var
// OR
summ var if group == 1
summ var if group == 0

// Visual check
histogram clean_var
```

### Check for Missing Values
```stata
// Count missing observations
count if var == .

// List observations with missing
list id var if var == .

// Missing by group
tab group, m
bysort group: count if var == .

// Missing pattern across variables
misstable summarize
misstable patterns
```

### Verify Merge Success
```stata
// After merge, ALWAYS check!
tab _merge
/*
Ideal result for M:1 merge (county to hospitals):
  _merge |      Freq.
  -------+----------
       1 |        50  <- Hospitals in counties not in county dataset
       3 |    10,000  <- Successfully matched hospitals
*/

// List unmatched from master
list id county_name if _merge == 1

// List unmatched from using
list county_name if _merge == 2

// Verify merged variable has valid values
summ merged_var if _merge == 3, d
// Should NOT be all missing
```

---

## 10. Common Workflows

### Workflow 1: Clean Outcome Variable

```stata
// ========== STEP 1: Explore raw data ==========
codebook outcome
summ outcome, d
tab outcome, m
histogram outcome

// ========== STEP 2: Identify issues ==========
// Questions to ask:
// - What values represent missing?
// - Are there outliers?
// - Is the range sensible?
// - Any impossible values?

// ========== STEP 3: Create clean version ==========
gen outcome_clean = outcome

// ========== STEP 4: Handle missing values ==========
replace outcome_clean = . if outcome == 99
replace outcome_clean = . if outcome == 999
replace outcome_clean = . if outcome < 0

// ========== STEP 5: Handle outliers ==========
// Top-code at $1,000,000
replace outcome_clean = 1000000 ///
    if outcome > 1000000 & outcome != .

// ========== STEP 6: Verify ==========
summ outcome_clean, d
tab outcome outcome_clean, m
count if outcome != . & outcome_clean == .  // Should be 0
```

### Workflow 2: Prepare Covariates for Regression

```stata
// ===== For CONTINUOUS variables =====
summ age, d
// Check range, identify outliers

// Handle missing
replace age = . if age == 99

// Create transformed versions if needed
gen age_squared = age^2
gen log_age = log(age) if age > 0

// ===== For CATEGORICAL variables (numeric) =====
tab category, m
// Check all values are valid

// Create labeled version
label define cat_lbl 1 "A" 2 "B" 3 "C"
label values category cat_lbl

// ===== For CATEGORICAL variables (string) =====
// Encode to numeric for regression
encode string_var, gen(category_num)

// Verify encoding
tab string_var category_num

// ===== For BINARY flags =====
gen flag = 1 if condition & var != .
replace flag = 0 if !condition

// Verify
summ flag  // mean: 0-1, min: 0, max: 1
tab flag, m
```

### Workflow 3: Complete Analysis Example

**Research Question**: Does county income affect hospitalization costs?

```stata
// ========== STEP 1: Load and inspect data ==========
use "hospital_data.dta", clear
describe
summ totalcosts, d
tab county, m

// ========== STEP 2: Clean outcome variable ==========
gen cost_clean = totalcosts
replace cost_clean = 1000000 if totalcosts > 1000000 & totalcosts != .

// Verify
summ cost_clean, d
// Report: mean, SD, min, max

// ========== STEP 3: Clean covariates ==========

// Length of stay (handle "120 +" if needed)
codebook lengthofstay
destring lengthofstay, gen(los_num) force
replace los_num = 120 if lengthofstay == "120 +"

// Age group (encode string to numeric)
encode agegroup, gen(age_num)

// Admission type (encode)
encode typeofadmission, gen(admission_num)

// ED indicator (create 0/1 flag)
gen ED_flag = 1 if ed_indicator == "Y"
replace ED_flag = 0 if ed_indicator == "N"

// Verify all covariates
summ los_num, d
tab agegroup age_num
tab typeofadmission admission_num
tab ed_indicator ED_flag, m

// ========== STEP 4: Merge county data ==========

// Rename to match
rename hospitalcounty County_Name

// Perform M:1 merge
merge m:1 County_Name using "county_income.dta"

// Check merge
tab _merge

// Keep all hospital records
keep if _merge == 1 | _merge == 3
drop _merge

// Verify merged variable
summ County_Income, d
// REPORT: Min = $XX, Max = $XX

// ========== STEP 5: Run regression ==========
reg cost_clean County_Income los_num ///
    i.age_num i.ED_flag i.admission_num, robust

// ========== STEP 6: Interpret results ==========
/*
Example interpretation:
"Controlling for length of stay, age group, emergency
department status, and admission type, each $1,000
increase in county median income is associated with
a $73 increase in hospitalization costs. This
association is statistically significant (p<0.05).

While $73 may seem small, across thousands of
hospitalizations, this represents a substantial
amount of money and likely has practical significance."
*/

// ========== STEP 7: Additional analyses ==========

// Create binary outcome: expensive stays
gen expensive = 1 if cost_clean > 50000 & cost_clean != .
replace expensive = 0 if cost_clean <= 50000

// Verify
summ expensive
summ cost_clean if expensive == 1  // min should be > 50000
summ cost_clean if expensive == 0  // max should be <= 50000

// Logistic regression
logistic expensive County_Income los_num ///
    i.age_num i.ED_flag i.admission_num

// Interpretation:
// "Each $1,000 increase in county income is associated
// with a X% increase in the odds of an expensive stay
// (OR = X.XX, p<0.05)"

// Linear regression on binary outcome
reg expensive County_Income los_num ///
    i.age_num i.ED_flag i.admission_num, robust

// Interpretation:
// "Each $1,000 increase in county income is associated
// with a X percentage point increase in the probability
// of an expensive stay (p<0.05)"
```

---

## 11. Important Reminders

### Top 5 Critical Mistakes to Avoid

> ⚠️ **1. Missing Values**
> **ALWAYS** use `& var != .` in conditions
> Missing (.) is treated as infinity in Stata!
>
> **Wrong**: `replace var = 100 if var > 100`
> **Right**: `replace var = 100 if var > 100 & var != .`

> ⚠️ **2. substr() Position**
> Position starts at **1**, not 0!
> `substr(string, 1, 2)` = first 2 characters
> `substr(string, 2, 1)` = 2nd character only

> ⚠️ **3. Interaction with Continuous Variables**
> **MUST** use `c.` prefix for continuous variables!
> **Wrong**: `reg y i.sex##age`
> **Right**: `reg y i.sex##c.age`

> ⚠️ **4. Check _merge After Merging**
> **ALWAYS** run `tab _merge` and inspect results
> Decide what records to keep based on your research question

> ⚠️ **5. Verify Binary Variables**
> **ALWAYS** run `summ flag` after creating binary variables
> Check: mean ∈ [0,1], min=0, max=1

### Statistical Significance vs Practical Significance

```stata
// Example from midterm review:
// Sample: 500,000 people
// Finding: Gen Z vs Millennials differ by 3 minutes/day exercise
// p-value: 0.007

// Statistical Significance: YES (p < 0.05)

// Practical Significance: DEBATABLE
// - 3 minutes/day might be too small for health benefits
// - BUT: >10% relative difference (3/20 = 15%)
// - Large sample = "overpowered"
//   Can detect tiny differences that may not matter

// KEY LESSON: In large samples, even tiny differences
// can be statistically significant. Always discuss BOTH
// statistical AND practical significance.
```

### Complete Regression Interpretation Guide

**Linear Regression (Continuous Outcome)**:
```
Coefficient = β

Interpretation:
"Each 1-unit increase in X is associated with a β-unit
change in Y, controlling for [list other variables]."

Example: β = 73
"Each $1,000 increase in county income is associated
with a $73 increase in hospitalization costs,
controlling for length of stay, age, emergency status,
and admission type."

If significant (p<0.05), add:
"This association is statistically significant (p<0.05)."

Discuss practical significance:
"While $73 may seem modest, across thousands of
hospitalizations, this represents substantial costs."
```

**Logistic Regression (Binary Outcome)**:
```
Odds Ratio = OR

Interpretation:
"Each 1-unit increase in X is associated with an OR-fold
change in the odds of Y, controlling for [other variables]."

Example: OR = 1.02
"Each $1,000 increase in county income is associated
with a 2% increase in the odds of an expensive stay
(OR=1.02), controlling for length of stay, age,
emergency status, and admission type."
```

**Linear Regression on Binary Outcome**:
```
Coefficient = β

Interpretation:
"Each 1-unit increase in X is associated with a β
percentage point change in the probability of Y,
controlling for [other variables]."

Example: β = 0.04
"Each $1,000 increase in county income is associated
with a 4 percentage point increase in the probability
of an expensive stay (e.g., from 10% to 14%),
controlling for other factors."
```

### When to Use What

**Data Types for Research Questions**:
| Data Type | Best For | Not Good For |
|-----------|----------|--------------|
| Cross-sectional survey | Prevalence, associations at one time point | Causality, changes over time |
| Longitudinal survey | Within-person changes, temporal ordering, causality | Quick/cheap analysis |
| Claims/discharge data | Healthcare utilization, costs, readmissions | Clinical details, unmeasured confounders |
| EHR data | Clinical outcomes, lab values, detailed medications | Outcomes at other health systems |

**Merge Types**:
| Master Dataset | Using Dataset | Merge Type |
|----------------|---------------|------------|
| Many rows per ID | One row per ID | **M:1** |
| One row per ID | Many rows per ID | **1:M** |
| One row per ID | One row per ID | **1:1** |

**Regression Types**:
| Outcome Type | Method | Interpretation |
|--------------|--------|----------------|
| Continuous | Linear regression | β = unit change in outcome |
| Binary | Logistic regression | OR = fold-change in odds |
| Binary | Linear regression | β = percentage point change in probability |
| Panel/longitudinal | Fixed effects (xtreg, fe) | Within-person changes |

### Quality Metrics by Data Source

| Metric | EHR | Claims | Both OK | Neither |
|--------|-----|--------|---------|---------|
| HbA1c control | ✅ | ❌ | | |
| Blood pressure control | ✅ | ❌ | | |
| 90-day readmission | ❌ | ✅ | | |
| Length of stay | | | ✅ | |
| Medication adherence | | ✅ | | |
| Patient satisfaction | | | | ✅ (survey) |

**Reasoning**:
- **EHR**: Has detailed clinical data (labs, vitals) but limited to one health system
- **Claims**: Captures utilization across all providers but lacks clinical details
- **Surveys**: Needed for subjective measures (satisfaction, quality of life)

### Exam Day Strategy

**Before you start coding**:
1. ✅ Read the entire question carefully
2. ✅ Identify the outcome variable and predictors
3. ✅ Note any specific requirements (top-coding, missing values, etc.)
4. ✅ Plan your workflow mentally

**During coding**:
1. ✅ Start with data exploration (`describe`, `summ`, `tab`)
2. ✅ Create clean versions of variables (never overwrite originals)
3. ✅ **VERIFY EACH STEP** before moving on
4. ✅ For merges: `tab _merge` and decide what to keep
5. ✅ For binary flags: `summ` to check 0-1 range
6. ✅ For regressions: Check N, interpret coefficients, assess significance

**Writing interpretations**:
1. ✅ State the relationship (direction and magnitude)
2. ✅ Include the controlling variables
3. ✅ Note statistical significance
4. ✅ Discuss practical significance if appropriate
5. ✅ Use appropriate units

### Quick Reference Table

| Task | Command |
|------|---------|
| Load data | `use "file.dta", clear` |
| Import CSV | `import delimited "file.csv", clear` |
| Summary stats | `summ var, d` |
| Frequency | `tab var, m` |
| Create variable | `gen newvar = expression` |
| Binary flag | `gen flag = (condition) if var != .` |
| Top-code | `replace var = cap if var > cap & var != .` |
| Encode string | `encode str, gen(num)` |
| String to numeric | `destring str, gen(num) force` |
| M:1 merge | `merge m:1 id using "file.dta"` |
| Check merge | `tab _merge` |
| Linear regression | `reg y x1 x2 i.cat, r` |
| Logistic regression | `logistic binary_y x1 x2 i.cat` |
| Interaction (cont) | `reg y i.cat##c.cont` |
| Survey weights | `svyset [pweight=wt]` then `svy: reg y x` |
| Verify binary | `summ flag` (should be 0-1) |
| Cross-check | `tab oldvar newvar` |

---

## Emergency Quick Fixes

**"No observations" error**:
```stata
// Check if data is loaded
describe

// Check if all observations were dropped
count

// Load data again
use "file.dta", clear
```

**"Variable not found" error**:
```stata
// List all variables
describe

// Check exact spelling
lookfor keyword
```

**"Type mismatch" in merge**:
```stata
// Check variable types
describe merge_var

// If one is string and one is numeric, convert:
destring string_var, gen(numeric_var)
// or
gen string_var = string(numeric_var)
```

**Binary variable has mean > 1**:
```stata
// You forgot to handle missing!
// Recreate properly:
drop flag
gen flag = 1 if condition & var != .
replace flag = 0 if !condition & var != .
```

**Regression drops all observations**:
```stata
// Check for missing in key variables
summ outcome predictor1 predictor2

// List observations with any missing
egen anymiss = rowmiss(outcome predictor1 predictor2)
tab anymiss
list if anymiss > 0
```

---

## Final Checklist Before Submitting

✅ All variables have appropriate names and labels
✅ Binary variables have been verified (`summ` shows 0-1)
✅ Categorical variables are properly encoded for regression
✅ Missing values are handled correctly
✅ After merge: checked `_merge` and kept appropriate records
✅ Regression output includes all requested variables
✅ Interpretations are complete and accurate
✅ Sample sizes (N) are reported where requested
✅ Used `robust` standard errors (or know why not)
✅ All answers clearly indicate units (dollars, percentage points, etc.)

---

## Good Luck! 🍀

**Remember**:
- The goal is to show your understanding, not perfection
- Verify each step before moving on
- Write clear interpretations of your results
- If stuck, move to the next question and come back
- Use this cheat sheet - that's what it's for!

**You've got this!** 💪

---

*Stata Cheat Sheet for Large Scale Data Analysis*
*Version 1.0 | October 2025*
*For midterm Part 2 reference*
