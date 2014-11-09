function flag_vec = select_times(stats_vec, time_start, time_end)
% inputs example: 
% time_start = '11:00';
% time_end   = '13:00'; 

res = textscan(time_start, '%d:%d'); 
hr_start = res{1}; 
m_start = res{2}; 

res = textscan(time_end, '%d:%d'); 
hr_end = res{1}; 
m_end = res{2}; 

dates = datestr([stats_vec.min_pickup_t]'/(24*3600)); 
% dates = dates(:, end-8:end); 
res = textscan(dates', '%*s%d:%d:%*d'); 
hr_cur = res{1};
m_cur = res{2}; 

min_req = hr_cur>hr_start | (hr_cur==hr_start & m_cur>=m_start); 
max_req = hr_cur<hr_end   | (hr_cur==hr_end   & m_cur<=m_end); 
flag_vec = min_req & max_req; 
