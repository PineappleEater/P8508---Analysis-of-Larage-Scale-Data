* Import script for NHIS complete data with demographics, health status, and smoking
* File: nhis_00003.dat.gz contains sex, age, health status, and smoking status

set more off
clear

* Import from new comprehensive dataset
quietly infix                  ///
  int     year        1-4      ///
  long    serial      5-10     ///
  int     strata      11-14    ///
  int     psu         15-17    ///
  str     nhishid     18-31    ///
  long    hhweight    32-37    ///
  byte    pernum      38-39    ///
  str     nhispid     40-55    ///
  str     hhx         56-62    ///
  str     fmx         63-64    ///
  str     px          65-66    ///
  double  perweight   67-78    ///
  double  sampweight  79-90    ///
  double  longweight  91-101   ///
  double  partweight 102-112   ///
  double  fweight    113-124   ///
  byte    astatflg    125-125  ///
  byte    cstatflg    126-126  ///
  int     age        127-129   ///
  byte    sex        130-130   ///
  byte    health     131-131   ///
  byte    smokev     132-133   ///
  using `"nhis_00003.dat"'

* Adjust weights as per IPUMS specifications
replace sampweight = sampweight / 1000
replace fweight    = fweight    / 1000000

* Format weights
format perweight  %12.0f
format sampweight %12.3f
format fweight    %12.6f

* Variable labels
label var year       `"Survey year"'
label var serial     `"Sequential Serial Number, Household Record"'
label var strata     `"Stratum for variance estimation"'
label var psu        `"Primary sampling unit (PSU) for variance estimation"'
label var nhishid    `"NHIS Unique identifier, household"'
label var hhweight   `"Household weight, final annual"'
label var pernum     `"Person number within family/household"'
label var nhispid    `"NHIS Unique Identifier, person"'
label var hhx        `"Household number (from NHIS)"'
label var fmx        `"Family number (from NHIS)"'
label var px         `"Person number of respondent (from NHIS)"'
label var perweight  `"Final basic annual weight"'
label var sampweight `"Sample Person Weight"'
label var fweight    `"Final annual family weight"'
label var astatflg   `"Sample adult flag"'
label var cstatflg   `"Sample child flag"'
label var age        `"Age"'
label var sex        `"Sex"'
label var health     `"General health status"'
label var smokev     `"Ever smoked 100 cigarettes in life"'

* Value labels
label define sex_lbl 1 "Male" 2 "Female"
label values sex sex_lbl

label define smokev_lbl 00 `"NIU"' 01 `"No"' 02 `"Yes"' 07 `"Unknown-refused"' ///
                        08 `"Unknown-not ascertained"' 09 `"Unknown-don't know"'
label values smokev smokev_lbl

* Display data overview
di "Data import completed for NHIS demographics and smoking dataset"
di "Total observations imported: " _N
summarize year age
di "Year range:"
tab year if year >= 1997 & year <= 2018, missing
di "Sex distribution:"
tab sex, missing
di "Smoking status distribution:"
tab smokev, missing

* Check for data quality
count if !missing(year) & !missing(age) & !missing(sex) & !missing(smokev)
di "Complete observations: " r(N)

* Save the dataset
save "nhis_00002_imported.dta", replace