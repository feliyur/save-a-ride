function res = weekday2num(weekdays)

all_weekdays = {'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'}; 

res = zeros(size(weekdays)); 
[b res] = ismember(weekdays, all_weekdays); 
