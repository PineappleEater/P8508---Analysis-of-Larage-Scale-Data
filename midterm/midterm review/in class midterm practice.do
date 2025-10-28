***** MIDTERM PRACTICE *******

/*import the SPARCS data*/
import delimited "C:\Users\kld2128\OneDrive - Columbia University Irving Medical Center\Desktop\Large Scale Data 2025\Session 6\Hospital_Inpatient_Discharges__SPARCS_De-Identified___2021_20251006.csv", clear



*1. Check the total costs variable for any missings and topcode it
summ totalcosts, d /*no missings because N=total data set size*/

/*create the top coded version*/
gen totalcosts_clean=totalcosts
replace totalcosts_clean=1000000 if totalcosts>1000000 & totalcosts != .

/*SOMETHING TO THINK ABOUT!!! what if some of the totalcosts had been system missing (".")? What part of the code above protects us from accidentally misclassifying those?*/

summ totalcosts_clean, d

*2. CLean the covariates

/*check out lengthofstay*/
/*NOTE: this lengthofstay recoding is more complicated than anything you need to do on the midterm. don't worry if you found this variable hard.*/

codebook lengthofstay /*it's a string variable w/ 120 values. maybe we should take a look at the frequency table!*/
tab lengthofstay, m 
destring lengthofstay, gen(lengthofstay_num) force
summ lengthofstay_num, d
/*some are missing.... let's find out what happened by checking the original value for anything that now has a missing value*/
tab lengthofstay if lengthofstay_num==.

/*recode the ones that are "120 +" to be 120*/
replace lengthofstay_num=120 if lengthofstay=="120 +"


tab typeofadmission, m
tab agegroup, m

*both look OK, so we can just use "encode" to get them ready for use in regressions
*remember that encode is helpful so we don't have to manually create the numeric categories!

encode typeofadmission, gen(typeofadmission_num)
encode agegroup, gen(agegroup_num)

tab emergencydepartmentindicator, m
gen ED_flag=1 if emergencydepartmentindicator=="Y"
replace ED_flag=0 if emergencydepartmentindicator=="N"


*3. Merge in county characteristics

*if you wanted to take a look at the county data first, you can save your SPARCS file and open the county characteristics to take a look. You can also open a second instance of stata.

save SPARCS_midterm, replace

use NY_Census_Data, replace
*the county variable is called "County_Name". This is different from the variable name for county in our SPARCS data. WE will have to rename one of them in order to merge. Let's rename it in our SPARCS data. WE can also see that there is one row per county, which is useful for deciding what type of merge to do.

use SPARCS_midterm, replace
rename hospitalcounty County_Name

merge m:1 County_Name using NY_Census_Data
keep if _merge ==1 | _merge==3
* always take a look at the merge table to decide which records to keep. We want to keep all the SPARCS records, even if they didn't match to the county data. These ones will ultimately be left out of our regressions because the county income is missing, but in general, we don't really want to delete records from our original data. That is why we keep both _merge==1 and _merge==3

summ County_Income_1000Dollars, d
*min=59.3K, max=$165.7K


*4. Run a regression of mean hospital costs on county-level income, controlling for length of stay, type of admission, age group, and emergency indicator. 

reg totalcosts_clean County_Income_1000Dollars lengthofstay_num i.agegroup_num i.ED_flag i.typeofadmission_num, r
*interpretation: controlling for age, lengthofstay, emergency status, and type of admission, each $1000 increase in county median income is associated with a $73 increase in hospitalization costs. This difference is statistically significant. THe magnitude is somewhat small, but it probably still has practical significance, too, given that $73 additional dollars per hospitalization across thousands of hospitalizations is a substantial amoutn of money!


*5. create binary outcome of "expensive stays" and test if there is still an association

gen expensive_stay=1 if totalcosts_clean>50000 & totalcosts_clean!=.
replace expensive_stay=0 if totalcosts_clean<=50000 & totalcosts_clean!=.

/*this is how we can check if our binary flag was created correctly*/
summ totalcosts_clean if expensive_stay==1
summ totalcosts_clean if expensive_stay==0

/*WARNING: a logistic regression on this data set may be slow on your computer - it was being slow on mine. THe actual midterm will use a smaller dataset! I show the interpretation for a logistic regression on a binary outcome AND the interp for a linear regression on a binary outcome below*/

logistic expensive_stay County_Income_1000Dollars lengthofstay_num i.agegroup_num i.ED_flag i.typeofadmission_num
*interp: each additional $1000 in county median income is associated with a 1.XX increase in the odds of an expensive stay

reg expensive_stay County_Income_1000Dollars lengthofstay_num i.agegroup_num i.ED_flag i.typeofadmission_num
*interp: each additional $1000 in county median income is associated with a 0.04 percentage point increase in the probability of an expensive stay






