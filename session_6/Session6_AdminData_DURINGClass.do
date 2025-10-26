**** MSPH P8508 SESSION 6 IN-CLASS EXERCISES     ****
**** CLAIMS / DISCHARGE DATA					 **** 
**** ANALYZING STRING VARIABLES AND COSTS		 ****
**** RISK ADJUSTING OUTCOMES BY FACILITY		 ****

import delimited "Hospital_Inpatient_Discharges__SPARCS_De-Identified___2021_20251006.csv", clear
/*we use "delimited" to import text based files, like .csv or .txt data*/

/*CODEBOOKS ARE HERE:
https://health.data.ny.gov/Health/Hospital-Inpatient-Discharges-SPARCS-De-Identified/tg3i-cinn/about_data
*/


**********************************
*DISCHARGE DATA - GETTING FAMILIAR
**********************************

/*Unlike survey data, admin data is not often cleaned prior to release, so quality control and quality checking are important!*/

/*as one example, let's look at all the people coded as "newborn" admissions*/
tab agegroup if typeofadmission=="Newborn", sort

/*what do you notice?!*/

gen flag =1 if agegroup=="50 to 69" & typeofadmission=="Newborn"
list if flag==1
/*do you think the typo is in the age field or the newborn field?*/


/*And what should we do first to make it easier to search through string fields, which may use different cases (upper vs lower case)?*/
replace ccsrdiagnosisdescription=strupper(ccsrdiagnosisdescription)


/*Let's also concatenate the CCSR code and decription and the DRG code and description - this will help us when we look at tables*/

egen ccsr_full=concat(ccsrdiagnosiscode ccsrdiagnosisdescription), punct("- ")
egen proc_full=concat(ccsrprocedurecode ccsrproceduredescription), punct("- ")
egen aprdrg_full=concat(aprdrgcode aprdrgdescription), punct("- ")
egen aprmdc_full=concat(aprmdccode aprmdcdescription), punct("- ")

/*Let's get familiar with the NYS discharge data (SPARCS) by looking at hospitalizations for newborns -- e.g. birthweights*/



/*Step 1. learn about the birthweight variable*/
describe birthweight /*it's a string/character field. uh oh!*/

/*Step 2. convert it to numeric*/

/*YOU TRY: convert birthweight to a numeric field and call it birthweight_num and check it out in a histogram*/



/*Step 3. figure out what the newborn records are
There are several ways to do this*/

tab typeofadmission, m 
tabstat birthweight_num, by(typeofadmission) stat(n mean sd) /*birthweights occur accross all types of admission, suggesting that just using the "newborn" category will miss some admissions*/

tabstat birthweight_num, by(agegroup) stat(n mean sd)

tab ccsr_full if birthweight_num != ., sort /*we often use the primary diagnosis to define newborns*/
/*TIP: putting "sort" at the end of a tab statement will sort it in descending frequency*/

/*Let's define birth discharges as claims with the Liveborn CCS (diagnostic group), which is ccsrdiagnosiscode=="PNL001" */


summ birthweight_num if ccsrdiagnosiscode=="PNL001", d

/*let's set any birthweights over 6000 grams (13 lbs) to missing because they are data errors*/

replace birthweight_num=. if birthweight_num>6000


/*Step 4. Summarize the data. For example, now we can look at birthweight by county*/

encode hospitalcounty, gen(countynum) /*what is the purpose of this??*/

reg birthweight_num i.countynum   if ccsrdiagnosiscode=="PNL001", r
margins countynum

/*why is running a regression helpful, rather than just running the means for each county with tabstat, for example?*/


/*Remember when I said that with large scale data we sometimes find that "everything is significant" simply because the Ns are so large? Let's run a histogram comparing Albany and Bronx, seeing if the distributions actually look meaningfully different*/

codebook countynum, tab(100) /*this shows us the values for the county variable. tab(100) just forces it to give the whole list*/

twoway (histogram birthweight_num if countynum==1 & ccsrdiagnosiscode=="PNL001",  width(100) color(red%30)) (histogram birthweight_num if countynum==3 & ccsrdiagnosiscode=="PNL001", width(100) color(green%30)), legend(order(1 "Albany" 2 "Bronx" ))


