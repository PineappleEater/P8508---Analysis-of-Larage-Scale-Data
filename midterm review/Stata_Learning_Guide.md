# Stata 完备学习攻略
## 基于 Large-Scale Data Analysis 课程 (Sessions 1-7 & Homework 1-3)

---

## 目录

1. [基础篇](#基础篇) - 数据导入、查看与基本操作
2. [数据清理篇](#数据清理篇) - 变量创建与转换
3. [数据合并与重塑篇](#数据合并与重塑篇) - 复杂数据结构处理
4. [描述性统计篇](#描述性统计篇) - 汇总与分组统计
5. [回归分析篇](#回归分析篇) - 从简单到复杂
6. [字符串处理篇](#字符串处理篇) - 文本数据操作
7. [日期时间处理篇](#日期时间处理篇) - 时间序列数据
8. [可视化篇](#可视化篇) - 图表制作
9. [高级技巧篇](#高级技巧篇) - 效率与调试
10. [实战案例篇](#实战案例篇) - 完整分析流程

---

## 基础篇

### 1.1 工作环境设置

```stata
/*====================================
  STANDARD SETUP - 每个do文件开头
====================================*/

clear all              // Clear all data from memory
set more off          // Disable pause on output

cd "C:\Your\Working\Directory"  // Set working directory

capture log close     // Close any open log file
log using analysis.log, replace  // Start new log file
```

**关键点:**
- `clear all` 清除内存中所有数据和变量
- `set more off` 避免输出暂停（重要！）
- `capture` 避免命令失败时中断程序
- Log文件记录所有输出，便于检查结果

---

### 1.2 数据导入

#### 1.2.1 导入 SAS Transport 文件 (.xpt)

```stata
// Import from local file
import sasxport5 "LLCP2023.xpt", clear

// Import from URL (NHANES example)
import sasxport5 "https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2017/DataFiles/BMX_J.xpt", clear

// 导入后立即压缩以减小文件大小
compress
save BRFSS2023, replace
```

**为什么需要 compress?**
- SAS数据在Stata中可能存储效率低
- `compress` 可以将文件大小减少50%以上
- 例如：BRFSS从400MB压缩到211MB

#### 1.2.2 导入 CSV 文件

```stata
// Import delimited text files
import delimited "admissions.csv", clear
save admissions.dta, replace

// Import with specific string columns (prevent leading zeros loss)
import delimited "medrecon.csv", stringcols(5 6) clear
```

**关键参数:**
- `stringcols(5 6)` - 强制第5、6列读取为字符串
- 用于保留前导零（如药品代码 "0001234567"）

#### 1.2.3 导入 Excel 文件

```stata
// Import Excel - INCORRECT (first row as data)
import excel "CoffeeData.xlsx", clear

// Import Excel - CORRECT (first row as variable names)
import excel "CoffeeData.xlsx", clear firstrow
```

**常见错误:**
- 忘记 `firstrow` 导致变量名变成第一行数据

#### 1.2.4 导入 Stata 自身格式

```stata
// Save Stata format
save filename.dta, replace

// Load Stata format
use filename.dta, clear

// Load specific variables only
use var1 var2 var3 using filename.dta, clear
```

---

### 1.3 数据查看与探索

#### 1.3.1 基本查看命令

```stata
/*====================================
  DATA INSPECTION COMMANDS
====================================*/

// View first 10 observations
list in 1/10

// View specific variables for first 10 rows
list var1 var2 var3 in 1/10

// Browse data interactively (opens Data Editor)
browse

// View variable information
describe
describe var1 var2  // Specific variables

// Check variable type (string vs numeric)
describe idate imonth iday iyear
```

**输出示例:**
```
     variable name   storage type   display format   value label
     ─────────────────────────────────────────────────────────────
     idate           str8           %9s
     imonth          str2           %2s
     age             int            %8.0g
```
- `str8` = 字符串类型，最多8个字符
- `int` = 整数类型

#### 1.3.2 频数统计

```stata
// Basic frequency table
tab variable_name

// Include missing values
tab variable_name, missing
tab variable_name, m  // Shorthand

// Without value labels (show numeric codes)
tab variable_name, nolabel
tab variable_name, m nol

// Two-way frequency table
tab var1 var2

// Two-way with row percentages
tab var1 var2, row

// Two-way with column percentages
tab var1 var2, col

// Sort by frequency (descending)
tab variable_name, sort
```

**实战例子:**
```stata
// Check diagnosis codes by frequency
tab ccsr_full, sort

// Compare gender across smoking status
tab female ever_smoked, row
```

#### 1.3.3 连续变量统计

```stata
// Basic summary statistics
summarize variable_name
sum variable_name  // Shorthand

// Detailed statistics (including percentiles)
summarize variable_name, detail
sum variable_name, d  // Shorthand

// Multiple variables
sum var1 var2 var3
```

**详细统计输出包括:**
- Mean, SD, Min, Max
- Percentiles: 1%, 5%, 10%, 25%, 50%, 75%, 90%, 95%, 99%
- Skewness, Kurtosis

---

## 数据清理篇

### 2.1 变量创建

#### 2.1.1 基本生成 (gen)

```stata
/*====================================
  VARIABLE GENERATION BASICS
====================================*/

// Create empty variable
gen new_var = .

// Create with calculation
gen bmi = weight / (height^2)

// Create with condition
gen age_group = .
replace age_group = 1 if age >= 20 & age != .
replace age_group = 0 if age < 20 & age != .

// Create dummy variable
gen female = .
replace female = 1 if gender == "F"
replace female = 0 if gender == "M"

// More concise way (one-liner)
gen female = (gender == "F") if gender != .
```

**重要规则:**
- 使用 `& age != .` 排除缺失值
- Stata中缺失值 `.` 被视为无穷大
- 条件 `age >= 20` 会将缺失值误判为真！

#### 2.1.2 条件赋值技巧

```stata
// Method 1: Step-by-step (safest)
gen obesity_class = .
replace obesity_class = 0 if bmxbmi < 18.5 & ridageyr >= 20 & bmxbmi != .
replace obesity_class = 1 if bmxbmi >= 18.5 & bmxbmi < 25 & ridageyr >= 20
replace obesity_class = 2 if bmxbmi >= 25 & bmxbmi < 30 & ridageyr >= 20

// Method 2: Using recode
recode smokev (1 = 0) (2 = 1) (9 = .), gen(smoker)

// Method 3: Using inlist
gen employed = .
replace employed = 1 if inlist(EMPST, 1, 2, 3)
replace employed = 0 if EMPST == 4
```

**inlist() 的优势:**
- 避免多个 `|` (OR) 操作符
- 更清晰易读

#### 2.1.3 使用 egen (扩展生成)

```stata
/*====================================
  EGEN - EXTENDED GENERATE
====================================*/

// Row minimum across variables
egen atleast1_adl = rowmin(diffwalk diffdres diffalon)

// Row maximum
egen worst_score = rowmax(pain1 pain2 pain3)

// Row total (sum)
egen total_score = rowtotal(item1 item2 item3 item4)

// Row total with missing option (only sum non-missing)
egen k6 = rowtotal(arestless asad aworthless ahopeless aeffort anervous), missing

// Row mean
egen avg_score = rowmean(test1 test2 test3)

// Group statistics
egen avg_weight_by_state = mean(weight), by(state)
egen share_flu_by_month = mean(flu_shot), by(month_year)

// Concatenate strings
egen state_month = concat(_state imonth), punct("_")
egen ccsr_full = concat(ccsrdiagnosiscode ccsrdiagnosisdescription), punct("- ")
```

**rowtotal 常见错误:**
```stata
// WRONG - will sum even if some values missing
egen k6 = rowtotal(var1 var2 var3 var4 var5 var6)
tab k6 if var1 == ., m  // Shows values even when var1 missing!

// CORRECT - need to replace with missing if any component missing
egen k6 = rowtotal(var1 var2 var3 var4 var5 var6), missing
replace k6 = . if var1 == . | var2 == . | var3 == . | var4 == . | var5 == . | var6 == .
```

---

### 2.2 变量转换

#### 2.2.1 字符串转数值 (destring)

```stata
/*====================================
  STRING TO NUMERIC CONVERSION
====================================*/

// Basic destring
destring string_var, gen(numeric_var)

// With force (convert non-numeric to missing)
destring birthweight, gen(birthweight_num) force
// "N/A" → .
// "2500" → 2500
// "Unknown" → .

// Replace the original variable
destring string_var, replace
```

**什么时候需要 force?**
- 数据中混有数字和文本
- 例如: "2500", "N/A", "Unknown"
- force将非数字转为缺失值

#### 2.2.2 数值转分类 (encode)

```stata
/*====================================
  NUMERIC ENCODING
====================================*/

// Convert string to labeled numeric
encode race, gen(race_num)

// Example:
// "White" → 1 (labeled as "White")
// "Black" → 2 (labeled as "Black")
// "Hispanic" → 3 (labeled as "Hispanic")

// Use in regression
reg outcome i.race_num age female
```

**为什么需要 encode?**
- 回归分析需要数值变量
- 保留原始标签，便于解释

#### 2.2.3 变量标签

```stata
/*====================================
  VARIABLE LABELS
====================================*/

// Label variable
label variable bmi "Body Mass Index (kg/m²)"
label variable age "Age at admission (years)"

// Define value labels
label define gender_lbl 0 "Male" 1 "Female"
label define yesno 0 "No" 1 "Yes"

// Assign value labels to variable
label values female gender_lbl
label values smoker yesno

// Multi-line label definition
label define obesity_lbl ///
    0 "Underweight" ///
    1 "Healthy Weight" ///
    2 "Overweight" ///
    3 "Class 1 Obesity" ///
    4 "Class 2 Obesity" ///
    5 "Class 3 Obesity (Severe)"

label values obesity_class obesity_lbl
```

---

### 2.3 缺失值处理

#### 2.3.1 识别缺失值

```stata
/*====================================
  MISSING VALUE IDENTIFICATION
====================================*/

// Check for missing
count if variable == .

// Count non-missing
count if variable != .

// Using missing() function
count if missing(variable)

// Multiple conditions
count if variable1 == . | variable2 == . | variable3 == .
```

#### 2.3.2 缺失值编码

```stata
// Recode specific values to missing
replace education = . if inlist(education, 7, 9)
replace drg_code = 9999 if missing(drg_code)

// Create missing indicator
gen acuity_missing = (missing(acuity))
gen educ_miss = 1 if educ_years == .
replace educ_miss = 0 if educ_years != .
```

#### 2.3.3 单次插补 (Single Imputation)

```stata
/*====================================
  SINGLE IMPUTATION EXAMPLE
====================================*/

// Step 1: Create missing indicator
gen acuity_missing = (missing(acuity))

// Step 2: Predict missing values using regression
reg acuity age i.race_eth_num i.drg_code i.admission_type_num
predict acuity_hat

// Step 3: Create imputed variable
gen acuity_imp = acuity
replace acuity_imp = acuity_hat if missing(acuity)

// Step 4: Use in regression (with missing indicator)
reg los age i.insurance i.drg_code acuity_imp i.acuity_missing
```

**为什么需要缺失指示变量?**
- 控制插补带来的偏差
- 插补值与真实值可能系统性不同

---

## 数据合并与重塑篇

### 3.1 数据合并 (Merge)

#### 3.1.1 一对一合并 (1:1)

```stata
/*====================================
  ONE-TO-ONE MERGE
====================================*/

// Merge demographics with body measures
use NHANES_demo, clear
merge 1:1 subject_id using NHANES_bmx

// Check merge results
tab _merge
/*
_merge values:
  1 = obs from master only
  2 = obs from using only
  3 = obs from both (matched)
*/

// Keep only matched observations
keep if _merge == 3
drop _merge
```

**使用场景:**
- 两个数据集有相同的唯一标识符
- 例如：一个住院记录对应一个DRG编码

#### 3.1.2 多对一合并 (m:1)

```stata
/*====================================
  MANY-TO-ONE MERGE
====================================*/

// Many admissions to one patient
use admissions, clear
merge m:1 subject_id using patients

tab _merge
drop _merge
```

**使用场景:**
- 多条记录对应一个主记录
- 例如：多次住院（admissions）对应一个患者（patients）

#### 3.1.3 一对多合并 (1:m)

```stata
/*====================================
  ONE-TO-MANY MERGE
====================================*/

// One admission to many diagnoses
use admissions, clear
merge 1:m subject_id hadm_id using diagnosis

tab _merge
keep if _merge == 3 | _merge == 1
drop _merge
```

**使用场景:**
- 一条主记录对应多条子记录
- 例如：一次住院有多个诊断

#### 3.1.4 合并策略总结

```stata
// Always check merge results!
tab _merge

// Common pattern: keep master + matched
keep if _merge == 3 | _merge == 1
drop _merge

// Save merged dataset
save merged_data, replace
```

---

### 3.2 数据重塑 (Reshape)

#### 3.2.1 长格式转宽格式 (Long → Wide)

```stata
/*====================================
  LONG TO WIDE RESHAPE
====================================*/

// Original data (long format):
// subject_id   round   MNHLTH   EMPST
// 1001         1       4        1
// 1001         2       3        1
// 1001         3       4        2

keep DUID PID DUPERSID PANEL MNHLTH1 MNHLTH2 MNHLTH3 EMPST1 EMPST2 EMPST3

// After reshape wide:
// DUPERSID   MNHLTH1   MNHLTH2   MNHLTH3   EMPST1   EMPST2   EMPST3
// 1001       4         3         4         1        1        2

// Reshape long
reshape long MNHLTH EMPST, i(DUPERSID) j(round)
```

**参数解释:**
- `i(DUPERSID)` - 唯一标识符（"hinge"变量）
- `j(round)` - 新创建的变量，存储后缀（1, 2, 3...）
- `MNHLTH EMPST` - 需要重塑的变量stem

#### 3.2.2 宽格式转长格式 (Wide → Long)

```stata
/*====================================
  WIDE TO LONG RESHAPE
====================================*/

// Original data (wide format):
// stay_id   ndc1          ndc2          ndc3
// 501       "12345-678"   "98765-432"   "55555-555"

// Goal: One row per medication
keep ndc stay_id ndc_id

// Step 1: Create sequence ID
bysort stay_id: generate ndc_id = _n

// Step 2: Reshape
reshape wide ndc, i(stay_id) j(ndc_id)

// After reshape (long format):
// stay_id   ndc_id   ndc
// 501       1        "12345-678"
// 501       2        "98765-432"
// 501       3        "55555-555"
```

**重塑诊断数据示例:**
```stata
// Diagnosis data: multiple diagnoses per patient
use diagnosis, clear

// Create sequence number for each diagnosis
bysort subject_id: generate dx_id = _n

// Keep essential variables
keep subject_id dx_id icd_code icd_title

// Reshape to wide (one row per patient)
reshape wide icd_code icd_title, i(subject_id) j(dx_id)

// Result: icd_code1, icd_code2, icd_code3, etc.
```

---

### 3.3 数据折叠 (Collapse)

```stata
/*====================================
  COLLAPSE - CREATE SUMMARY DATASETS
====================================*/

// Save original data first!
save original_data, replace

// Calculate mean by group
collapse (mean) flu_shot, by(month_year)

// Multiple statistics
collapse (mean) mean_los=los (sd) sd_los=los (count) n=los, by(provider_group)

// Use collapsed data for graphing
twoway line flu_shot month_year

// Restore original data
use original_data, clear
```

**警告:**
- `collapse` 会**永久改变**数据集
- 务必先用 `save` 或 `preserve`

---

## 描述性统计篇

### 4.1 Tabstat - 灵活的统计表

```stata
/*====================================
  TABSTAT - FLEXIBLE STATISTICS
====================================*/

// Basic usage
tabstat variable, stat(n mean sd)

// By groups
tabstat bmi, by(age_group) stat(n mean sd min p50 max)

// Multiple variables
tabstat bmi weight height, by(gender) stat(n mean sd)

// Format output
tabstat bmi, by(age_group) stat(n mean sd) format(%9.2f)

// Column format
tabstat bmi, by(age_group) stat(n mean sd) col(stat)
```

**常用统计量:**
- `n` - 观测数
- `mean` - 均值
- `sd` - 标准差
- `min` / `max` - 最小/最大值
- `p50` - 中位数
- `p25` `p75` - 四分位数

---

### 4.2 分组统计技巧

```stata
/*====================================
  GROUP STATISTICS
====================================*/

// Using egen to create group means
egen avg_weight_by_height = mean(weight) if weight < 7777, by(height)

// Using bysort
bysort state: egen avg_los = mean(los)

// Count observations per group
bysort subject_id: gen n_admissions = _N

// Sequence number within group
bysort subject_id: gen admission_seq = _n

// Keep first observation per group
bysort subject_id: keep if _n == 1
```

**_n vs _N:**
- `_n` - 当前组内的序号（1, 2, 3...）
- `_N` - 当前组的总观测数

---

### 4.3 去重 (Duplicates)

```stata
/*====================================
  DUPLICATE HANDLING
====================================*/

// Check for duplicates
duplicates report stay_id

// List duplicate examples
duplicates examples stay_id ndc

// Tag duplicates (create flag variable)
duplicates tag stay_id ndc, gen(dupe_flag)

// Drop exact duplicates (keep one)
duplicates drop stay_id ndc, force

// Drop ALL duplicates (including first occurrence)
duplicates drop stay_id if dupe_flag > 0, force
```

**实战案例:**
```stata
// Remove duplicate diagnoses per patient
use diagnosis, clear
bysort subject_id icd_code: keep if _n == 1

// Deduplicate after merge
merge 1:m subject_id stay_id using diagnosis
duplicates drop subject_id stay_id, force
```

---

## 回归分析篇

### 5.1 简单线性回归

```stata
/*====================================
  SIMPLE LINEAR REGRESSION
====================================*/

// Basic regression
reg outcome predictor

// With robust standard errors
reg outcome predictor, robust
reg outcome predictor, r  // Shorthand

// Clustered standard errors
reg outcome predictor, vce(cluster cluster_var)

// Example: State-level clustering
reg physhlth_clean more_dunkins, vce(cluster _state)
```

**为什么需要robust/clustered SE?**
- Robust: 处理异方差（error spread不一致）
- Clustered: 处理组内相关（如同一州的观测不独立）

---

### 5.2 多元回归

```stata
/*====================================
  MULTIPLE REGRESSION
====================================*/

// Multiple predictors
reg bmi below_200fpl female us_born age

// Categorical predictors (i. prefix)
reg bmi below_200fpl female i.education age

// Continuous predictors (usually don't need c. prefix)
reg bmi age female

// With confidence level
reg bmi below_200fpl female age, level(95)
```

**提取回归结果:**
```stata
// After regression
local coef = _b[below_200fpl]        // Coefficient
local se = _se[below_200fpl]          // Standard error
local pval = 2*ttail(e(df_r), abs(_b[below_200fpl]/_se[below_200fpl]))

// Calculate confidence intervals
local ci_lower = `coef' - invttail(e(df_r), 0.025)*`se'
local ci_upper = `coef' + invttail(e(df_r), 0.025)*`se'

// Display
di "Coefficient: " %5.3f `coef'
di "95% CI: [" %5.3f `ci_lower' ", " %5.3f `ci_upper' "]"
```

---

### 5.3 交互作用

#### 5.3.1 分类×分类交互

```stata
/*====================================
  CATEGORICAL × CATEGORICAL INTERACTION
====================================*/

// Interaction between two binary variables
reg k6 i.smoker i.insured i.smoker#i.insured, robust

// Get predicted means for each combination
margins i.smoker#i.insured

/*
Output example:
        smoker   insured   Margin
        0        0         5.2
        0        1         4.8
        1        0         6.1
        1        1         5.5
*/
```

#### 5.3.2 分类×连续交互

```stata
/*====================================
  CATEGORICAL × CONTINUOUS INTERACTION
====================================*/

// IMPORTANT: Use c. prefix for continuous variable!
reg k6 i.smoker age i.smoker#c.age, robust

// WRONG (will treat age as categorical):
reg k6 i.smoker age i.smoker#i.age, robust  // DON'T DO THIS!
```

**常见错误警告:**
- 忘记 `c.` 会将连续变量当作分类变量
- 导致为每个年龄值创建虚拟变量（灾难性！）

---

### 5.4 Logistic 回归

```stata
/*====================================
  LOGISTIC REGRESSION
====================================*/

// Binary outcome
gen obese = (obesity_class >= 3) if obesity_class != .

// Logistic regression (reports log-odds)
logit obese below_200fpl female i.education age

// Logistic regression (reports odds ratios)
logistic obese below_200fpl female i.education age
// OR
logit obese below_200fpl female i.education age, or

// Get predicted probabilities
margins i.education

// Extract odds ratio
local or_edu5 = exp(_b[5.education])
di "OR for college vs <9th grade: " %5.3f `or_edu5'
```

---

### 5.5 固定效应回归

```stata
/*====================================
  INDIVIDUAL FIXED EFFECTS
  (Within-Person Analysis)
====================================*/

// Absorb individual-level fixed effects
areg outcome i.predictor, robust absorb(person_id)

// Example: Employment and mental health
areg MNHLTH_clean i.employed, r absorb(DUPERSID)

// Note: Time-invariant variables will be dropped!
areg MNHLTH_clean i.employed i.female, r absorb(DUPERSID)
// Warning: "female omitted because of collinearity"
```

**固定效应的含义:**
- 控制所有个体层面的不变特征
- 只利用个体内部的时间变化
- 无法估计不随时间变化的变量（如性别、种族）

---

### 5.6 Margins - 边际效应

```stata
/*====================================
  MARGINS - PREDICTED VALUES
====================================*/

// After regression, get predicted means
reg outcome i.group_var age female
margins group_var

// Save margins for later use
margins facility_num, saving(unadj_means, replace)

// For logged outcomes, transform back
reg log_cost i.facility_num
margins facility_num, expression(exp(predict(xb)))

// After logistic, get probabilities (automatic)
logit obese i.smoker i.insured
margins i.smoker#i.insured  // Returns probabilities, not log-odds!
```

---

### 5.7 假设检验 (Test)

```stata
/*====================================
  HYPOTHESIS TESTING
====================================*/

// Test single coefficient = 0
reg los i.provider_group age female
test 2.provider_group

// Test multiple coefficients jointly
test 2.provider_group 3.provider_group 4.provider_group

// Test interaction term
reg k6 i.female year_centered i.female#c.year_centered
test female#c.year_centered

// Loop through multiple tests
forvalues i = 2/10 {
    capture test `i'.provider_group
    if _rc == 0 {
        local pval = r(p)
        di "Provider group `i' vs P0: p = " %6.4f `pval'
    }
}
```

---

## 字符串处理篇

### 6.1 字符串转换

```stata
/*====================================
  STRING CASE CONVERSION
====================================*/

// Convert to uppercase
replace diagnosis_desc = strupper(diagnosis_desc)
// "Septicemia" → "SEPTICEMIA"

// Convert to lowercase
replace diagnosis_desc = strlower(diagnosis_desc)
// "Septicemia" → "septicemia"

// Proper case (first letter capitalized)
replace name = strproper(name)
// "john smith" → "John Smith"
```

**为什么需要转换?**
- 便于搜索（不区分大小写）
- 数据一致性

---

### 6.2 字符串提取 (substr)

```stata
/*====================================
  STRING EXTRACTION - SUBSTR()
====================================*/

// Syntax: substr(string, position, length)
// IMPORTANT: Position starts at 1, not 0!

// Extract first 2 characters
gen provider_group = substr(admit_provider_id, 1, 2)
// "P001234" → "P0"

// Extract manufacturer code (first 5 digits of NDC)
gen manufacturer = substr(ndc, 1, 5)
// "12345-678-90" → "12345"

// COMMON ERROR:
gen wrong = substr(admit_provider_id, 2, 1)
// "P001234" → "0" (NOT "P0"!)
```

**关键错误教训（来自作业3）:**
```stata
// ❌ WRONG - only extracts 2nd character
gen provider_group = substr(admit_provider_id, 2, 1)
// Result: "0", "1", "2"... (wrong!)

// ✅ CORRECT - extracts first 2 characters
gen provider_group = substr(admit_provider_id, 1, 2)
// Result: "P0", "P1", "P2"... (correct!)
```

---

### 6.3 字符串匹配 (regex)

```stata
/*====================================
  STRING PATTERN MATCHING
====================================*/

// Check if string contains pattern
gen is_black = regexm(race, "BLACK")

// Create race/ethnicity categories
gen race_eth = ""
replace race_eth = "Black" if regexm(race, "BLACK")
replace race_eth = "White" if regexm(race, "WHITE")
replace race_eth = "Hispanic" if regexm(race, "HISPANIC")
replace race_eth = "Other" if regexm(race, "UNKNOWN|OTHER|UNABLE")

// Filter observations
tab ccsr_full if regex(ccsr_full, "FRACTURE"), sort
tab aprdrg_full if regex(aprdrg_full, "ALC") | regex(aprdrg_full, "DRUG"), sort

// Complex pattern (alcohol/drug related)
gen alcdrug = 0
replace alcdrug = 1 if aprmdccode == 20 | ///
                       inrange(ccsrdiagnosiscode, "MBD017", "MBD026") | ///
                       ccsrdiagnosiscode == "INJ022"
```

**regex vs regexm:**
- `regexm(string, pattern)` - 返回1/0（是否匹配）
- `regex(string, pattern)` - 在条件语句中使用

---

### 6.4 字符串拆分 (split)

```stata
/*====================================
  STRING SPLITTING
====================================*/

// Split variable by delimiter
split state_month, gen(state_month_part) parse("_")

// Example:
// Original: "NY_Jan", "CA_Feb"
// Result:
//   state_month_part1: "NY", "CA"
//   state_month_part2: "Jan", "Feb"
```

---

## 日期时间处理篇

### 7.1 日期转换

#### 7.1.1 字符串转日期

```stata
/*====================================
  DATE CONVERSION FUNCTIONS
====================================*/

// Convert string to date (date only, no time)
gen date_var = date(date_string, "MDY")
format date_var %td

// Example:
// "1/15/2023" → 22660 (days since Jan 1, 1960)
// After format: "15jan2023"

// Common date formats:
// "MDY" - Month/Day/Year (e.g., "1/15/2023")
// "DMY" - Day/Month/Year (e.g., "15/1/2023")
// "YMD" - Year/Month/Day (e.g., "2023/1/15")
```

#### 7.1.2 字符串转日期时间

```stata
/*====================================
  DATETIME CONVERSION
====================================*/

// Convert to date + time (clock)
gen arrival_time = clock(intime, "YMD hms")
format arrival_time %tc

// Example:
// "2023-01-15 14:30:00" → 1989648600000 (milliseconds since 1960)
// After format: "15jan2023 14:30:00"

// Format codes:
// YMD - Year Month Day
// hms - hours minutes seconds
// hm - hours minutes (no seconds)
```

**格式必须匹配原始数据!**
```stata
// If your data is "01/15/2023 2:30 PM":
gen dt = clock(datetime_string, "MDY hm")  // NO seconds

// If your data is "2023-01-15 14:30:00":
gen dt = clock(datetime_string, "YMD hms")  // WITH seconds
```

---

### 7.2 日期计算

```stata
/*====================================
  DATE CALCULATIONS
====================================*/

// Length of stay (in days)
gen admit_date = date(admittime, "YMD hms")
gen disch_date = date(dischtime, "YMD hms")
gen los = disch_date - admit_date

// ED wait time (in milliseconds, then convert to hours)
gen arrival_time = clock(intime, "YMD hms")
gen depart_time = clock(outtime, "YMD hms")
gen wait_time = depart_time - arrival_time

// Convert milliseconds to hours
replace wait_time = wait_time / 1000 / 60 / 60

// Extract year from date
gen birth_year_extracted = year(birth_date)
gen age = year(admit_date) - birth_year
```

---

### 7.3 创建时间分组变量

```stata
/*====================================
  TIME GROUPING VARIABLES
====================================*/

// Create month-year variable for trend analysis
destring iyear, gen(year_num)
destring imonth, gen(month_num)

// Assign everyone to 1st of the month
gen month_year = mdy(month_num, 1, year_num)
format month_year %td

// Example:
// Interviewed on March 13, 2023 → March 1, 2023
// Interviewed on March 28, 2023 → March 1, 2023

// Use for grouping
collapse (mean) flu_shot, by(month_year)
twoway line flu_shot month_year
```

---

## 可视化篇

### 8.1 基础图表

#### 8.1.1 直方图

```stata
/*====================================
  HISTOGRAM
====================================*/

// Basic histogram
histogram variable_name

// With specific number of bins
histogram los, bin(20)

// Frequency vs density
histogram los, frequency  // Count
histogram los, density    // Probability density

// With bin width
histogram birthweight, width(100)

// Customize appearance
histogram los, bin(20) frequency ///
    title("Distribution of Length of Stay") ///
    subtitle("MIMIC IV Data - Hospital Admissions") ///
    xtitle("Length of Stay (days)") ///
    ytitle("Frequency") ///
    scheme(s2color)

// Overlapping histograms
twoway (histogram bmi if female==0, width(1) color(blue%30)) ///
       (histogram bmi if female==1, width(1) color(red%30)), ///
       legend(order(1 "Male" 2 "Female"))
```

---

#### 8.1.2 散点图

```stata
/*====================================
  SCATTER PLOT
====================================*/

// Basic scatter
scatter y_var x_var

// With marker options
scatter weight height, mcolor(ebblue) msize(medium)

// Multiple scatter layers
twoway (scatter weight height if female==0, mcolor(blue)) ///
       (scatter weight height if female==1, mcolor(red)), ///
       legend(order(1 "Male" 2 "Female"))
```

---

#### 8.1.3 折线图

```stata
/*====================================
  LINE PLOT
====================================*/

// Basic line graph
twoway line y_var x_var

// Trend over time
sort month_year
twoway line smoking_prev year

// Combined scatter + line
twoway (scatter smoking_prev year, mcolor(red)) ///
       (line smoking_prev year, lcolor(red))

// Add linear fit
twoway (scatter y x) ///
       (lfit y x, lcolor(blue) lpattern(dash))
```

---

### 8.2 复杂图表

#### 8.2.1 叠加多个图层

```stata
/*====================================
  LAYERED GRAPHS
====================================*/

// Scatter + line + fit
twoway (scatter smoking_prev year, mcolor(red) msize(medium)) ///
       (line smoking_prev year, lcolor(red) lwidth(medium)) ///
       (lfit smoking_prev year, lcolor(blue) lpattern(dash)), ///
       title("Smoking Trends Over Time", size(medium)) ///
       subtitle("NHIS Data", size(small)) ///
       xtitle("Year") ///
       ytitle("Proportion Ever Smoked") ///
       ylabel(0(0.05)0.7, format(%4.2f)) ///
       legend(order(1 "Data Points" 2 "Trend Line" 3 "Linear Fit")) ///
       note("Data: NHIS IPUMS Extract") ///
       scheme(s2color)
```

#### 8.2.2 原始数据 + 平均值

```stata
/*====================================
  RAW DATA + SUMMARY LINE
====================================*/

// Create average by group
egen avgweight_by_height = mean(weight) if weight < 7777, by(height)

// Sort by x-axis variable
sort height

// Layer scatter + line
twoway (scatter weight height if weight<7777, mcolor(ebblue)) ///
       (line avgweight_by_height height, lwidth(thick) lcolor(red)), ///
       ytitle("Body Weight") ///
       legend(order(1 "Observed body weight" 2 "Average body weight") position(3))
```

---

### 8.3 图表选项详解

```stata
/*====================================
  GRAPH OPTIONS REFERENCE
====================================*/

// Titles
title("Main Title", size(medium))
subtitle("Subtitle", size(small))
xtitle("X-Axis Label")
ytitle("Y-Axis Label")
note("Data source notes")

// Axis scales
ylabel(0(0.1)1, format(%4.2f))  // Y-axis: 0 to 1, step 0.1
xlabel(2000(5)2020)              // X-axis: 2000 to 2020, step 5

// Colors
mcolor(red)          // Marker color
lcolor(blue)         // Line color
color(green%30)      // 30% transparency

// Line styles
lwidth(thick)        // Line width: thin, medium, thick
lpattern(dash)       // Line pattern: solid, dash, dot

// Legend
legend(order(1 "Label 1" 2 "Label 2"))
legend(position(3))  // Position: 12=top, 6=bottom, 3=right

// Schemes
scheme(s2color)      // Clean color scheme
scheme(s1mono)       // Monochrome
```

---

### 8.4 导出图表

```stata
/*====================================
  EXPORT GRAPHS
====================================*/

// Export as PNG
graph export "figure1.png", replace

// Export with size specification
graph export "figure1.png", replace width(800) height(600)

// Export as PDF
graph export "figure1.pdf", replace

// Export as EPS (for publications)
graph export "figure1.eps", replace
```

---

## 高级技巧篇

### 9.1 循环与宏

#### 9.1.1 Local 宏

```stata
/*====================================
  LOCAL MACROS - TEMPORARY STORAGE
====================================*/

// Store value
local mean_age = 45.2
local pval = 0.032

// Display
di "Mean age is " `mean_age'
di "P-value: " %5.3f `pval'

// Store from regression
reg bmi age female
local coef = _b[age]
local se = _se[age]

// Use in calculations
local ci_lower = `coef' - 1.96*`se'
local ci_upper = `coef' + 1.96*`se'
```

**Local vs Global:**
- Local: 只在当前do文件/程序中有效
- Global: 在整个Stata session中有效

#### 9.1.2 For 循环

```stata
/*====================================
  FORVALUES LOOP
====================================*/

// Loop through numbers
forvalues i = 1/10 {
    di "Processing provider group `i'"
    capture test `i'.provider_group
    if _rc == 0 {
        local pval = r(p)
        di "  P-value: " %6.4f `pval'
    }
}

// Loop with step
forvalues year = 2000(5)2020 {
    di "Analyzing year `year'"
}
```

```stata
/*====================================
  FOREACH LOOP
====================================*/

// Loop through list
foreach var in age bmi weight height {
    summarize `var', detail
}

// Loop through variables matching pattern
foreach var of varlist dx_* {
    tab `var'
}
```

---

### 9.2 条件执行

```stata
/*====================================
  CONDITIONAL EXECUTION
====================================*/

// If-else in do file
if `pval' < 0.05 {
    di "Statistically significant"
}
else {
    di "Not significant"
}

// Capture (ignore errors)
capture confirm variable age
if _rc == 0 {
    di "Variable age exists"
}
else {
    di "Variable age does not exist"
    gen age = .
}

// Quietly (suppress output)
quietly summarize age
local mean = r(mean)
di "Mean age: " %5.2f `mean'
```

---

### 9.3 Preserve & Restore

```stata
/*====================================
  PRESERVE & RESTORE
====================================*/

// Preserve current dataset
preserve

// Make temporary changes
keep if age >= 65
collapse (mean) bmi, by(state)
list in 1/10

// Restore original dataset
restore

// Now back to original data
```

**使用场景:**
- 临时分析不改变原数据
- 避免重复加载大文件

---

### 9.4 效率技巧

#### 9.4.1 数据压缩

```stata
/*====================================
  DATA EFFICIENCY
====================================*/

// Compress after import
import sasxport5 "large_file.xpt", clear
compress
save compressed_file, replace
// File size: 400MB → 211MB

// Keep only needed variables
use var1 var2 var3 using huge_file.dta, clear

// Drop unnecessary variables early
drop var100-var500
```

#### 9.4.2 排序优化

```stata
// Sort once, use multiple times
sort subject_id hadm_id
bysort subject_id hadm_id: gen n = _n
bysort subject_id hadm_id: gen N = _N

// Instead of:
bysort subject_id hadm_id: gen n = _n
bysort subject_id hadm_id: gen N = _N  // Re-sorts!
```

---

### 9.5 调试技巧

```stata
/*====================================
  DEBUGGING STRATEGIES
====================================*/

// Check variable creation immediately
gen provider_group = substr(admit_provider_id, 1, 2)
tab provider_group  // Verify correct values!

// List examples
list subject_id provider_group admit_provider_id in 1/20

// Check merge results
merge 1:1 id using other_file
tab _merge
list if _merge != 3  // Investigate unmatched

// Use assert for data validation
assert age >= 0 & age <= 120
assert !missing(subject_id)

// Display during execution
di "Checkpoint 1: Data loaded"
di "Number of observations: " _N
```

**关键教训（来自作业3）:**
```stata
// ALWAYS verify variable creation!
gen provider_group = substr(admit_provider_id, 1, 2)
tab provider_group  // Would have caught the substr() error immediately!

// If output shows "0", "1", "2" instead of "P0", "P1", "P2"
// → Fix before running entire analysis!
```

---

## 实战案例篇

### 10.1 完整分析流程示例

```stata
/*==============================================================================
  COMPLETE ANALYSIS WORKFLOW
  Example: Hospital Length of Stay Analysis
==============================================================================*/

/*------------------------------------------------------------------------------
  STEP 1: SETUP
------------------------------------------------------------------------------*/
clear all
set more off
cd "C:\Project\Data"

capture log close
log using analysis.log, replace

/*------------------------------------------------------------------------------
  STEP 2: IMPORT DATA
------------------------------------------------------------------------------*/
di "========== IMPORTING DATA =========="

import delimited "admissions.csv", clear
save admissions.dta, replace

import delimited "patients.csv", clear
save patients.dta, replace

import delimited "drg.csv", clear
save drg.dta, replace

/*------------------------------------------------------------------------------
  STEP 3: MERGE DATASETS
------------------------------------------------------------------------------*/
di "========== MERGING DATASETS =========="

use admissions, clear
merge m:1 subject_id using patients
drop if _merge == 2
drop _merge

merge 1:1 subject_id hadm_id using drg
replace drg_code = 9999 if missing(drg_code)
drop _merge

save merged_data, replace

/*------------------------------------------------------------------------------
  STEP 4: CREATE VARIABLES
------------------------------------------------------------------------------*/
di "========== CREATING VARIABLES =========="

// Date variables
gen admit_date = date(admittime, "YMD hms")
format admit_date %td
gen disch_date = date(dischtime, "YMD hms")
format disch_date %td

// Outcome
gen los = disch_date - admit_date
label variable los "Length of Stay (days)"

// Demographics
gen age = year(admit_date) - birth_year
label variable age "Age at admission"

gen race_eth = ""
replace race_eth = "Black" if regexm(race, "BLACK")
replace race_eth = "White" if regexm(race, "WHITE")
replace race_eth = "Hispanic" if regexm(race, "HISPANIC")
replace race_eth = "Other" if race_eth == ""
encode race_eth, gen(race_num)

// Provider groups
gen provider_group = substr(admit_provider_id, 1, 2)
encode provider_group, gen(provider_num)

// Encode other categoricals
encode insurance, gen(insurance_num)

/*------------------------------------------------------------------------------
  STEP 5: DESCRIPTIVE STATISTICS
------------------------------------------------------------------------------*/
di "========== DESCRIPTIVE STATISTICS =========="

summarize los, detail
tabstat los, by(provider_group) stat(n mean sd p50)

histogram los, bin(20) frequency ///
    title("Distribution of Length of Stay") ///
    xtitle("Days") ytitle("Frequency")
graph export "los_histogram.png", replace

/*------------------------------------------------------------------------------
  STEP 6: REGRESSION ANALYSIS
------------------------------------------------------------------------------*/
di "========== UNADJUSTED ANALYSIS =========="

reg los i.provider_num
margins provider_num

di "========== RISK-ADJUSTED ANALYSIS =========="

reg los i.provider_num age i.race_num i.insurance_num i.drg_code, robust
margins provider_num

/*------------------------------------------------------------------------------
  STEP 7: SAVE RESULTS
------------------------------------------------------------------------------*/
save final_analysis, replace

log close
di "Analysis complete!"
```

---

### 10.2 常见错误速查表

| 错误症状 | 可能原因 | 解决方案 |
|---------|---------|---------|
| 变量全是缺失值 | 条件语句忽略了缺失值 | 添加 `& var != .` |
| `substr()` 结果不对 | 位置参数错误 | 记住：位置从1开始，不是0 |
| 回归提示变量被省略 | 共线性 | 检查固定效应或重复变量 |
| 合并后观测数不对 | 合并类型错误 | 检查应该用1:1, m:1还是1:m |
| `reshape` 失败 | i()或j()变量不对 | 确认唯一标识符和后缀变量 |
| 日期显示为数字 | 忘记format | 使用 `format var %td` 或 `%tc` |
| 图表横轴乱序 | 忘记排序 | 画图前 `sort x_variable` |
| 回归标准误太小 | 未考虑聚类 | 使用 `vce(cluster cluster_var)` |
| `collapse` 后数据丢失 | 覆盖了原数据 | 先 `save` 或 `preserve` |

---

### 10.3 代码规范模板

```stata
/********************************************************************************
* Project: [Project Name]
* Author: [Your Name]
* Date: [Date]
* Purpose: [Brief description]
*
* Input files:
*   - data1.csv
*   - data2.dta
*
* Output files:
*   - analysis_results.dta
*   - figure1.png
********************************************************************************/

/*==============================================================================
  SECTION 1: SETUP
==============================================================================*/
clear all
set more off

// Set directories
cd "C:\Project"
global data ".\data"
global output ".\output"

// Start log
capture log close
log using "$output\analysis_log.log", replace

/*==============================================================================
  SECTION 2: LOAD AND PREPARE DATA
==============================================================================*/
di "========== LOADING DATA =========="

import delimited "$data\file.csv", clear
// ... data cleaning code ...

/*==============================================================================
  SECTION 3: ANALYSIS
==============================================================================*/
di "========== RUNNING ANALYSIS =========="

// ... analysis code ...

/*==============================================================================
  SECTION 4: SAVE RESULTS
==============================================================================*/
save "$output\results.dta", replace

log close
di "Analysis complete!"
```

---

## 附录：快速参考

### A. 常用命令速查

**数据操作:**
```stata
use filename, clear          // Load data
save filename, replace       // Save data
merge 1:1 id using file      // Merge datasets
reshape long var, i(id) j(t) // Reshape to long
collapse (mean) var, by(grp) // Create summary dataset
```

**变量操作:**
```stata
gen var = expression         // Create variable
replace var = expression     // Modify variable
recode var (old=new), gen(new_var)  // Recode
encode str_var, gen(num_var) // String to labeled numeric
destring str_var, gen(num)   // String to numeric
```

**统计分析:**
```stata
sum var, d                   // Summary statistics
tab var, m                   // Frequency table
tabstat var, by(grp) stat(n mean sd)  // Group statistics
reg y x1 x2, r              // Regression with robust SE
logit y x1 x2               // Logistic regression
margins group_var           // Predicted margins
```

**字符串:**
```stata
strupper(str)               // To uppercase
substr(str, pos, len)       // Extract substring
regexm(str, pattern)        // Pattern matching
```

**日期:**
```stata
date(str, "MDY")            // String to date
clock(str, "YMD hms")       // String to datetime
year(date_var)              // Extract year
```

---

### B. 学习路径建议

**Week 1-2: 基础**
- 数据导入与保存
- 变量创建与清理
- 描述性统计
- 简单回归

**Week 3-4: 进阶**
- 数据合并
- 字符串处理
- 日期时间
- 可视化

**Week 5-6: 高级**
- 数据重塑
- 复杂回归（交互、固定效应）
- 缺失值处理
- 编程技巧

**实战项目:**
1. NHANES BMI分析（练习merge, 描述统计, 回归）
2. NHIS趋势分析（练习时间序列, 可视化）
3. MIMIC EHR分析（练习字符串, reshape, 复杂merge）

---

### C. 推荐资源

**官方文档:**
- Stata help: `help command_name`
- Stata manual: [https://www.stata.com/manuals/](https://www.stata.com/manuals/)

**在线资源:**
- UCLA IDRE: [https://stats.idre.ucla.edu/stata/](https://stats.idre.ucla.edu/stata/)
- Stata YouTube频道

**调试技巧:**
1. 每创建一个变量就验证（`tab`, `list`, `sum`）
2. 合并后检查 `_merge`
3. 回归后检查样本量（`e(N)`）
4. 使用 `assert` 验证假设

---

## 结语

这份学习攻略基于你在Large-Scale Data Analysis课程中接触的所有技术，从最基础的数据导入到高级的固定效应回归。

**学习建议:**
1. **边学边练** - 每个命令都在Stata中运行一遍
2. **重视错误** - 每个错误都是学习机会（尤其是substr的教训！）
3. **建立模板** - 为常见任务建立代码模板
4. **记录笔记** - 在CLAUDE.md中记录遇到的问题和解决方案

**记住:**
- 先 `tab` 再 `reg`（先理解数据再分析）
- 先 `save` 再 `collapse`（先保存再汇总）
- 先 `preserve` 再实验（先备份再尝试）

祝学习顺利！
