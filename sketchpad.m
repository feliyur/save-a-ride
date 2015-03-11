function sketchpad()
%% Var definitions
global database_files data_dir date_format database_files_names split_interval_seconds global_info
global MIN_LONGITUDE MIN_LATITUDE MAX_LONGITUDE MAX_LATITUDE MIN_X MIN_Y MAX_X MAX_Y
global roadsShp

MIN_LONGITUDE = -74.02;
MAX_LONGITUDE = -73.94; 
MIN_LATITUDE = 40.6;
MAX_LATITUDE = 40.8; 

[MIN_X, MIN_Y] = ll2utm(MIN_LATITUDE, MIN_LONGITUDE); 
[MAX_X, MAX_Y] = ll2utm(MAX_LATITUDE, MAX_LONGITUDE); 
    
data_dir = 'D:\Work\Data\save-a-ride'; 
database_files = {fullfile(data_dir, 'trip_data_1.csv'),     ...
                  fullfile(data_dir, 'trip_data_2.csv'),     ...
                  fullfile(data_dir, 'trip_data_8.csv'),     ...
                  fullfile(data_dir, 'trip_data_9.csv'),     ...
                  fullfile(data_dir, 'trip_data_10.csv'),     ...
                  fullfile(data_dir, 'trip_data_11.csv'),     ...
                  fullfile(data_dir, 'trip_data_12.csv')  };

split_interval_seconds = 3600; 

% roads_shapefile = 'D:\Fichiers\this_year\this_month\new-york-latest.shp\roads.shp'; 

date_format = 'yyyy-mmm-dd HH:MM:SS'; 

database_files_names = {}; 
for ii=1:numel(database_files)
    [PATHSTR,NAME,EXT] = fileparts(database_files{ii}); 
    database_files_names = [database_files_names, NAME]; 
end

global_info = global_database_info(data_dir, database_files_names); 

format long g

%%

%     x_start = MIN_X;   
%     x_end = MAX_X; 
%     y_start = MIN_Y;   
%     y_end = MAX_Y; 
%     
%     x_tolerance = 500; 
%     y_tolerance = 500; 
%     t_tolerance = 300; 
%     
%     x_step = 2*x_tolerance; 
%     y_step = 2*y_tolerance; 
%     start_time=global_info.min_start_datenum+6*3600; % 6 am
%     end_time = start_time+24*3600; 
%     t_interval = 22100; % half an hour 
%     t_step = max(3600, t_interval); % one hour
%     global_info = global_database_info(data_dir, database_files_names); 

    start_time=global_info.min_start_datenum; % 6 am
    
% stats = calc_stats([MIN_X, MAX_X, 4000, 500], [MIN_Y, MAX_Y, 4000, 500], ...
%     [start_time, start_time+31*24*3600, 3600, 300]); 

% stats = stats([stats.total_num_trips]>1000); 
stats2 = calc_stats([MIN_X, MAX_X, 25000, 500], [MIN_Y, MAX_Y, 25000, 500], ...
    [start_time, start_time+31*24*3600, 3600, 300, 60*5]); 

%%
global_info = global_database_info(data_dir, database_files_names); 
tic; sliceDB = sliceDBRect([-inf, -inf, global_info.min_start_datenum+3600, inf, inf, global_info.min_start_datenum+7200]); toc

[sliceDB, stats] = process_dataset(sliceDB, 500, 600, Inf); 
sliceDB



%%
x_tolerance = 300; 
y_tolerance = 300; 
t_tolerance = 180; 

adj = compute_adjacency(sliceDB, x_tolerance, y_tolerance, t_tolerance); 
%TODO: compute only lower triangle then inc = inc | inc'; 



%%            
              
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



% 06:00-00:00 normal
% 01:00-06:00 low
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



end 


%%


