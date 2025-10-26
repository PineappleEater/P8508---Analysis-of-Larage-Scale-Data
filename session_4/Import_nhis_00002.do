* NOTE: You need to set the Stata working directory to the path
* where the data file is located.

set more off

clear
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
  double  fweight     91-102   ///
  byte    astatflg    103-103  ///
  byte    cstatflg    104-104  ///
  int     age         105-107  ///
  byte    sex         108-108  ///
  byte    marstcur    109-109  ///
  int     racenew     110-112  ///
  byte    hispeth     113-114  ///
  byte    usborn      115-116  ///
  byte    hinotcove   117-117  ///
  byte    smokev      118-119  ///
  byte    aeffort     120-120  ///
  byte    ahopeless   121-121  ///
  byte    anervous    122-122  ///
  byte    arestless   123-123  ///
  byte    asad        124-124  ///
  byte    aworthless  125-125  ///
  using `"nhis_00002.dat"'

replace sampweight = sampweight / 1000
replace fweight    = fweight    / 1000000

format perweight  %12.0f
format sampweight %12.3f
format fweight    %12.6f

label var year       `"Survey year"'
label var serial     `"Sequential Serial Number, Household Record"'
label var strata     `"Stratum for variance estimation"'
label var psu        `"Primary sampling unit (PSU) for variance estimation"'
label var nhishid    `"NHIS Unique identifier, household"'
label var hhweight   `"Household weight, final annual"'
label var pernum     `"Person number within family/household (from reformatting)"'
label var nhispid    `"NHIS Unique Identifier, person"'
label var hhx        `"Household number (from NHIS)"'
label var fmx        `"Family number (from NHIS)"'
label var px         `"Person number of respondent (from NHIS)."'
label var perweight  `"Final basic annual weight"'
label var sampweight `"Sample Person Weight"'
label var fweight    `"Final annual family weight"'
label var astatflg   `"Sample adult flag"'
label var cstatflg   `"Sample child flag"'
label var age        `"Age"'
label var sex        `"Sex"'
label var marstcur   `"Current marital status"'
label var racenew    `"Self-reported Race (Post-1997 OMB standards)"'
label var hispeth    `"Hispanic ethnicity"'
label var usborn     `"Born in the United States"'
label var hinotcove  `"Health Insurance coverage status"'
label var smokev     `"Ever smoked 100 cigarettes in life"'
label var aeffort    `"Felt everything an effort, past 30 days (adults)"'
label var ahopeless  `"How often felt hopeless, past 30 days (adults)"'
label var anervous   `"How often felt nervous, past 30 days (adults)"'
label var arestless  `"How often felt restless, past 30 days (adults)"'
label var asad       `"How often felt sad, past 30 days (adults)"'
label var aworthless `"How often felt worthless, past 30 days (adults)"'

label define astatflg_lbl 0 `"NIU"'
label define astatflg_lbl 1 `"Sample adult, has record"', add
label define astatflg_lbl 2 `"Sample adult, no record"', add
label define astatflg_lbl 3 `"Not selected as sample adult"', add
label define astatflg_lbl 4 `"No one selected as sample adult"', add
label define astatflg_lbl 5 `"Armed forces member"', add
label define astatflg_lbl 6 `"AF member, selected as sample adult"', add
label values astatflg astatflg_lbl

label define cstatflg_lbl 0 `"NIU"'
label define cstatflg_lbl 1 `"Sample child-has record"', add
label define cstatflg_lbl 2 `"Sample child-no record"', add
label define cstatflg_lbl 3 `"Not selected as sample child"', add
label define cstatflg_lbl 4 `"No one selected as sample child"', add
label define cstatflg_lbl 5 `"Emancipated minor"', add
label values cstatflg cstatflg_lbl

