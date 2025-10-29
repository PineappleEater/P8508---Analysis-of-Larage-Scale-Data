# Large Scale Data 期中考试完整复习指南
# Comprehensive Midterm Study Guide for Large Scale Data

---

## 📋 目录 Table of Contents

1. [考试结构与要求 Exam Structure](#考试结构与要求)
2. [Part 1: 概念与逻辑题复习 Concepts & Logic](#part-1-概念与逻辑题复习)
3. [Part 2: Stata编程复习 Stata Programming](#part-2-stata编程复习)
4. [代码备忘单 Code Cheat Sheet](#代码备忘单)
5. [练习题与答案 Practice Questions](#练习题与答案)
6. [考前检查清单 Pre-Exam Checklist](#考前检查清单)

---

## 考试结构与要求 Exam Structure

### Part 1: 概念与逻辑题（闭卷 Closed-book）

- **目标 Goal**: 不是记忆 (not memorization)，而是应用逻辑推理 (apply logical reasoning) 到新情境
- **重点 Focus**: 解释你的推理过程 (explain your reasoning) 和理由 (rationale)
- **不考 Not Tested**: 具体调查的事实细节 (specific survey facts)（如NHANES的具体响应率 response rate）
- **考察 Testing**: 一般性的优缺点 (pros/cons)、为什么响应率下降 (why response rate declining)、带来什么偏倚 (what biases introduced)

### Part 2: 数据分析（开卷 Open-book）

- **工具 Tool**: Stata
- **允许 Allowed**: 使用代码备忘单 (code cheat sheet)、参考资料 (reference materials)
- **考察 Testing**: 数据清洗 (data cleaning)、合并 (merging)、回归分析 (regression analysis)、结果解读 (interpretation)

---

## Part 1: 概念与逻辑题复习 Concepts & Logic Review

### 1️⃣ 数据类型的优缺点 Pros & Cons of Data Types

#### 横断面调查 Cross-sectional Surveys

**例子 Examples**: BRFSS, NHANES, NHIS

**优点 Advantages**:
- 成本相对较低 (relatively low cost)
- 可以快速收集大量样本 (quickly collect large samples)
- 适合估计某一时间点的流行率 (estimate prevalence at one time point)
- 全国代表性 (nationally representative)（如果设计良好 if well-designed）

**缺点 Disadvantages**:
- 无法追踪个体变化 (cannot track individual changes)
- 难以建立因果关系 (difficult to establish causality)（只能看关联 only associations）
- 只能比较不同人群 (compare different people)，而非同一个人的变化
- 响应率下降问题 (declining response rate) 严重

**最适合的研究问题 Best Research Questions**:
- "美国成年人中糖尿病的患病率是多少？What is the prevalence of diabetes?"
- "不同收入群体的健康保险覆盖率有何差异？Insurance coverage differences by income?"

---

#### 纵向调查 Longitudinal Surveys

**例子 Examples**: MEPS, National Longitudinal Survey of Youth

**优点 Advantages**:
- 可以追踪同一个体随时间的变化 (track same individuals over time)
- 支持 within-person 分析（个体固定效应 individual fixed effects）
- 更好地建立因果推断 (better causal inference)
- 可以控制不随时间变化的个体特征 (control for time-invariant characteristics)

**缺点 Disadvantages**:
- 成本高昂 (high cost)
- 样本流失 attrition 问题
- 数据收集周期长 (long data collection period)
- 可能存在学习效应 (learning effects)

**最适合的研究问题 Best Research Questions**:
- "生孩子后睡眠时间是否减少？Does having a baby reduce sleep?"
- "退休后心理健康是否改善？Does retirement improve mental health?"
- "失业对健康的影响如何？Impact of unemployment on health?"

---

#### Claims/出院数据 Discharge Data

**例子 Examples**: SPARCS, Medicare Claims

**优点 Advantages**:
- 样本量巨大 (large sample size)
- 包含实际医疗利用和费用信息 (actual healthcare utilization & costs)
- 跨多个医疗机构 (across multiple providers)
- 行政数据 (administrative data)，较少缺失值 (less missing data)
- 可以追踪同一患者在不同医疗机构的就诊 (track patients across providers)

**缺点 Disadvantages**:
- 缺乏临床细节 (lack clinical details)（如实验室结果 lab results、生命体征 vital signs）
- 诊断可能不准确 (diagnoses may be inaccurate)（为了计费目的 for billing purposes）
- 没有未就医的人群 (excludes non-users)
- 缺少社会经济背景信息 (lack socioeconomic information)
- 可能有编码错误 (coding errors)

**最适合的研究问题 Best Research Questions**:
- "不同县的住院费用是否有差异？Hospitalization cost differences by county?"
- "90天再入院率是多少？What is the 90-day readmission rate?"

**质量指标适用性 Quality Metrics Applicability**:
- ✅ 适合 Good for: 再入院率 (readmission rate)、住院天数 (length of stay)、医疗利用 (utilization)
- ❌ 不适合 Not good for: 需要详细临床数据的指标 (metrics requiring clinical details)（如血压控制率 BP control rate）

---

#### EHR 数据 Electronic Health Records

**例子 Examples**: 医院系统的电子病历 Hospital system EHR

**优点 Advantages**:
- 详细的临床信息 (detailed clinical information)（实验室结果 lab results、生命体征 vital signs、用药 medications）
- 纵向数据 (longitudinal data)（重复就诊 repeated visits）
- 真实世界数据 (real-world data)
- 包含非结构化数据 (unstructured data)（医生笔记 physician notes）

**缺点 Disadvantages**:
- 仅限单一医疗系统内的人群 (limited to single health system)
- 数据质量参差不齐 (variable data quality)
- 可能有系统性偏倚 (systematic bias)（只有在该系统就医的人 only users of that system）
- 缺少其他医疗系统的就诊记录 (missing visits to other systems)
- 数据标准化困难 (difficult to standardize)

**最适合的研究问题 Best Research Questions**:
- "特定医疗系统中糖尿病患者的血糖控制情况 Diabetes control in a specific system"
- "某种新药在真实世界中的疗效 Real-world effectiveness of a new drug"

**质量指标适用性 Quality Metrics Applicability**:
- ✅ 适合 Good for: 需要详细临床数据的指标（如HbA1c控制率 HbA1c control rate）
- ❌ 不适合 Not good for: 需要跨系统数据的指标（如90天全因再入院率 all-cause 90-day readmission）

---

#### 文本数据 Text-based Data

**例子 Examples**: 医生笔记 physician notes、主诉字段 chief complaint

**优点 Advantages**:
- 包含丰富的非结构化信息 (rich unstructured information)
- 可能包含其他数据源没有的细节 (details not in other sources)

**缺点 Disadvantages**:
- 需要自然语言处理技术 (requires NLP - natural language processing)
- 分析复杂 (complex analysis)
- 质量不一致 (inconsistent quality)

---

### 2️⃣ 回归分析核心概念 Core Regression Concepts

#### Survey Weights 调查权重

**为什么需要调查权重？ Why use survey weights?**

1. **设计性过度抽样 Design-based oversampling**: 调查设计时故意多抽取某些群体（如少数族裔 minority groups）
2. **低响应率 Low response rate**: 某些群体的响应率较低
3. **非代表性样本 Non-representative sample**: 即使是随机抽样，也可能运气不好抽到非代表性样本

**如何理解？ How to understand?**
- 调查权重 (survey weight) 表示每个受访者"代表"多少人
- 权重 = 1.5 意味着这个受访者代表 represents 1.5个人
- 使用权重后的结果可以推广到整体人群 (generalize to population)

**什么时候使用？ When to use?**
- 分析调查数据时（BRFSS, NHANES, NHIS, MEPS等）
- 想要结果代表整体人群 (want results representative of population) 时

**Stata代码 Code**:
```stata
// 设置调查设计 Set survey design
svyset [pweight = weight_variable]

// 带权重的回归 Weighted regression
svy: reg outcome predictors
```

---

#### 分类变量 vs 连续变量 Categorical vs Continuous Variables

**分类变量 Categorical Variables**:
- 使用 `i.variable` 前缀 (prefix)
- Stata会自动创建虚拟变量 (dummy variables)
- 第一个类别自动成为参考组 (reference group)
- 例子: 种族 (race)、年龄组 (age group)、入院类型 (admission type)

**连续变量 Continuous Variables**:
- 使用 `c.variable` 或直接写变量名
- 系数 (coefficient) 表示变量每增加1个单位的效应 (effect per 1-unit increase)
- 例子: 年龄 (age)、收入 (income)、BMI、住院天数 (length of stay)

**何时选择？ When to choose?**
- 如果变量有自然顺序且差异有意义 (natural order & meaningful differences) → 连续 continuous
- 如果想看每个类别的独立效应 (separate effect for each category) → 分类 categorical
- 如果关系可能非线性 (relationship may be non-linear) → 考虑分类

---

#### Logistic vs Linear 回归 Regression

**对于二元结果 For binary outcomes，两种都可以，但要正确解读！Both OK but interpret correctly!**

| 特征 Feature | Logistic回归 | Linear回归 |
|------|-------------|-----------|
| **命令 Command** | `logistic` 或 `logit` | `reg` |
| **结果解读 Interpretation** | Odds Ratios 比值比 | Percentage Point Difference 百分点差异 |
| **系数含义 Coefficient Meaning** | 几率的倍数变化 fold-change in odds | 概率的加法变化 additive change in probability |
| **例子解读 Example** | "OR=1.5表示几率增加50%" | "coef=0.04表示概率增加4个百分点" |

**Logistic回归解读示例 Logistic Interpretation Example**:
```
系数 Coefficient = 1.5 (OR)
解读 Interpretation: "县收入每增加$1000，expensive stay的几率 (odds) 增加50%
Each $1000 increase in county income is associated with 50% increase in odds of expensive stay"
```

**Linear回归解读示例 Linear Interpretation Example**:
```
系数 Coefficient = 0.04
解读 Interpretation: "县收入每增加$1000，expensive stay的概率 (probability) 增加4个百分点（从10%到14%）
Each $1000 increase in county income is associated with 4 percentage point increase
in probability of expensive stay (e.g., from 10% to 14%)"
```

---

#### Interaction Terms 交互项

**目的 Purpose**: 测试 X 和 Y 的关系是否因变量 Z 而异
Test if the relationship between X and Y varies by variable Z

**例子 Examples**:
- 收入对健康的影响是否因性别而异？Does income effect on health vary by sex?
- 药物效果是否因年龄而异？Does drug effect vary by age?

**Stata语法 Syntax**:
```stata
// ## 包含主效应和交互效应 includes main effects + interaction
reg outcome var1##var2

// # 仅交互效应 interaction only
reg outcome var1#var2
```

---

#### Individual Fixed Effects 个体固定效应

**什么时候使用？ When to use?**
- 有纵向数据 (longitudinal data)（同一个人多个时间点 same person, multiple time points）
- 想要控制个体内部不随时间变化的因素 (control for time-invariant individual factors)
- 想要研究"个体内部的变化" (within-person changes)

**优点 Advantages**:
- 控制所有不随时间变化的个体特征 (controls all time-invariant characteristics)（无论观察到还是未观察到 observed or unobserved）
- 更强的因果推断 (stronger causal inference)

**Stata命令 Commands**:
```stata
// 设置面板数据 Set panel data
xtset person_id

// 固定效应回归 Fixed effects regression
xtreg outcome predictors, fe
```

---

#### Robust Standard Errors 稳健标准误

**为什么使用？ Why use?**
- 异方差 heteroskedasticity: 不同观察值的误差方差不同 (error variance differs across observations)
- 大样本中很常见 (common in large samples)
- 使标准误更准确 (makes standard errors more accurate)

**Stata语法 Syntax**:
```stata
reg outcome predictors, r
// 或 or
reg outcome predictors, robust
```

**纪律差异 Disciplinary differences**:
- 经济学 Economics: 几乎总是使用 robust SE
- 生物统计 Biostatistics: 不一定使用
- 考试 Exam: 不会因为不使用而扣分，但要知道为什么可能想用

---

### 3️⃣ 统计显著性 vs 实际意义 Statistical vs Practical Significance

**关键区别 Key Distinction**:

| 统计显著性 Statistical Significance | 实际/临床意义 Practical/Clinical Significance |
|-----------|-------------|
| p < 0.05 | 差异是否足够大到重要 Is difference large enough to matter |
| 受样本量影响 Affected by sample size | 不受样本量影响 Not affected by sample size |
| 技术性判断 Technical judgment | 实质性判断 Substantive judgment |

**例子 Example**:
在50万人的BRFSS调查中 In BRFSS survey of 500,000 people，发现Gen Z和Millennials的每日运动时间差3分钟（20分钟 vs 23分钟），p=0.007。

**分析 Analysis**:
- ✅ **统计显著 Statistically significant**: p < 0.05
- ❓ **实际意义 Practical significance**: 值得讨论 debatable
  - 3分钟可能太小，没有健康益处 may be too small for health benefits
  - 但这是>10%的差异，可能有意义 but >10% difference, may matter
  - 在大样本中 in large samples，即使很小的差异也能达到统计显著（"overpowered"）

---

### 4️⃣ 变量类型与处理 Variable Types & Handling

#### Binary/Dummy Variables 二元变量

**定义 Definition**: 0/1 标志变量 flag variable

**常用场景 Common Uses**:
- 计算百分比 calculate percentages（如流感疫苗接种率 flu vaccination rate）
- 作为结果变量 as outcome variable（logistic或linear回归）
- 作为控制变量 as control variable

**创建方法 Creation Method**:
```stata
// 标准方法 Standard approach
gen flag = 1 if condition
replace flag = 0 if opposite_condition
```

**验证方法 Verification**:
```stata
summ flag  // mean应该在0-1之间 should be 0-1
tab original_var flag
```

---

#### Categorical Variables 分类变量

**例子 Examples**: 种族 race、教育水平 education level、入院类型 admission type

**处理方法 Handling Methods**:
```stata
// 方法1 Method 1: encode（字符串→数值分类 string to numeric categorical）
encode string_var, gen(categorical_var)

// 方法2 Method 2: 手动创建 manual creation
gen race_cat = 1 if race == "White"
replace race_cat = 2 if race == "Black"

// 使用时加 i. 前缀 Use with i. prefix in regression
reg outcome i.categorical_var
```

---

#### Continuous Variables 连续变量

**例子 Examples**: 年龄 age、BMI、收入 income、住院天数 length of stay

**常见处理 Common Handling**:
```stata
// Top-coding 截尾（处理极端值 handle outliers）
gen var_clean = var
replace var_clean = 1000000 if var > 1000000 & var != .

// 对数转换 Logarithmic transformation（处理右偏数据 handle right-skewed data）
gen log_var = log(var + 1)  // +1避免log(0) avoid log(0)
```

---

#### String Variables 字符串变量

**常见操作 Common Operations**:
```stata
// 转换为数值 Convert to numeric
destring string_var, gen(numeric_var) force

// 查看无法转换的值 Check what couldn't be converted
tab string_var if numeric_var == .

// 字符串匹配 String matching
gen flag = 1 if strpos(string_var, "keyword") > 0
```

---

#### Missing Values 缺失值

**关键原则 Key Principle**: 在所有条件中加入 `& var != .`
Always add `& var != .` in conditions

**原因 Reason**: Stata中缺失值（.）被视为非常大的数
Missing (.) is treated as very large number in Stata

**正确做法 Correct Approach**:
```stata
// ✅ 正确 Correct
replace var_clean = 100 if var > 100 & var != .

// ❌ 错误 Wrong（会把缺失值也设为100 will also set missing to 100）
replace var_clean = 100 if var > 100
```

---

### 5️⃣ 数据管理操作 Data Management Operations

#### Merging 合并数据

**四种合并类型 Four Merge Types**:

##### 1:1 Merge
- **场景 Scenario**: 两个数据集都是每个ID一行 both datasets have 1 row per ID
- **例子 Example**: 合并NHANES的饮酒问卷到人口统计文件（都是每人一行）

```stata
merge 1:1 person_id using "second_dataset.dta"
```

##### 1:M Merge
- **场景 Scenario**: 主数据集每ID一行，第二个数据集每ID多行
  Master: 1 row per ID, Using: many rows per ID
- **例子 Example**: 合并就诊数据到用药数据

```stata
merge 1:m visit_id using "medications.dta"
```

##### M:1 Merge（最常用！Most common!）
- **场景 Scenario**: 主数据集每ID多行，第二个数据集每ID一行
  Master: many rows per ID, Using: 1 row per ID
- **例子 Example**: 合并县级收入数据到住院数据（同一县可能有多次住院）

```stata
merge m:1 county_name using "county_data.dta"
```

**合并后的检查 Post-merge Check**:
```stata
tab _merge
/*
_merge == 1: 仅在主数据集中 master only
_merge == 2: 仅在第二个数据集中 using only
_merge == 3: 两个数据集都有（匹配成功 matched）
*/

// 通常保留1和3 Usually keep 1 and 3
keep if _merge == 1 | _merge == 3
drop _merge
```

---

#### Reshape/Transpose 重塑数据

**Wide → Long 宽到长**:
```stata
reshape long var_prefix, i(id) j(time)
```

**Long → Wide 长到宽**:
```stata
reshape wide var_name, i(id) j(time)
```

#### Append 追加数据

**场景 Scenario**: 合并结构相同的数据集（增加行数 add rows）

```stata
append using "second_dataset.dta"
```

---

## Part 2: Stata编程复习 Stata Programming Review

### 🔧 完整工作流程 Complete Workflows

#### 工作流程1: 清洗结果变量 Clean Outcome Variable

```stata
// 1. 探索原始数据 Explore raw data
codebook variable_name
tab variable_name, m
summ variable_name, d

// 2. 识别问题 Identify issues
// - 缺失值是什么？What represents missing?
// - 有异常值吗？Any outliers?
// - 数据类型正确吗？Correct data type?

// 3. 创建清洗版本 Create clean version
gen var_clean = var_original

// 4. 处理缺失值 Handle missing
replace var_clean = . if var_original == 99
replace var_clean = . if var_original < 0

// 5. 处理异常值 Handle outliers（top-code 截尾）
replace var_clean = 1000000 if var_original > 1000000 & var_original != .

// 6. 验证 Verify
summ var_clean, d
tab var_original var_clean
```

---

#### 工作流程2: 验证变量质量 Verify Variable Quality

```stata
// 1. 对于二元/分类变量 For binary/categorical variables
tab new_var old_var  // 交叉表 cross-tabulation
tab new_var, m       // 检查缺失 check missing

// 2. 对于连续变量 For continuous variables
summ new_var, d      // 检查范围、均值、中位数 check range, mean, median
summ new_var if condition == 1
summ new_var if condition == 0
histogram new_var    // 可选：可视化 optional: visualize

// 3. 对于二元变量特别检查 Special check for binary variables
summ binary_var
// mean应该在0-1之间 should be 0-1
// min应该是0，max应该是1 min=0, max=1

// 4. 检查缺失值 Check missing
count if new_var == .
```

---

#### 工作流程3: 合并数据 Merge Data

```stata
// 1. 理解数据结构 Understand data structure
// - 主数据集unique by什么？Master unique by what?
// - 第二个数据集unique by什么？Using unique by what?

// 2. 检查合并变量 Check merge variable
// - 变量名是否一致？Names match?（不一致需要rename）
// - 变量类型是否一致？Types match?（都是数值或都是字符串）
// - 变量值是否匹配？Values match?（如大小写、空格）

// 3. 执行合并 Perform merge
merge m:1 merge_var using "file.dta"

// 4. 检查合并结果 Check merge results
tab _merge
// 决定保留哪些记录 decide what to keep

// 5. 清理 Clean up
keep if _merge == 1 | _merge == 3
drop _merge
```

---

#### 工作流程4: 回归分析 Regression Analysis

```stata
// 1. 准备变量 Prepare variables
// - 结果变量清洗完成 outcome cleaned
// - 预测变量清洗完成 predictors cleaned
// - 确定变量类型 determine variable types（连续 vs 分类）

// 2. 运行回归 Run regression
// - 选择回归类型 choose regression type（linear vs logistic）
// - 确定控制变量 determine control variables
// - 决定是否用robust SE decide whether to use robust SE

reg outcome predictor1 predictor2 i.categorical_var, r

// 3. 检查结果 Check results
// - 系数的方向符合预期吗？Coefficients in expected direction?
// - 显著性如何？Significance level?
// - 样本量正确吗？Sample size correct?
// - R-squared合理吗？R-squared reasonable?

// 4. 解读结果 Interpret results
// - 写出系数的含义 write coefficient meaning
// - 说明统计显著性 state statistical significance
// - 评估实际意义 assess practical significance
// - 考虑控制变量的作用 consider role of controls
```

---

## 代码备忘单 Code Cheat Sheet

### 📝 变量清洗 Variable Cleaning

```stata
/* ========================================
   探索数据 Explore Data
   ======================================== */

// 查看变量信息 View variable info
codebook variable_name
describe variable_name

// 汇总统计 Summary statistics（d = detail）
summ variable_name, d

// 频率表 Frequency table（m = missing）
tab variable_name, m

// 查看前几行数据 View first few rows
list variable_name in 1/10

/* ========================================
   创建二元变量 Create Binary Variable (0/1 Flag)
   ======================================== */

// 标准方法 Standard method
gen binary_var = 1 if condition
replace binary_var = 0 if opposite_condition

// 例子1 Example 1: 年龄18岁及以上 age 18 and over
gen adult = 1 if age >= 18 & age != .
replace adult = 0 if age < 18 & age != .

// 例子2 Example 2: 昂贵住院 expensive hospitalization（费用>$50,000）
gen expensive = 1 if totalcosts > 50000 & totalcosts != .
replace expensive = 0 if totalcosts <= 50000 & totalcosts != .

// 例子3 Example 3: 急诊标志 ED flag
gen ED_flag = 1 if ed_indicator == "Y"
replace ED_flag = 0 if ed_indicator == "N"

// 验证二元变量 Verify binary variable
summ binary_var  // mean应在0-1之间，min=0, max=1
tab original_var binary_var

/* ========================================
   处理缺失值 Handle Missing Values
   ======================================== */

// 识别缺失值的编码 Identify missing value codes
tab variable_name, m
codebook variable_name

// 将特定值设为系统缺失 Set specific values to system missing
replace variable_name = . if variable_name == 99
replace variable_name = . if variable_name == 999
replace variable_name = . if variable_name < 0

// 在条件中保护缺失值 Protect missing in conditions（重要！Important!）
replace new_var = value if old_var > threshold & old_var != .

// 创建缺失标志 Create missing flag
gen missing_flag = (variable_name == .)

/* ========================================
   Top-coding 截尾（处理极端值 Handle Outliers）
   ======================================== */

// 标准方法 Standard method
gen var_clean = var_original
replace var_clean = 1000000 if var_original > 1000000 & var_original != .

// 验证 Verify
summ var_original, d
summ var_clean, d

/* ========================================
   分类变量处理 Handle Categorical Variables
   ======================================== */

// 方法1 Method 1: encode（字符串→数值分类 string to numeric categorical）
encode string_var, gen(categorical_var)

// 方法2 Method 2: 手动创建 manual creation（更多控制 more control）
gen admission_type = .
replace admission_type = 1 if type == "Elective"
replace admission_type = 2 if type == "Emergency"
replace admission_type = 3 if type == "Urgent"

// 添加值标签 Add value labels
label define admission_lbl 1 "Elective" 2 "Emergency" 3 "Urgent"
label values admission_type admission_lbl

// 在回归中使用 Use in regression（自动创建虚拟变量 auto-create dummies）
reg outcome i.categorical_var

/* ========================================
   字符串变量处理 Handle String Variables
   ======================================== */

// 转换为数值 Convert to numeric（force忽略无法转换的 force ignores errors）
destring string_var, gen(numeric_var) force

// 查看无法转换的值 Check what couldn't be converted
tab string_var if numeric_var == .

// 处理特殊字符串 Handle special strings（例子：length of stay "120 +"）
destring lengthofstay, gen(los_num) force
replace los_num = 120 if lengthofstay == "120 +"

// 字符串匹配 String matching
gen contains_keyword = strpos(string_var, "keyword") > 0

/* ========================================
   对数转换 Logarithmic Transformation
   ======================================== */

// 处理右偏数据 Handle right-skewed data
gen log_cost = log(cost + 1)  // +1避免log(0) avoid log(0)

// 或者先处理0值 Or handle 0 values first
gen log_cost = log(cost) if cost > 0
replace log_cost = 0 if cost == 0

/* ========================================
   创建分组变量 Create Grouped Variables
   ======================================== */

// 基于连续变量创建分类 Create categories from continuous
gen age_group = 1 if age < 30
replace age_group = 2 if age >= 30 & age < 50
replace age_group = 3 if age >= 50 & age < 70
replace age_group = 4 if age >= 70 & age != .

// 使用recode（更简洁 more concise）
recode age (0/29=1) (30/49=2) (50/69=3) (70/max=4), gen(age_group)
```

---

### 📊 数据合并 Data Merging

```stata
/* ========================================
   M:1 Merge（最常用！Most common!）
   ======================================== */

// 场景 Scenario：合并县级数据到个人数据
// Merge county-level data to individual records
// 准备工作 Preparation
use "main_data.dta", clear
rename county County_Name  // 确保变量名一致 ensure names match

// 执行合并 Perform merge
merge m:1 County_Name using "county_characteristics.dta"

// 检查结果 Check results
tab _merge
/*
1 = master only（主数据集独有 in master only）
2 = using only（第二数据集独有 in using only）
3 = matched（匹配成功 matched successfully）
*/

// 保留想要的记录 Keep desired records
keep if _merge == 1 | _merge == 3  // 保留主数据集的所有记录 keep all master records
// 或 OR
keep if _merge == 3  // 只保留匹配的记录 keep matched only

// 清理 Clean up
drop _merge

/* ========================================
   1:1 Merge
   ======================================== */

// 场景 Scenario：合并两个都是每人一行的数据集
// Merge two datasets, both with 1 row per person
use "demographics.dta", clear
merge 1:1 person_id using "questionnaire.dta"

tab _merge
keep if _merge == 3  // 通常只保留匹配的 usually keep matched only
drop _merge

/* ========================================
   1:M Merge
   ======================================== */

// 场景 Scenario：主数据集每ID一行，第二数据集每ID多行
// Master has 1 row per ID, using has many rows per ID
use "visits.dta", clear
merge 1:m visit_id using "medications.dta"

tab _merge
keep if _merge == 3
drop _merge

/* ========================================
   Merge前的检查 Pre-merge Checks
   ======================================== */

// 检查变量是否唯一 Check if variable is unique
use "data.dta", clear
duplicates report merge_variable
// 应该显示0 duplicates（对于1端 for the "1" side）

// 检查变量类型 Check variable type
describe merge_variable

// 检查变量值 Check variable values
tab merge_variable
summ merge_variable

/* ========================================
   Append（追加行 Stack Rows）
   ======================================== */

// 场景 Scenario：合并结构相同的数据集
// Combine datasets with same structure
use "data2020.dta", clear
append using "data2021.dta"
append using "data2022.dta"
```

---

### 📈 回归分析 Regression Analysis

```stata
/* ========================================
   线性回归 Linear Regression
   ======================================== */

// 基本线性回归 Basic linear regression
reg outcome predictor

// 多个预测变量 Multiple predictors
reg outcome predictor1 predictor2 predictor3

// 带分类变量 With categorical variables（i.前缀 i. prefix）
reg outcome continuous_var i.categorical_var

// 带robust标准误 With robust standard errors（推荐 recommended!）
reg outcome predictor1 predictor2, robust
// 或简写 or shorthand:
reg outcome predictor1 predictor2, r

// 完整例子 Complete example
reg totalcosts_clean County_Income lengthofstay i.agegroup i.ED_flag i.admission_type, r

/* ========================================
   Logistic回归 Logistic Regression
   ======================================== */

// Logistic回归 Logistic regression（输出odds ratios）
logistic binary_outcome predictor1 predictor2

// 带分类变量 With categorical variables
logistic binary_outcome continuous_var i.categorical_var

// 例子 Example
logistic expensive_stay County_Income lengthofstay i.agegroup i.ED_flag

/* ========================================
   交互项 Interaction Terms
   ======================================== */

// 分类×分类 Categorical × Categorical
reg outcome i.var1##i.var2
// ## 包含主效应和交互效应 includes main effects + interaction

// 分类×连续 Categorical × Continuous
// ⚠️ 重要 IMPORTANT: 连续变量使用c. 前缀！Use c. for continuous!
reg outcome i.category##c.continuous

// 例子 Example：收入效应是否因性别而异？
// Does income effect vary by sex?
reg health i.sex##c.income age

/* ========================================
   调查权重 Survey Weights
   ======================================== */

// 设置调查设计 Set survey design
svyset [pweight = survey_weight]

// 带权重的回归 Weighted regression
svy: reg outcome predictors
svy: logistic binary_outcome predictors

/* ========================================
   个体固定效应 Individual Fixed Effects（纵向数据 Longitudinal Data）
   ======================================== */

// 设置面板数据 Set panel data
xtset person_id time_variable

// 固定效应回归 Fixed effects regression
xtreg outcome predictors, fe

// 随机效应回归 Random effects regression（对比 for comparison）
xtreg outcome predictors, re

/* ========================================
   回归后检查 Post-regression Checks
   ======================================== */

// 查看完整结果 View complete results
reg outcome predictors
estimates table

// 预测值 Predicted values
predict yhat

// 残差 Residuals
predict residuals, residuals

// 诊断图 Diagnostic plots
rvfplot  // 残差 vs 拟合值 residuals vs fitted values
```

---

### ✅ 验证与检查 Verification & Validation

```stata
/* ========================================
   变量验证 Variable Verification
   ======================================== */

// 交叉表 Cross-tabulation（分类/二元变量 categorical/binary variables）
tab new_var old_var
tab new_var old_var, row col  // 带百分比 with percentages

// 汇总统计 Summary statistics（连续变量 continuous variables）
summ new_var, d

// 分组汇总 Grouped summary
bysort group_var: summ outcome_var
// 或 or
summ outcome if group == 1
summ outcome if group == 0

// 检查二元变量范围 Check binary variable range
summ binary_var
// mean应在0-1之间，min=0, max=1
// mean should be 0-1, min=0, max=1

/* ========================================
   数据探索 Data Exploration
   ======================================== */

// 描述所有变量 Describe all variables
describe

// 汇总所有数值变量 Summarize all numeric variables
summ

// 列出变量名 List variable names
ds

// 查看数据维度 View data dimensions
display _N  // 观察数量 number of observations
display c(k)  // 变量数量 number of variables

/* ========================================
   缺失值检查 Check Missing Values
   ======================================== */

// 统计缺失值 Count missing
count if variable == .

// 所有变量的缺失值 Missing for all variables
mdesc

// 缺失值模式 Missing patterns
misstable summarize
misstable patterns

/* ========================================
   异常值检查 Check Outliers
   ======================================== */

// 识别异常值 Identify outliers
summ variable, d
// 查看p1, p99 check p1, p99

// 列出异常值 List outliers
list id variable if variable > p99_value

/* ========================================
   逻辑检查 Logic Checks
   ======================================== */

// 检查不可能的值 Check impossible values
assert age >= 0 & age <= 120
// 如果有违反，Stata会报错 Stata will error if violated

// 统计违反条件的观察 Count violations
count if age < 0 | age > 120

// 检查互斥条件 Check mutually exclusive conditions
assert (var1 == 1 & var2 == 0) | (var1 == 0 & var2 == 1)
```

---

## 练习题与答案 Practice Questions & Answers

### 📚 概念题练习 Conceptual Practice

#### 练习1 Practice 1: 纵向 vs 横断面数据 Longitudinal vs Cross-sectional

**题目 Question**:
你正在研究"生孩子是否导致睡眠时间减少 Does having a baby reduce sleep time"。有两个数据集可选：
1. National Longitudinal Survey of Youth 97: 从1997年开始每年调查同一批青少年
2. NHIS: 每年调查不同的美国人样本

哪个数据集更适合，为什么？Which is better and why?

**答案 Answer**:
National Longitudinal Survey of Youth 97更适合。原因：
- 研究问题关注的是"生孩子后的变化 changes after having a baby"，需要追踪同一个人在生孩子前后的睡眠变化
- 纵向数据可以进行 within-person analysis（个体内分析），比较同一个人生孩子前后的睡眠时间
- 横断面数据 cross-sectional data 只能比较有孩子的人和没孩子的人，但这两组人可能在很多其他方面不同（年龄 age、收入 income等），难以建立因果关系 establish causality
- 纵向数据可以控制个体内部不随时间变化的因素 control for time-invariant individual factors

---

#### 练习2 Practice 2: 对数转换 Log Transformation

**题目 Question**:
你的主管建议对右偏的费用数据进行"对数转换 log transformation"。这是什么意思？需要哪些步骤？

**答案 Answer**:
对数转换 log transformation 是将右偏分布 right-skewed distribution 转换为更接近正态分布 more normal distribution：

1. **原因 Reason**: 费用数据 cost data 通常右偏（大多数人费用低，少数人费用极高 most low, few very high）
2. **步骤 Steps**:
   - 先处理0值（因为log(0)未定义 undefined）：`gen cost_plus1 = cost + 1`
   - 取对数 take log：`gen log_cost = log(cost_plus1)`
   - 验证 verify：`histogram log_cost` 查看分布 check distribution
3. **优点 Advantages**:
   - 使数据更接近正态分布 more normal distribution
   - 减少极端值的影响 reduce impact of outliers
   - 回归结果更容易解释 easier to interpret（百分比变化 percentage changes）

---

#### 练习3 Practice 3: 调查权重 Survey Weights

**题目 Question**:
你决定在分析中使用调查权重 survey weights。用几句话向同事解释为什么。

**答案 Answer**:
调查权重使分析结果能够代表整体人群 make results representative of population：
- 调查样本可能不是完全随机的（某些群体被过度抽样 oversampling，某些群体响应率低 low response rate）
- 权重 weights 告诉我们每个受访者"代表 represent"多少人
- 例如，权重=1.5意味着这个受访者代表1.5个人
- 使用权重后，结果可以推广到整个美国人口 generalize to US population，而不仅仅是样本 sample

---

## 考前检查清单 Pre-Exam Checklist

### ✅ Part 1准备 Part 1 Preparation

- [ ] 理解不同数据类型的优缺点 Understand pros/cons of data types
- [ ] 能够根据研究问题选择合适的数据类型 Choose appropriate data type for research questions
- [ ] 理解调查权重的作用 Understand role of survey weights
- [ ] 区分统计显著性和实际意义 Distinguish statistical vs practical significance
- [ ] 知道何时用logistic vs linear回归 Know when to use logistic vs linear
- [ ] 理解如何解读两种回归的系数 Interpret coefficients from both regressions
- [ ] 了解交互项的用途 Understand purpose of interaction terms
- [ ] 理解固定效应的概念 Understand fixed effects concept
- [ ] 能够识别合适的合并类型 Identify appropriate merge type（1:1, 1:M, M:1）
- [ ] 知道什么质量指标适合什么数据类型 Know which quality metrics for which data

### ✅ Part 2准备 Part 2 Preparation

**代码技能 Coding Skills**:
- [ ] 创建0/1二元变量 Create 0/1 binary variables
- [ ] Top-code连续变量 Top-code continuous variables
- [ ] 使用encode处理分类变量 Use encode for categorical variables
- [ ] destring字符串变量 Destring string variables
- [ ] 处理缺失值 Handle missing values（& var != .）
- [ ] 执行M:1 merge Perform M:1 merge
- [ ] 检查merge结果 Check merge results（tab _merge）
- [ ] 运行线性回归 Run linear regression with分类变量（i.）
- [ ] 运行logistic回归 Run logistic regression
- [ ] 使用robust标准误 Use robust standard errors
- [ ] 验证新创建的变量 Verify newly created variables

**验证技能 Verification Skills**:
- [ ] 用tab做交叉表验证 Use tab for cross-tabulation verification
- [ ] 用summ检查连续变量范围 Use summ to check continuous variable range
- [ ] 分组汇总 Grouped summary（summ if）
- [ ] 检查二元变量的均值在0-1之间 Check binary mean is 0-1

**解读技能 Interpretation Skills**:
- [ ] 解读线性回归系数 Interpret linear regression coefficients
- [ ] 解读logistic回归的OR Interpret logistic OR
- [ ] 评估统计显著性 Assess statistical significance
- [ ] 评估实际意义 Assess practical significance
- [ ] 写出完整的结果解读 Write complete interpretation

---

## 🎯 最后的建议 Final Advice

### Part 1策略 Part 1 Strategy
1. **解释"为什么 why"**: 不只说"我会用纵向数据 I'll use longitudinal"，要说"因为能追踪个体变化 because can track individual changes"
2. **举例说明 Give examples**: 用具体例子支持你的论点 support arguments with examples
3. **承认权衡 Acknowledge tradeoffs**: "虽然X有优点 advantage，但也有Y这个缺点 disadvantage"
4. **展示思考 Show thinking**: 让评分者看到你的推理过程 let grader see reasoning

### Part 2策略 Part 2 Strategy
1. **先探索再清洗 Explore then clean**: 先用tab/summ了解数据 understand data first
2. **每步验证 Verify each step**: 不要等到最后才检查 don't wait until end
3. **保护缺失值 Protect missing**: 在所有条件中加 `& var != .` in all conditions
4. **注释代码 Comment code**: 简短注释帮助你追踪思路 help track your thinking
5. **完整解读 Complete interpretation**: 不只报告系数 not just coefficient，要完整解释含义 explain meaning

---

## 📚 重要概念快速参考 Quick Reference of Key Concepts

| 概念 Concept | 关键点 Key Points |
|------|--------|
| **Survey Weights 调查权重** | 使样本代表人群 make sample representative；每个人"代表"多少人 how many each person represents |
| **Logistic回归** | 系数=Odds Ratios 比值比（几率比） |
| **Linear回归** | 系数=百分点差异 percentage point difference |
| **M:1 merge** | 主数据集多行/ID master many rows/ID，第二数据集一行/ID using 1 row/ID |
| **i.variable** | 分类变量前缀 categorical prefix，自动创建虚拟变量 auto-create dummies |
| **Robust SE 稳健标准误** | 处理异方差 handle heteroskedasticity，使标准误更准确 more accurate SEs |
| **Top-coding 截尾** | 将极端值限制在某个上限 cap extreme values at threshold |
| **encode** | 字符串→数值分类变量 string to numeric categorical |
| **destring** | 字符串→数值 string to numeric（加force忽略错误 add force to ignore errors） |
| **& var != .** | 保护缺失值不被误处理 protect missing from mishandling |
| **Fixed Effects 固定效应** | 控制个体内不变特征 control time-invariant characteristics；纵向数据 longitudinal |
| **Interaction 交互项** | 测试X→Y关系是否因Z而异 test if X→Y varies by Z |

---

## 💪 你能做到！You Can Do This!

记住老师说的 Remember what professor said：
> "你能做到困难的事情——这是一个非常安全的尝试场所。
> You can do challenging things – this is a very safe place to try."

这门课的目标 Course goals 不是让你成为编程专家 not to make you coding expert，而是：
- 建立使用大规模数据的信心 Build confidence with large-scale data
- 培养逻辑思维和问题解决能力 Develop logical thinking & problem-solving
- 学会选择合适的方法回答研究问题 Choose appropriate methods for research questions
- 理解数据分析的局限性和优势 Understand limitations & strengths of data analysis

你已经学了这么多，做了这么多练习 You've learned so much and practiced。
相信你的准备 Trust your preparation，相信你的能力 trust your abilities！

祝考试顺利！Good luck on your exam！🎓

---

*最后更新 Last Updated: 2025年10月 October 2025*
*根据Session 8复习材料编制 Based on Session 8 review materials*
