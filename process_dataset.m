function [myDB stats] = process_dataset(myDB, XY_TOLERANCE_VEC, T_TOLERANCE_VEC, MAX_PASSANGER_COUNT)
    %% cleaning data (parameters set inside the function)
%     disp('filtering dataset '); 

    %% Compute incidence statistics    
%     disp('computing incidence statistics '); 
    % Tolerance for grouping
    % Grouping is done in a grid, cell size is determined here 
%     X_TOLERANCE = 200; % meters
%     Y_TOLERANCE = 200; % meters
%     T_TOLERANCE= 3000; % 3 minutes 
    
%     new_count = []; 
%     TOLERANCE_VEC = 150:50:8000; 
    stats.xy_tolerance_vec = XY_TOLERANCE_VEC; 
    stats.t_tolerance_vec = T_TOLERANCE_VEC; 
    stats.num_trips_saved = zeros(numel(XY_TOLERANCE_VEC), numel(T_TOLERANCE_VEC)); 
    stats.max_num_passangers = zeros(numel(XY_TOLERANCE_VEC), numel(T_TOLERANCE_VEC)); 

    stats.ratio_trips_saved = []; 
    stats.min_pickup_t = []; 
    stats.max_dropoff_t = []; 

    if isempty(myDB)
        stats.total_num_trips =0; 
        return; 
    end

    myDB = filter_dataset(myDB); 
    stats.total_num_trips = myDB.num_trips; 
    
    for ii=1:numel(XY_TOLERANCE_VEC)
       XY_TOLERANCE = XY_TOLERANCE_VEC(ii); 
%         TOLERANCE = 100
        X_TOLERANCE = XY_TOLERANCE; 
        Y_TOLERANCE = XY_TOLERANCE; 
        
        for jj = 1:numel(T_TOLERANCE_VEC)         
            T_TOLERANCE = T_TOLERANCE_VEC(jj); 
            
            [myDB, incM] = incidence_matrix(myDB, X_TOLERANCE, Y_TOLERANCE, T_TOLERANCE); 
            
            copassangers = sum(incM.M, length(size(incM.M))); % sum along last dimension
            
%             active_cells = any(incM.M,); 
            copassangers = sparse(copassangers(:)); 
            if isinf(MAX_PASSANGER_COUNT)
                corides = double(copassangers>0); 
            else 
                corides = ceil(copassangers/MAX_PASSANGER_COUNT); 
            end
            stats.num_trips_saved(ii, jj) = myDB.num_trips-sum(corides(:)); 
            stats.max_num_passangers(ii, jj) = max(copassangers); 
            
%         new_count(end+1) = (myDB.num_trips-num_final)/myDB.num_trips;   % ratio of final out of initial 
        end
    end
    
    stats.ratio_trips_saved = stats.num_trips_saved/stats.total_num_trips; 
    stats.min_pickup_t = myDB.min_pickup_t; 
    stats.max_dropoff_t = myDB.max_dropoff_t; 
    
    
% %     figure; 
% %     
% %     subplot(1, 2, 1); 
% %     plot(TOLERANCE_VEC, (myDB.num_trips-new_count)/myDB.num_trips); 
% %     xlabel('distance tolerance [m]'); ylabel('ratio of rides saved to total # of rides'); 
% %     title(['varying distance tolerance, time tolerance=' num2str(T_TOLERANCE) 's, total rides=' num2str(myDB.num_trips)]);
% %      
% %     subplot(1, 2, 2); 
% %     plot(TOLERANCE_VEC, myDB.num_trips-new_count); 
% %     xlabel('distance tolerance [m]'); ylabel('# of rides saved'); 
% %     title(['varying distance tolerance, time tolerance=' num2str(T_TOLERANCE) 's, total rides=' num2str(myDB.num_trips)]);


%     %% Save statistics
%     mkdir('data'); 
%     save(['data\myDB' num2str(ii) '.mat'],'myDB', 'ratio_final', '-v7.3'); 
end
