function myDB = delete_idx_from_db(myDB, ind)

% fprintf('Cleaning %i bad records\n',sum(ind));
% myDB.delta_dist(ind) = [];
myDB.dropoff_latitude(ind) = [];
myDB.dropoff_longitude(ind) = [];
myDB.passenger_count(ind) = [];
myDB.pickup_latitude(ind) = [];
myDB.pickup_longitude(ind) = [];
myDB.trip_distance(ind) = [];
myDB.trip_time_in_secs(ind) = [];
% myDB.pickup_x(ind) = []; 
% myDB.pickup_y(ind) = []; 
% myDB.dropoff_x(ind) = []; 
% myDB.dropoff_y(ind) = []; 
myDB.pickup_time(ind) = []; 
myDB.dropoff_time(ind) = []; 
