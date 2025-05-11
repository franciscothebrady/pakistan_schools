** exploratory and data transformations

* load data

use ${raw_data_dir}/francisco.dta", clear

*use "H:\My Drive\774\774 Paper\Do Files\francisco.dta", clear

/*SALMAN's CHANGE - Keepint data from below anonymized_id <= 456553. Above them, these are related to medical school and we dont have the inter scores for them*/
keep if anonymized_id <= 456553

encode CollegeExtended1 , gen(ce)

label list ce

//keep if ce==2

