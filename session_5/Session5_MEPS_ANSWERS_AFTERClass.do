**** MSPH P8508 SESSION 5 IN-CLASS EXERCISES     ****
**** MEPS              							 **** 
**** Transposing, doing within-person analysis	 ****
**** and imputing missing values (single imp) 	 ****



use h244, replace 
tab MNHLTH1, m
tab MNHLTH3, m
tab MNHLTH5, m

********************
*TRANSPOSING DATA 
********************
 
keep DUID PID DUPERSID PANEL MNHLTH1 MNHLTH2 MNHLTH3 MNHLTH4 MNHLTH5 EMPST1 EMPST2 EMPST3 EMPST4 EMPST5 REGION1 EDUCYR SEX AGE1X
reshape long MNHLTH EMPST, i(DUPERSID) j(round) 
/*j(round) tells stata that I want to create a new variable called Round that pulls the suffix from the MNHLTH and EMPST variables to indicate which round they are from
i(DUPERSID) tells Stata to "hinge" on the person identifier*/

label define EMPST_lab -15 "CANNOT BE COMPUTE" -8 "DK" -7 "REFUSED" -1 "INAPPLICABLE" 1 "EMPLOYED AT INTERV" 2 "JOB TO RETURN TO" 3 "JOB DURING ROUND" 4 "NOT EMPLOYED DURING ROUND"
label values EMPST EMPST_lab

/*the reason we had to relabel the variable is because the labels all said "round 5" even for the other rounds. this is just a necessary quirk -- Stata can only retain one label -- so easiest to just relabel after transposing*/


tab EMPST, m
tab  EMPST round, m


*************************
*WITHIN-PERSON REGRESSION 
*aka INDIVIDUAL FIXED EFF
*************************

/*FOR YOU TO DO ON YOUR OWN (codebook if you need: https://meps.ahrq.gov/data_stats/download_data/pufs/h244/h244cb.pdf):
	
(1) Clean the employment status variable into a binary dummy for employed or not. 
(2) Clean the mental health variables so that the values are reversed, where higher numbers mean better mental health
(3) Clean the education years variable, so we can interpret it as a continuous variable (years of education) ranging from 0 to 17. You can treat the highest category (5+ years of college) as topcoded at 17.

call them:
	employed
	MNHLTH_clean
	educ_years
*/
	
gen employed=.
replace employed=1 if inlist(EMPST, 1, 2, 3)
replace employed=0 if EMPST==4


recode  MNHLTH (1=5) (2=4) (3=3) (4=2) (5=1), gen(MNHLTH_clean)
replace MNHLTH_clean =. if  !inlist(MNHLTH, 1, 2, 3, 4, 5)
 
tab EDUCYR
gen educ_years=.
replace educ_years=EDUCYR if EDUCYR>=0 & EDUCYR<=17

/*and finally let's clean the sex and region variables together*/

tab SEX, m/*no missings! great!*/
/*but best practice is to change it to a 0/1 instead of a 1/2 though*/
recode SEX (1=0) (2=1), gen(female)
tab SEX female, m

tab REGION1, m
recode  REGION1 (-1 = .), gen(region) /*all we need to do is clean missings*/
tab region



save h244_cleaned, replace


/*FOR YOU TO DO: 

Run the following 2 regressions:

(1) a linear regression of MNHLTH_clean on the employed dummy
(2) same regression but control for education, sex, and geography*/


reg MNHLTH_clean i.employed, r /*employment is associated with better mental health*/

reg MNHLTH_clean i.employed i.female i.region educ_years, r /*employment is associated with better mental health, even after accounting for differences in education, sex, and geography*/


/*and now we are going to run the version  doing a WITHIN-PERSON / INDIVIDUAL FIXED EFFECTS analysis*/

areg MNHLTH_clean i.employed, r absorb(DUPERSID) /*as the same individual person changes employment status, there is no evidence of a concurrent change in their mental health*/

/*And what happens if we try to include a "Stable"/time-invariant characteristic as a confounder in the within-person regression, like sex?*/
areg MNHLTH_clean i.employed i.female, r absorb(DUPERSID) /*as the same individual person changes employment status, there is no evidence of a concurrent change in their mental health*/



***********************
*TRANSPOSING DATA AGAIN
* long to wide! 
***********************

/*Maybe we plan to do household-level analyses, and so we want to reshape the data to only have one record per household.

THere are a lot of things we could do that you've already learned -- collapse the data, use egen to create summary means by household ID -- but another option is to transpose the data so all family members are on a single row*/


use h244, replace

keep DUID PID   TOTEXPY1  

replace TOTEXPY1=. if TOTEXPY1==-1 /*clean the expenditure variable*/

reshape wide TOTEXPY1 , i(DUID) j(PID)
/*What are the i() and j() doing?*/

egen household_spending_y1=rowtotal(TOTEXPY1*)   /*we can sum up all spending across the family*/
 
 summ household_spending_y1, d    /*note, the family-level weight is stored in a different file, and if we wanted weighted estimates, we'd need to pull that in.*/




/*IMPUTING*/
use h244_cleaned, replace /*use our data from the first exercise that we cleaned, looking at mental health and employment*/

/*let's impute years of education using single imputation*/


***create dummy var if educ missing***
gen educ_miss = 1 if educ_years == .
replace educ_miss = 0 if educ_years != .

***clean age***
gen age = AGE1X if AGE1X != -1


***test if missingness is associated with other variables ***
regress educ_miss female 
regress educ_miss i.region 
regress educ_miss i.employed 
regress educ_miss age

regress educ_miss female i.region i.employed age
regress educ_years female i.region i.employed age


***begin imputation***
reg educ_years female i.region i.employed age
predict educ_predicted
gen educ_imp = educ_years
replace educ_imp = educ_predicted if educ_imp == .



***run regression using imputed education***
reg MNHLTH_clean i.employed i.female i.region educ_imp  , r  
***original regression from first exercise***
reg MNHLTH_clean i.employed i.female i.region educ_years  , r  

***can also add the missing indicator, which controls for the fact that some educ_imp values are imputed and others are from the original variable*/
reg MNHLTH_clean i.employed i.female i.region educ_imp educ_miss, r  





/*BONUS EXERCISE IF WE HAVE TIME*/

***********************
*MANAGING HOUSEHOLD DATA
***********************

/*WITHOUT ACTUALLY RUNNING CODE, come up with a suggestion of how we might do the following:

Our research question: Do utilization patterns differ for opposite-sex versus same-sex couples

What variables do you think you'd need?
What commands would you run?
How would you check your work?

*/

