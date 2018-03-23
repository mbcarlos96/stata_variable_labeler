/*********************************************************************************************************************************************
Description: This file scans all .dta files in a directory and all subdirectories and extracts the variable labels and samples
of the variable and exports them to a .csv file. 

Inputs: Path to top directory.
Outputs: var_labels.csv (saved in the current working directory)
Date Last Modified: March 23, 2018
Last Modified By: Marisa Carlos (mcarlos@povertyactionlab.org)
**********************************************************************************************************************************************/

version 15.1
clear all
set more off 
set maxvar 120000

*sysdir set PLUS "U:\Documents\Stata_personal\Downloaded" // UNCOMMENT AND CHANGE PATH IF WANT TO SET FOLDER WHERE DOWNLOADED ADO FILES STORED
*sysdir set PERSONAL "U:\Documents\Stata_personal\Personal" // UNCOMMENT AND CHANGE PATH IF WANT TO SET FOLDER WHERE PERSONAL ADO FILES STORED

cd "" // CHANGE PATH TO WHERE YOU WANT TO SAVE OUTPUT
global directory_to_scan "" // SET THIS DIRECTORY TO THE ONE YOU WANT TO SCAN (change options at botton of do-file)

***Command "filelist" required:
capture ssc install filelist

capture program drop var_label_scan
program var_label_scan
	syntax anything(name=data_directory id="path of directory containing data")[, ALLvars NOTUNIQue decode_var SAMPles(integer 5)]
	/*
	EXPLANATION OF INPUTS:
		data_directory = path of top folder containing data (will search that folder and all subfolders)
		allvars = output all variables, including those containing labels
		missonly = only output variables that are missing a variable label 
		notunique = the samples output do not need to be unique (speeds up the program)
		decode_var = decode variables with value labels before writing samples to output
		samples = number of samples to output to excel, default is 5
	*/
	
	tempfile file_list
	filelist, directory(`data_directory') pattern("*.dta")
	gen temp="/"
	egen file_path = concat(dirname temp filename)
	keep file_path
	save `file_list'

	qui count
	forvalues i=1/`r(N)' {
		local file_`i' = file_path[`i']
	}
	
	capture file close label_file
	file open label_file using var_labels.csv, write replace text
	
	foreach header in "file" "var" "varlabel" {
		file write label_file "`header',"
	}

	if `samples'>0 {
		forvalues j=1/`samples' {
			file write label_file "samp`j',"
		}
	}
	file write label_file _n
	
	qui count

	forvalues i=1/`r(N)' { 
		use "`file_`i''", clear
		
		*Go through all the variables and write the variable name and label to the output file:
		foreach var of varlist * {
			local label : variable label `var'
			***Remove commas from the variable label (otherwise reads it as new column):
			local label = subinstr("`label'",",","",.)
			*If they say dont say all variables and the label is missing OR they say all variables:
			if ((missing("`allvars'") & missing("`label'")) | (!missing("`allvars'"))) {
				file write label_file "`file_`i'',`var',`label',"
				
				*If the user wants samples output, make sure there arent any quotation marks in string vars:
				if `samples'>0 {
					capture confirm string variable `var'
					if _rc==0 {
						qui replace `var' = subinstr(`var',`"""',"",.)
					}
					
					*If the user wants only unique values output (the default), tag and sort values:
					if missing("`notunique'") {
						*Tag unique values of the variable:
						tempvar tag_var 
						egen `tag_var' = tag(`var')
						gsort - `tag_var'
						drop `tag_var'
					}
					
					*If the user wants string variables decoded, decode and output the decoded values:
					if !missing("`decode_var'") {
						tempvar decoded_var
						capture decode `var', gen(`decoded_var')
						if _rc==0 {
							local var "``decoded_var''"
							local samp_var `decoded_var'
						}
						else {
							local samp_var `var'
						}
					}
					forvalues j=1/`samples' {
						local samp = `samp_var'[`j']
						***Remove commas from sample (otherwise reads it as new column):
						local samp = subinstr("`samp'",",","",.)
						file write label_file "`samp',"
					}
					capture drop `decoded_var'
				}
			
				file write label_file _n
			}
		}
	}

	file close label_file
end

var_label_scan ${directory_to_scan}
