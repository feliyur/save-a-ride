% function adj = compute_adjacency(sliceDB, incM, dbg)
function adj = compute_adjacency(sliceDB, x_tolerance, y_tolerance, dbg)
if nargin<5
    dbg = 0; end

if isempty(sliceDB) || ~sliceDB.num_trips
    adj = [];
    return; 
end

[sliceDB, incM] = incidence_matrix(sliceDB, x_tolerance, y_tolerance, Inf); 

adj =  logical(sparse([], [], [], incM.num_pickup_x*incM.num_pickup_y, incM.num_dropoff_x*incM.num_dropoff_y, sliceDB.num_trips)); 

copassangers = sum(incM.M, length(size(incM.M))); 
rides_ind = find(copassangers);
[px, dx, py, dy] = ind2sub(size(copassangers), rides_ind); % pickup_x, dropoff_x, pickup_y, dropoff_y

src_ind = sub2ind([incM.num_pickup_y, incM.num_pickup_x], py, px); 
dst_ind = sub2ind([incM.num_dropoff_y, incM.num_dropoff_x], dy, dx); 

adj(sub2ind(size(adj), src_ind, dst_ind)) = true; 
adj = adj | adj'; 

% cnt = 0; 
% for ii=1:sliceDB.num_trips
%     if dbg>0 && ~mod(ii, 1000)
%         ii
%         cnt
%     end
% %     A = repmat(sliceDB.pickup_latitude, 1, sliceDB.num_trips); 
% %     B = A < A'; clear A; 
%     sel = abs(sliceDB.pickup_x-sliceDB.pickup_x(ii))<x_tolerance & ...
%         abs(sliceDB.pickup_y-sliceDB.pickup_y(ii))<y_tolerance & ...
%         abs(sliceDB.pickup_time-sliceDB.pickup_time(ii))<t_tolerance & ...
%         abs(sliceDB.dropoff_x-sliceDB.dropoff_x(ii))<x_tolerance & ...
%         abs(sliceDB.dropoff_y-sliceDB.dropoff_y(ii))<y_tolerance; 
%         cnt = cnt + sum(double(sel)); 
%     adj(sel, ii) = true; 
% end