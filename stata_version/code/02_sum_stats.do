** visualization and summary statistics 
* order of operations:
* 1. load cleaned data
* 2. create summary tables overall
* 3. by Language
* 4. by HSS type
* 5. by language of instruction

* set up 
clear
capture ssc install estout, replace
capture ssc install binscatter, replace
capture ssc install catplot, replace

* set paths
do set_global_paths.do

di "tables are saved in: $tabs"
di "figures are saved in: $figs"


* load data 
use "${proc}/01_processed_scores.dta"

********************************
** tables **
********************************
** overall summary statistics ** 
dtable, ///
	define(minmax = min max, delimiter(" - ")) ///
	continuous(lss_year lss_estyear, statistics(minmax)) ///
	continuous(lssc_score ///
	eft tfey lss_boys ///
	lss_classrooms lss_water lss_electricity ///
	lss_toilets lss_boundarywall lss_playground ///
	lss_laboratory lss_area lss_urban ///
	lss_private lss_english lss_urdu ///
	lss_ownbuilding lss_library lss_boys ///
	hssc_score govt_top ///
	hss_private hss_med hss_eng ///
	, statistics(mean sd)) ///
	nformat(%1.0f min max) ///
	nformat(%4.2f mean sd) ///
	column(summary(Mean (sd))) ///
	note(LSS: Lower Secondary School) ///
	export("${tabs}table_1.docx", replace)

** summary by english language LSS **
dtable, ///
	by(lss_english) ///
	define(minmax = min max, delimiter(" - ")) ///
	continuous(lss_year lss_estyear, statistics(minmax)) ///
	continuous(lssc_score ///
	eft tfey lss_boys ///
	lss_classrooms lss_water lss_electricity ///
	lss_toilets lss_boundarywall lss_playground ///
	lss_laboratory lss_area ///
	lss_private lss_urban ///
	lss_ownbuilding lss_library lss_boys ///	
	hssc_score govt_top ///
	hss_private hss_med hss_eng ///
	, statistics(mean sd)) ///
	nformat(%1.0f min max) ///
	nformat(%4.2f mean sd) ///
	column(summary(Mean (sd))) ///
	note(English = 1 denotes English as medium of instruction) ///
	export("${tabs}summary_language.docx", replace)

** summary of vars used in models only ***
dtable, ///
	define(minmax = min max, delimiter(" - ")) ///
	continuous(lss_estyear, statistics(minmax)) ///
	continuous(lssc_score ///
	lss_private eft lss_area lss_ownbuilding ///
	lss_boundarywall lss_boys lss_classrooms ///
	lss_electricity lss_estyear lss_laboratory ///
	lss_library lss_playground lss_toilets ///
	, statistics(mean sd)) ///
	nformat(%1.0f min max) ///
	nformat(%4.2f mean sd) ///
	column(summary(Mean (sd))) ///
	title(School Controls) ///
	export("${tabs}school_controls.docx", replace)


/* less nice tables 
estpost summarize eft tfey lssc_score hssc_score hss_med hss_eng lss_private hss_private male govt_top lss_english
esttab using "summary_statistics.rtf", replace ///
    cells("mean(fmt(2))") ///
    label title("Summary Statistics") 

* Add pct for categorical variables
local vlist "SchoolType lss_language hss_spec"
foreach v of local vlist {
	estpost tabulate `v', nototal
	esttab using "summary_statistics.rtf", append ///
	cells("pct(fmt(2))") ///
	label title("Frequencies")
}
*/

/** summary by language transition
eststo urdu: quietly estpost summarize ///
    lssc_score hssc_score if lss_english == 0
eststo english: quietly estpost summarize ///
    lssc_score hssc_score if lss_english == 1
* out    
esttab urdu english using "summary_language.rtf", replace ///
	mtitles("Urdu/Both LSS" "English LSS") ///
	cells("mean(pattern(1 1 0) fmt(2)) sd(pattern(1 1 0)) ") ///
	label ///
	title("Summary by Language of Instruction") 
*/	

*******************************
** viz **
*******************************
* distribution of all test scores
hist lssc_score, fraction width(10) ///
	title("Distribution of LSS Certificate Scores") ///
	caption("Note: 2013-2020" "Source: FRB") ///
	name(scorehist, replace) 

