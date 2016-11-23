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

%% Perform sift
i = 2;
i1 = X1{i};
i2 = X2{i};
figure(1)
imagesc(i1)
colormap('gray')
figure(2) 
imagesc(i2)
colormap('gray')

[k1, d1] = vl_sift(i1);
[k2, d2] = vl_sift(i2);

[m, s] = vl_ubcmatch(d1,d2,1/0.77);

k1_m = k1(1:2,m(1,:));
k2_m = k2(1:2,m(2,:));
%% Perform Ransac
%RANSAC as described in lecture 8, FMAN20

nbr_matches = length(m);
n = 2; %nbr points/vectors requred to find R and t for rigid registration

if coll == 1
    k = 6000;
    t_dist = 3;
    d = nbr_matches*0.01;
elseif coll == 2;
    k = 20000;
    t_dist = 4;
    d = nbr_matches*0.01;
end
nbr_close_d = d;
nbr_close_best = 0;
R_best = [];
t_best = [];
s_best = [];
best_indices = [];
good_indices = [];
good_indices2 = [];

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
        [nbr_close, good_indices2] = test_performance(R_reg, t_reg, s_reg, k1_fit, k2_fit, t_dist);
        
        if nbr_close > nbr_close_best
            R_best = R_reg;
            t_best = t_reg;
            s_best = s_reg;
            nbr_close_best = nbr_close;
            best_indices = good_indices2;
            disp('newBest');
        end
    else
        nbr_close;
    end
end
%Final fit
best_indices = good_indices2;
k1_fit = k1_m(:,best_indices);
k2_fit = k2_m(:,best_indices);
%[R_best, t_best, s_best] = feval(registration_name, k1_fit, k2_fit);
%R_best = R_reg; t_best = t_reg; s_best = s_reg;
[~, best_indices] = test_performance(R_best, t_best,s_best, k1_fit, k2_fit, t_dist);

[theta, d] = get_data(R_best,t_best);
str = sprintf('Angle: %3.1f degrees, norm of t: %2.1f and s: %1.2f', theta, d, s_best);
disp(str)
%% Pullback time
% best_mean_X1 = mean(k1_m(:,best_indices),2);
% best_mean_X2_r = mean(rigid_transformation(R_best,t_best,k2_m(:,best_indices)),2);

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

imref2 = imref2d(size(i2));
[i1_r, rout_1] = imwarp(i1, tform, 'OutputView', imref2);

figure(3)
imagesc(i2_r)
colormap('gray');

% figure(3)
% imagesc(i1_r)
% colormap('gray');

figure(4)
imagesc(i1_r)
colormap('gray');

figure(5)
imshowpair(i2_r, rout_2, i1, imref1)

figure(6)
imshowpair(i1_r, rout_1, i2, imref2)
%i2_new = pullback(R_best, t_best, x_1, y_1, i2);
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
