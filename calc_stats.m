function stats_mat = calc_stats(x_lim, y_lim, t_lim)

% loop over all the cities
% compute statistics vector
% compute shifted autocorrelation

    global database_files data_dir date_format database_files_names split_interval_seconds roads_shapefile global_info
%     global MIN_X MIN_Y MAX_X MAX_Y
    global roadsShp
    
%     x_start = MIN_X;   
%     x_end = MAX_X; 
%     y_start = MIN_Y;   
%     y_end = MAX_Y; 
%     
%     x_tolerance = 500; 
%     y_tolerance = 500; 
%     t_tolerance = 300; 
%     
%     x_step = 2*x_tolerance; 
%     y_step = 2*y_tolerance; 
%     start_time=global_info.min_start_datenum+6*3600; % 6 am
%     end_time = start_time+24*3600; 
%     t_interval = 22100; % half an hour 
%     t_step = max(3600, t_interval); % one hour
%     global_info = global_database_info(data_dir, database_files_names); 

    x_lim = num2cell(x_lim); y_lim = num2cell(y_lim); t_lim=num2cell(t_lim); 
    [x_start, x_end, x_step, x_tolerance] = deal(x_lim{:}); 
    [y_start, y_end, y_step, y_tolerance] = deal(y_lim{:}); 
    [start_time, end_time, t_step, t_tolerance, t_offset] = deal(t_lim{:}); 


%     global_info = global_database_info(data_dir, database_files_names); 

%     s = shaperead(roads_shapefile); 
    
%     mean_deg = []; 
    stats_mat = []; 
    y_cells = max(ceil((y_end-y_start)/y_step), 1); 
    x_cells = max(ceil((x_end-x_start)/x_step), 1); 
    t_cells = ceil((end_time-start_time)/t_offset); 
    total_chunks = t_cells*x_cells*y_cells; 
    chunk_count = 0; 
    for cur_time=start_time:t_offset:end_time-1
        for cur_x=x_start:x_step:x_end-1
            for cur_y=y_start:y_step:y_end-1
                fprintf(['processed %d chunks out of %d' char(10)], int32(chunk_count), int32(total_chunks)); 
                sliceDB = sliceDBRect([cur_x, cur_y, cur_time, cur_x+x_step, cur_y+y_step, cur_time+t_step]); 
%                 sliceRoads = sliceRoadsRect([cur_x, cur_y, cur_x+x_step, cur_y+y_step]); 
%                sliceDB = filter_dataset(sliceDB); 
                [sliceDB, stats] = process_dataset(sliceDB, x_tolerance, t_tolerance, Inf);                 
                
                adj = compute_adjacency(sliceDB, x_tolerance, y_tolerance); 
                stats.features = compute_features(adj); 
    
                stats_mat = [stats_mat, stats]; 
                
                chunk_count = chunk_count + 1; 
            end
        end
    end

    stats_mat = reshape(stats_mat, [y_cells, x_cells, t_cells]); 
end

function features = compute_features(adj)
    
    % predeclare fields to make all feature structs compatible
    features.num_cells = size(adj, 1); 
    features.num_connections = 0; 
    features.mean_deg = -1; 
    features.mean_closeness = -1; 
    features.density = -1; 
    features.mean_eig = -1; 
    if isempty(adj)
        return;    end 
                
    features.mean_deg = full(mean(sum(adj)));
    features.num_connections = full((sum(adj(:))-sum(diag(adj)))/2); 
    dist = graphallshortestpaths(adj, 'Directed', false);
    features.mean_closeness = mean(sum(2.^(-dist)));
    features.density = 2*sum(adj(:))/(features.num_cells*(features.num_cells-1)); 
    
    adj = full(double(adj)); 
    [V,D]=eig(adj);
    [~,ind]=max(diag(D));
    features.mean_eig=mean(V(:,ind)); 
end
