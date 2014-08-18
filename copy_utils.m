function copy_utils()
    %% Get files
    configuration = 'Release'; 
    copyfile(fullfile('analyze_data\x64', configuration, 'analyze_data.*')); 


    %% Subsample
    full_database_file = 'D:\Work\Data\save-a-ride\trip_data_11.csv'; 
    subsampled_database_file = 'trip_data_11_subsampled.csv'; 
    number_of_samples = 1000; 
    eval(['!analyze_data.exe -mode sample -in "' full_database_file '" -out "' subsampled_database_file '" -num-samples ' num2str(number_of_samples) '']); 

    %% Get file info
    data_dir = 'D:\Work\Data\save-a-ride'; 
    database_files = {fullfile(data_dir, 'trip_data_1.csv'),     ...
                      fullfile(data_dir, 'trip_data_2.csv'),     ...
                      fullfile(data_dir, 'trip_data_8.csv'),     ...
                      fullfile(data_dir, 'trip_data_9.csv'),     ...
                      fullfile(data_dir, 'trip_data_10.csv'),     ...
                      fullfile(data_dir, 'trip_data_11.csv'),     ...
                      fullfile(data_dir, 'trip_data_12.csv')  };

    %%
    get_databases_info(database_files); 
    
    %% Split entire database
    TARGET_DIR = 'D:\Work\Data\save-a-ride\splits'; 
    mkdir(TARGET_DIR); 
    
    SPLIT_INTERVAL = 3600; % one hour [seconds]
    for ii=1:numel(database_files)
        % Load info
        [PATHSTR,NAME,EXT] = fileparts(database_files{ii});
        load(NAME); 
        
        % Split datafile
        eval(['!analyze_data.exe -mode split -in "' database_files{ii} '" -time-start ' num2str(info.min_start_datenum) ' -interval ' num2str(SPLIT_INTERVAL) ' -o ' NAME '-split -append false -count 100000']); 
        
        % Copy splits
        cur_target_dir = fullfile(TARGET_DIR, NAME); 
        status = rmdir(cur_target_dir, 's'); 
        mkdir(cur_target_dir); 
        movefile([NAME '-split_*.csv'], cur_target_dir); 
        
        %
        filelist = dir(fullfile(cur_target_dir, '*-split_*.csv'));
        for jj=1:numel(filelist)
            disp(['Processing split ' num2str(jj) ' of ' num2str(numel(filelist))]); 
            myDB = load_dataset(fullfile(cur_target_dir, filelist(jj).name));
            [PATHSTR,NAME,EXT] = fileparts(filelist(jj).name);
            save(fullfile(cur_target_dir, [NAME '.mat']), 'myDB'); 
            
        end
%         %% Delete split files
%         delete([NAME '-split_*.csv']); 
    end
    
    %% Process splits
    split = 'D:\Work\Data\save-a-ride\splits\trip_data_1\trip_data_1-split_45.csv'; 
    
    
    %% Load info file
    date_format = 'yyyy-mmm-dd HH:MM:SS'; 
    ds_info = dataset('File', info_file, 'Format','%s%s%d','Delimiter',',','ReturnOnError',0);

    epoch_date = datenum(1970, 1, 1); 
    min_start_time = datenum(ds_info.min_start_time, date_format)-epoch_date; % [days]
    min_end_time = datenum(ds_info.max_end_time, date_format)-epoch_date; % [days]

    time_start = min_start_time*3600*24; % [seconds]
    time_end = time_start + 60*60*1*1; % #seconds * #minutes * #hours * #days
    in_file = subsampled_database_file; 

     [PATHSTR,NAME,EXT] = fileparts(in_file);
    out_file = [NAME, '-cropped.csv'];
    command_line = ['!analyze_data.exe -mode crop -in "' in_file '" -time-start ' num2str(time_start) ' -time-end ' num2str(time_end) ' -o "' out_file '" -count 10000']; 
    eval(command_line); 
end

function get_databases_info(database_files)
    for ii=1:numel(database_files)
        info = get_info_for_file(database_files{ii}); 
        save(info.original_datafile_name, 'info'); 
    end
end

