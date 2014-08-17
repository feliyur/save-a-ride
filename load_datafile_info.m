function info = load_datafile_info(datafile)

info = struct('min_start_datestr', '', ...
              'min_start_datenum', 0, ... % seconds
              'max_end_datestr', '', ...
              'max_end_datenum', 0, ... % seconds
              'num_records', 0 ); 
        
date_format = 'yyyy-mmm-dd HH:MM:SS'; 
ds_info = dataset('File', datafile, 'Format','%s%s%d','Delimiter',',','ReturnOnError',0);

epoch_date = datenum(1970, 1, 1); 
min_start_time = datenum(ds_info.min_start_time, date_format)-epoch_date; % [days]
min_start_time = min_start_time*24*3600; % [seconds]

max_end_time = datenum(ds_info.max_end_time, date_format)-epoch_date; % [days]
max_end_time = max_end_time*24*3600; % [seconds]

info.min_start_datestr = ds_info.min_start_time; 
info.min_start_datenum = min_start_time; 
info.max_end_datestr = ds_info.max_end_time; 
info.max_end_datenum = max_end_time; 
info.num_records = ds_info.num_records; 
