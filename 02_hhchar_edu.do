/*------------------------------------------------------------------------------
# Name:		02_hhchar_edu
# Purpose:	Process household data and create hh characteristic variables
# Author:	Patrick Gault
# Created:	2015/2/21
# License:	MIT License
# Ado(s):	labutil, labutil2 (ssc install labutil, labutil2)
# Dependencies:copylables, attachlabels, 00_SetupFoldersGlobals.do, 01_hhchar.do
#-------------------------------------------------------------------------------
*/

clear
capture log close
log using "$pathlog/02_hhchar_edu.log", replace

/*Sort education dataset GSEC4.dta in order to merge with 01_hhchar.dta and save
in $pathout*/
use "$pathin/GSEC4.dta", clear
sort HHID PID
save "$pathout/GSEC4_sorted.dta"

* Load 01_hhchar.dta and merge with GSEC4_sorted.dta.
use "$pathout/01_hhchar", clear
merge HHID PID using "$pathout/01_hhchar" "$pathout/GSEC4_sorted.dta"
save "$pathout/02_hhchar_edu", replace


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


* Create variable to reflect the maximum level of education in the household for those 25+
egen educAdult = max(educ) if h2q8>24, by(HHID)
egen educAdult_r = max(educAdult), by(HHID) //ac
replace educAdult = educAdult_r  //ac
drop educAdult_r  //ac

g educHoh = educ if hoh==1
la var educAdult "Highest adult education in household"
la var educHoh "Education of Hoh"

* Create dummys distinguishing between adult women's and men's education in same hh
g byte primFem = (h2q3 == 2) & (h2q8>15) & (educ == 2)
g byte lowsecondFem = (h2q3 == 2) & (h2q8>15) & (educ == 5)
g byte upsecondFem = (h2q3 == 2) & (h2q8>15) & (educ == 6)
g byte tertFem = (h2q3 == 2) & (h2q8>15) & (educ == 8)

g byte primMale = (h2q3 == 1) & (h2q8>15) & (educ == 2)
g byte lowsecondMale = (h2q3 == 1) & (h2q8>15) & (educ == 5)
g byte upsecondMale = (h2q3 == 1) & (h2q8>15) & (educ == 6)
g byte tertMale = (h2q3 == 1) & (h2q8>15) & (educ == 8)

* Collapse everything down to HH-level using max values for all vars
* Copy variable labels to reapply after collapse
include "$pathdo/copylabels.do"

#delimit ;
	collapse (max) hoh femhead agehead ageheadsq marriedHead widowHead 
		singleHead marriedmonoHead marriedpolyHead divorcedHead divorcedFemhead
		widowHead widowFemhead singleHead singleFemhead educ educAdult educHoh 
		primFem lowsecondFem upsecondFem tertFem primMale lowsecondMale
		upsecondMale tertMale
		sample_type, by(HHID) fast;
#delimit cr
order HHID

* Reapply variable lables & value labels
include "$pathdo/attachlabels.do"

* Create value labels for edu
la def ed 0 "No Education" 1 "Pre-primary" 2 "Primary" /*
	*/ 3 "Post-Primary Specialized" 4 "Junior Vocational" 5 "Lower Secondary" /*
	*/ 6 "Upper Secondary" 7 "Post-Secondary Specialized" 8 "Tertiary"
foreach x of varlist educ educAdult educHoh {
	label values `x' ed
	}
*end

* Add notes to variables if needed
notes educAdult: missing values indicate that no member of household was over 25
compress


* Save
save "$pathout/hhchar_edu.dta", replace

* Keep a master file of only household id's for missing var checks
keep HHID
save "$pathout\hhid.dta", replace


* Create an html file of the log for internet sharability
log2html "$pathlog/02_hhchar_edu", replace
log close
