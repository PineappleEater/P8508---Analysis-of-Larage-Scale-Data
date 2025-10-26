**** MSPH P8508 SESSION 4 IN-CLASS EXERCISES     ****
**** NHIS              							 **** 
**** More on graphing, using survey weights,	 ****
**** and interpretting regression output 		 ****


********************
*MORE COMPLEX GRAPHS
********************

use BRFSS2023_Session4, replace /*a version of BRFSS from last week, but just limitedto a few variables*/

/*Last week, I showed how you could create a summary data set using "collapse", which you can use to graph summary data -- e.g., by state or month.
You can also create graphs without collapsing the data, although it is important to understand what you're doing!

In this example, we are going to use egen to create a new "summary" flu shot variable by month, which we will attach to all 433,323 BRFSS records. So basically, everyone interviewed in Jan 2023 will all have the same value of "share_flu_byMonth", which is the share of people interviewed in Jan 2023 who got a flu shot in the last 12 months.

We can then use this summary variable to graph the trend, but we want to sort our data by the month variable first. Otherwise, the line graph will look crazy.
*/

egen share_flu_byMonth=mean(flu_shot), by(month_year) /*creating summary variable by  month to reattach to each record*/
sort month_year /*sorting by month before graphing*/
twoway line share_flu_byMonth month_year, ylabel(0(.1) .7) /*graphing the trend, but it appears as only one dot for each month (because each observation within that month has the same exact value for share_flu_byMonth)*/



/*now I'll show you how you can do two graphs on top of each other -- one that uses the underlying 433,323 records, and one that uses summary data like we did above*/

scatter weight2 htin4 if weight2<7777, mcolor(ebblue) /*this is a scatter of height and body weight for all 433,323 respondents. lots of dots!!! and it may take Stata a second to render it.*/

egen avgweight_byHeight=mean(weight2) if weight2<7777 , by(htin4) /*we can create a variable capturing AVERAGE body weight for each height (in inches), and reattach this to our dataset. Everyone who is 60 inches, for example, will have the same value of avgweight_byHeight, which will be the average body weight of everyone who is 60 inches tall*/

sort htin4 /*sort by the horizontal axis (X) variable*/

twoway (scatter weight2 htin4 if weight2<7777, mcolor(ebblue) ytitle("Body Weight")) (line avgweight_byHeight htin4, lwidth(thick) lcolor(red)), legend(order(1 "Observed body weight" 2 "Average body weight") position(3)  ) /*this is how you can stack two graphs on top of each other. Each graph needs to be fully in parentheses, including any options (like marker or line color). Then you can have the overall options (e.g., for the graph's legend) at the end, after a comma */



*********************
*EXPLORING NHIS DATA
*********************
***run do-file that IHIS gave us
do Import_nhis_00002.do
save nhis_00002, replace



/*ON YOUR OWN: 
	- explore and clean the 6 component variables of the K6 psychological distress index
		- aworthless
		- asad
		- arestless
		- anervous
		- ahopeless
		- aeffort

		RENAME YOUR CLEANED VARIABLES WITH _clean AT THE END.
*/



/*now let's create the k6 index. The k6 index is the sum of the 6 component variables*/

egen k6=rowtotal(arestless_clean asad_clean aworthless_clean ahopeless_clean aeffort_clean anervous_clean), missing
tab k6 if arestless_clean==., m /*this shows us that some people with a missing value on the RESTLESS component have a k6 score. so egen created a sum even if some of the component values were missing. Therefore, we need to recode these people with a missing value on ANY Of the components as missing*/
replace k6=. if  arestless_clean ==. | asad_clean ==. | aworthless_clean ==. | ahopeless_clean ==. | aeffort_clean ==. | anervous_clean ==. 

tab k6 if arestless_clean==., m /*fixed!*/


*********************
*USING WEIGHTS
*********************

/*let's get the mean K6 score, both weighted and unweighted*/

mean k6
mean k6 [pweight=sampweight]


/*now let's get the share of people with and without health insurance*/
tab hinotcove, m
tab hinotcove, m nol

recode hinotcove (1 = 1) (2 = 0) (9 = .), gen(insured)
tab insured hinotcove, m

mean insured /*the mean of a binary variable = the share with that value*/
mean insured [pweight=perweight]

/*why did we use perweight instead of sampweight??*/




************************************
*REGRESSION MARGINS AND INTERACTIONS
************************************

/*lets see if smokers have different psychological distress levels than nonsmokers*/

/*first, recode the smokev variable*/
tab smokev, m /*what do the 0s mean here???*/

gen smoker_ever=.
replace smoker_ever=1 if smokev==2
replace smoker_ever=0 if smokev==1


/*on your own: run a regression of K6 score on smoking status*/






/*now let's see if there is an interaction with health insurance.
	Maybe we hypothesize that having health insurance is a buffer against psychological distress for smokers*/
	
reg  k6 i.smoker_ever i.insured i.smoker_ever#i.insured , robust


/*now let's see if there is an interaction with age.
	Maybe we hypothesize that as people age, the association between smoking and distress weakens */
	

reg  k6 i.smoker_ever age i.smoker_ever#c.age , robust
/*VERY IMPORTANT!!!! With a continuous variable in an interaction, you must use c.VARNAME. Otherwise it will assume it is a categorical variable and give you very weird results*/


/*now lets see how using "margins" can help us understand our regression output*/
reg  k6 i.smoker_ever i.insured i.smoker_ever#i.insured , robust
margins i.smoker_ever#i.insured /*this will give us the predicted means for each group*/

/*ON YOUR OWN: calculate whether the differences in the predicted means from the margins commmand matches the coefficients in your regression

hint: they should!*/



/*margins can be especially useful for binary outcomes in a logistic regression*/

gen high_k6=1 if k6>=13 & k6 !=.
replace high_k6=0 if k6<13 & k6 != . /*now we can use a logistic regression to test whether smoking and insurance are associated with having a high K6 score*/

tab high_k6

logistic high_k6 i.smoker_ever i.insured i.smoker_ever#i.insured
margins i.smoker_ever#i.insured /*this will give us the predicted PROBABILITY for each group -- margins automatically converts the prediction from the model for you to give you PROBABILITIES, not odds*/
















