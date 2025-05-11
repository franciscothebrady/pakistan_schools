cd "C:\FBR returns"
* load raw data
use "final.dta", replace

* gen ID 
gen anonymized_id = _n
* keep only variables we want for minimum viable product
keep ObtainedMarks MatricYear SchoolType SchoolTypeExtended MatricStudyGroup TotalMarks ObtainedMarks Status Gender Inter College1 CollegeExtended1 Subj eft tfey Language anonymized_id

save "francisco.dta", replace