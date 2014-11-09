function flag_vec = select_weekdays(stats_vec, weekdays)
% inputs example: 
% weekdays = {'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'};

dates = datestr([stats_vec.min_pickup_t]'/(24*3600)); 
% dates = dates(:, end-8:end); 
res = weekday(dates); 
weekdays_num = weekday2num(weekdays); 
flag_vec = ismember(res, weekdays_num); 

