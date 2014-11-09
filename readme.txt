____________________________________________________________________________________________
Description of main functionality

--------------------------------------------------------------------------------------------
function produce_global_database()

produces .mat files from large database files defined inside the function
each manhattan database file contains data for one month of the year. 
inside the function define an interval to split (e.g. one hour) so that it can 
be processed separately 

--------------------------------------------------------------------------------------------
function get_databases_info(database_files)

produces a .mat file containing statistics (number of records, time of first / last record 
etc) for every database file specified in the input cell array. 

--------------------------------------------------------------------------------------------
info = get_info_for_file(datafile)

Produces an info *struct* for the given large database file. 

--------------------------------------------------------------------------------------------
info = load_datafile_info(datafile)

Computes an info structg file for a txt database file. 

--------------------------------------------------------------------------------------------
function stats = process_datafile(sample_file, XY_TOLERANCE_VEC, T_TOLERANCE_VEC)

Loads sample file and calls process_dataset. 

--------------------------------------------------------------------------------------------
function [myDB stats] = process_dataset(myDB, XY_TOLERANCE_VEC, T_TOLERANCE_VEC)

Main computation for a data matrix - finds correspondences between trips. 
____________________________________________________________________________________________
TODO
--------------------------------------------------------------------------------------------
Adjust times' 'datenum' saved in loaded database matrix to be relative to epoch date (datenum(1970, 1, 1))
change required in load_dataset function and others that use the time. 

