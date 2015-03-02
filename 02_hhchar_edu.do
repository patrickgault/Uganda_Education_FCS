/*------------------------------------------------------------------------------
# Name:		01_hhchar_edu
# Purpose:	Process household characteristics and education characteristics
# Author:	Patrick Gault
# Created:	2015/2/21
# License:	MIT License
# Ado(s):	labutil, labutil2 (ssc install labutil, labutil2)
# Dependencies: copylables, attachlabels, 00_SetupFoldersGlobals.do
#-------------------------------------------------------------------------------
*/

clear
capture log close
log using "/Users/patrickgault/Documents/Documents/Academic/GWU/Spring 2015/Uganda/Log/01_hhchar_educ",replace

*Load HH Roster, GSEC2.dta
use "/Users/patrickgault/Documents/Documents/Academic/GWU/Spring 2015/Uganda/Datain/GSEC2.dta",clear

* Merge education data to household roster using the force command
merge 1:1 HHID PID using "/Users/patrickgault/Documents/Documents/Academic/GWU/Spring 2015/Uganda/Datain/GSEC4.dta", force

**********************************
*Head of Household Characteristics
**********************************

/* Demographic list to calculate:
1. Head of Household Sex
2. Relationship Status
*/

* Create head of household variable based on primary respondent and sex
g byte hoh = h2q4 == 1
la var hoh "Head of household"

g byte malehead = h2q3 == 1 & h2q4 == 1
la var malehead "male head of household"

g byte femhead = h2q3 == 2 & h2q4 == 1
la var femhead "Female head of household"

g agehead = h2q8 if hoh == 1
la var agehead "Age of head of household"

g ageheadsq = agehead^2
la var ageheadsq "Squared age of the head (for non-linear effects)"

* Create head of household relationship status variable based on head of household status and relationship status
g byte marriedmonoHead = h2q10 == 1 & hoh==1
la var marriedmonoHead "married monogamously HoH"

g byte marriedpolyHead = h2q10 == 2 & hoh==1
la var marriedpolyHead "married polygamously HoH"

g byte divorcedHead = (h2q10 == 3 & hoh==1)
la var divorcedHead "divorced HoH"

g byte divorcedFemhead = (h2q10 == 3 & femhead)
la var divorcedFemhead "divorced Female head of household"

g byte widowHead = (h2q10 == 4 & hoh==1)
la var widowHead "widowed HoH"

g byte widowFemhead = (h2q10 == 4 & femhead)
la var widowFemhead "widowed Female head of household"

g byte singleHead = (h2q10==5 & hoh==1)
la var singleHead "single HoH"

g byte singleFemhead = (h2q10==5 & femhead)
la var singleFemhead "single HoH"

* Create household size variables
bysort HHID: gen hhSize = _N 
la var hhSize "household size"

**********************************
*Head of Household Education Characteristics
**********************************

/* Education list to calculate
1. Head of Household Education
3. Adult Male Education
4. Adult Female Education
*/


/*No Education value definitions listed in codebook for section 4 Module

Education level values found in h4q7 defined using the following:
http://microdata.worldbank.org/index.php/catalog/565/datafile/F2/V110
http://www.classbase.com/countries/Uganda/Education-System

No Education (0)
Pre-Primary (Less than Primary Year 1)
Primary Level (Years 1 - 7)
Post-Primary Specialized Training or Certificate
Junior Vocational/Technical (Years 8 - 10)
Lower Secondary (Years 8 - 11)
Upper Secondary (Years 11 - 13)
Post-Secondary Specialized Training or Certificate
Tertiary (Above Secondary other than Post-Secondary Specialized Training or Cer
tificate)
*/


*Create education level variable

