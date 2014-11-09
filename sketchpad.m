%% Var definitions
global database_files data_dir date_format

data_dir = 'D:\Work\Data\save-a-ride'; 
database_files = {fullfile(data_dir, 'trip_data_1.csv'),     ...
                  fullfile(data_dir, 'trip_data_2.csv'),     ...
                  fullfile(data_dir, 'trip_data_8.csv'),     ...
                  fullfile(data_dir, 'trip_data_9.csv'),     ...
                  fullfile(data_dir, 'trip_data_10.csv'),     ...
                  fullfile(data_dir, 'trip_data_11.csv'),     ...
                  fullfile(data_dir, 'trip_data_12.csv')  };

split_interval_seconds = 3600; 

date_format = 'yyyy-mmm-dd HH:MM:SS'; 

database_files_names = {}; 
for ii=1:numel(database_files)
    [PATHSTR,NAME,EXT] = fileparts(database_files{ii}); 
    database_files_names = [database_files_names, NAME]; 
end


%%            
              

XY_TOLERANCE_VEC = 150:50:4000; 
T_TOLERANCE_VEC = [120, 300]; 
MAX_PASSANGER_COUNT = 4; 

% start_time = '2013-Jan-01 00:00:00'; 
% end_time   = '2013-Jan-17 00:00:00'; 

% for ii=1:12
%     start_time = datestr(datenum(2013, ii, 1), date_format); 
%     end_time   = datestr(datenum(2013, ii+1, 1), date_format); 
%     stats_vec = compute_stats(start_time, end_time, XY_TOLERANCE_VEC, T_TOLERANCE_VEC); 
% 
%     fname = ['stats' sprintf('%.2d', ii) '-' start_time '-' end_time '.mat']; 
%     fname(fname==':') = []; 
%     save(fname, 'stats_vec', 'start_time', 'end_time', 'XY_TOLERANCE_VEC', 'T_TOLERANCE_VEC'); 
% end
generate_stats('D:\Work\Data\save-a-ride\stats\4_passanger_max', XY_TOLERANCE_VEC, T_TOLERANCE_VEC, MAX_PASSANGER_COUNT); 

%%
stats_file = fullfile(data_dir, 'stats\4_passanger_max\stats09-2013-Sep-01 000000-2013-Oct-01 000000.mat'); 
load(stats_file); 
% datestr([stats_vec(14:24:end).min_pickup_t]'/(24*3600))


T_TOLERANCE_IND = 2; 

times_flag = select_times(stats_vec, '06:00', '24:00'); 
weekday_flag = ~select_weekdays(stats_vec, {'Sun', 'Sat'}); 

% vec = stats_vec(flag_vec); 
vec = stats_vec(times_flag & weekday_flag); 
ratios = [vec.ratio_trips_saved]; 
ratios = ratios(:, T_TOLERANCE_IND:2:end); 

plot(XY_TOLERANCE_VEC, mean(ratios, 2)); 
%     times = [sprintf('%.2d', mod(ii-1, 24)) ':00 - ' sprintf('%.2d', mod(ii, 24)) ':00'];
% times = [datestr(datenum_start, 'yyyy-mmm-dd HH:MM') ' - ' datestr(datenum_end, 'yyyy-mmm-dd HH:MM')];
%     day = datestr(datenum_start, 'yyyy-mmm-dd');
xlabel('distance tolerance [m]'); ylabel('ratio of rides saved to total # of rides'); 
title(['varying distance tolerance, time tolerance=' num2str(T_TOLERANCE_VEC(T_TOLERANCE_IND)) 's, total rides=' num2str(sum([vec.total_num_trips]))]);



06:00-00:00 normal
01:00-06:00 low
%%
% sample_file = 'D:\Work\Data\save-a-ride\splits\trip_data_1\trip_data_1-split_46.mat';
% stats = process_datafile(sample_file, XY_TOLERANCE_VEC, T_TOLERANCE_VEC); 


% %     figure; 
% %     
% %     subplot(1, 2, 1); 
% %     plot(TOLERANCE_VEC, (myDB.num_trips-new_count)/myDB.num_trips); 
% %     xlabel('distance tolerance [m]'); ylabel('ratio of rides saved to total # of rides'); 
% %     title(['varying distance tolerance, time tolerance=' num2str(T_TOLERANCE) 's, total rides=' num2str(myDB.num_trips)]);
% %      
% %     subplot(1, 2, 2); 
% %     plot(TOLERANCE_VEC, myDB.num_trips-new_count); 
% %     xlabel('distance tolerance [m]'); ylabel('# of rides saved'); 
% %     title(['varying distance tolerance, time tolerance=' num2str(T_TOLERANCE) 's, total rides=' num2str(myDB.num_trips)]);
