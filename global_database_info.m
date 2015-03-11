function global_info = global_database_info(data_dir, database_files_names)

%% get global db stats
global_info = []; 
for curdb=database_files_names
    mn = load(fullfile(data_dir, curdb{1}), 'info');     
    if isempty(global_info)
        global_info = mn.info; 
        
%         if numel(database_files_names) > 1
            global_info.original_datafile = {global_info.original_datafile};
            global_info.original_datafile_name = {global_info.original_datafile_name}; 
%         end
        
        continue; 
    end
    info = mn.info; 
    if info.min_start_datenum < global_info.min_start_datenum
        global_info.min_start_datenum = info.min_start_datenum; 
        global_info.min_start_datestr = info.min_start_datestr; 
    end
    
    if info.max_end_datenum > global_info.max_end_datenum
        global_info.max_end_datenum = info.max_end_datenum; 
        global_info.max_end_datestr = info.max_end_datestr; 
    end
    
    global_info.num_records = global_info.num_records + global_info.num_records; 
    
    global_info.original_datafile = [global_info.original_datafile, {info.original_datafile}]; 
    global_info.original_datafile_name = [global_info.original_datafile_name, {info.original_datafile_name}]; 
end
