/*------------------------------------------------------------------------------
# Name:		03_FCS
# Purpose:	Generate WFP Food Consumption Score
# Author:	Patrick Gault
# Created:	2015/2/21
# License:	MIT License
# Ado(s):	labutil, labutil2 (ssc install labutil, labutil2)
# Dependencies: copylables, attachlabels, 00_SetupFoldersGlobals.do
#-------------------------------------------------------------------------------
*/

clear
capture log close
log using "$pathlog/03_FCS.log", replace

use "$pathin/GSEC15B.dta", replace

egen cereal_days = max(h15bq3b) if inlist(h15bq2c, 1), by(HHID)
g cerealFCS = cereal_days * 2

egen starches_days = max(h15bq3b) if inlist(h15bq2c, 2), by(HHID)
g starchesFCS = starches_days * 2

*Wheat, rice, cereal, starch
egen staples_days = max(h15bq3b) if inlist(h15bq2c, 1, 2), by(HHID)
g staplesFCS = staples_days * 2

* legumes, beans, lentils, nuts, peas & nuts and seeds
egen pulse_days = max(h15bq3b) if inlist(h15bq2c, 4), by(HHID)
g pulseFCS = pulse_days * 3

* Both weighted by 1
egen veg_days = max(h15bq3b) if inlist(h15bq2c, 6), by(HHID)
g vegFCS = veg_days

egen fruit_days = max(h15bq3b) if inlist(h15bq2c, 7), by(HHID)
g fruitFCS = fruit_days

* meat, poultry, fish, eggs
egen meat_days = max(h15bq3b) if inlist(h15bq2c, 8), by(HHID)
g meatFCS = meat_days * 4

egen milk_days = max(h15bq3b) if inlist(h15bq2c, 9), by(HHID)
g milkFCS = milk_days * 4

egen sugar_days = max(h15bq3b) if inlist(h15bq2c, 3), by(HHID)
g sugarFCS = sugar_days * 0.5

egen oil_days = max(h15bq3b) if inlist(h15bq2c, 10), by(HHID)
g oilFCS = oil_days * 0.5

* Label the variables, get their averages and plot them on same graph to compare
local ftype cereal starches staples pulse veg fruit meat milk sugar oil 
local n: word count `ftype'
forvalues i = 1/`n' {
	local a: word `i' of `ftype'
	la var `a'_days "Number of days consuming `a'"
	replace `a'_days = 0 if `a'_days == .
	replace `a'FCS = 0 if `a'FCS == .
}
*end

*preserve
keep HHID cereal_days-oilFCS
ds(HHID), not
collapse (max) `r(varlist)', by(HHID)

egen FCS = rsum2(staplesFCS pulseFCS vegFCS fruitFCS meatFCS milkFCS sugarFCS oilFCS)

sum *FCS
assert FCS <= 112
la var FCS "Food Consumption Score"

* Merge with administrative variables
merge 1:1 HHID using "$pathin/UNPS_Geovars_1112.dta"

* Save
save "$pathout/FCS.dta", replace

* Keep a master file of only household id's for missing var checks
keep HHID
save "$pathout\hhid.dta", replace


* Create an html file of the log for internet sharability
log2html "$pathlog/03_FCS", replace
log close