graph export "${figs}scorehist.png", width(500) replace

* test score distribution by school type
twoway (histogram lssc_score if lss_private==0, ///
	width(10) fraction color(navy%70)) ///
       (histogram lssc_score if lss_private==1, ///
       width(10) fraction color(maroon%70)), ///
       title("Distribution of LSS Certificate Scores") ///
       xtitle("LSS Certificate Score") ///
       ytitle("Fraction") ///
       legend(order(1 "Government" 2 "Private")) ///
       caption("Note: 2013-2020" "Source: FRB") ///
       name(scorehist_schooltype, replace)
       
graph export "${figs}scorehist_schooltype.png", width(500) replace

* test score distribution by LSS language 
twoway (histogram lssc_score if lss_english==0, ///
	width(10) fraction color(navy%70)) ///
       (histogram lssc_score if lss_english==1, ///
       width(10) fraction color(maroon%70)), ///
       title("Distribution of LSS Certificate Scores") ///
       xtitle("LSS Certificate Score") ///
       ytitle("Fraction") ///
       legend(order(1 "Urdu" 2 "English")) ///
       caption("Note: 2013-2020" "Source: FRB") ///
       name(scorehist_lang, replace)
       
graph export "${figs}scorehist_lang.png", width(500) replace

* Scores over time by group (non-exclusive)
preserve
collapse (mean) lssc_score=lssc_score, by(lss_year lss_private lss_english)
sort lss_year  // Sort the data by year

* Separate data for each group into distinct variables
gen group_private = .
replace group_private = lssc_score if lss_private == 1
gen group_public = .
replace group_public = lssc_score if lss_private == 0
gen group_english = .
replace group_english = lssc_score if lss_english == 1
gen group_urdu = .
replace group_urdu = lssc_score if lss_english == 0

* Plot the line graph with multiple series
twoway (mspline group_private lss_year, lwidth(medium) ///
	lcolor(blue) lpattern(solid)) ///
       (mspline group_public lss_year, lwidth(medium) ///
       lcolor(red) lpattern(dash)) ///
       (mspline group_english lss_year, lwidth(medium) ///
       lcolor(green) lpattern(dot)) ///
       (mspline group_urdu lss_year, lwidth(medium) ///
       lcolor(orange) lpattern(shortdash)), ///
	legend(order(1 "Private" 2 "Government" 3 "English" 4 "Urdu")) ///
	title("Average LSSC Score by Year") ///
	xtitle("Year") ///
	ytitle("Average LSSC Score") ///
	caption("Data Source: FRB" "Note: Non-exclusive groups.")
restore
graph export "${figs}group_lssc_score_by_year.png", replace

* test score distribution by tax status
twoway (histogram lssc_score if eft==0, ///
	width(10) fraction color(navy%70)) ///
       (histogram lssc_score if eft==1, ///
       width(10) fraction color(maroon%70)), ///
       title("Distribution of LSS Certificate Scores") ///
       subtitle("By Household Tax Behavior") ///
       xtitle("LSS Certificate Score") ///
       ytitle("Fraction") ///
       legend(order(1 "Never Filed" 2 "Ever Filed")) ///
       caption("Note: 2013-2020" "Source: FRB") ///
       name(scorehist_tax, replace)
       
graph export "${figs}scorehist_tax.png", width(500) replace

* test takers per year, private/public
graph bar (percent), over(lss_private) over(lss_year) ///
    title("LSS Certificate Takers") ///
    subtitle("by School Type") ///
    ytitle("Percent") /// 
    legend(label(1 "Government") label(2 "Private")) ///
    asyvars ///
    bar(1, color(navy)) bar(2, color(maroon)) 

graph export "${figs}testcount_bytype.png", width(500) replace

* test takers by year, english/urdu
graph bar (percent), over(lss_english) over(lss_year) ///
    title("LSS Certificate Takers") ///
    subtitle("by LSS Language") ///
    ytitle("Percent") /// 
    legend(label(1 "Urdu") label(2 "English")) ///
    asyvars ///
    bar(1, color(navy)) bar(2, color(maroon)) 

graph export "${figs}testcount_bylang.png", width(500) replace

