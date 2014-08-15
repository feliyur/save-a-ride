%% Get files
configuration = 'Release'; 
copyfile(fullfile('analyze_data\x64', configuration, 'analyze_data.*')); 


%% Subsample
full_database_file = 'D:\Work\Data\save-a-ride\trip_data_11.csv'; 
subsampled_database_file = 'trip_data_11_subsampled.csv'; 
number_of_samples = 1000; 
eval(['!analyze_data.exe -mode sample -in "' full_database_file '" -out "' subsampled_database_file '" -num-samples ' num2str(number_of_samples) '']); 

%% Get file info

get_info_for_file = subsampled_database_file; 
 [PATHSTR,NAME,EXT] = fileparts(get_info_for_file);
info_file = [NAME '-info.csv']; 
tic
eval(['!analyze_data.exe -mode info -in "' get_info_for_file '" -out "' info_file '" -count 10000']); 
toc

%% Load info file
ds_info = dataset('File', info_file, 'Format','%s%s%d','Delimiter',',','ReturnOnError',0);

min_start_time = datenum(ds.min_start_time); 