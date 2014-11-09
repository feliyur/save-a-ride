function copy_utils()
    %% Get files
    configuration = 'Release'; 
    copyfile(fullfile('analyze_data\x64', configuration, 'analyze_data.*')); 


%     %% Subsample
%     full_database_file = 'D:\Work\Data\save-a-ride\trip_data_11.csv'; 
%     subsampled_database_file = 'trip_data_11_subsampled.csv'; 
%     number_of_samples = 1000; 
%     eval(['!analyze_data.exe -mode sample -in "' full_database_file '" -out "' subsampled_database_file '" -num-samples ' num2str(number_of_samples) '']); 


end


