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

coll = 2
do_click = 0;
if coll == 1
    registration_name = 'rigid_registration';
    %registration_name = 'similarity_registration';

elseif coll == 2
    registration_name = 'similarity_registration';
end
    
if do_scan
    scan_data;
elseif do_load
    str = sprintf('data%d', coll);
    load(str);
end

%% Show the images
do_show = 0;
if do_show
for i = 1:length(X1)
    figure(1)
    imagesc(X1{i})
    colormap('gray')
    figure(2) 
    imagesc(X2{i})
    colormap('gray')
    pause;
end
end
%record_data = zeros(total_nbr_images, 2)
%for i_all = 1:total_nbr_images

%% Perform sift
%i = i_all;
i = 6;
image_i = i;
savestr = sprintf('coll%dimage%d',coll, i);
i2 = X1{i};
i1 = X2{i};


[k1, d1] = vl_sift(i1);
[k2, d2] = vl_sift(i2);

if coll == 1
    thresh = 1/0.77;
elseif coll == 2
    thresh = 1/0.77;
end

[m, s] = vl_ubcmatch(d1,d2,thresh);

k1_m = k1(1:2,m(1,:));
k2_m = k2(1:2,m(2,:));

figure(1)
imHandle1 = imagesc(i1);
colormap('gray')
vl_plotsiftdescriptor(d1(:,m(1,:)), k1(:,m(1,:)));

figure(2) 
imHandle2 = imagesc(i2);
colormap('gray')
vl_plotsiftdescriptor(d2(:,m(2,:)), k2(:,m(2,:)));
%% Get manual T:
if do_click
n = 5;
[x,y] = ginput(n)
end

%% Perform Ransac
%RANSAC as described in lecture 8, FMAN20

nbr_matches = length(m);
n = 2; %nbr points/vectors requred to find R and t for rigid registration

if coll == 1
    k = 10000;
    t_dist = 5;
    d = max(nbr_matches*0.01,7);
elseif coll == 2;
    k = 30000;
    t_dist = 5;%10
    d = max(nbr_matches*0.01,3);
end
nbr_close_d = d;
nbr_close_best = 0;
R_best = [];
t_best = [];
s_best = [];
best_indices = [];
good_indices = [];
good_indices2 = [];
best_max_dist = inf;

test_ind = randi(nbr_matches,k,2);

for test_nbr = 1:k
    m_tmp = m(:,test_ind(test_nbr,:));
    X1_sift = k1(1:2,m_tmp(1,:));
    X2_sift = k2(1:2,m_tmp(2,:));
    %[R_rig, t_rig]=rigid_registration(X1_sift,X2_sift);
    [R_reg, t_reg, s_reg]=feval(registration_name,X1_sift,X2_sift);
%     Y = rigid_transformation(R_rig, t_rig, X1)
%     test = [Y - X2, Y, X2, X1]
    [nbr_close, good_indices] = test_performance(R_reg, t_reg, s_reg, k1_m, k2_m, t_dist);
    if nbr_close > d
        k1_fit = k1_m(:,good_indices);
        k2_fit = k2_m(:,good_indices);
        [R_reg, t_reg, s_reg] = feval(registration_name,k1_fit, k2_fit);
        [nbr_close, good_indices2, max_dist] = test_performance(R_reg, t_reg, s_reg, k1_m, k2_m, t_dist);
        
        if (nbr_close >= nbr_close_best) && (max_dist<best_max_dist) && (abs(s_reg) > 1e-2)
            R_best = R_reg;
            t_best = t_reg;
            s_best = s_reg;
            best_max_dist = max_dist;
            nbr_close_best = nbr_close;
            best_indices = good_indices2;
            disp('newBest');
        end
    else
        nbr_close;
    end
end
%Final fit
%best_indices = good_indices2;
k1_fit = k1_m(:,best_indices);
k2_fit = k2_m(:,best_indices);
[R_best, t_best, s_best] = feval(registration_name, k1_fit, k2_fit);
%R_best = R_reg; t_best = t_reg; s_best = s_reg;
[~, best_indices] = test_performance(R_best, t_best,s_best, k1_m, k2_m, t_dist);

[theta, d] = get_data(R_best,t_best);
str = sprintf('Angle: %3.1f degrees, norm of t: %2.1f and s: %1.2f', theta, d, s_best);
disp(str)
record_data(i,:) = [theta, d, s_best]
%% Pullback time
% best_mean_X1 = mean(k1_m(:,best_indices),2);
% best_mean_X2_r = mean(rigid_transformation(R_best,t_best,k2_m(:,best_indices)),2);
%i2_new = pullback(R_best, t_best, x_1, y_1, i2);

