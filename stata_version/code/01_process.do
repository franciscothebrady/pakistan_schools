** Create cleaned data file for estimation
* this file
* 1. loads raw data
* 2. does some initial filtering
* 3. creates some binary variables
* 4. defines variable labels
* 5. saves output to processed directory

* set global paths 
do set_global_paths.do
/*salman's changes*/
//cd "H:\My Drive\774\774 Paper\Processed Data\Data"
* load data 
*use "${raw_data_dir}/francisco.dta", clear

use "${raw}francisco.dta", clear

* no longer relevant
/*SALMAN's CHANGE - Keeping data from below anonymized_id <= 456553. Above them, these are related to medical school and we dont have the inter scores for them*/
//keep if anonymized_id <= 456553 // only affects 407 observations

* label and rename some variables
rename MatricStudyGroup lss_studygroup
label variable lss_studygroup "Grade 9-10 Study Group"
rename MatricYear lss_year
label variable lss_year "Year Student Took LSS Certificate"
rename EstablishmentYear lss_estyear
label variable lss_estyear "LSS Year founded"
* Obtained marks variable means grade 9-10 certificate score
gen lssc_score = ObtainedMarks
label variable lssc_score "LSS Certificate Score"
* marks for higher secondary grades 11-12 examination
gen hssc_score = Inter
label variable hssc_score "HSS Certificate Score"
/*this is the subject they specialize in HSS -- prep for university */
gen hss_spec = Subj 
label variable hss_spec "HSS Specialization"
* If student does Medical specialization in Higher Secondary School
* clean hss specialization, drop missing
drop if hss_spec == "0"
drop if hss_spec == "ML"
gen hss_med = (Subj == "Med")
label variable hss_med "HSS Medical Specialization"
* engineering specialization in hss
gen hss_eng = (Subj == "Eng") 
label variable hss_eng "HSS Engineering Specialization"
* binary gender 
gen lss_boys = (Gender == "Boys")
label variable lss_boys "LSS Boys"
* convert college1 into binary for means 
gen hss_private = (College1 == "Private")
label variable hss_private "HSS Private"
* convert secondary school type into binary for means 
* note: if the school is not private, then it is a govt school
gen lss_private = (SchoolType == "Private")
label variable lss_private "LSS Private"
* School location characteristics
rename district lss_district
label variable lss_district "LSS District (Lahore)"
rename uc_name lss_ucname
label variable lss_ucname "LSS Union Council"
rename moza lss_moza 
label variable lss_moza "LSS Moza"
rename tehsil lss_tehsil
label variable lss_tehsil "LSS Tehsil"
rename permanent_address lss_permaddress
label variable lss_permaddress "LSS Permanent Address"
rename markaz lss_markaz 
label variable lss_markaz "LSS Markaz (District)"
rename street_name lss_street
label variable lss_street "LSS street name"
* urban/rural
gen lss_urban = 0
replace lss_urban = 1 if School_Location == "Urban"
label variable lss_urban "LSS Urban Location"
* Single-sex Schools, etc
* first collapse categorys
/*replace School_Gender = "Boys" if School_Gender == "Male"
replace School_Gender = "Girls" if School_Gender == "Female"
gen lss_coed = 0
replace lss_coed = 1 if School_Gender == "Both"
label variable lss_coed "LSS Coeducational"
* Boys school only
gen lss_boys = 0
replace lss_boys = 1 if School_Gender == "Boys"
label variable lss_boys "LSS Single-sex (Boys)"
*/
* Prestigious/Selective Public Higher Secondary 
gen govt_top = (CollegeExtended1 == "Government-Top")
label variable govt_top "HSS Top Gov't"
* label tax status variables
label variable eft "Ever filed taxes"
label variable tfey "Filed taxed every year"
* language of instruction in lower secondary school
/* this code is obsolete because salman renamed the variable
gen lss_language = Language
* combine "Mixed" and "Both" into one category
replace lss_language = "Both" if lss_language == "Mixed"
* add Unknown category
replace lss_language = "Unknown" if lss_language == "0"
*/
* now called MediumOfInstruction
gen lss_language = MediumOfInstruction
label  variable lss_language "LSS Language/Exam Language"
tab lss_language
* create binary for language in LSS
gen lss_english = (lss_language == "English")
label variable lss_english "LSS in English"
gen lss_urdu = (lss_language == "Urdu")
label variable lss_urdu "LSS in Urdu"
* tax filing behavior 
label variable eft "Ever filed taxes Indicator"
label variable tfey "Filed taxes every year Indicator"
* school infrastructure characteristics
rename ClassRooms lss_classrooms
label variable lss_classrooms "LSS Number of Classrooms"
* clean playground variable 
rename play_ground lss_playground 
label variable lss_playground "LSS Playgrounds"
* cleaning
* playground
replace lss_playground = "1" if lss_playground == "Yes"
replace lss_playground = "0" if lss_playground == "No"
destring lss_playground, replace
* water 
rename drink_water lss_water
replace lss_water = "1" if lss_water == "Yes"
replace lss_water = "0" if lss_water == "No"
destring lss_water, replace
label variable lss_water "LSS Drinkable Water"
* electricity
rename electricity lss_electricity
replace lss_electricity = "1" if lss_electricity == "Yes"
replace lss_electricity = "0" if lss_electricity == "No"
destring lss_electricity, replace
label variable lss_electricity "LSS Electricity"
*tab lss_playground
* clean and label the toilets variable
rename toilets lss_toilets
label variable lss_toilets "LSS Toilets"
replace lss_toilets = "1" if lss_toilets == "Yes"
replace lss_toilets = "0" if lss_toilets == "No"
destring lss_toilets, replace
* boundary wall 
rename boundary_wall lss_boundarywall
label variable lss_boundarywall "LSS Boundary Wall"
replace lss_boundarywall = "1" if lss_boundarywall == "Yes"
replace lss_boundarywall = "0" if lss_boundarywall == "No"
destring lss_boundarywall, replace
* laboratory 
rename lab_exist lss_laboratory
label variable lss_laboratory "LSS Laboratory"
replace lss_laboratory = "1" if lss_laboratory == "Yes"
replace lss_laboratory = "0" if lss_laboratory == "No"
destring lss_laboratory, replace
* school total area 
* kanal is a unit of measurement equal to 0.125 acres
gen lss_area = TotalAreaKanal
label variable lss_area "LSS Total Area (Kanal)"
* school owns building 
gen lss_ownbuilding = 0
replace lss_ownbuilding = 1 if bldg_ownship == "Owned"
label variable lss_ownbuilding "LSS Owns Building"
* library
* note: this variable contains 0, 1, 2, No, and Yes
* assume 1/Yes means library, else 0
gen lss_library = 0
replace lss_library = 1 if inlist(library, "1", "Yes")
destring lss_library, replace
label variable lss_library "LSS Has Library"
*tab library lss_library, row