* Private HSS by LSS language 
preserve
collapse (mean) hss_private, by(lssc_score lss_english)
drop if hss_private == 0
twoway (scatter hss_private lssc_score if lss_english == 1) ///
	(scatter hss_private lssc_score if lss_english == 0), ///
    ytitle("Private HSS") ///
    xtitle("LSSC Score") ///
    title("Enrollment in Private HSS by Score") ///
    caption("Note: 2013-2020, excluding no enrollments" "Source: FRB") ///
    legend(order(1 "English" 2 "Urdu")) ///
    name(private_bylang, replace)
restore 
graph export "${figs}private_byscorelang.png", width(500) replace

* Private HSS by LSS language, 800+ score
preserve
collapse (mean) hss_private if lssc_score > 800, by(lssc_score lss_english)
drop if hss_private == 0
twoway (scatter hss_private lssc_score if lss_english == 1) ///
	(scatter hss_private lssc_score if lss_english == 0), ///
    ytitle("Private HSS") ///
    xtitle("LSSC Score") ///
    title("Enrollment in Private HSS") ///
    subtitle("LSSC Score 800+") /// 
    caption("Note: 2013-2020, excluding no enrollments" "Source: FRB") ///
    legend(order(1 "English" 2 "Urdu")) ///
    name(privatehighscore_bylang, replace)
restore 
graph export "${figs}privatehighscore_bylang.png", width(500) replace

* probability of top govt by LSS language 
preserve
collapse (mean) govt_top, by(lssc_score lss_english)
drop if govt_top == 0
twoway (scatter govt_top lssc_score if lss_english == 1) ///
	(scatter govt_top lssc_score if lss_english == 0), ///
    ytitle("Top Govt. HSS") ///
    xtitle("LSSC Score") ///
    title("Enrollment in Top Govt. HSS") ///
    caption("Note: 2013-2020, excluding no enrollments" "Source: FRB") ///
    legend(order(1 "English" 2 "Urdu")) ///
    name(topgov_byscorelang, replace)
restore 

graph export "${figs}topgov_byscorelang.png", width(500) replace

* top govt by LSS Language, 800+ score
preserve
collapse (mean) govt_top if lssc_score > 800, by(lssc_score lss_english)
drop if govt_top == 0
twoway (scatter govt_top lssc_score if lss_english == 1) ///
	(scatter govt_top lssc_score if lss_english == 0), ///
    ytitle("Top Govt. HSS") ///
    xtitle("LSSC Score") ///
    title("Enrollment in Top Govt. HSS") ///
    subtitle("LSSC Score 800+") ///
    caption("Note: 2013-2020, excluding no enrollments" "Source: FRB") ///
    legend(order(1 "English" 2 "Urdu")) ///
    name(topgovhighscore_bylang, replace)
restore 

graph export "${figs}topgovhighscore_bylang.png", width(500) replace

/* unnecesary because they are now on the same graph
* for urdu students 
preserve
*drop if lssc_score == 0
collapse (mean) govt_top if lss_urdu == 1, by(lssc_score)
twoway (scatter govt_top lssc_score), ///
    ytitle("P(Top Govt.)") ///
    xtitle("LSSC Score") ///
    title("Probability of Top Govt. School by Score") ///
    caption("For Students in Urdu LSS") ///
    name(topgov_urdu, replace)
restore 

graph combine topgov_english topgov_urdu, ///
    title("Top Govt. by LSS Language")
graph export topgov_language.png, width(500) replace
*/

* by language and school type 
* scores by language and school type
/*
gen lang_school = lss_language + lss_private
preserve 
collapse (mean) govt_top, by(lang_school lssc_score)
twoway (scatter govt_top lssc_score), by(lang_school) ///
    ytitle("P(Top Govt.)") ///
    xtitle("LSSC Score") ///
    title("") ///
    caption("") 
restore 

graph export lang_school_scores.png, replace
*/

* medical or engineering 
/*
preserve 
collapse (mean) govt_top if (hss_med == 1 | hss_eng == 1), by(lssc_score)
twoway (scatter govt_top), by(lssc_score) ///
    ytitle("P(Top Govt.)") ///
    xtitle("LSSC Score") ///
    title("") ///
    caption("Med. or Eng. Focus") 
restore 
*/