R = R_best;
t = t_best;
s = s_best;
[y_1, x_1] = size(i1);
T = [s*R', [0;0]; t' 1];
Tinv = [R/s, [0;0]; -t'*R/s 1];
if coll == 1 %Detta ska kunna tas bort, hade bara kvar för säkerhets skull
    T = [R', [0;0]; t' 1];
    Tinv = [R, [0;0]; -t'*R 1];
end
tform = affine2d(T);
tforminv = affine2d(Tinv);
%i1_r = imwarp(i1, tform);
imref1 = imref2d(size(i1));
[i2_r, rout_2] = imwarp(i2, tforminv,'OutputView', imref1);
%[i2_r, rout_2] = imwarp(i2, tform,'OutputView', imref1);



imref2 = imref2d(size(i2));
[i1_r, rout_1] = imwarp(i1, tform, 'OutputView', imref2);


k2_fit_r = similarity_transformation(R',-R'*t/s,1/s, k2_fit)
k1_fit_r = similarity_transformation(R, t, s, k1_fit);
%pullback of sift koordinates:
% im2Sift = zeros(size(i2));
% for i = 1:length(k2_fit)
%     im2Sift(round(k2_fit(2,i))',round(k2_fit(1,i))') = 1;
% end    
% sum(sum(im2Sift))
% 
% im2Sift_r = imwarp(im2Sift, tforminv, 'OutputView', imref1);
% sum(sum(im2Sift_r))
% %im2Sift_r(im2Sift_r > 0) = 1;
% [im2Sift_y, im2Sift_x] = find(im2Sift_r > 0);


% figure(3)
% imagesc(i1_r)
% colormap('gray');


figure(3)
clf;
imshowpair(i2_r, rout_2, i1, imref1)
hold on;
plot(k2_fit_r(1,:),k2_fit_r(2,:), 'bo')
plot(k1_fit(1,:),k1_fit(2,:), 'kx')

figure(6)
clf;
imshowpair(i1_r, rout_1, i2, imref2)
hold on;
plot(k1_fit_r(1,:),k1_fit_r(2,:), 'bo')
plot(k2_fit(1,:),k2_fit(2,:), 'kx')
title(str)
saveas(gcf,savestr,'epsc')
%end
%% Test the result
%T_manual
clickStr = sprintf('clickData%d.mat',coll);
load(clickStr)
x1_man =[X1_c(image_i,:);Y1_c(image_i,:)];
x2_man =[X2_c(image_i,:);Y2_c(image_i,:)];
[R_man, t_man, s_man] = feval(registration_name, x1_man, x2_man);
T_man = [s_man*R_man', [0;0]; t_man' 1];
tform_man= affine2d(T_man);
x1_r_man = similarity_transformation(R_man,t_man,s_man,x1_man);
x1_r_auto = similarity_transformation(R,t,s,x1_man);

eps_man = x2_man - x1_r_man;
eps_tot_man = 1/(length(eps_man)-1)*sum(sum(eps_man.^2));
eps_auto = x2_man - x1_r_auto;
eps_tot_auto = 1/(length(eps_man)-1)*sum(sum(eps_auto.^2));
eps_tot_diff = eps_tot_auto-eps_tot_man;
if eps_tot_diff <= t_dist
    disp('Okay image registration');
    I_c(image_i) = 1;
else
    I_c(image_i) = 0;
end

eps_c(image_i,:) = [eps_tot_man, eps_tot_auto, eps_tot_diff];
imref2 = imref2d(size(i2));
[i1_r_man, rout_1_man] = imwarp(i1, tform_man, 'OutputView', imref2);
save(clickStr,'X1_c','Y1_c','X2_c','Y2_c','eps_c','I_c');

figure(7)
imshowpair(i1_r_man, rout_1_man, i2, imref2)
hold on;
plot(x1_r_man(1,:),x1_r_man(2,:), 'rx')
plot(x2_man(1,:),x2_man(2,:), 'bo')




%%
% figure(4)
% imagesc(i2_r)
% colormap('gray');
% 
% 
% figure(5)
% imagesc(i1_r)
% colormap('gray');
% 
%% Align %Denna är som matlabs imwarp('outputview') fast mycket långsammare
% [X, Y] = meshgrid(1:x_1, 1:y_1);
% X_r = imwarp(X, tform);
% Y_r = imwarp(Y, tform);
% i2_new = zeros(size(i1));
% for i = 1:size(X_r,1)
%     for j = 1:size(X_r,2)
%         x = X_r(i,j);
%         y = Y_r(i,j);
%         i2_new(i,j) = interpolatePixel(i2, x, y);
%     end
% end
% 
% figure(5)
% imagesc(i2_new)
% colormap('gray');

%% Frågor
%y = \phi(x), x \in R^d, y \in R^d? eller y \in R^d2
%Blir min rotationsmatris rätt?
%Finns det nåt smartare sätt att göra interpoleringen
%Testar att rotera alla landmark-punkter och jämföra deras mean i de båda
%bilderna, då tänker man väl inte på paddingen? Så det borde blivit samma?
%Vidare, går det att göra samma operation på paddingen?
