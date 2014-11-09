function [myDB stats] = process_dataset(myDB, XY_TOLERANCE_VEC, T_TOLERANCE_VEC, MAX_PASSANGER_COUNT)
    %% cleaning data (parameters set inside the function)
%     disp('filtering dataset '); 
    myDB = filter_dataset(myDB); 

    %% Compute incidence statistics    
%     disp('computing incidence statistics '); 
    % Tolerance for grouping
    % Grouping is done in a grid, cell size is determined here 
%     X_TOLERANCE = 200; % meters
%     Y_TOLERANCE = 200; % meters
%     T_TOLERANCE= 3000; % 3 minutes 
    
%     new_count = []; 
%     TOLERANCE_VEC = 150:50:8000; 
    stats.xy_tolerance_vec = XY_TOLERANCE_VEC; 
    stats.t_tolerance_vec = T_TOLERANCE_VEC; 
    stats.total_num_trips = myDB.num_trips; 
    stats.num_trips_saved = zeros(numel(XY_TOLERANCE_VEC), numel(T_TOLERANCE_VEC)); 
    stats.max_num_passangers = zeros(numel(XY_TOLERANCE_VEC), numel(T_TOLERANCE_VEC)); 
    
    for ii=1:numel(XY_TOLERANCE_VEC)
       XY_TOLERANCE = XY_TOLERANCE_VEC(ii); 
%         TOLERANCE = 100
        X_TOLERANCE = XY_TOLERANCE; 
        Y_TOLERANCE = XY_TOLERANCE; 
        
        for jj = 1:numel(T_TOLERANCE_VEC)         
            T_TOLERANCE = T_TOLERANCE_VEC(jj); 
            
            [myDB, incM] = incidence_matrix(myDB, X_TOLERANCE, Y_TOLERANCE, T_TOLERANCE); 
            
            copassangers = sum(incM.M, length(size(incM.M))); % sum along last dimension
            
%             active_cells = any(incM.M,); 
            copassangers = sparse(copassangers(:)); 
            corides = ceil(copassangers/MAX_PASSANGER_COUNT); 
            stats.num_trips_saved(ii, jj) = myDB.num_trips-sum(corides(:)); 
            stats.max_num_passangers(ii, jj) = max(copassangers); 
            
%         new_count(end+1) = (myDB.num_trips-num_final)/myDB.num_trips;   % ratio of final out of initial 
        end
    end
    
    stats.ratio_trips_saved = stats.num_trips_saved/stats.total_num_trips; 
    stats.min_pickup_t = myDB.min_pickup_t; 
    stats.max_dropoff_t = myDB.max_dropoff_t; 
    
    
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


%     %% Save statistics
%     mkdir('data'); 
%     save(['data\myDB' num2str(ii) '.mat'],'myDB', 'ratio_final', '-v7.3'); 
end

function myDB = filter_dataset(myDB)
    % Filtering
    % 1. geographical: anything out of bounds is filtered out
    MIN_LONGITUDE = -74.02;
    MAX_LONGITUDE = -73.94; 
    MIN_LATITUDE = 40.6;
    MAX_LATITUDE = 40.8; 

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