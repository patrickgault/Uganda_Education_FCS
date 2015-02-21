/*------------------------------------------------------------------------------
# Name:		01_hhchar
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
log using "$pathlog/01_hhchar.log", replace


* Load household survey module of all individuals.
use "$pathin/GSEC2.dta", clear
sort HHID PID

/* Demographic list to calculate
1. Head of Household Sex
2. Relationship Status
*/

* Create head of household variable based on primary respondent and sex
g byte hoh = h2q4 == 1
la var hoh "Head of household"

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
la var widowFemhead "Widowed Female head of household"

g byte singleHead = (h2q10==5 & hoh==1)
la var singleHead "single HoH"

g byte singleFemhead = (h2q10==5 & femhead)
la var singleFemhead "single HoH"


* Save
save "$pathout/hhchar.dta", replace

* Keep a master file of only household id's for missing var checks
keep HHID PID
save "$pathout\hhid.dta", replace


* Create an html file of the log for internet sharability
log2html "$pathlog/01_hhchar", replace
log close
