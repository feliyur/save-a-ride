function generate_stats(out_dir, XY_TOLERANCE_VEC, T_TOLERANCE_VEC, MAX_PASSANGER_COUNT)
% Usage example: 
%
% XY_TOLERANCE_VEC = 150:50:4000; 
% T_TOLERANCE_VEC = [120, 300]; 
% MAX_PASSANGER_COUNT = 4; 
% 
% generate_stats('D:\Work\Data\save-a-ride\stats\4_passanger_max', XY_TOLERANCE_VEC, T_TOLERANCE_VEC, MAX_PASSANGER_COUNT); 
%


if ~exist(out_dir, 'dir')
    mkdir(out_dir); 
end

global date_format

for ii=1:12
    start_time = datestr(datenum(2013, ii, 1), date_format); 
    end_time   = datestr(datenum(2013, ii+1, 1), date_format); 
    stats_vec = compute_stats(start_time, end_time, XY_TOLERANCE_VEC, T_TOLERANCE_VEC, MAX_PASSANGER_COUNT); 

    fname = ['stats' sprintf('%.2d', ii) '-' start_time '-' end_time '.mat']; 
    fname(fname==':') = []; 
    save(fullfile(out_dir, fname), 'stats_vec', 'start_time', 'end_time', 'XY_TOLERANCE_VEC', 'T_TOLERANCE_VEC'); 
end