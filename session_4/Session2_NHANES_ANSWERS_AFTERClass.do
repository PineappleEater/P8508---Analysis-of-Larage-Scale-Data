**** MSPH P8508 SESSION 2 IN-CLASS EXERCISES     ****
**** NHANES              						 **** 
**** Basic summary stats/regress 				****



cd "C:\Users\[YOUR FOLDER HERE]"


* Open log file first
capture log close
log using session2.log, replace


* NHANES files *

*******************
*IMPORTING THE DATA
********************

*we are going to start with pulse and blood pressure measurements
import sasxport5 "https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2017/DataFiles/BPX_J.xpt", clear
save NHANES2017_bpx, replace


*looking at descriptive stats about a variable

*there are several ways
summ bpxpls, d /*what does this variable measure? how did you figure it out?*/
histogram bpxpls

tabstat bpxpls, stat(n mean sd min median max) /*the tabstat command, vs summ, gives you a little more flexibility to ask for specific statistics in a cleaner format*/

tab bpxpls  /*because bpxpls has a narrow range, we can also run a freq table*/
tab bpxpls, m  /*add , m to see how many missings as well*/

*do you notice anything interesting about this variable?




********************
*CREATING VARIABLES
********************


*creating a new categorical variable based on an old one
*the three ways I showed in lecture

/*option 1 - safest but most lines of code*/
gen irreg_pulse=.
replace irreg_pulse=1 if bpxpuls==2 
replace irreg_pulse=0 if bpxpuls ==1
tab irreg_pulse bpxpuls, m

/*option 2 - riskiest but fewest lines of code*/
gen irreg_pulse_v2= bpxpuls==2  
tab irreg_pulse_v2 bpxpuls, m /*what happened?*/
/*how should we fix this?*/

/*KACIE'S ANSWER*/
*this is the fix. 
replace irreg_pulse_v2=. if bpxpuls==. 


/*option 3 - using recode; handy, but only useful for simple recodes*/
recode bpxpuls (1 =0) (2=1), gen(irreg_pulse_v3)
tab irreg_pulse_v3 bpxpuls, m  




*creating a binary ('dummy') variable from a CONTINUOUS one

*an abnormally high resting pulse is defined as over 100 beats per minute

*IMPORTANT! The first 2 methods are INCORRECT. I am showing them for illustration purposes!

*attempt 1 (wrong)
gen pulse_high_try1=.
replace pulse_high_try1=1 if bpxpls >100
replace pulse_high_try1=0 if bpxpls<=100
tab pulse_high_try1 /*what do you notice? */

*attempt 2 (wrong)
*starting with a "blank canvas" of 0s - risky!
gen pulse_high_try2=0
replace pulse_high_try2=1 if bpxpls >100 & bpxpls != .
tab pulse_high_try2 /*what do you notice?*/


*attempt 3 (right)
*SAFEST METHOD!
gen pulse_high_correct=. /*start with "blank canvas" of missings*/
replace pulse_high_correct=1 if bpxpls >100 & bpxpls != . /*make sure "." is excluded*/
replace pulse_high_correct=0 if bpxpls <=100 & bpxpls != . /*make sure "." is excluded*/
tab pulse_high_correct

*Remember: Stata treats missing values as equal to infinity (i.e. a very large number)


*how can we check?


*we could try listing a few observations 
list bpxpls pulse_high* in 1/10  

*we can explictly check where the missings go 
tab  pulse_high_correct if bpxpls==. , m
tab  pulse_high_try1 if bpxpls==., m
tab  pulse_high_try2 if bpxpls==., m


save NHANES2017_bpx, replace


*******************
*MERGING NEW FILES
*******************
help merge

import sasxport5 "https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2017/DataFiles/DEMO_J.xpt", clear
save NHANES2017_demo, replace

merge 1:1 seqn using NHANES2017_bpx
*A 1:1 merge is for data sets that have a unique identifier for each row in both data sets. Here we are starting with the demographics file and merging in the pulse data


list in 1/50 if _merge==1
* we can look at who didn't match


*checking age across our high pulse status dummy (the right one and a wrong one)
tabstat ridageyr, by(pulse_high_correct) stat( n mean   min max)
tabstat ridageyr, by(pulse_high_try1) stat( n mean   min max)
* We get a different number of observations! Why?
* It is important to be very careful with creating new variables! 


drop _merge
save NHANES2017_bpx_demo, replace


/*now: on your own, merge in the alcohol use file. Did anything interesting happen? Describe the people in the different _merge categories*/




/*KACIE'S ANSWER*/
import sasxport5 "https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2017/DataFiles/ALQ_J.xpt", clear
save NHANES2017_alc, replace

use NHANES2017_bpx_demo, replace
drop _merge /*we have to drop or rename the prior merge variable when we want to do another merge*/