* No education listed 
g educ = . 
la var educ "Education levels"
* No education (This includes:"Don't Know" and "2" Responses))
replace educ = 0 if inlist(h4q7, 2, 99)
* Pre-primary
replace educ = 1 if inlist(h4q7, 10)
* Primary
replace educ = 2 if inlist(h4q7, 11, 12, 13, 14, 15, 16, 17)
* Post-Primary Specialized Training or Certificate
replace educ = 3 if inlist(h4q7, 41)
* Junior Techincal/Vocational 
replace educ = 4 if inlist(h4q7, 21, 22, 23)
* Lower Secondary 
replace educ = 5 if inlist(h4q7, 31, 32, 33, 34)
* Upper Secondary 
replace educ = 6 if inlist(h4q7, 35, 36)
* Post-Secondary Specialized Training or Certificate
replace educ = 7 if inlist(h4q7, 51)
* Tertiary
replace educ = 8 if inlist(h4q7, 61)

* Create head of household education variables

g byte maleheadPrimary = h2q3 == 1 & h2q4 == 1 & educ == 2
la var maleheadPrimary "male head of household with primary education"

g byte maleheadLowSecondary = h2q3 == 1 & h2q4 == 1 & educ == 5
la var maleheadLowSecondary "male head of household with lower secondary education"

g byte maleheadUpSecondary = h2q3 == 1 & h2q4 == 1 & educ == 6
la var maleheadUpSecondary "male head of household with upper secondary education"

g byte maleheadTertiary = h2q3 == 1 & h2q4 == 1 & educ == 8
la var maleheadTertiary "male head of household with tertiary education"

g byte femheadPrimary = h2q3 == 2 & h2q4 == 1 & educ == 2
la var femheadPrimary "female head of household with primary education"

g byte femheadLowSecondary = h2q3 == 2 & h2q4 == 1 & educ == 5
la var femheadLowSecondary "female head of household with lower secondary education"

g byte femheadUpSecondary = h2q3 == 2 & h2q4 == 1 & educ == 6
la var femheadUpSecondary "female head of household with upper secondary education"

g byte femheadTertiary = h2q3 == 2 & h2q4 == 1 & educ == 8
la var femheadTertiary "female head of household with tertiary education"

* Create head of household educational variable based on head of household status and relationship status
g byte marriedmonoHeadPrimary = h2q10 == 1 & hoh==1 & educ == 2
la var marriedmonoHeadPrimary "married monogamously HoH with primary education"

g byte marriedmonoHeadLowSecondary = h2q10 == 1 & hoh==1 & educ == 5
la var marriedmonoHeadLowSecondary "married monogamously HoH with lower secondary education"

g byte marriedmonoHeadUpSecondary = h2q10 == 1 & hoh==1 & educ == 6
la var marriedmonoHeadUpSecondary "married monogamously HoH with upper secondary education"

g byte marriedmonoHeadTertiary = h2q10 == 1 & hoh==1 & educ == 8
la var marriedmonoHeadTertiary "married monogamously HoH with tertiary education"

*

g byte marriedpolyHeadPrimary = h2q10 == 2 & hoh==1 & educ == 2
la var marriedpolyHeadPrimary "married polygamously HoH with primary education"

g byte marriedpolyHeadLowSecondary = h2q10 == 2 & hoh==1 & educ == 5
la var marriedpolyHeadLowSecondary "married polygamously HoH with lower secondary education"

g byte marriedpolyHeadUpSecondary = h2q10 == 2 & hoh==1 & educ == 6
la var marriedpolyHeadUpSecondary "married polygamously HoH with upper secondary education"

g byte marriedpolyHeadTertiary = h2q10 == 2 & hoh==1 & educ == 8
la var marriedpolyHeadTertiary "married polygamously HoH with tertiary education"

*

g byte divorcedHeadPrimary = (h2q10 == 3 & hoh==2 & educ == 2)
la var divorcedHeadPrimary "divorced HoH with primary education"

g byte divorcedHeadLowSecondary = (h2q10 == 3 & hoh==2 & educ == 5)
la var divorcedHeadLowSecondary "divorced HoH with lower secondary education"