label define sex_lbl 1 `"Male"'
label define sex_lbl 2 `"Female"', add
label define sex_lbl 7 `"Unknown-refused"', add
label define sex_lbl 8 `"Unknown-not ascertained"', add
label define sex_lbl 9 `"Unknown-don't know"', add
label values sex sex_lbl

label define marstcur_lbl 0 `"NIU"'
label define marstcur_lbl 1 `"Married, spouse present"', add
label define marstcur_lbl 2 `"Married, spouse absent"', add
label define marstcur_lbl 3 `"Married, spouse in household unknown"', add
label define marstcur_lbl 4 `"Separated"', add
label define marstcur_lbl 5 `"Divorced"', add
label define marstcur_lbl 6 `"Widowed"', add
label define marstcur_lbl 7 `"Living with partner"', add
label define marstcur_lbl 8 `"Never married"', add
label define marstcur_lbl 9 `"Unknown marital status"', add
label values marstcur marstcur_lbl

label define racenew_lbl 100 `"White only"'
label define racenew_lbl 200 `"Black/African American only"', add
label define racenew_lbl 300 `"American Indian/Alaska Native only"', add
label define racenew_lbl 400 `"Asian only"', add
label define racenew_lbl 500 `"Other Race and Multiple Race"', add
label define racenew_lbl 510 `"Other Race and Multiple Race (2019-forward: Excluding American Indian/Alaska Native)"', add
label define racenew_lbl 520 `"Other Race"', add
label define racenew_lbl 530 `"Race Group Not Releasable"', add
label define racenew_lbl 540 `"Multiple Race"', add
label define racenew_lbl 541 `"Multiple Race (1999-2018: Including American Indian/Alaska Native)"', add
label define racenew_lbl 542 `"American Indian/Alaska Native and Any Other Race"', add
label define racenew_lbl 997 `"Unknown-Refused"', add
label define racenew_lbl 998 `"Unknown-Not ascertained"', add
label define racenew_lbl 999 `"Unknown-Don't Know"', add
label values racenew racenew_lbl

label define hispeth_lbl 10 `"Not Hispanic/Spanish origin"'
label define hispeth_lbl 20 `"Mexican"', add
label define hispeth_lbl 21 `"Mexican-Mexicano"', add
label define hispeth_lbl 22 `"Mexicano"', add
label define hispeth_lbl 23 `"Mexican-American"', add
label define hispeth_lbl 24 `"Chicano"', add
label define hispeth_lbl 30 `"Puerto Rican"', add
label define hispeth_lbl 40 `"Cuban/Cuban American"', add
label define hispeth_lbl 50 `"Dominican (Republic)"', add
label define hispeth_lbl 60 `"Other Hispanic"', add
label define hispeth_lbl 61 `"Central or South American"', add
label define hispeth_lbl 62 `"Other Latin American, type not specified"', add
label define hispeth_lbl 63 `"Other Spanish"', add
label define hispeth_lbl 64 `"Hispanic/Latino/Spanish, non-specific type"', add
label define hispeth_lbl 65 `"Hispanic/Latino/Spanish, type refused"', add
label define hispeth_lbl 66 `"Hispanic/Latino/Spanish, type not ascertained"', add
label define hispeth_lbl 67 `"Hispanic/Spanish, type don't know"', add
label define hispeth_lbl 70 `"Multiple Hispanic"', add
label define hispeth_lbl 90 `"Unknown"', add
label define hispeth_lbl 91 `"Unknown if Hispanic/Spanish origin"', add
label define hispeth_lbl 92 `"Two origins, unknown which is the main"', add
label define hispeth_lbl 93 `"Origin unknown, refused or not reported"', add
label define hispeth_lbl 99 `"NIU"', add
label values hispeth hispeth_lbl

label define usborn_lbl 10 `"No"'
label define usborn_lbl 11 `"No, born in U.S. territory"', add
label define usborn_lbl 12 `"No, born outside U.S. and U.S. territories"', add
label define usborn_lbl 20 `"Yes, born in U.S."', add
label define usborn_lbl 96 `"NIU"', add
label define usborn_lbl 97 `"Unknown-refused"', add
label define usborn_lbl 98 `"Unknown-not ascertained"', add
label define usborn_lbl 99 `"Unknown-don't know"', add
label values usborn usborn_lbl

