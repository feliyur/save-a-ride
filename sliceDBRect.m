function sliceDB = sliceDBRect(rect)
% rect - actually defines a cube, row vector 
% of 6 parameters: (longitude_start, latitude_start, time_start, 
%                     longitude_end,    latitude_end,   time_end )

global database_files_names data_dir split_interval_seconds

sliceDB = [];

for df = database_files_names
    mn = load(df{1}, 'info'); 
    info = mn.info; 
        
    
    if all(info.max_end_datenum<rect(:, 3)) || all(info.min_start_datenum>rect(:, 6))
        continue; end
            
    splits_dir = fullfile(data_dir, 'splits', info.original_datafile_name); 
%     splits_files = dir(fullfile(splits_dir, '*.mat'))'; ; 

    adddatenum = datenum(1970, 1, 1)*24*3600; 

    MAX_IND = floor((info.max_end_datenum-info.min_start_datenum)/split_interval_seconds); 
    min_split_idx = max(floor((rect(3)-info.min_start_datenum)/split_interval_seconds), 0); 
    max_split_idx = min(floor((rect(6)-info.min_start_datenum)/split_interval_seconds), MAX_IND); 
    for split_idx = min_split_idx:max_split_idx
        split_file = fullfile(splits_dir, [info.original_datafile_name '-split_' num2str(split_idx) '.mat']); 
        if ~exist(split_file, 'file')
            continue;   end
        load(split_file); 
        myDB = filter_dataset(myDB); 
%         [myDB.pickup_x, myDB.pickup_y] = ll2utm(myDB.pickup_latitude, myDB.pickup_longitude);
%         [myDB.dropoff_x, myDB.dropoff_y] = ll2utm(myDB.dropoff_latitude, myDB.dropoff_longitude);
        fnames = fieldnames(myDB)'; 
        if isempty(sliceDB)
            for ff = fnames
                eval(['sliceDB.' ff{1} ' = []; ']);
            end
            sliceDB = repmat(sliceDB, size(rect, 1), 1); 
        end
        
        for jj=1:size(rect, 1)
            if info.max_end_datenum<rect(jj, 3) || info.min_start_datenum>rect(jj, 6)
                continue; end
            
            
    
            selected_entries = ...
                myDB.pickup_x >= rect(jj, 1) & ...
                myDB.pickup_y  >= rect(jj, 2) & ...
                myDB.pickup_time  >= rect(jj, 3) +adddatenum & ...
                myDB.pickup_x < rect(jj, 4) & ...
                myDB.pickup_y  < rect(jj, 5) & ...
                myDB.pickup_time  < rect(jj, 6)+adddatenum;  %#ok<NASGU>

            for ff = fnames
                f = ff{1}; 
                f = f(1:3); 
                if strcmp(f, 'min') || strcmp(f, 'max') || strcmp(f, 'num')
                    continue; end
                eval(['sliceDB(jj).' ff{1} ' = [sliceDB(jj).' ff{1} '; myDB.' ff{1} '(selected_entries)]; ']);
            end
        end
    end
end
 
% [sliceDB.pickup_x, sliceDB.pickup_y] = ll2utm(sliceDB.pickup_latitude, sliceDB.pickup_longitude);
% [sliceDB.dropoff_x, sliceDB.dropoff_y] = ll2utm(sliceDB.dropoff_latitude, sliceDB.dropoff_longitude);
if ~isempty(sliceDB)
    sliceDB.num_trips = numel(sliceDB.pickup_longitude);  end
