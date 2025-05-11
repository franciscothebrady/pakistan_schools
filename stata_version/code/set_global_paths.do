* Set up global paths

clear

display "i am here"

local user c(username)
if `user' == "francisco" {
	di "user is francisco"
	global top "/home/francisco/project774/"
	global raw "/home/francisco/project774/data/raw/"
	global proc "/home/francisco/project774/data/processed/"
	global figs "/home/francisco/project774/results/figures/"
	global tabs "/home/francisco/project774/results/tables/"
} 
else {
	di "user is salman"
	global top "H:\My Drive\774\774 Paper\"
	global raw "H:\My Drive\774\774 Paper\data\raw\"
	global proc "H:\My Drive\774\774 Paper\data\processed\"
	global figs "H:\My Drive\774\774 Paper\results\figures\"
	global tabs "H:\My Drive\774\774 Paper\results\tables\"
}
else {
	di "hello professor holz"
	di "please set your working directory or leave all globals set to '.'"
	global top "."
	global raw "."
	global proc "."
	global figs "."
	global tabs "."
}

di "top level is $top"


// /* Top level directory */
// if "`c(username)'" == "francisco" {
//	
//     global base_dir "/home/francisco/project774"
// } 
// else {
//     global base_dir "H:/My Drive/774/774 Paper"
// }
//
// // Define folder paths
// global do_dir "${base_dir}/Do Files"
// global paper_dir "${base_dir}/Formalized Paper"
// global proposals_dir "${base_dir}/Grant Proposals"
// global processed_data_dir "${base_dir}/Processed Data"
// global raw_data_dir "${base_dir}/Raw Data"
// global tables_dir "${base_dir}/Tables"
// global visualization_dir "${base_dir}/Visualization"
//
// // Display the base directory
// display "Base directory is set to: ${base_dir}"