label define hinotcove_lbl 0 `"NIU"'
label define hinotcove_lbl 1 `"No, has coverage"', add
label define hinotcove_lbl 2 `"Yes, has no coverage"', add
label define hinotcove_lbl 7 `"Unknown-refused"', add
label define hinotcove_lbl 8 `"Unknown-not ascertained"', add
label define hinotcove_lbl 9 `"Unknown-don't know"', add
label values hinotcove hinotcove_lbl

label define smokev_lbl 00 `"NIU"'
label define smokev_lbl 01 `"No"', add
label define smokev_lbl 02 `"Yes"', add
label define smokev_lbl 07 `"Unknown-refused"', add
label define smokev_lbl 08 `"Unknown-not ascertained"', add
label define smokev_lbl 09 `"Unknown-don't know"', add
label values smokev smokev_lbl

label define aeffort_lbl 0 `"None of the time"'
label define aeffort_lbl 1 `"A little of the time"', add
label define aeffort_lbl 2 `"Some of the time"', add
label define aeffort_lbl 3 `"Most of the time"', add
label define aeffort_lbl 4 `"All of the time"', add
label define aeffort_lbl 6 `"NIU"', add
label define aeffort_lbl 7 `"Unknown-refused"', add
label define aeffort_lbl 8 `"Unknown-not ascertained"', add
label define aeffort_lbl 9 `"Unknown-don't know"', add
label values aeffort aeffort_lbl

label define ahopeless_lbl 0 `"None of the time"'
label define ahopeless_lbl 1 `"A little of the time"', add
label define ahopeless_lbl 2 `"Some of the time"', add
label define ahopeless_lbl 3 `"Most of the time"', add
label define ahopeless_lbl 4 `"All of the time"', add
label define ahopeless_lbl 6 `"NIU"', add
label define ahopeless_lbl 7 `"Unknown-refused"', add
label define ahopeless_lbl 8 `"Unknown-not ascertained"', add
label define ahopeless_lbl 9 `"Unknown-don't know"', add
label values ahopeless ahopeless_lbl

label define anervous_lbl 0 `"None of the time"'
label define anervous_lbl 1 `"A little of the time"', add
label define anervous_lbl 2 `"Some of the time"', add
label define anervous_lbl 3 `"Most of the time"', add
label define anervous_lbl 4 `"All of the time"', add
label define anervous_lbl 6 `"NIU"', add
label define anervous_lbl 7 `"Unknown-refused"', add
label define anervous_lbl 8 `"Unknown-not ascertained"', add
label define anervous_lbl 9 `"Unknown-don't know"', add
label values anervous anervous_lbl

label define arestless_lbl 0 `"None of the time"'
label define arestless_lbl 1 `"A little of the time"', add
label define arestless_lbl 2 `"Some of the time"', add
label define arestless_lbl 3 `"Most of the time"', add
label define arestless_lbl 4 `"All of the time"', add
label define arestless_lbl 6 `"NIU"', add
label define arestless_lbl 7 `"Unknown-refused"', add
label define arestless_lbl 8 `"Unknown-not ascertained"', add
label define arestless_lbl 9 `"Unknown-don't know"', add
label values arestless arestless_lbl

label define asad_lbl 0 `"None of the time"'
label define asad_lbl 1 `"A little of the time"', add
label define asad_lbl 2 `"Some of the time"', add
label define asad_lbl 3 `"Most of the time"', add
label define asad_lbl 4 `"All of the time"', add
label define asad_lbl 6 `"NIU"', add
label define asad_lbl 7 `"Unknown-refused"', add
label define asad_lbl 8 `"Unknown-not ascertained"', add
label define asad_lbl 9 `"Unknown-don't know"', add
label values asad asad_lbl

label define aworthless_lbl 0 `"None of the time"'
label define aworthless_lbl 1 `"A little of the time"', add
label define aworthless_lbl 2 `"Some of the time"', add
label define aworthless_lbl 3 `"Most of the time"', add
label define aworthless_lbl 4 `"All of the time"', add
label define aworthless_lbl 6 `"NIU"', add
label define aworthless_lbl 7 `"Unknown-refused"', add
label define aworthless_lbl 8 `"Unknown-not ascertained"', add
label define aworthless_lbl 9 `"Unknown-don't know"', add
label values aworthless aworthless_lbl

