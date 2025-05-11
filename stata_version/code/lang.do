cd "C:\FBR returns"

use "final.dta", replace

label define test_school_type 0 "Private" 1 "Gov"
label values gov_school test_school_type


drop consolidated

generate consolidated = ""
replace consolidated = "Loc" if inlist(ste, 6, 10, 11, 12) // City, District, Division
replace consolidated = "Fed" if inlist(ste, 4, 5, 7, 8, 13, 14, 15, 16) // ASF, Cantonment, Customs, DHA, LDA, Postal, Railways, Rangers
replace consolidated = "Prv" if inlist(ste, 1, 2, 18, 19) // Big chain, Church
replace consolidated = "Gov" if inlist(ste, 3, 17) // Provincial Government
replace consolidated = "Daanish" if ste == 9
replace consolidated = "Pres" if ste == 20

label define consolidated 1 "Loc" 2 "Fed" 3 "Prv" 4 "Gov" 5 "Daanish" 6 "Pres"
encode consolidated, gen(category)


keep if p_matric>=88 & p_matric<=92

keep if Inter!=0

encode Language, gen(lang)

keep if lang	== 3 | lang	==	5

reg Inter i.lang,r

reghdfe Inter i.lang, absorb(subj MatricYear male)


margins i.lang

marginsplot, ///
    xtitle("School Type in grade 09-10") ///
    ytitle("Average score in grade 11-12.") ///
    title("Language transition penality. n = 4,954") ///
    name(plot1, replace) plotregion(margin(large))