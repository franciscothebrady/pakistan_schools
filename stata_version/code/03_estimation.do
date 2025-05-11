** estimations
* order of operations:
* 1. load cleaned data
* 2. spec 1: raw regressions without control
* 3. spec 2: control for all school characteristics 
* 	year FE, 
* 4. model 3
* 5. model 3

* set up 
clear
capture ssc reghdfe replace
capture ssc coefplot replace

* set paths
do set_global_paths.do

di "results are output to: $tabs"

* load data 
use "${proc}/01_processed_scores.dta"

** correlation 
corr transition lss* hss*

** specification 1: raw correlation no controls
reg hssc_score transition lssc_score lss_private eft, rob
* store estimate for table
eststo spec1
estadd local yearfe "No"
estadd local schoolcontrols "No"
estadd local hsspec "No"
* esttab, label se s(yearfe schoolfe, label("Year FE" "School FE"))

** specification 2: all the school controls, still no FE
reg hssc_score transition lssc_score lss_private eft lss_area lss_ownbuilding lss_boundarywall lss_boys lss_classrooms lss_electricity lss_estyear lss_laboratory lss_library lss_playground lss_toilets, rob
eststo spec2
estadd local yearfe "No"
estadd local schoolcontrols "Yes"
estadd local hsspec "No"

*esttab spec2, label se s(yearfe schoolfe, label("Year FE" "School FE"))

** specification 3: only the useful controls, only year FE
reghdfe hssc_score transition lssc_score lss_private eft lss_area lss_ownbuilding lss_boundarywall lss_boys lss_classrooms lss_electricity lss_estyear lss_library lss_playground, absorb(hss_spec lss_year) vce(robust)
eststo spec3
estadd local yearfe "Yes"
estadd local schoolcontrols "Yes"
estadd local hsspec "Yes"
esttab spec3

// * absorb HSS subject
// reghdfe hssc_score transition lssc_score lss_private eft lss_area lss_ownbuilding lss_boundarywall lss_boys lss_classrooms lss_electricity lss_estyear lss_library lss_playground, absorb(hss_spec lss_year) vce(robust)

** specification 4: drop school controls, add year control and cluster SE at school level
reghdfe hssc_score transition lssc_score lss_private eft, absorb(lss_year hss_spec) vce(cluster lss_id)
eststo spec4
estadd local yearfe "Yes"
estadd local schoolcontrols "No"
estadd local hsspec "Yes"
*esttab spec4

** spec 5: keep controls, cluster at school level
reg hssc_score transition lssc_score lss_private eft lss_area lss_ownbuilding lss_boundarywall lss_boys lss_classrooms lss_electricity lss_estyear lss_library lss_playground i.lss_year, vce(cluster lss_id)
eststo spec5
estadd local yearfe "No"
estadd local schoolcontrols "Yes"
estadd local hsspec "No"

** spec 6: drop school controls, add year control and cluster SE at school level
gen private_transition = lss_private*transition

reghdfe hssc_score transition lssc_score lss_private private_transition eft lss_area lss_ownbuilding lss_boundarywall lss_boys lss_classrooms lss_electricity lss_estyear lss_library lss_playground, absorb(lss_year hss_spec) vce(cluster lss_id)

eststo spec6
estadd local yearfe "No"
estadd local schoolcontrols "Yes"
estadd local hsspec "No"

*****************
** output tables 
*****************
esttab spec1 spec2 using "${tabs}models1-2.rtf", ///
	nogaps ///
	se s(yearfe schoolcontrols hsspec, ///
	label("Year FE" "School Controls" "HSS Specialization")) ///
	label wide replace 

*esttab spec3 spec4 spec5 
	
esttab spec3 spec4 spec5 using "${tabs}models3-5.rtf", ///
	drop(*.lss_year) ///
	nogaps ///
	nonumbers mtitles("(3)" "(4)" "(5)")  ///
	se s(yearfe schoolcontrols hsspec, ///
	label("Year FE" "School Controls" "HSS Specialization")) ///
	label wide replace
	
// esttab gradrate1 gradrate2 grad2sls grad2sls2 using "results/results.rtf", ///
// 	se s(year inst post02, ///
// 	label("Academic Year FE" "Institution FE" "Time")) ///
// 	addnotes(Note: Real 2015 Dollars) ///
// 	drop(*.academicyear) label append

******************************
** coefplot
******************************

coefplot (spec1, label(No Controls) pstyle(p6)) ///
	 (spec2, label(LSS Controls) pstyle(p7)) ///
	 (spec3, label(LSS Controls, Year FE) pstyle(p8)) ///
	 (spec4, label(Year FE) pstyle(p9)) ///
	 (spec5, label(LSS Controls) pstyle(p10)) ///
	 , keep(transition lss_private eft) ///
	 msymbol(S) ///
	 xline(0) ///
	 coeflabels(transition = "Transition" ///
		lss_private = "Private LSS" ///
		eft = "Ever Filed Taxes") ///
	 title(Language Transition)

graph export "${figs}coefplot.png", width(500) replace


******************************
** DiD set up **
******************************
* rename score vars
rename lssc_score score_lss
rename hssc_score score_hss
* reshape to long 
reshape long score_, i(student_id) j(school_level) string
rename score_ score
* create indicator for higher secondary 
gen high_secondary = (school_level == "hss")
label variable high_secondary "Higher Secondary"
* interaction for did
gen urdXhss = lss_urdu * high_secondary
label variable urdXhss "LSS Urdu X HSS Interaction (Treatment)"

*** run it bb 
reghdfe score lss_urdu high_secondary urdXhss eft lss_private ///
        , absorb(lss_year) vce(cluster student_id)
	
*** using didreg
didregress (score) (urdXhss), group(student_id) ///
	time(high_secondary) vce(cluster student_id)
eststo didmodel
estadd local yearfe "Yes"


esttab didmodel using "${tabs}didmodel_urdu.rtf", ///
	nogaps se s(yearfe, ///
	label("Year FE")) ///
	label ///
	addnote(Note: Errors clustered at the student level) ///
	replace

// esttab spec3 spec4 spec5 using "${tabs}models3-5.rtf", ///
// 	nogaps ///
// 	se s(schoolfe yearfe, ///
// 	label("Year FE" "School FE")) ///
// 	label replace

	

	
