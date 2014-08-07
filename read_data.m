addpath utils

%% Parameters
% Database and sampling
full_datafile = 'D:\Fichiers\this_year\this_month\4yaniv\data\trip_data_11.csv\trip_data_11.csv'; 
sample_size = 1000; 
number_of_samples = 1; 

% Filtering
% 1. geographical: anything out of bounds is filtered out
MIN_LONGITUDE = -74.02;
MAX_LONGITUDE = -73.94; 
MIN_LATITUDE = 40.6;
MAX_LATITUDE = 40.8; 

% 2. trip-wise: trips too short in distance or time are filtered out
DISTANCE_THRESH = 0.07; % miles
TIME_THRESH = 60; % seconds

% Tolerance for grouping
% Grouping is done in a grid, cell size is determined here 
X_TOLERANCE = 2000; % meters
Y_TOLERANCE = 2000; % meters
T_TOLERANCE = 120; % 3 minutes 
    
    
%%
mkdir('samples'); 

for ii=1:number_of_samples
    %% Create a sample
    eval(['!analyze_data "' full_datafile '" ', num2str(sample_size)]);
%     [PATHSTR,NAME,EXT]=fileparts(full_datafile);
    sample_file = ['first_' num2str(sample_size), '.csv']; 
    movefile(sample_file, 'samples');
    sample_file = fullfile(pwd, 'samples', sample_file);
    
    %% read data
    ds = dataset('File', sample_file, ...
        'Format','%s%s%s%s%s%s%s%f%f%f%f%f%f%f','Delimiter',',','ReturnOnError',0);

    myDB.passenger_count = ds.passenger_count;
    myDB.trip_time_in_secs = ds.trip_time_in_secs;
    myDB.trip_distance = ds.trip_distance;
    myDB.pickup_longitude = ds.pickup_longitude;
    myDB.pickup_latitude = ds.pickup_latitude;
    myDB.dropoff_longitude = ds.dropoff_longitude;
    myDB.dropoff_latitude = ds.dropoff_latitude;
    myDB.pickup_time = 24*3600*datenum(ds.pickup_datetime);   % convert to seconds
    myDB.dropoff_time = 24*3600*datenum(ds.dropoff_datetime); % convert to seconds

    clear ds;
    
    %% cleaning data 
    % 1. Filter out records that fall out of geographical bounding box bounds 
    myDB = delete_idx_from_db(myDB, (myDB.pickup_latitude<MIN_LATITUDE)|(myDB.pickup_latitude>MAX_LATITUDE)); 
    myDB = delete_idx_from_db(myDB, (myDB.pickup_longitude<MIN_LONGITUDE) | (myDB.pickup_longitude>MAX_LONGITUDE));
    myDB = delete_idx_from_db(myDB, (myDB.dropoff_latitude<MIN_LATITUDE) | (myDB.dropoff_latitude>MAX_LATITUDE)); 
    myDB = delete_idx_from_db(myDB, (myDB.dropoff_longitude<MIN_LONGITUDE) | (myDB.dropoff_longitude>MAX_LONGITUDE)); 

    % 2. Filter out trips with unlikely high avg. velocity above bound
    MAX_VELOCITY = 70; % miles per hour
    avg_velocity = double(myDB.trip_distance)./(double(myDB.trip_time_in_secs)/double(3600)); 
    myDB = delete_idx_from_db(myDB, avg_velocity>=MAX_VELOCITY | avg_velocity<=0);

    % 3. Filter out trips with zero distance or zero velocity
    myDB = delete_idx_from_db(myDB, myDB.trip_distance<=0 | myDB.trip_time_in_secs<=0);

    % 4. Filter out trips with low total distance or low time
    myDB = delete_idx_from_db(myDB, myDB.trip_distance<=DISTANCE_THRESH | myDB.trip_time_in_secs<=TIME_THRESH); 

    %% Some more calculations on the valid data
    [myDB.pickup_x, myDB.pickup_y] = ll2utm(myDB.pickup_latitude, myDB.pickup_longitude);
    [myDB.dropoff_x, myDB.dropoff_y] = ll2utm(myDB.dropoff_latitude, myDB.dropoff_longitude);

    myDB.min_pickup_x = min(myDB.pickup_x);
    myDB.min_pickup_y = min(myDB.pickup_y); 

    myDB.min_dropoff_x = min(myDB.dropoff_x);
    myDB.min_dropoff_y = min(myDB.dropoff_y); 

    myDB.min_pickup_t = min(myDB.pickup_time); 
    myDB.min_dropoff_t = min(myDB.dropoff_time); 

    myDB.max_pickup_x = max(myDB.pickup_x);
    myDB.max_pickup_y = max(myDB.pickup_y); 

    myDB.max_dropoff_x = max(myDB.dropoff_x);
    myDB.max_dropoff_y = max(myDB.dropoff_y); 

    myDB.max_pickup_t = max(myDB.pickup_time); 
    myDB.max_dropoff_t = max(myDB.dropoff_time); 

    myDB.num_trips = numel(myDB.pickup_x);    
    
    %% Compute incidence data
    [myDB, incM] = incidence_matrix(myDB, X_TOLERANCE, Y_TOLERANCE, T_TOLERANCE); 
    
    active_cells = any(incM.M,7); 
    num_final = sum(active_cells(:)); 
    ratio_final = num_final/myDB.num_trips  % ratio of final out of initial
    
    %% Save statistics
    mkdir('data'); 
    save(['data\myDB' num2str(ii) '.mat'],'myDB', 'ratio_final', '-v7.3'); 
end


%%
% August 2013
for i=1:6; 
    ind = myDB.passenger_count == i; 
%    fprintf('%i passengers, mean distance is %f (delta dist is %f km) and mean time is %f (%i trips)\n', i, mean(myDB.trip_distance(ind)), 1.6*69*nanmean(myDB.delta_dist(ind)), mean(myDB.trip_time_in_secs(ind)), sum(ind)); 
    fprintf('%i passengers, mean distance is %2.2f km and mean time is %i minutes (%i trips)\n', i, 1.6*69*nanmean(myDB.delta_dist(ind)), round(mean(myDB.trip_time_in_secs(ind))/60), sum(ind)); 
end;

max(myDB.pickup_x)-min(myDB.pickup_x)
max(myDB.pickup_y)-min(myDB.pickup_y)
max(myDB.pickup_time)-min(myDB.pickup_time)
(max(myDB.pickup_time)-min(myDB.pickup_time))/(3600*24) % data time range in days

%% duration
figure; 
hist(round((myDB.trip_distance*3600)./myDB.trip_time_in_secs));

%% Show pickup / dropoff dots
figure
plot(myDB.pickup_longitude, myDB.pickup_latitude, '*')
hold on; plot(myDB.dropoff_longitude, myDB.dropoff_latitude, '*')
axis equal

figure
plot(myDB.pickup_x, myDB.pickup_y, '*')
hold on; plot(myDB.dropoff_x, myDB.dropoff_y, '*')
axis equal
