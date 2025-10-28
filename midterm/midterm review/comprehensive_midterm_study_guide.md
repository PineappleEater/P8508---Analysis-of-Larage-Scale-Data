# Large Scale Data 期中考试完整复习指南

## 📋 目录
1. [考试结构与要求](#考试结构与要求)
2. [Part 1: 概念与逻辑题复习](#part-1-概念与逻辑题复习)
3. [Part 2: Stata编程复习](#part-2-stata编程复习)
4. [代码备忘单](#代码备忘单)
5. [练习题与答案](#练习题与答案)
6. [考前检查清单](#考前检查清单)

---

## 考试结构与要求

### Part 1: 概念与逻辑题（闭卷）
- **目标**: 不是记忆，而是应用逻辑推理到新情境
- **重点**: 解释你的推理过程和理由
- **不考**: 具体调查的事实细节（如NHANES的具体响应率）
- **考察**: 一般性的优缺点、为什么响应率下降、带来什么偏倚

### Part 2: 数据分析（开卷）
- **工具**: Stata
- **允许**: 使用代码备忘单、参考资料
- **考察**: 数据清洗、合并、回归分析、结果解读

---

## Part 1: 概念与逻辑题复习

### 1️⃣ 数据类型的优缺点

#### 横断面调查 (Cross-sectional Surveys)
**例子**: BRFSS, NHANES, NHIS

**优点**:
- 成本相对较低
- 可以快速收集大量样本
- 适合估计某一时间点的流行率
- 全国代表性（如果设计良好）

**缺点**:
- 无法追踪个体变化
- 难以建立因果关系（只能看关联）
- 只能比较不同人群，而非同一个人的变化
- 响应率下降问题严重

**最适合的研究问题**:
- "美国成年人中糖尿病的患病率是多少？"
- "不同收入群体的健康保险覆盖率有何差异？"

#### 纵向调查 (Longitudinal Surveys)
**例子**: MEPS, National Longitudinal Survey of Youth

**优点**:
- 可以追踪同一个体随时间的变化
- 支持 within-person（个体固定效应）分析
- 更好地建立因果推断
- 可以控制不随时间变化的个体特征

**缺点**:
- 成本高昂
- 样本流失（attrition）问题
- 数据收集周期长
- 可能存在学习效应

**最适合的研究问题**:
- "生孩子后睡眠时间是否减少？"
- "退休后心理健康是否改善？"
- "失业对健康的影响如何？"

#### Claims/出院数据 (Discharge Data)
**例子**: SPARCS, Medicare Claims

**优点**:
- 样本量巨大
- 包含实际医疗利用和费用信息
- 跨多个医疗机构
- 行政数据，较少缺失值
- 可以追踪同一患者在不同医疗机构的就诊

**缺点**:
- 缺乏临床细节（如实验室结果、生命体征）
- 诊断可能不准确（为了计费目的）
- 没有未就医的人群
- 缺少社会经济背景信息
- 可能有编码错误

**最适合的研究问题**:
- "不同县的住院费用是否有差异？"
- "90天再入院率是多少？"

**质量指标适用性**:
- ✅ 适合: 再入院率、住院天数、医疗利用
- ❌ 不适合: 需要详细临床数据的指标（如血压控制率）

#### EHR 数据 (电子健康记录)
**例子**: 医院系统的电子病历

**优点**:
- 详细的临床信息（实验室结果、生命体征、用药）
- 纵向数据（重复就诊）
- 真实世界数据
- 包含非结构化数据（医生笔记）

**缺点**:
- 仅限单一医疗系统内的人群
- 数据质量参差不齐
- 可能有系统性偏倚（只有在该系统就医的人）
- 缺少其他医疗系统的就诊记录
- 数据标准化困难

**最适合的研究问题**:
- "特定医疗系统中糖尿病患者的血糖控制情况"
- "某种新药在真实世界中的疗效"

**质量指标适用性**:
- ✅ 适合: 需要详细临床数据的指标（如HbA1c控制率）
- ❌ 不适合: 需要跨系统数据的指标（如90天全因再入院率）

#### 文本数据 (Text-based Data)
**例子**: 医生笔记、主诉字段

**优点**:
- 包含丰富的非结构化信息
- 可能包含其他数据源没有的细节

**缺点**:
- 需要自然语言处理技术
- 分析复杂
- 质量不一致

---

### 2️⃣ 回归分析核心概念

#### Survey Weights (调查权重)

**为什么需要调查权重？**
1. **设计性过度抽样**: 调查设计时故意多抽取某些群体（如少数族裔）
2. **低响应率**: 某些群体的响应率较低
3. **非代表性样本**: 即使是随机抽样，也可能运气不好抽到非代表性样本

**如何理解？**
- 调查权重表示每个受访者"代表"多少人
- 权重 = 1.5 意味着这个受访者代表1.5个人
- 使用权重后的结果可以推广到整体人群

**什么时候使用？**
- 分析调查数据时（BRFSS, NHANES, NHIS, MEPS等）
- 想要结果代表整体人群时

**Stata代码**:
```stata
svyset [pweight = weight_variable]
svy: reg outcome predictors
```

#### 分类变量 vs 连续变量

**分类变量 (Categorical)**:
- 使用 `i.variable` 前缀
- Stata会自动创建虚拟变量（dummy variables）
- 第一个类别自动成为参考组
- 例子: 种族、年龄组、入院类型

**连续变量 (Continuous)**:
- 使用 `c.variable` 或直接写变量名
- 系数表示变量每增加1个单位的效应
- 例子: 年龄、收入、BMI、住院天数

**何时选择？**
- 如果变量有自然顺序且差异有意义 → 连续
- 如果想看每个类别的独立效应 → 分类
- 如果关系可能非线性 → 考虑分类

#### Logistic vs Linear 回归

**对于二元结果，两种都可以，但要正确解读！**

| 特征 | Logistic回归 | Linear回归 |
|------|-------------|-----------|
| **命令** | `logistic` 或 `logit` | `reg` |
| **结果解读** | Odds Ratios（比值比） | Percentage Point Difference（百分点差异） |
| **系数含义** | 几率的倍数变化 | 概率的加法变化 |
| **例子解读** | "OR=1.5表示几率增加50%" | "coef=0.04表示概率增加4个百分点" |

**Logistic回归解读示例**:
```
系数 = 1.5
解读: "县收入每增加$1000，expensive stay的几率（odds）增加50%"
```

**Linear回归解读示例**:
```
系数 = 0.04
解读: "县收入每增加$1000，expensive stay的概率增加4个百分点（从10%到14%）"
```

#### Interaction Terms (交互项)

**目的**: 测试X和Y的关系是否因变量Z而异

**例子**:
- 收入对健康的影响是否因性别而异？
- 药物效果是否因年龄而异？

**Stata语法**:
```stata
reg outcome var1##var2  // ## 包含主效应和交互效应
reg outcome var1#var2   // # 仅交互效应
```

#### Individual Fixed Effects (个体固定效应)

**什么时候使用？**
- 有纵向数据（同一个人多个时间点）
- 想要控制个体内部不随时间变化的因素
- 想要研究"个体内部的变化"

**优点**:
- 控制所有不随时间变化的个体特征（无论观察到还是未观察到）
- 更强的因果推断

**Stata命令**:
```stata
xtset person_id
xtreg outcome predictors, fe
```

#### Robust Standard Errors

**为什么使用？**
- 异方差（heteroskedasticity）: 不同观察值的误差方差不同
- 大样本中很常见
- 使标准误更准确

**Stata语法**:
```stata
reg outcome predictors, r
// 或
reg outcome predictors, robust
```

**纪律差异**:
- 经济学: 几乎总是使用robust SE
- 生物统计: 不一定使用
- 考试: 不会因为不使用而扣分，但要知道为什么可能想用

---

### 3️⃣ 统计显著性 vs 实际意义

**关键区别**:

| 统计显著性 | 实际/临床意义 |
|-----------|-------------|
| p < 0.05 | 差异是否足够大到重要 |
| 受样本量影响 | 不受样本量影响 |
| 技术性判断 | 实质性判断 |

**例子**:
在50万人的BRFSS调查中，发现Gen Z和Millennials的每日运动时间差3分钟（20分钟 vs 23分钟），p=0.007。

**分析**:
- ✅ **统计显著**: p < 0.05
- ❓ **实际意义**: 值得讨论
  - 3分钟可能太小，没有健康益处
  - 但这是>10%的差异，可能有意义
  - 在大样本中，即使很小的差异也能达到统计显著（"overpowered"）

---

### 4️⃣ 变量类型与处理

#### Binary/Dummy Variables (二元变量)
**定义**: 0/1 标志变量

**常用场景**:
- 计算百分比（如流感疫苗接种率）
- 作为结果变量（logistic或linear回归）
- 作为控制变量

**创建方法**:
```stata
gen flag = 1 if condition
replace flag = 0 if opposite_condition
```

**验证方法**:
```stata
summ flag  // mean应该在0-1之间
tab original_var flag
```

#### Categorical Variables (分类变量)
**例子**: 种族、教育水平、入院类型

**处理方法**:
```stata
// 方法1: encode（字符串→数值分类）
encode string_var, gen(categorical_var)

// 方法2: 手动创建
gen race_cat = 1 if race == "White"
replace race_cat = 2 if race == "Black"
// etc.

// 使用时加 i. 前缀
reg outcome i.categorical_var
```

#### Continuous Variables (连续变量)
**例子**: 年龄、BMI、收入、住院天数

**常见处理**:
```stata
// Top-coding（截尾）
gen var_clean = var
replace var_clean = 1000000 if var > 1000000 & var != .

// 对数转换（处理右偏数据）
gen log_var = log(var + 1)  // +1避免log(0)
```

#### String Variables (字符串变量)
**常见操作**:
```stata
// 转换为数值
destring string_var, gen(numeric_var) force

// 查看无法转换的值
tab string_var if numeric_var == .

// 字符串匹配
gen flag = 1 if strpos(string_var, "keyword") > 0
```

#### Dates (日期)
**处理方法**:
```stata
// 导入时指定日期格式
// 或使用date()函数转换
gen date_numeric = date(date_string, "MDY")
format date_numeric %td
```

#### Missing Values (缺失值)
**关键原则**: 在所有条件中加入 `& var != .`

**原因**: Stata中缺失值（.）被视为非常大的数，会满足 `> threshold` 条件

**正确做法**:
```stata
// ✅ 正确
replace var_clean = 100 if var > 100 & var != .

// ❌ 错误（会把缺失值也设为100）
replace var_clean = 100 if var > 100
```

---

### 5️⃣ 数据管理操作

#### Merging (合并数据)

**四种合并类型**:

##### 1:1 Merge
- **场景**: 两个数据集都是每个ID一行
- **例子**: 合并NHANES的饮酒问卷到人口统计文件（都是每人一行）
```stata
merge 1:1 person_id using "second_dataset.dta"
```

##### 1:M Merge
- **场景**: 主数据集每ID一行，第二个数据集每ID多行
- **例子**: 合并就诊数据（每次就诊一行）到用药数据（每次就诊可能多个药物）
```stata
merge 1:m visit_id using "medications.dta"
```

##### M:1 Merge（最常用！）
- **场景**: 主数据集每ID多行，第二个数据集每ID一行
- **例子**: 合并县级收入数据到住院数据（同一县可能有多次住院）
```stata
merge m:1 county_name using "county_data.dta"
```

##### M:M Merge
- **注意**: 很少使用，通常不推荐
- 如果需要，考虑使用 `joinby` 命令

**合并后的检查**:
```stata
tab _merge
/*
_merge == 1: 仅在主数据集中
_merge == 2: 仅在第二个数据集中
_merge == 3: 两个数据集都有（匹配成功）
*/

// 通常保留1和3
keep if _merge == 1 | _merge == 3
drop _merge
```

#### Reshape/Transpose

**Wide → Long**:
```stata
reshape long var_prefix, i(id) j(time)
```

**Long → Wide**:
```stata
reshape wide var_name, i(id) j(time)
```

#### Append (追加数据)

**场景**: 合并结构相同的数据集（增加行数）

```stata
append using "second_dataset.dta"
```

---

### 6️⃣ 质量指标

**什么指标适合什么数据？**

| 质量指标 | EHR数据 | Claims数据 | 两者皆可 | 两者皆不适合 |
|---------|--------|-----------|---------|------------|
| HbA1c控制率 | ✅ | ❌ | | |
| 血压控制率 | ✅ | ❌ | | |
| 90天再入院率 | ❌ | ✅ | | |
| 住院天数 | | | ✅ | |
| 用药依从性 | | ✅ | | |
| 患者满意度 | | | | ✅（需要调查）|
| 预防性筛查率 | | | ✅ | |

**原则**:
- 需要详细临床数据（实验室结果、生命体征）→ EHR更好
- 需要跨医疗机构数据 → Claims更好
- 主观感受或行为 → 需要调查数据

---

## Part 2: Stata编程复习

### 🔧 完整工作流程

#### 工作流程1: 清洗结果变量

```
1. 探索原始数据
   ├── codebook variable_name
   ├── tab variable_name, m
   └── summ variable_name, d

2. 识别问题
   ├── 缺失值是什么？
   ├── 有异常值吗？
   └── 数据类型正确吗？

3. 创建清洗版本
   ├── gen var_clean = var_original
   ├── 处理缺失值
   ├── 处理异常值（top-code, 设为missing等）
   └── 转换数据类型（如需要）

4. 验证新变量
   ├── summ var_clean, d
   ├── tab var_original var_clean
   └── 检查逻辑是否正确
```

#### 工作流程2: 验证变量质量

```
1. 对于二元/分类变量
   ├── tab new_var old_var  // 交叉表
   └── tab new_var, m       // 检查缺失

2. 对于连续变量
   ├── summ new_var, d      // 检查范围、均值、中位数
   ├── summ new_var if condition == 1
   ├── summ new_var if condition == 0
   └── histogram new_var    // 可选：可视化

3. 对于二元变量特别检查
   └── summ binary_var
       // mean应该在0-1之间
       // min应该是0，max应该是1

4. 检查缺失值
   └── count if new_var == .
```

#### 工作流程3: 合并数据

```
1. 理解数据结构
   ├── 主数据集unique by什么？
   └── 第二个数据集unique by什么？

2. 检查合并变量
   ├── 变量名是否一致？（不一致需要rename）
   ├── 变量类型是否一致？（都是数值或都是字符串）
   └── 变量值是否匹配？（如大小写、空格）

3. 执行合并
   └── merge type merge_var using "file.dta"

4. 检查合并结果
   ├── tab _merge
   ├── 决定保留哪些记录
   └── keep if _merge == 1 | _merge == 3

5. 清理
   └── drop _merge
```

#### 工作流程4: 回归分析

```
1. 准备变量
   ├── 结果变量清洗完成
   ├── 预测变量清洗完成
   └── 确定变量类型（连续 vs 分类）

2. 运行回归
   ├── 选择回归类型（linear vs logistic）
   ├── 确定控制变量
   └── 决定是否用robust SE

3. 检查结果
   ├── 系数的方向符合预期吗？
   ├── 显著性如何？
   ├── 样本量正确吗？
   └── R-squared合理吗？

4. 解读结果
   ├── 写出系数的含义
   ├── 说明统计显著性
   ├── 评估实际意义
   └── 考虑控制变量的作用
```

---

## 代码备忘单

### 📝 变量清洗

```stata
/* ========================================
   探索数据
   ======================================== */

// 查看变量信息
codebook variable_name
describe variable_name

// 汇总统计（d = detail）
summ variable_name, d

// 频率表（m = missing）
tab variable_name, m

// 查看前几行数据
list variable_name in 1/10

// 查看满足条件的数据
list var1 var2 if condition


/* ========================================
   创建二元变量 (0/1 Flag)
   ======================================== */

// 标准方法
gen binary_var = 1 if condition
replace binary_var = 0 if opposite_condition

// 例子1: 年龄18岁及以上
gen adult = 1 if age >= 18 & age != .
replace adult = 0 if age < 18 & age != .

// 例子2: 昂贵住院（费用>$50,000）
gen expensive = 1 if totalcosts > 50000 & totalcosts != .
replace expensive = 0 if totalcosts <= 50000 & totalcosts != .

// 例子3: 急诊标志
gen ED_flag = 1 if ed_indicator == "Y"
replace ED_flag = 0 if ed_indicator == "N"

// 验证二元变量
summ binary_var  // mean应在0-1之间，min=0, max=1
tab original_var binary_var


/* ========================================
   处理缺失值
   ======================================== */

// 识别缺失值的编码
tab variable_name, m
codebook variable_name

// 将特定值设为系统缺失
replace variable_name = . if variable_name == 99
replace variable_name = . if variable_name == 999
replace variable_name = . if variable_name < 0

// 在条件中保护缺失值（重要！）
replace new_var = value if old_var > threshold & old_var != .

// 创建缺失标志
gen missing_flag = (variable_name == .)


/* ========================================
   Top-coding（截尾）
   ======================================== */

// 标准方法
gen var_clean = var_original
replace var_clean = 1000000 if var_original > 1000000 & var_original != .

// 验证
summ var_original, d
summ var_clean, d


/* ========================================
   分类变量处理
   ======================================== */

// 方法1: encode（字符串→数值分类）
encode string_var, gen(categorical_var)

// 方法2: 手动创建（更多控制）
gen admission_type = .
replace admission_type = 1 if type == "Elective"
replace admission_type = 2 if type == "Emergency"
replace admission_type = 3 if type == "Urgent"

// 添加值标签
label define admission_lbl 1 "Elective" 2 "Emergency" 3 "Urgent"
label values admission_type admission_lbl

// 在回归中使用（自动创建虚拟变量）
reg outcome i.categorical_var


/* ========================================
   字符串变量处理
   ======================================== */

// 转换为数值（force忽略无法转换的）
destring string_var, gen(numeric_var) force

// 查看无法转换的值
tab string_var if numeric_var == .

// 处理特殊字符串（例子：length of stay "120 +"）
destring lengthofstay, gen(los_num) force
replace los_num = 120 if lengthofstay == "120 +"

// 字符串匹配
gen contains_keyword = strpos(string_var, "keyword") > 0


/* ========================================
   对数转换
   ======================================== */

// 处理右偏数据
gen log_cost = log(cost + 1)  // +1避免log(0)

// 或者先处理0值
gen log_cost = log(cost) if cost > 0
replace log_cost = 0 if cost == 0


/* ========================================
   创建分组变量
   ======================================== */

// 基于连续变量创建分类
gen age_group = 1 if age < 30
replace age_group = 2 if age >= 30 & age < 50
replace age_group = 3 if age >= 50 & age < 70
replace age_group = 4 if age >= 70 & age != .

// 使用recode（更简洁）
recode age (0/29=1) (30/49=2) (50/69=3) (70/max=4), gen(age_group)
```

### 📊 数据合并

```stata
/* ========================================
   M:1 Merge（最常用）
   ======================================== */

// 场景：合并县级数据到个人数据
// 准备工作
use "main_data.dta", clear
rename county County_Name  // 确保变量名一致

// 执行合并
merge m:1 County_Name using "county_characteristics.dta"

// 检查结果
tab _merge
/*
1 = master only（主数据集独有）
2 = using only（第二数据集独有）
3 = matched（匹配成功）
*/

// 保留想要的记录
keep if _merge == 1 | _merge == 3  // 保留主数据集的所有记录
// 或
keep if _merge == 3  // 只保留匹配的记录

// 清理
drop _merge


/* ========================================
   1:1 Merge
   ======================================== */

// 场景：合并两个都是每人一行的数据集
use "demographics.dta", clear
merge 1:1 person_id using "questionnaire.dta"

tab _merge
keep if _merge == 3  // 通常只保留匹配的
drop _merge


/* ========================================
   1:M Merge
   ======================================== */

// 场景：主数据集每ID一行，第二数据集每ID多行
use "visits.dta", clear
merge 1:m visit_id using "medications.dta"

tab _merge
keep if _merge == 3
drop _merge


/* ========================================
   Merge前的检查
   ======================================== */

// 检查变量是否唯一
use "data.dta", clear
duplicates report merge_variable
// 应该显示0 duplicates（对于1端）

// 检查变量类型
describe merge_variable

// 检查变量值
tab merge_variable
summ merge_variable


/* ========================================
   Append（追加行）
   ======================================== */

// 场景：合并结构相同的数据集
use "data2020.dta", clear
append using "data2021.dta"
append using "data2022.dta"
```

### 📈 回归分析

```stata
/* ========================================
   线性回归
   ======================================== */

// 基本线性回归
reg outcome predictor

// 多个预测变量
reg outcome predictor1 predictor2 predictor3

// 带分类变量（i.前缀）
reg outcome continuous_var i.categorical_var

// 带robust标准误
reg outcome predictor1 predictor2, r
// 或
reg outcome predictor1 predictor2, robust

// 完整例子
reg totalcosts_clean County_Income lengthofstay i.agegroup i.ED_flag i.admission_type, r


/* ========================================
   Logistic回归
   ======================================== */

// Logistic回归（输出odds ratios）
logistic binary_outcome predictor1 predictor2

// 带分类变量
logistic binary_outcome continuous_var i.categorical_var

// 例子
logistic expensive_stay County_Income lengthofstay i.agegroup i.ED_flag


/* ========================================
   交互项
   ======================================== */

// ## 包含主效应和交互效应
reg outcome var1##var2

// 带分类变量的交互
reg outcome continuous_var##i.categorical_var

// 例子：收入效应是否因年龄组而异
reg health_outcome income##i.age_group


/* ========================================
   调查权重
   ======================================== */

// 设置调查设计
svyset [pweight = survey_weight]

// 带权重的回归
svy: reg outcome predictors
svy: logistic binary_outcome predictors


/* ========================================
   个体固定效应（纵向数据）
   ======================================== */

// 设置面板数据
xtset person_id time_variable

// 固定效应回归
xtreg outcome predictors, fe

// 随机效应回归（对比）
xtreg outcome predictors, re


/* ========================================
   回归后检查
   ======================================== */

// 查看完整结果
reg outcome predictors
estimates table

// 预测值
predict yhat

// 残差
predict residuals, residuals

// 诊断图
rvfplot  // 残差 vs 拟合值
```

### ✅ 验证与检查

```stata
/* ========================================
   变量验证
   ======================================== */

// 交叉表（分类/二元变量）
tab new_var old_var
tab new_var old_var, row col  // 带百分比

// 汇总统计（连续变量）
summ new_var, d

// 分组汇总
bysort group_var: summ outcome_var
// 或
summ outcome if group == 1
summ outcome if group == 0

// 检查二元变量范围
summ binary_var
// mean应在0-1之间，min=0, max=1


/* ========================================
   数据探索
   ======================================== */

// 描述所有变量
describe

// 汇总所有数值变量
summ

// 列出变量名
ds

// 查看数据维度
display _N  // 观察数量
display c(k)  // 变量数量


/* ========================================
   缺失值检查
   ======================================== */

// 统计缺失值
count if variable == .

// 所有变量的缺失值
mdesc

// 缺失值模式
misstable summarize
misstable patterns


/* ========================================
   异常值检查
   ======================================== */

// 识别异常值
summ variable, d
// 查看p1, p99

// 列出异常值
list id variable if variable > p99_value


/* ========================================
   逻辑检查
   ======================================== */

// 检查不可能的值
assert age >= 0 & age <= 120
// 如果有违反，Stata会报错

// 统计违反条件的观察
count if age < 0 | age > 120

// 检查互斥条件
assert (var1 == 1 & var2 == 0) | (var1 == 0 & var2 == 1)
```

### 💾 数据管理

```stata
/* ========================================
   保存与加载
   ======================================== */

// 保存数据
save "filename.dta", replace

// 加载数据
use "filename.dta", clear

// 保存子集
keep if condition
save "subset.dta", replace


/* ========================================
   变量管理
   ======================================== */

// 保留变量
keep var1 var2 var3

// 删除变量
drop var1 var2

// 重命名
rename old_name new_name

// 变量顺序
order var1 var2 var3, first
order var1 var2 var3, after(other_var)


/* ========================================
   观察管理
   ======================================== */

// 保留观察
keep if condition

// 删除观察
drop if condition

// 删除重复
duplicates drop

// 保留唯一值
duplicates drop id, force


/* ========================================
   排序
   ======================================== */

// 排序
sort variable
gsort -variable  // 降序


/* ========================================
   导入数据
   ======================================== */

// CSV文件
import delimited "filename.csv", clear

// Excel文件
import excel "filename.xlsx", sheet("Sheet1") firstrow clear

// 固定宽度文本
infix var1 1-10 var2 11-20 using "filename.txt"
```

---

## 练习题与答案

### 📚 概念题练习

#### 练习1: 纵向 vs 横断面数据

**题目**:
你正在研究"生孩子是否导致睡眠时间减少"。有两个数据集可选：
1. National Longitudinal Survey of Youth 97: 从1997年开始每年调查同一批青少年
2. NHIS: 每年调查不同的美国人样本

哪个数据集更适合，为什么？

**答案**:
National Longitudinal Survey of Youth 97更适合。原因：
- 研究问题关注的是"生孩子后的变化"，需要追踪同一个人在生孩子前后的睡眠变化
- 纵向数据可以进行within-person分析，比较同一个人生孩子前后的睡眠时间
- 横断面数据只能比较有孩子的人和没孩子的人，但这两组人可能在很多其他方面不同（年龄、收入等），难以建立因果关系
- 纵向数据可以控制个体内部不随时间变化的因素

---

#### 练习2: 对数转换

**题目**:
你的主管建议对右偏的费用数据进行"对数转换"。这是什么意思？需要哪些步骤？

**答案**:
对数转换是将右偏分布转换为更接近正态分布：
1. **原因**: 费用数据通常右偏（大多数人费用低，少数人费用极高）
2. **步骤**:
   - 先处理0值（因为log(0)未定义）：`gen cost_plus1 = cost + 1`
   - 取对数：`gen log_cost = log(cost_plus1)`
   - 验证：`histogram log_cost` 查看分布
3. **优点**:
   - 使数据更接近正态分布
   - 减少极端值的影响
   - 回归结果更容易解释（百分比变化）

---

#### 练习3: 调查权重

**题目**:
你决定在分析中使用调查权重。用几句话向同事解释为什么。

**答案**:
调查权重使分析结果能够代表整体人群：
- 调查样本可能不是完全随机的（某些群体被过度抽样，某些群体响应率低）
- 权重告诉我们每个受访者"代表"多少人
- 例如，权重=1.5意味着这个受访者代表1.5个人
- 使用权重后，结果可以推广到整个美国人口，而不仅仅是样本

---

#### 练习4: 数据合并类型

**题目**:
你在制药公司工作，有两个数据集：
- 数据集A: 你们公司研究的7种疾病（每种疾病一行）
- 数据集B: 所有竞争对手的产品（数千行，每个产品一行，多个公司可能针对同一疾病）

如何合并？为什么？

**答案**:
使用 **1:M merge**，以疾病名称为合并变量：
- 数据集A是"1"端：每种疾病一行（unique by disease）
- 数据集B是"M"端：每种疾病可能有多行（多个竞争产品）
- 合并后保留`_merge==1`或`_merge==3`（你们公司研究的疾病）
- 不保留`_merge==2`（你们公司不研究的疾病，如COVID-19）

```stata
use "your_company.dta", clear
merge 1:m disease using "competitor_data.dta"
keep if _merge == 1 | _merge == 3
drop _merge
```

---

#### 练习5: 统计显著性 vs 实际意义

**题目**:
在500,000人的BRFSS调查中，你发现Gen Z和Millennials的每日运动时间差3分钟（20 vs 23分钟），p=0.007。评论：
1. 是否统计显著？
2. 是否有实际意义？

**答案**:

**1. 统计显著性**:
- ✅ 是，p=0.007 < 0.05

**2. 实际意义**:
- 值得讨论。可能**没有**很强的实际意义：
  - 3分钟/天可能太小，不足以产生健康益处
  - 每周仅21分钟差异
- 但也有理由认为**有**实际意义：
  - 这是>10%的相对差异（3/20 = 15%）
  - 在人口层面，即使小差异也可能重要
- **重要认识**: 在如此大的样本中（50万人），即使很小的差异也会达到统计显著。我们"overpowered"了，能检测到可能不重要的微小差异。

---

### 💻 编程题练习

#### 练习6: 清洗费用变量并top-code

**任务**: 清洗totalcosts变量，top-code在$1,000,000

```stata
// 1. 检查原始变量
summ totalcosts, d
// 注意：检查是否有缺失值

// 2. 创建清洗版本
gen totalcosts_clean = totalcosts
replace totalcosts_clean = 1000000 if totalcosts > 1000000 & totalcosts != .

// 3. 验证
summ totalcosts_clean, d
// 检查max是否≤1,000,000

// 4. 比较
summ totalcosts, d
summ totalcosts_clean, d
```

---

#### 练习7: 创建二元变量

**任务**: 创建"昂贵住院"标志（费用>$50,000）

```stata
// 1. 创建标志
gen expensive_stay = 1 if totalcosts_clean > 50000 & totalcosts_clean != .
replace expensive_stay = 0 if totalcosts_clean <= 50000 & totalcosts_clean != .

// 2. 验证
summ expensive_stay
// mean应在0-1之间，min=0, max=1

// 3. 交叉检查
tab expensive_stay, m

// 4. 分组验证
summ totalcosts_clean if expensive_stay == 1
// min应该>50,000
summ totalcosts_clean if expensive_stay == 0
// max应该≤50,000
```

---

#### 练习8: 处理分类变量

**任务**: 准备回归用的分类变量

```stata
// 方法1: encode（字符串→数值）
encode typeofadmission, gen(admission_type_num)
encode agegroup, gen(agegroup_num)

// 验证
tab typeofadmission admission_type_num
tab agegroup agegroup_num

// 方法2: 急诊标志（二元）
gen ED_flag = 1 if ed_indicator == "Y"
replace ED_flag = 0 if ed_indicator == "N"

// 验证
tab ed_indicator ED_flag, m
```

---

#### 练习9: M:1 Merge

**任务**: 合并县级收入数据到住院数据

```stata
// 0. 查看第二个数据集的结构（可选）
use "NY_Census_Data.dta", clear
describe
list in 1/5
// 注意：县变量叫County_Name，每个县一行

// 1. 回到主数据集
use "SPARCS_data.dta", clear

// 2. 重命名以匹配
rename hospitalcounty County_Name

// 3. 执行M:1 merge
merge m:1 County_Name using "NY_Census_Data.dta"

// 4. 检查结果
tab _merge
/*
_merge==1: SPARCS记录，但没有县数据
_merge==2: 县数据，但没有SPARCS记录（不应该有）
_merge==3: 匹配成功
*/

// 5. 保留SPARCS的所有记录
keep if _merge == 1 | _merge == 3

// 6. 检查合并的变量
summ County_Income_1000Dollars, d
// 报告min和max

// 7. 清理
drop _merge
```

---

#### 练习10: 完整回归分析

**任务**: 研究县收入与住院费用的关系

```stata
// 1. 运行线性回归
reg totalcosts_clean County_Income_1000Dollars lengthofstay_num ///
    i.agegroup_num i.ED_flag i.admission_type_num, r

// 2. 解读结果（示例）
/*
如果County_Income系数 = 73, p<0.05:

解读：控制住院天数、年龄组、急诊状态和入院类型后，
县收入每增加$1,000，住院费用平均增加$73。
这个差异在统计上显著（p<0.05）。

虽然$73看起来不大，但考虑到成千上万次住院，
累积效应可能在实际中也是重要的。
*/

// 3. 检查样本量
display e(N)

// 4. 保存结果（可选）
estimates store model1
```

---

#### 练习11: Logistic回归

**任务**: 分析县收入与昂贵住院的关系

```stata
// 方法1: Logistic回归
logistic expensive_stay County_Income_1000Dollars lengthofstay_num ///
    i.agegroup_num i.ED_flag i.admission_type_num

// 解读（如果OR=1.02, p<0.05）:
/*
县收入每增加$1,000，昂贵住院的几率（odds）增加2% (OR=1.02)。
这个关联在统计上显著。
*/

// 方法2: Linear回归（on binary outcome）
reg expensive_stay County_Income_1000Dollars lengthofstay_num ///
    i.agegroup_num i.ED_flag i.admission_type_num, r

// 解读（如果coef=0.0004, p<0.05）:
/*
县收入每增加$1,000，昂贵住院的概率增加0.04个百分点
（从10%增加到10.04%）。
*/
```

---

## 考前检查清单

### ✅ Part 1准备

- [ ] 理解不同数据类型的优缺点
- [ ] 能够根据研究问题选择合适的数据类型
- [ ] 理解调查权重的作用
- [ ] 区分统计显著性和实际意义
- [ ] 知道何时用logistic vs linear回归
- [ ] 理解如何解读两种回归的系数
- [ ] 了解交互项的用途
- [ ] 理解固定效应的概念
- [ ] 能够识别合适的合并类型（1:1, 1:M, M:1）
- [ ] 知道什么质量指标适合什么数据类型

### ✅ Part 2准备

**代码技能**:
- [ ] 创建0/1二元变量
- [ ] Top-code连续变量
- [ ] 使用encode处理分类变量
- [ ] destring字符串变量
- [ ] 处理缺失值（& var != .）
- [ ] 执行M:1 merge
- [ ] 检查merge结果（tab _merge）
- [ ] 运行线性回归with分类变量（i.）
- [ ] 运行logistic回归
- [ ] 使用robust标准误
- [ ] 验证新创建的变量

**验证技能**:
- [ ] 用tab做交叉表验证
- [ ] 用summ检查连续变量范围
- [ ] 分组汇总（summ if）
- [ ] 检查二元变量的均值在0-1之间

**解读技能**:
- [ ] 解读线性回归系数
- [ ] 解读logistic回归的OR
- [ ] 评估统计显著性
- [ ] 评估实际意义
- [ ] 写出完整的结果解读

### ✅ 工具准备

- [ ] 打印或准备电子版代码备忘单
- [ ] 确保能访问课程材料
- [ ] 熟悉Stata界面和命令
- [ ] 准备好计算器（如果需要）

### ✅ 心态准备

- [ ] 记住：Part 1重视逻辑，不是记忆
- [ ] 记住：Part 2是开卷，可以参考资料
- [ ] 每一步都验证结果
- [ ] 写清楚你的推理过程
- [ ] 不要怕犯错——这是学习的地方！

---

## 🎯 最后的建议

### Part 1策略
1. **解释"为什么"**: 不只说"我会用纵向数据"，要说"因为能追踪个体变化"
2. **举例说明**: 用具体例子支持你的论点
3. **承认权衡**: "虽然X有优点，但也有Y这个缺点"
4. **展示思考**: 让评分者看到你的推理过程

### Part 2策略
1. **先探索再清洗**: 先用tab/summ了解数据
2. **每步验证**: 不要等到最后才检查
3. **保护缺失值**: 在所有条件中加 `& var != .`
4. **注释代码**: 简短注释帮助你追踪思路
5. **完整解读**: 不只报告系数，要完整解释含义

### 时间管理
- Part 1: 不要花太多时间纠结措辞，写出你的逻辑即可
- Part 2: 如果卡住了，跳过继续，回头再看
- 留时间检查：特别是Part 2的代码和结果

### 如果遇到困难
- **Part 1**: 即使不确定，也要写出你的思考过程
- **Part 2**: 参考备忘单，一步一步来
- **记住**: 老师看重的是理解和应用，不是完美

---

## 📚 重要概念快速参考

| 概念 | 关键点 |
|------|--------|
| **Survey Weights** | 使样本代表人群；每个人"代表"多少人 |
| **Logistic回归** | 系数=Odds Ratios（几率比） |
| **Linear回归** | 系数=百分点差异 |
| **M:1 merge** | 主数据集多行/ID，第二数据集一行/ID |
| **i.variable** | 分类变量前缀，自动创建虚拟变量 |
| **Robust SE** | 处理异方差，使标准误更准确 |
| **Top-coding** | 将极端值限制在某个上限 |
| **encode** | 字符串→数值分类变量 |
| **destring** | 字符串→数值（加force忽略错误） |
| **& var != .** | 保护缺失值不被误处理 |
| **Fixed Effects** | 控制个体内不变特征；纵向数据 |
| **Interaction** | 测试X→Y关系是否因Z而异 |

---

## 💪 你能做到！

记住老师说的：
> "你能做到困难的事情——这是一个非常安全的尝试场所。"

这门课的目标不是让你成为编程专家，而是：
- 建立使用大规模数据的信心
- 培养逻辑思维和问题解决能力
- 学会选择合适的方法回答研究问题
- 理解数据分析的局限性和优势

你已经学了这么多，做了这么多练习。相信你的准备，相信你的能力！

祝考试顺利！🎓

---

*最后更新: 2025年10月*
*根据Session 8复习材料编制*
