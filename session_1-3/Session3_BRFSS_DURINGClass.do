**** MSPH P8508 SESSION 3 IN-CLASS EXERCISES     ****
**** BRFSS              						 **** 
**** Generating variables (intermediate) 		 ****
**** and basic visualization & regression options****



cd "C:\Users\l1697\OneDrive\Desktop\Academic\Biostats Courses\Larage Scale Data"


* Open log file first
capture log close
log using session3.log, replace


* BRFSS files *

*******************
*IMPORTING THE DATA
********************

*BRFSS data is stored all in one file, unlike NHANES
import sasxport5 LLCP2023.xpt, clear

*That import might have been a little slow! (Was the wheel in the bottom right of your stata window spinning for a few minutes?) Why? What is the file size?

*NEW COMMAND: compress is a nice way to reduce file size when opening a file that originated from a different software into Stata. Stata can reduce the size of variables and store them more efficiently. This is especially true when pulling in from SAS versions
compress
save BRFSS2023, replace
// use BRFSS2023, replace

*What is the file size now??


di "the file size now is 211 MB"


*******************************
*GETTING FAMILIAR WITH THE DATA
*******************************


/* Identify and run basic summary statistics on the following variables:
- "Number of Days Physical Health Not Good"
- "Length of time since last routine checkup"
- "Currently Taking Prescription Blood Pressure Medication"

Be prepared to answer questions about what you've found and how to interpret these variables

*/

tab physhlth, m
tab bpmeds1, m



****************************************
*CREATING AND HANDLING COMPLEX VARIABLES
****************************************


/*Let's learn how to quickly read across multiple variables to create a new variable that draws information from other fields 

*/

/*there are 3 fields that capture difficulty with "Activities of daily living":
- diffwalk
- diffdres
- diffalon

*/
tab diffwalk, m
tab diffdres, m
tab diffalon, m

/*one easy way to create a flag for people who report difficulty with ANY of these tasks is to use egen*/

egen atleast1_adl=rowmin(diffwalk diffdres diffalon)
tab atleast1_adl, m
*anyone who has a min of 1 has at least 1 ADL

/*we can also use egen to create summaries by particular groups*/
gen diffwalk_binary=.
replace diffwalk_binary=1 if diffwalk==1
replace diffwalk_binary=0 if diffwalk==2

tab diffwalk diffwalk_binary, m

egen share_diffwalk_byState=mean(diffwalk_binary), by(_state)
tabstat share_diffwalk_byState, by(_state) stats(n mean sd)




/* Now, we want to create a numeric variable that tells us the interview date*/


/*first, list the following variables for the first 10 observations:
- idate
- imonth 
- iday 
- iyear

*/


list idate imonth iday iyear in 1/10
describe idate imonth iday iyear 
*describe tells us what type of variable it is
*"Str" indicates it is a string (or character variable)


/*try running the mean of one of these fields*/
/*what happens?*/

/*the first thing we can try is to convert these string fields to numeric ones*/
destring imonth, gen(month_num)
sum month_num, d


/*that works!
but we can also just directly convert the string date to a full numeric date*/
gen date_numeric = date(idate, "MDY")
list idate imonth iday iyear date_numeric in 1/10
*this converted it to a numeric date! But why does it look funny?

format date_numeric %td
list idate imonth iday iyear date_numeric in 1/10
*now we have it formatted as a human readable date


/*let's try concatenating a variable.*/

/*Maybe we want an identifier that is composed of the State of the interview concatenated with the month of the interview*/
egen state_month=concat(_state imonth), punct("_")
list _state idate imonth iday iyear date_numeric state_month in 1/10

/*and then what if we want to split it apart again?*/
split state_month, gen(state_month_part) parse("_")



****************************************
*BASIC VISUALIZATION
****************************************
 
/*LET'S CLEAN THE "# OF DAYS IN POOR PHYSICAL HEALTH" VARIABLE
variable name is physhlth

take a few minutes to try to clean it on your own*/


gen physhlth_clean=.
replace physhlth_clean=1 if 
replace physhlth_clean=0 if diffwalk==2


/*Let's try to look at this variable over time*/

/*Our goal: to group everyone who was interviewed in the same month together

There are a few ways to do this -- we could concatenate month and year together, for example

However, if we want to plot it in a graph, we need it to be a numeric value

So the best way to do this, is to assign everyone interviewed in a given month the the first day of that month. For example, if I was interviewed March 13, 2023, My month group variable would be March 1, 2023.*/
destring iyear, gen(year_num)

gen month_year=mdy(month_num, 1, year_num)

format month_year %td


/*let's look at flu shots over time 
(question: did you get a flu shot in the last 12 months?
variable name: flushot7*/
gen flu_shot=.
replace flu_shot=1 if flushot7==1
replace flu_shot=0 if flushot7==2

 
tabstat flu_shot, by(month_year) stat(n mean sd )

save BRFSS2023_class, replace/*lets save our data set we've worked on! the next step will alter our data set in a major way, so we want to keep a version of the data we've been working with before we do that*/

collapse flu_shot, by(month_year) /*this is useful when you want to create and save a summary data set -- for example, for graphing something*/

help twoway
twoway line flu_shot month_year, yaxis(min=0)




****************************************
*CUSTOMIZING REGRESSION OPTIONS
****************************************

/*merge in coffee data*/
import excel "CoffeeData.xlsx", clear 
list in 1/10
/*uh oh! what's happening with the first row??*/

import excel "CoffeeData.xlsx", clear firstrow
list in 1/10
/*the "firstrow" option fixes this for us*/

rename FIPS  _state

*what type of merge do we want to do?



*what does the merge table tell us? 
*what states are we missing from each data set?

/*let's create a variable that indicates if there are EQUAL OR MORE DUNKINs than starbucks in a state*/
gen more_dunkins=1 if Dunkin_Starbucks_Ratio>=1 & Dunkin_Starbucks_Ratio !=.
replace more_dunkins=0 if Dunkin_Starbucks_Ratio<1  & Dunkin_Starbucks_Ratio !=.
tab more_dunkins, m

tabstat physhlth_clean, by(more_dunkins) stats(n mean sd p50)


reg physhlth_clean more_dunkins 


/*clustering / robust SEs in regression*/

*often, we want to use robust SEs in regression to account for the fact that the heteroskedasticity assumption is not met (error spread is not consistent) or the errors are not actually independent of one another 

reg physhlth_clean more_dunkins, robust /*adding the robust option gives us robust SEs*/

*in cases where our "Exposure" is actually at a larger unit -- e.g., State -- we probably actually want to use "cluster robust" standard errors, where the standard errors are more conservative to account for the fact that there isn't actually that much variation in the exposure (only 52 possible values, rather than thousands!). To decide what level to cluster at, ask yourself "what is the unit of my exposure?" State? County? Family? Individual? etc.

reg physhlth_clean more_dunkins, vce(cluster _state) /*adding vce(cluster varname) gives us cluster robust SEs*/



di "The Aanlaysis is complete!"





