**** MSPH P8508 SESSION 7 IN-CLASS EXERCISES     ****
**** EHR DATA					 				 **** 
**** MERGING AND TRANSPOSING CONTINUED		 	 ****
**** DEDUPLICATING								 ****


import delimited edstays.csv, clear
save edstays.dta, replace


import delimited admissions.csv, clear
save admissions.dta, replace


import delimited diagnosis.csv, clear
save diagnosis.dta, replace

import delimited triage.csv, clear
save triage.dta, replace

import delimited poe.csv, clear
save poe.dta, replace

import delimited poe_detail.csv, clear
save poe_detail.dta, replace
 
import delimited medrecon.csv, stringcols(5 6) clear 
save medrecon, replace
* NOTE: for this one, we have to include stringcols (5 6) because we want the drug codes to come in as strings (character vars) even though they look like numbers, because they can have "leading 0s" (e.g., 0001234567). don't worry about this too much, just wanted to point it out. you won't need to figure this out on your own in this course.




/*CODEBOOKS ARE HERE:

https://mimic.mit.edu/docs/iv/modules/ed/
AND
https://mimic.mit.edu/docs/iv/modules/hosp/

*/


**********************************
*EHR DATA - GETTING FAMILIAR
**********************************

/*We will start by following one patient through several different files. This will help you get a sense for the relational data base structure and see all the things we can learn about patients in a dataset like this*/


/*we will follow subject_id 10039997*/
use edstays, replace

keep if subject_id==10039997
save 10039997, replace

/*how many of her ED visits led to an inpatient stay?*/


***FOR THIS SECTION, YOU WILL COME UP WITH THE MERGE STATEMENTS. WE WILL WORK THROUGH THEM TOGETHER AND YOU CAN TYPE ALONG. THE ANSWERS WILL BE POSTED AFTER CLASS


/*If i want to merge in the hospitalization info, what kind of merge will I do?*/

keep if _merge==3 | _merge==1 /*keep our subject's records, regardless of whether they linked to an inpatient stay or not*/


/*lets see why she was at the ED based on diagnoses*/
/*what kind of merge do you think we should do?*/
drop _merge


/*note that we use stay_id instead of hadm_id, since we are merging in something about the ED stay, not the hospital/inpatient admission*/


keep if _merge==3 | _merge==1 /*keep our subject's records, regardless of whether they linked  or not*/

sort subject_id stay_id


/*lets see how she was assessed on arrival at the ED during "triage"*/
/*what kind of merge do you think we should do?*/
drop _merge



keep if _merge==3 | _merge==1 /*keep our subject's records, regardless of whether they linked  or not*/

/*let's deduplicate the data, because when we added in the diagnoses, we ended up with multiple rows per visit*/

duplicates drop subject_id hadm_id, force

/*if we wanted to only keep the primary diagnosis, we would use "keep if seq_num==1" rather than the "duplicates drop" command. If we don't care which diagnosis gets kept, then we can just use the duplicates command*/


/*lets see what provider orders were written*/
/*what kind of merge do you think we should do?*/
drop _merge


keep if _merge==3 | _merge==1 /*keep our subject's records, regardless of whether they linked  or not*/

sort subject_id stay_id


/*lets get detail about those provider orders*/
/*what kind of merge do you think we should do?*/
drop _merge

keep if _merge==3 | _merge==1 /*keep our subject's records, regardless of whether they linked or not*/




**********************************
*CALCULATING ED WAIT TIMES
**********************************



use edstays, replace

/*what type of variables are the dates ?*/
describe intime outtime

/*remember that stata has a function to convert strings to actual numeric dates:
- to get the exact date AND time, we use clock()
- to get just the date, we use date()
*/


gen arrival_time = clock(intime, "YMD hms") /*you need to make sure you use the correct format. the raw data is YMD hms (year, month, day, hour minute second). If you opened and saved it in excel first, it might have changed to be MDY hm*/
format arrival_time %tc
gen depart_time = clock(outtime, "YMD hms")
format depart_time %tc



/*what if we wanted to convert those dates to just dates rather than date AND time?*/




*OK let's calculate wait times in the ED*/
gen wait_time=depart_time-arrival_time
summ wait_time, d
* it's in milliseconds! let's convert to hours


replace wait_time=wait_time/1000/60/60
summ wait_time, d

gen female=1 if gender=="F"
replace female=0 if gender=="M"

reg wait_time i.female, r
margins female




*********************************************
*MORE DATA MANAGEMENT PRACTICE USING RX DATA
********************************************


merge 1:m stay_id using medrecon
sort subject_id stay_id

/*let's check for duplicates*/
sort stay_id ndc

duplicates examples stay_id ndc
duplicates tag stay_id ndc , gen(dupe_flag)
duplicates drop stay_id ndc, force

 bysort stay_id  : generate ndc_id = _n /*this is just so we can number each NDC within the stay -- for example, if we wanted to see how many medications each person was on at the time of their ED visit. don't worry too much about learning to do this for now*/

/*the first 5 digits of the NDC (drug code) are the manufacuturer*/

/*let's extract those digits and save them to their own variable. Maybe we want to know what manufacturer is producing the most drugs for our health system's population*/

/*What command do you think we will use?*/

tab manufacuturer, sort


/*Finally, what if we wanted to create a data set that was only one row per stay, but had all their current medications listed as separate columns?*/

keep ndc stay_id ndc_id
reshape wide ndc, i(stay_id) j(ndc_id)
/*what are the i() and j() doing?*/



 










