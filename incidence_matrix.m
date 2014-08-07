function [myDB, incM] = incidence_matrix(myDB, x_tolerance, y_tolerance, t_tolerance)

incM.x_tolerance = x_tolerance; % meters
incM.y_tolerance = y_tolerance; % meters
incM.t_tolerance = t_tolerance; % 3 minutes 

incM.base_pickup_x = floor(myDB.min_pickup_x/incM.x_tolerance)*incM.x_tolerance;
incM.base_pickup_y = floor(myDB.min_pickup_y/incM.y_tolerance)*incM.y_tolerance; 
incM.base_pickup_time = floor(myDB.min_pickup_t/incM.t_tolerance)*incM.t_tolerance; 

incM.base_dropoff_x = floor(myDB.min_dropoff_x/incM.x_tolerance)*incM.x_tolerance;  
incM.base_dropoff_y = floor(myDB.min_dropoff_y/incM.y_tolerance)*incM.y_tolerance; 
incM.base_dropoff_time = floor(myDB.min_dropoff_t/incM.t_tolerance)*incM.t_tolerance; 

incM.num_pickup_x = ceil((myDB.max_pickup_x-incM.base_pickup_x)/incM.x_tolerance); 
incM.num_pickup_y = ceil((myDB.max_pickup_y-incM.base_pickup_y)/incM.y_tolerance); 
incM.num_pickup_time = ceil((myDB.max_pickup_t-incM.base_pickup_time)/incM.t_tolerance);

incM.num_dropoff_x = ceil((myDB.max_dropoff_x-incM.base_dropoff_x)/incM.x_tolerance); 
incM.num_dropoff_y = ceil((myDB.max_dropoff_y-incM.base_dropoff_y)/incM.y_tolerance); 
incM.num_dropoff_time = ceil((myDB.max_dropoff_t-incM.base_dropoff_time)/incM.t_tolerance); 

% incM.num_trips = myDB.num_trips; 

incM.M = ndSparse.build([1+round((myDB.pickup_x-incM.base_pickup_x)/incM.x_tolerance), ...1
                   1+round((myDB.dropoff_x-incM.base_dropoff_x)/incM.x_tolerance), ...
                   1+round((myDB.pickup_y-incM.base_pickup_y)/incM.y_tolerance), ...
                   1+round((myDB.dropoff_y-incM.base_dropoff_y)/incM.y_tolerance), ...
                   1+round((myDB.pickup_time-incM.base_pickup_time)/incM.t_tolerance), ...
                   1+round((myDB.dropoff_time-incM.base_dropoff_time)/incM.t_tolerance), ...
                   (1:myDB.num_trips)'], ones(myDB.num_trips, 1));

               