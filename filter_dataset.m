function myDB = filter_dataset(myDB)
    global MIN_LONGITUDE MIN_LATITUDE MAX_LONGITUDE MAX_LATITUDE
    % Filtering
    % 1. geographical: anything out of bounds is filtered out
%     MIN_LONGITUDE = -74.02;
%     MAX_LONGITUDE = -73.94; 
%     MIN_LATITUDE = 40.6;
%     MAX_LATITUDE = 40.8; 

    % 2. trip-wise: trips too short in distance or time are filtered out
    DISTANCE_THRESH = 0.04; % miles
    TIME_THRESH = 60; % seconds

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
end