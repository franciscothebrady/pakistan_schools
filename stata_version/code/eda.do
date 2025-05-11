** exploratory and data transformations

* load data 
use "${processed_data_dir}francisco", clear

/*SALMAN's CHANGE - Keepint data from below anonymized_id <= 456553. Above them, these are related to medical school and we dont have the inter scores for them*/
keep if anonymized_id <= 456553 // only affects 407 observations

* LABEL and rename some variables
label variable MatricStudyGroup "Grade 9-10 Study Group"
label variable Inter "Higher Secondary School (Inter) Certificate Score"
label variable ObtainedMarks "Secondary School Certificate (SSC) Score"

* CREATE binary variables for categories
* binary gender 
gen male = (Gender == "Boys")
label variable Subj "Specialization in Higher Secondary School"
* Medical Study in College (Higher Secondary School)
gen medicine = (Subj == "Med")
label variable medicine "Medical Specialization"

*sum
* label some variables so they are more legible to me
tab MatricStudyGroup



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

* convert college1 into binary for means 
gen college_private = (College1 == "Private")
* convert secondary school type into binary for means 
gen private_lower = (SchoolType == "Private")
label define pl 0 "Government" 1 "Private"
label values private_lower pl

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