/*We can get gender- and race-adjusted county means*/

gen female=.
replace female=1 if gender=="F"
replace female=0 if gender=="M"

encode race, gen(race_num)

reg birthweight_num i.countynum i.female i.race_num if ccsrdiagnosiscode=="PNL001" , r
margins countynum



*****************************************
*LEVERAGING DIAGNOSTIC AND PROCEDURE DATA
*****************************************
tab ccsr_full, m sort
tab proc_full, m sort
tab aprdrg_full, m sort
tab aprmdc_full, m sort


/*let's search the text fields to try to identify alcohol and drug related hospitalizations*/

tab ccsr_full if regex(ccsr_full, "ALC") | regex(ccsr_full, "DRUG") , sort

tab aprdrg_full if regex(aprdrg_full, "ALC") | regex(aprdrg_full, "DRUG") , sort

tab aprmdc_full if regex(aprmdc_full, "ALC") | regex(aprmdc_full, "DRUG") , sort


tab ccsr_full if regex(aprmdc_full, "ALCOHOL/DRUG")  /*look at all of the CCSR groups we missed because we only searched for ALC and DRUG in our initial search!*/


/*As you can see, there is often a trade off between creating definitions that are too narrow versus too wide, and there is always a risk of accidentally including irrelevant cases or excluding relevant ones*/

/*Most people in the health services research field rely on the CCSR / ICD (diagnosis-based) definitions, but how outcomes are defined can really vary based on prior literature, your own assessment of the data quality, and sensitivity analyses (seeing if results are sensitive to different definitions). Defintions also often include procedure, specialty, and revenue code information*/


/*ONE WAY WE MIGHT DEFINE ALC & DRUG HOSPS
	- Use the "MDC" from the drg grouper (aprmdccode==20) 
	or
	- A CCS category between MBD017 TO MBD026
	or
	- A CCS category for overdose INJ022*/


gen alcdrug=0
replace alcdrug=1 if aprmdccode==20 | inrange(ccsrdiagnosiscode, "MBD017", "MBD026") | ccsrdiagnosiscode== "INJ022"
replace alcdrug=. if aprmdccode==. & ccsrdiagnosiscode==""

tab alcdrug
tab aprmdc_full if alcdrug==1
tab ccsr_full if alcdrug==1
tab aprdrg_full if alcdrug==1

encode agegroup, gen(agegroup_num)

reg alcdrug i.agegroup_num   , r
margins agegroup_num


/*YOUR TURN:  Identify hospitalizations for all types of broken bones. THen tell me the difference between charges and costs for those hospitalizations*/





********************************************
*RISK ADJUSTING MORTALITY RATES BY FACILITY
********************************************

/*let's focus on the NYP hospitals*/
tab facilityname if regex(facilityname, "Presb")



/*risk adjust mortality for age, gender,  and CCSR*/

tab patientdisposition, m

/*How would we create a flag for people who died during their stay?*/




/*we need to convert ccs diagnosis code and facility name to numeric indicators to use in the regessions. how do we do that?*/

encode ccsrdiagnosiscode, gen(ccsr_num)
encode facilityname, gen(facility_num)

/*now how would we get the UNADJUSTED mortality rates for each site*/
reg died  i.facility_num if regex(facilityname, "Presb")
margins facility_num, saving(unadj_facility_means, replace)

/*and how would we get the ADJUSTED mortality rates for each site
	Adjust for age group, gender,  and CCSR
*/

reg died i.female  i.agegroup_num i.ccsr_num i.facility_num if regex(facilityname, "Presb")
margins facility_num, saving(adj_facility_means, replace)
 


********************************************
*LOGGING SPENDING
********************************************


histogram totalcosts if totalcosts<1000000, width(1000) 
gen log_totalcosts=log(totalcosts)
histogram log_totalcosts   

reg log_totalcosts i.facility_num if regex(facilityname, "Presb") 
margins facility_num , expression(exp(predict(xb))) /*This just gives us the difference in the (geometric) means in actual dollars*/



