function [myDB, incM] = incidence_matrix(myDB, x_tolerance, y_tolerance, t_tolerance)

MAX_T_TOLERANCE = 3600*24*365*1000;

incM.x_tolerance = x_tolerance; % meters
incM.y_tolerance = y_tolerance; % meters
incM.t_tolerance = t_tolerance; % 3 minutes 

base_x = min(floor(myDB.min_pickup_x/incM.x_tolerance)*incM.x_tolerance, floor(myDB.min_dropoff_x/incM.x_tolerance)*incM.x_tolerance); 
base_y = min(floor(myDB.min_pickup_y/incM.y_tolerance)*incM.y_tolerance, floor(myDB.min_dropoff_y/incM.y_tolerance)*incM.y_tolerance); 

t_tolerance_or_0 = ~isinf(incM.t_tolerance)*min(incM.t_tolerance, MAX_T_TOLERANCE); 
base_time = min(floor(myDB.min_pickup_t/incM.t_tolerance)*t_tolerance_or_0, floor(myDB.min_dropoff_t/incM.t_tolerance)*t_tolerance_or_0); 

incM.base_pickup_x = base_x; 
incM.base_pickup_y = base_y; 
incM.base_pickup_time = base_time; 

incM.base_dropoff_x = base_x;  
incM.base_dropoff_y = base_y; 
incM.base_dropoff_time = base_time; 

num_x = max(1+round((max(myDB.pickup_x)-incM.base_pickup_x)/incM.x_tolerance), 1+round((max(myDB.dropoff_x)-incM.base_dropoff_x)/incM.x_tolerance)); 
num_y = max(1+round((max(myDB.pickup_y)-incM.base_pickup_y)/incM.y_tolerance), 1+round((max(myDB.dropoff_y)-incM.base_dropoff_y)/incM.y_tolerance)); 
num_time = max(1+round((max(myDB.pickup_time)-incM.base_pickup_time)/incM.t_tolerance)); 



incM.num_pickup_x = num_x; 
incM.num_pickup_y = num_y; 
incM.num_pickup_time = num_time;

incM.num_dropoff_x = num_x; 
incM.num_dropoff_y = num_y; 
incM.num_dropoff_time = num_time; 

% % incM.num_trips = myDB.num_trips; 
if isempty(myDB.passenger_count)
    incM.num_cells = 0; 
    incM.M = 0; 
    return; 
end

% incM.num_cells = incM.num_pickup_x*incM.num_pickup_y*incM.num_pickup_time * ...
%                     incM.num_dropoff_x*incM.num_dropoff_y*incM.num_dropoff_time * ...
%                         myDB.num_trips; 
                    
% if incM.num_cells >= 2^53-1
%     disp break here
% end
% incM.num_cells = incM.num_pickup_x*incM.num_pickup_y*incM.num_pickup_time * myDB.num_trips; 
incM.num_cells = incM.num_pickup_x*incM.num_pickup_y*incM.num_pickup_time * ...
                    incM.num_dropoff_x*incM.num_dropoff_y*myDB.num_trips; 

% incM.M = ndSparse.build([1+round((myDB.pickup_x-incM.base_pickup_x)/incM.x_tolerance), ...1
%                    1+round((myDB.dropoff_x-incM.base_dropoff_x)/incM.x_tolerance), ...
%                    1+round((myDB.pickup_y-incM.base_pickup_y)/incM.y_tolerance), ...
%                    1+round((myDB.dropoff_y-incM.base_dropoff_y)/incM.y_tolerance), ...
%                    1+round((myDB.pickup_time-incM.base_pickup_time)/incM.t_tolerance), ...
%                    1+round((myDB.dropoff_time-incM.base_dropoff_time)/incM.t_tolerance), ...
%                    (1:myDB.num_trips)'], true(myDB.num_trips, 1));

incM.M = ndSparse.build([1+round((myDB.pickup_x-incM.base_pickup_x)/incM.x_tolerance), ...1
                   1+round((myDB.dropoff_x-incM.base_dropoff_x)/incM.x_tolerance), ...
                   1+round((myDB.pickup_y-incM.base_pickup_y)/incM.y_tolerance), ...
                   1+round((myDB.dropoff_y-incM.base_dropoff_y)/incM.y_tolerance), ...
                   1+round((myDB.pickup_time-incM.base_pickup_time)/incM.t_tolerance), ...
                   (1:myDB.num_trips)'], ones(myDB.num_trips, 1));

               