merge 1:1 seqn using NHANES2017_alc
summ ridageyr if _merge==1, d
summ ridageyr if _merge==3, d

/*now on your own: 
- explore and tell me about the income variable (indfmin2)
- try to create a 4-level "Income Group" variable that is cut at
	Group 1: 0 - less than 20,000
	Group 2: 20,000 - less than 55,000
	Group 3: 55,000 - less than 100,000
	Group 4: 100,000 and over
- explain your logic
- label your new variable and its values
 */

summ indfmin2, d
tab indfmin2, m
*from this output you should start to suspect that this variable is NOT income in dollars. It is in fact already categorized. Additionally, the categories are a bit odd. for example, category 12 is 20,000 and over, but several of the other categories have more specific amounts that are over 20,000. What is going on here?

*you have probably looked at the codebook by now and realized that you will have trouble deciding what to do with the people who chose "20,000 and over". They might be in group 2, 3 or 4. 

*there are several logical ways to deal with this, but you need to document your choice and why you made that choice. In a real study, you might do "sensitivity analyses" where you see what happens to your results (E.g., in a regression) when you alter that choice. Here are some ways you might have decided to deal with it:

*Treating anyone who didn't give an exact income as missing
*Treating the people in category 12 as missing, but putting the people in 13 into the "less than 20,000 category"
*Assign people from category 12 to groups 2-4 "randomly", in proportion to the general sample (or devise some other rule for re-coding them into groups 2-4)
*Impute (predict) a more specific income of those people based on other characteristics -- we haven't covered this approach yet, but we will in a few weeks!!



*Finally, what did you do with the people in group 77 and 99. Did you recode them as missing? "."

*as an example, here is some code to do option 1 (treat anyone in 12 or 13 as missing, in addition to the other missing categories)

gen income_group=.
replace income_group= 1 if indfmin2==1 | indfmin2==2 | indfmin2==3 | indfmin2==4
replace income_group=2 if indfmin2==5 | indfmin2==6 | indfmin2==7 | indfmin2==8
replace income_group=3 if indfmin2==9 | indfmin2==10 | indfmin2==14 
replace income_group=4 if  indfmin2==15 

tab indfmin2 income_group, m
tab income_group

label var income_group "Income Groups"
label define income_group_label 1 "Under 20K" 2 "20K - LT 55K" 3 "55K - LT 100K" 4 "100K and over"
label values income_group income_group_label
tab income_group /*now it shows the labels!*/



*********************
*APPENDING NEW FILES
*********************

/*A merge adds new columns; an append adds more rows*/

* imagine we want to see whether reported fiber intake changes from the first dietary interview to the second one (Which is several weeks later)

* how would we set up a "longitudinal" data set tracking each respondent over their two dietary interviews?

import sasxport5 "https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2017/DataFiles/DR1TOT_J.xpt", clear
rename dr1tfibe fiber_grams
gen day=1

save NHANES2017_dietday1, replace



import sasxport5 "https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2017/DataFiles/DR2TOT_J.xpt", clear
rename dr2tfibe fiber_grams
gen day=2

save NHANES2017_dietday2, replace




use NHANES2017_dietday1, replace
append using NHANES2017_dietday2

keep seqn day fiber_grams

sort seqn day

tabstat fiber_grams, by(day) stat(n mean sd median)

merge 1:1 seqn using NHANES2017_bpx_demo /*what does Stata tell you?*/

*how do you think you would fix it?
*hint: try looking at the "help" documentation again

/*KACIE'S ANSWER'*/
merge m:1 seqn using NHANES2017_bpx_demo  /*this is the fix; it is a "many to one" merge rather than a one-to-one merge*/



************
*REGRESSIONS
************

/*Let's use our fiber data to run a regression.
First, let's drop the second dietary recall observation, since our pulse/BP and demographic data are only from the time of the first dietary recall
*/

drop if day==2

summ fiber_grams, d

/*let's do a linear regression of systolic blood pressure on fiber intake*/

summ bpxsy1, d
*looks good!

reg bpxsy1 fiber_grams

/*NOW: you will add a covariate:
	- age: continuous
	
Then try adding age as a 3-level variable
	- under 40
	- 40 - less than 65
	- 65+
	
Then try running the regression among only people  65+ 
*/
	
	
/*KACIE'S ANSWER*/
	
reg  bpxsy1 fiber_grams   ridageyr

gen age_3groups=.
replace age_3groups=1 if ridageyr<40 & ridageyr != .
replace age_3groups=2 if ridageyr<65 & ridageyr>=40 & ridageyr != .
replace age_3groups=3 if ridageyr>=65 & ridageyr != .

tabstat ridageyr, by(age_3groups) stat(n mean sd median min max)
tab age_3groups


reg  bpxsy1 fiber_grams   i.age_3groups

/*only among people 65+*/
reg  bpxsy1 fiber_grams  if age_3groups==3