g byte divorcedHeadUpSecondary = (h2q10 == 3 & hoh==2 & educ == 6)
la var divorcedHeadUpSecondary "divorced HoH with upper secondary education"

g byte divorcedHeadTertiary = (h2q10 == 3 & hoh==2 & educ == 8)
la var divorcedHeadTertiary "divorced HoH with tertiary education"

*

g byte divorcedFemheadPrimary = (h2q10 == 3 & femhead & educ == 2)
la var divorcedFemheadPrimary "divorced Female head of household with primary education"

g byte divorcedFemheadLowSecondary = (h2q10 == 3 & femhead & educ == 5)
la var divorcedFemheadLowSecondary "divorced Female head of household with upper secondary education"

g byte divorcedFemheadUpSecondary = (h2q10 == 3 & femhead & educ == 6)
la var divorcedFemheadUpSecondary "divorced Female head of household with upper secondary education"

g byte divorcedFemheadTertiary = (h2q10 == 3 & femhead & educ == 8)
la var divorcedFemheadTertiary "divorced Female head of household with tertiary education"

*

g byte widowHeadPrimary = (h2q10 == 4 & hoh==1 & educ == 2)
la var widowHeadPrimary "widowed HoH with primary education"

g byte widowHeadLowSecondary = (h2q10 == 4 & hoh==1 & educ == 5)
la var widowHeadLowSecondary "widowed HoH with lower secondary education"

g byte widowHeadUpSecondary = (h2q10 == 4 & hoh==1 & educ == 6)
la var widowHeadUpSecondary "widowed HoH with upper secondary education"

g byte widowHeadTertiary = (h2q10 == 4 & hoh==1 & educ == 8)
la var widowHeadTertiary "widowed HoH with tertiary education"

*

g byte widowFemheadPrimary = (h2q10 == 4 & femhead & educ == 2)
la var widowFemheadPrimary "widowed Female head of household with primary education"

g byte widowFemheadLowSecondary = (h2q10 == 4 & femhead & educ == 5)
la var widowFemheadLowSecondary "widowed Female head of household with lower secondary education"

g byte widowFemheadUpSecondary = (h2q10 == 4 & femhead & educ == 6)
la var widowFemheadUpSecondary "widowed Female head of household with upper secondary education"

g byte widowFemheadTertiary = (h2q10 == 4 & femhead & educ == 8)
la var widowFemheadTertiary "widowed Female head of household with tertiary education"

* 

g byte singleHeadPrimary = (h2q10==5 & hoh==1 & educ == 2)
la var singleHeadPrimary "single HoH with primary education"

g byte singleHeadLowSecondary = (h2q10==5 & hoh==1 & educ == 5)
la var singleHeadLowSecondary "single HoH with lower secondary education"

g byte singleHeadUpSecondary = (h2q10==5 & hoh==1 & educ == 6)
la var singleHeadUpSecondary "single HoH with upper secondary education"

g byte singleHeadTertiary = (h2q10==5 & hoh==1 & educ == 8)
la var singleHeadTertiary "single HoH with tertiary education"

*

g byte singleFemheadPrimary = (h2q10==5 & femhead & educ == 2)
la var singleFemheadPrimary "single female HoH with primary education"

g byte singleFemheadLowSecondary = (h2q10==5 & femhead & educ == 5)
la var singleFemheadLowSecondary "single female HoH with lower secondary education"

g byte singleFemheadUpSecondary = (h2q10==5 & femhead & educ == 6)
la var singleFemheadUpSecondary "single female HoH with upper secondary education"

g byte singleFemheadTertiary = (h2q10==5 & femhead & educ == 8)
la var singleFemheadTertiary "single female HoH with tertiary education"


********Create variable to reflect the maximum level of education in the household for those 25+
********egen educAdultmax = max(educ) if h2q8>24, by(HHID)
********egen educAdultmax_r = max(educAdult), by(HHID) //ac
********replace educAdultmax = educAdult_r  //ac
********drop educAdultmax_r  //ac

