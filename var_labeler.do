/*********************************************************************************************************************************************
Description: This file takes the edited output from var_label_scan.do (var_labels.csv) and reads in the added variable labels. To use this file,
first run var_label_scan.do, open the output "var_labels.csv", add variable labels for the variables that you wish to label, save the csv file 
and use this file to read in the file paths, variable names and labels. The file will label the variables and save the datsets in place of the 
old files. Only the variable labels are changed - nothing else in the data is edited.

Inputs: Path to where var_labels.csv 
Outputs: Saved versions of the datafiles contained in the variable "file" in var_labels.csv
Date Last Modified: March 21, 2018
Last Modified By: Marisa Carlos (mcarlos@povertyactionlab.org)
**********************************************************************************************************************************************/

version 15.1
clear all
set more off 
set maxvar 120000

if c(username)=="mbc96_TH" {
	sysdir set PLUS "U:\Documents\Stata_personal\Downloaded" 
	sysdir set PERSONAL "U:\Documents\Stata_personal\Personal"
	global path_to_csv "U:/Documents/var_labels.csv" // path to CSV sheet containing variable labels (output from var_label_scan)
}

capture program drop label_variables_from_csv
program label_variables_from_csv
	syntax anything(name=var_label_csv_path id="path to .csv sheet containing variable names and labels")
	/*
	EXPLANATION OF INPUTS:
		var_label_csv_path = Path to .csv sheet containing variable names and labels 
	*/
	
	*Read in CSV sheet with file paths, variable names, and labels: 
	import delimited using "`var_label_csv_path'", varnames(1) delimiter(",") stringcols(_all) colrange(1:3)
	
	*Tag files: 
	egen file_tag = tag(file)
	qui count if file_tag==1
	gsort - file_tag
	local num_files = r(N)
	forvalues i = 1/`num_files' {
		local file_`i' = file[`i']
		*display "FILE `i' = `file_`i''"
		
		local file_`i'_vars_to_label 
		preserve
			qui keep if file=="`file_`i''"
			local num_vars_to_label_file_`i' = 0
			qui count
			forvalues j=1/`r(N)' {
				local ++num_vars_to_label_file_`i'
				local file_`i'_var_`j' = var[`j']
				local file_`i'_vars_to_label `file_`i'_vars_to_label' `file_`i'_var_`j''
				local file_`i'_label_`j' = varlabel[`j']
			}
		restore
	}
	
	forvalues i = 1/`num_files' {
		use "`file_`i''", clear
		local j=0
		foreach var of local file_`i'_vars_to_label {
			label variable `var' "`file_`i'_label_`++j''"
			save, replace
		}
	}
end

label_variables_from_csv ${path_to_csv}