* school id (for LSS)
rename school_id lss_id
label variable lss_id "LSS School ID" 
* student id 
rename anonymized_id student_id
label variable student_id "Student ID"

****************************
** create treatment variable
* treatment = started in urdu school
* everyone ends up in english HSS
**************************** 
gen transition = 0 
replace transition = 1 if lss_english == 0
label variable transition "Student attended Urdu LSS (transition to English)"

* drop small N years 
keep if lss_year > 2013 & lss_year < 2020
sum

* keep only processed variables and school address because @Salman 
* needs to tell me what to do with them
keep lss_id student_id lss_year lss_estyear transition lss_studygroup lssc_score ///
	hssc_score hss_spec hss_med hss_eng hss_private /// 
	lss_private govt_top eft tfey lss_urban ///
	lss_language lss_english lss_urdu lss_classrooms ///
	lss_playground lss_water lss_electricity lss_toilets ///
	lss_boundarywall lss_laboratory lss_area lss_ownbuilding /// 
	lss_library lss_boys lss_district lss_tehsil lss_moza lss_permaddress
	
save "${proc}01_processed_scores.dta", replace

/*
binscatter Inter ObtainedMarks if SchoolType == "Government", ///
    title("Government Lower Secondary") ///
    xtitle(Gr. 10 Score) ytitle(Gr. 12 Score) ///
    name(gov_plot, replace)

binscatter Inter ObtainedMarks if SchoolType == "Private", ///
    title("Private Lower Secondary") ///
    xtitle(Gr. 10 Score) ytitle(Gr. 12 Score) ///
    name(priv_plot, replace)

graph combine gov_plot priv_plot, ///
    title("Scores by School Type")
graph export scores_schooltype.png, width(500) replace

/* use binscatter, which bins data into quantiles
binscatter Inter ObtainedMarks, title("Grade 10 scores vs. Grade 12 scores") xtitle(Grade 10 (SSC)) ytitle(Grade 12 (HSSC))
graph export grade10v12.png, width(500) replace
*/

* passing grades
/*histogram ObtainedMarks, by(Status) ///
	kdensity ///
	title("SSC Scores by Status") title("") ///
    ytitle("Frequency") ///
    xtitle("SSC Score")
*/


* calculate prob. of private college by each SSC Bin
preserve
drop if ssc_bin < 200
collapse (mean) college_private, by(ssc_bin)
twoway (scatter college_private ssc_bin), ///
    ytitle("Private") ///
    xtitle("SSC Score Bin") ///
    note("50 point bins") /// 
    title("Probability of Private College by SSC Score")
restore 
graph export private_byscore.png, width(500) replace

* prob of private by SSC bin and private lower 
preserve
drop if ssc_bin < 200
collapse (mean) college_private, by(ssc_bin private_lower)
twoway (scatter college_private ssc_bin), by(private_lower) ///
    ytitle("Private") ///
    xtitle("SSC Score Bin") ///
    note("50 point bins") /// 
    title("Private College by SSC Score") ///
    legend(label(1 "Government" 2 "Private"))
restore 
graph export private_byscore_type.png, width(500) replace


* private college based on private lower secondary and SSC score
reg college_private private_lower ssc_bin male i.MatricYear, rob
eststo priv_college
* med school based on private lower
reg med private_lower ssc_bin male i.MatricYear, rob
eststo med

esttab priv_college med, drop(*.MatricYear)
*/
