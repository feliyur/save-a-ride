function stats_vec = compute_stats(start_time, end_time, XY_TOLERANCE_VEC, T_TOLERANCE_VEC, MAX_PASSANGER_COUNT)
% Parameters example: 
%
% start_time = '2013-Jan-01 00:00:00'; 
% end_time   = '2013-Jan-17 00:00:00'; 
% 
% XY_TOLERANCE_VEC = 150:50:4000; 
% T_TOLERANCE_VEC = [120, 300]; 

    global database_files data_dir date_format
    
    epoch_date = datenum(1970, 1, 1); 

    start_time_datenum = (datenum(start_time, date_format)-epoch_date)*24*3600;
    end_time_datenum = (datenum(end_time, date_format)-epoch_date)*24*3600; 

    start_time_datenum_global = datenum(start_time, date_format)*24*3600; % NOT relative to the epoch
    end_time_datenum_global = datenum(end_time, date_format)*24*3600; % NOT relative to the epoch

    assert(length(start_time) == length(end_time)); 

    total_records_num = estimate_workload(database_files, start_time, end_time); 
    processed_records_num = 0; 
    
    stats_vec = []; 
    h = waitbar(processed_records_num,'Please wait...');
    for ii=1:numel(database_files)
        [PATHSTR,NAME,EXT] = fileparts(database_files{ii}); 
        load([NAME, '.mat']);

        %% See if this dataset is relevant
        if info.min_start_datenum<=start_time_datenum && info.max_end_datenum>=end_time_datenum; 
            %% Get dataset splits
            splits_dir = fullfile(data_dir, 'splits', NAME); 
            ltsplits = dir(fullfile(splits_dir, [NAME '-split_*.mat'])); 
            split_ids = sscanf([ltsplits.name], [NAME '-split_%d.mat']); 
            [sorted, idx] = sort(split_ids); 
            ltsplits = ltsplits(idx); 
            for jj=1:numel(ltsplits)
    %         ltsplits = ltsplits()
                load(fullfile(splits_dir, ltsplits(jj).name)); 

                myDB = delete_idx_from_db(myDB, find(myDB.pickup_time<start_time_datenum_global)); 
                myDB = delete_idx_from_db(myDB, find(myDB.dropoff_time>end_time_datenum_global));             

    %           sample_file = fullfile(data_dir, 'splits', NAME, ); 
                [myDB, stats] = process_dataset(myDB, XY_TOLERANCE_VEC, T_TOLERANCE_VEC, MAX_PASSANGER_COUNT); 
                processed_records_num = processed_records_num + size(myDB, 1); 
                
                stats_vec = [stats_vec stats]; 
                waitbar(processed_records_num/total_records_num, h, ['Please wait... ' num2str(round(100*processed_records_num/total_records_num)) '%']); 
            end
        end
    end
    close(h); 
end

function total_records_num = estimate_workload(database_files, start_time, end_time)

    global data_dir
    
    date_format = 'yyyy-mmm-dd HH:MM:SS'; 
    epoch_date = datenum(1970, 1, 1); 

    start_time_datenum = (datenum(start_time, date_format)-epoch_date)*24*3600;
    end_time_datenum = (datenum(end_time, date_format)-epoch_date)*24*3600; 

    start_time_datenum_global = datenum(start_time, date_format)*24*3600; % NOT relative to the epoch
    end_time_datenum_global = datenum(end_time, date_format)*24*3600; % NOT relative to the epoch
    
    total_records_num = 0; 
    for ii=1:numel(database_files)
        [PATHSTR,NAME,EXT] = fileparts(database_files{ii}); 
        load([NAME, '.mat']);

        %% See if this dataset is relevant
        if info.min_start_datenum<=start_time_datenum && info.max_end_datenum>=end_time_datenum; 
            %% Get dataset splits
            splits_dir = fullfile(data_dir, 'splits', NAME); 
            ltsplits = dir(fullfile(splits_dir, [NAME '-split_*.mat'])); 
            for jj=1:numel(ltsplits)
    %         ltsplits = ltsplits()
                load(fullfile(splits_dir, ltsplits(jj).name)); 

                myDB = delete_idx_from_db(myDB, find(myDB.pickup_time<start_time_datenum_global)); 
                myDB = delete_idx_from_db(myDB, find(myDB.dropoff_time>end_time_datenum_global));             

                total_records_num = total_records_num + size(myDB, 1); 
            end
        end
    end
end