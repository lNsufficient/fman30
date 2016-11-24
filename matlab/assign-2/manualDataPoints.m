do_reset = 1
do_scan = 1;

if ~do_reset
    clear;
    do_scan = 0;
    do_load = 1
else
    clear;
    do_scan = 1;
    do_load = 0;
end

coll = 1
do_click = 0;
if coll == 1
    registration_name = 'rigid_registration';
    registration_name = 'similarity_registration';

elseif coll == 2
    registration_name = 'similarity_registration';
end
    
if do_scan
    scan_data;
elseif do_load
    str = sprintf('data%d', coll);
    load(str);
end


%% Plot
clickStr = sprintf('clickData%d.mat',coll)
nbr_clicks = 5;
load(clickStr);

i = 5;
savestr = sprintf('coll%dimage%d',coll, i);
i2 = X1{i};
i1 = X2{i};
close all;

figure(1)
imHandle1 = imagesc(i1);
colormap('gray')

figure(2) 
imHandle2 = imagesc(i2);
colormap('gray')
%% figure(1)
figure(1)
imHandle1 = imagesc(i1);
colormap('gray')
hold on;

% Get manual T:
set(imHandle1, 'HitTest','off')
set(imHandle2, 'HitTest','off')
[x1,y1] = ginput(nbr_clicks);
X1_c(i,:) = x1';
Y1_c(i,:) = y1';

plot(x1, y1, 'rx')
%% figure(2)

figure(2) 
imHandle2 = imagesc(i2);
colormap('gray')
hold on;
% Get manual T:
[x2,y2] = ginput(nbr_clicks)
X2_c(i,:) = x2;
Y2_c(i,:) = y2;

plot(x2, y2, 'rx')
%% Save the data
save(clickStr,'X1_c','Y1_c','X2_c','Y2_c','eps_c','I_c');
