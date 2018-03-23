## Synopsis
This program contains two do-files: **var_label_scan.do** and **var_labeler.do**. 

The first (var_label_scan.do) scans all Stata (.dta) files found in a specified directory for variables that are not labeled. The output is a .csv file (var_labels.csv) which contains the following information:
* **file**: path of the .dta file
* **var**: variable name 
* **varlabel**: variable label
* **samp1**-**sampN**: data sample for the given variable

After the user adds labels to the variables by editing the "varlabel" field of var_labels.csv, the second do-file (var_labeler.do) reads in the .csv file and labels the variables accordingly. 

## Instructions

1) In the file var_label_scan.do, edit the global variable `directory_to_scan` with the folder containing the data to scan
2) Specify where the output file should be saved by editing the `cd` path 
3) Specify desired options (see below) and run var_label_scan.do 
4) Edit the "varlabel" field of var_labels.csv and save the file
5) In the file var_labeler.do, edit the global `path_to_csv` with the path to the file var_labels.csv
6) Run var_labeler.do 

#### Options for var_label_scan.do
* **allvars**: output all variables, including those with labels (default is to only output variables without labels)
* **notunique**: the data samples do not need to be unique (can speed up the program)
* **decode_var**: decode variables with value labels before writing samples to output
* **samples(#)**: number of samples to output to excel (default is 5)

