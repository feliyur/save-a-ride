%%
figure; 
plot(myDB.pickup_x, '.'); hold on; 
title pickup\_x
plot([1 numel(myDB.pickup_x)], [rect(jj, 1), rect(jj, 1)], 'r'); 
plot([1 numel(myDB.pickup_x)], [rect(jj, 4), rect(jj, 4)], 'r'); 

figure; 
plot(myDB.pickup_y, '.'); hold on; 
title pickup\_y
plot([1 numel(myDB.pickup_y)], [rect(jj, 2), rect(jj, 2)], 'r'); 
plot([1 numel(myDB.pickup_y)], [rect(jj, 5), rect(jj, 5)], 'r'); 

figure; 
adddatenum = datenum(1970, 1, 1)*24*3600; 
plot(myDB.pickup_time, '.'); hold on; 
title pickup\_t
plot([1 numel(myDB.pickup_time)], [rect(jj, 3)+adddatenum, rect(jj, 3)+adddatenum], 'r'); 
plot([1 numel(myDB.pickup_time)], [rect(jj, 6)+adddatenum, rect(jj, 6)+adddatenum], 'r'); 