g educHoh = educ if hoh==1
la var educHoh "Education of Hoh"

********la var educAdult "Highest adult education in household"


* Create dummys distinguishing between adult women's and men's education in same hh
g byte primFem = (h2q3 == 2) & (h2q8>15) & (educ == 2)
g byte lowSecondaryFem = (h2q3 == 2) & (h2q8 > 15) & (educ == 5)
g byte upSecondaryFem = (h2q3 == 2) & (h2q8 > 15) & (educ == 6)
g byte tertFem = (h2q3 == 2) & (h2q8 > 15) & (educ == 8)

g byte primMale = (h2q3 == 1) & (h2q8 > 15) & (educ == 2)
g byte lowSecondaryMale = (h2q3 == 1) & (h2q8 > 15) & (educ == 5)
g byte upSecondaryMale = (h2q3 == 1) & (h2q8 > 15) & (educ == 6)
g byte tertMale = (h2q3 == 1) & (h2q8 > 15) & (educ == 8)


********* Reapply variable lables & value labels
*********include "/Users/patrickgault/Documents/Documents/Academic/GWU/Spring 2015/Uganda/Stata/attachlabels"

********** Create value labels for edu
*********la def ed 0 "No Education" 1 "Pre-primary" 2 "Primary" /*
*********	*/ 3 "Post-Primary Specialized" 4 "Junior Vocational" 5 "Lower Secondary" /*
*********	*/ 6 "Upper Secondary" 7 "Post-Secondary Specialized" 8 "Tertiary"
*********foreach x of varlist educ educAdult educHoh {
*********	label values `x' ed
*********	}
*end


********** Add notes to variables if needed
*********notes educAdult: missing values indicate that no member of household was over 25
*********compress


*Collapse on HHID
#delimit ;
		collapse (max) hoh malehead femhead agehead ageheadsq marriedmonoHead marriedpolyHead
		widowHead singleHead divorcedHead divorcedFemhead widowFemhead singleFemhead
		educ hhSize maleheadPrimary maleheadLowSecondary maleheadUpSecondary maleheadTertiary
		femheadPrimary femheadLowSecondary femheadUpSecondary femheadTertiary marriedmonoHeadPrimary
		marriedmonoHeadLowSecondary marriedmonoHeadUpSecondary marriedmonoHeadTertiary
		marriedpolyHeadPrimary marriedpolyHeadLowSecondary marriedpolyHeadUpSecondary 
		marriedpolyHeadTertiary divorcedHeadPrimary divorcedHeadLowSecondary divorcedHeadUpSecondary 
		divorcedHeadTertiary divorcedFemheadPrimary divorcedFemheadLowSecondary divorcedFemheadUpSecondary 
		divorcedFemheadTertiary widowHeadPrimary widowHeadLowSecondary widowHeadUpSecondary widowHeadTertiary
		widowFemheadPrimary widowFemheadLowSecondary widowFemheadUpSecondary widowFemheadTertiary 
		singleHeadPrimary singleHeadLowSecondary singleHeadUpSecondary singleHeadTertiary singleFemheadPrimary 
		singleFemheadLowSecondary singleFemheadUpSecondary singleFemheadTertiary educHoh 
		primFem lowSecondaryFem upSecondaryFem tertFem primMale lowSecondaryMale upSecondaryMale tertMale, by(HHID) fast;
#delimit cr
order HHID


* Save
save "/Users/patrickgault/Documents/Documents/Academic/GWU/Spring 2015/Uganda/Stata/hhchar_edu.dta", replace

* Keep a master file of only household id's for missing var checks
keep HHID
save "/Users/patrickgault/Documents/Documents/Academic/GWU/Spring 2015/Uganda/Stata/hhid.dta", replace


* Create an html file of the log for internet sharability
log2html "/Users/patrickgault/Documents/Documents/Academic/GWU/Spring 2015/Uganda/Log/01_hhchar_educ", replace
log close

