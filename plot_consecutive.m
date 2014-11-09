function plot_consecutive(stats_vec)

f = figure; 
for ii=1:length(stats_vec)
    stats = stats_vec(ii); 
    T_TOLERANCE_IND = 1; 
    plot(stats.xy_tolerance_vec, stats.ratio_trips_saved(:, T_TOLERANCE_IND)); 
%     times = [sprintf('%.2d', mod(ii-1, 24)) ':00 - ' sprintf('%.2d', mod(ii, 24)) ':00'];
    datenum_start = stats.min_pickup_t/(3600*24); 
    datenum_end = stats.max_dropoff_t/(3600*24); 
    times = [datestr(datenum_start, 'yyyy-mmm-dd HH:MM') ' - ' datestr(datenum_end, 'yyyy-mmm-dd HH:MM')];
%     day = datestr(datenum_start, 'yyyy-mmm-dd');
    xlabel('distance tolerance [m]'); ylabel('ratio of rides saved to total # of rides'); 
    title([times char(10) 'varying distance tolerance, time tolerance=' num2str(stats.t_tolerance_vec(T_TOLERANCE_IND)) 's, total rides=' num2str(stats.total_num_trips)]);
    pause
end
close(f); 

