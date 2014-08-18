function myDB = load_dataset(sample_file)
    ds = dataset('File', sample_file, 'Format','%s%s%s%s%s%s%s%f%f%f%f%f%f%f','Delimiter',',','ReturnOnError',0);

    myDB.passenger_count = ds.passenger_count;
    myDB.trip_time_in_secs = ds.trip_time_in_secs;
    myDB.trip_distance = ds.trip_distance;
    myDB.pickup_longitude = ds.pickup_longitude;
    myDB.pickup_latitude = ds.pickup_latitude;
    myDB.dropoff_longitude = ds.dropoff_longitude;
    myDB.dropoff_latitude = ds.dropoff_latitude;
    myDB.pickup_time = 24*3600*datenum(ds.pickup_datetime);   % convert to seconds
    myDB.dropoff_time = 24*3600*datenum(ds.dropoff_datetime); % convert to seconds
end
