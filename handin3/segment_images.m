%% Load the images
clear;
load dmsa_images
interesting_images = dmsa_images(:,:,21:end);

show_nothing = 1;
do_show = 1;
if do_show && ~show_nothing
    for i = 1:5
        imagesc(interesting_images(:,:,i));
        colormap('gray');
        pause;
    end
end

%% Perform graythresh and closing
gray_level = zeros(5,1);
images_thresh =zeros(size(interesting_images));
images_close = images_thresh; 
do_show = 1; 
for i = 1:5
    gray_level(i) = graythresh(interesting_images(:,:,i))* max(max(interesting_images(:,:,i)));
    thresh_factor = 0.5; %found this by testing
    images_thresh(:,:,i) = interesting_images(:,:,i)>gray_level(i)*thresh_factor;
    se = strel('disk',2);
    images_close(:,:,i) = imclose(images_thresh(:,:,i),se);
    
    [i_l, num_islands] = bwlabel(images_close(:,:,i), 8);
    if num_islands > 2
        disp('use hists to eliminate the smallest islands')
    end
    
    left_col = zeros(2,1);
    for j = 1:2
        [~, J] = find(i_l == j);
        left_col(j) = min(J);
    end
    [~, rightmost_island] = max(left_col); 
    
    images_close(:,:,i) = (i_l == rightmost_island);
    %I assume that imclose only make the image bigger. No matter what, the
    %only interesting is imclose so I could just ignore images_thresh...
    images_thresh(:,:,i) = images_thresh(:,:,i).*images_close(:,:,i);
    %find out which is the right one
    

    if do_show && ~show_nothing
        imagesc(images_thresh(:,:,i)*255) 
        colormap('gray')
        pause; 
        imagesc(images_close(:,:,i)*255)
        pause;
    end       
end

%% Try to find the edges roughly so that sampling then can be done
images_edges = images_close*0;
for i = 1:5
    tmp_image = images_close(:,:,i);
    tmp_edge = edge(tmp_image);
    images_edges(:,:,i) = tmp_edge;
    if do_show && ~show_nothing
        imagesc(tmp_image*255)
        pause;
        imagesc(tmp_edge*255)
        pause;
    end
end

%% Get some sample points from the edgemap
X_points = {};
Y_points = {};

for i = 1:5
    [I, J] = find(images_edges(:,:,i));
    X_tmp = zeros(numel(I),1);
    Y_tmp = X_tmp*0;
    
    %Find the two first points (then continue counter clocwise
    %first point should have the lowest y value.
    [y_start, startInd] = min(I);
    
    X_tmp(1) = J(startInd);
    Y_tmp(1) = y_start;
    %Remove the matching indices, no longer needed.
    I(startInd) = [];
    J(startInd) = [];
    
    x_diff = J - X_tmp(1);
    y_diff = I - Y_tmp(1);
    
    dists = sqrt(sum([x_diff, y_diff].^2, 2));
    [dists_sorted, sort_I] = sort(dists);
    %this only works if the starting point is not the rightmost point
    i2 = find(dists_sorted.*((x_diff(sort_I))>0), 1);
    i2 = sort_I(i2);
    
    X_tmp(2) = J(i2);
    Y_tmp(2) = I(i2);
    
    J(i2) = [];
    I(i2) = [];
    
    %From now on I will assume that the closest point always is the right
    %way, because now two points have been removed. 
    
    for j = 3:numel(I)+2
        x_diff = J - X_tmp(j-1);
        y_diff = I - Y_tmp(j-1);
        dists = sqrt(sum([x_diff, y_diff].^2,2));
        [~, best_ind] = min(dists);
        X_tmp(j) = J(best_ind);
        Y_tmp(j) = I(best_ind);
        
        J(best_ind) = [];
        I(best_ind) = []; 
    end
    
    X_points{i} = X_tmp;
    Y_points{i} = Y_tmp;
end

%% Plot the points
X_sampled = {};
Y_sampled = {};
for i = 1:5
    X_p = X_points{i};
    Y_p = Y_points{i};
    
    %Use fewer points. 
    X_p_short = [];
    Y_p_short = [];
    N = length(X_p)/3;
    N = 14*3;
    n = (length(X_p)/(N));
    for j = 1:N
        curr_start = round((j-1)*n+1);
        curr_end  = min(round(j*n), length(X_p));
        indices = curr_start:curr_end;
        x = mean(X_p(indices));
        y = mean(Y_p(indices));
        X_p_short = [X_p_short; x];
        Y_p_short = [Y_p_short; y];
    end
    
    %Calculate total distance for those points.
    N = 14;
    [x_sampled, y_sampled] = resample_curve(X_p_short, Y_p_short, N);
    do_plot = 1;
    if do_plot && ~show_nothing
        clf;
        imagesc(images_edges(:,:,i))
        colormap('gray')
        hold on;
        plot(X_p_short(1), Y_p_short(1), 'og')
        for j = 1:length(x_sampled)
            plot(x_sampled(j), y_sampled(j), 'xr');
            pause;
        end
    end
    X_samples{i} = x_sampled;
    Y_samples{i} = y_sampled;
end

%% Do the thäng

%% Find R,t,s,b
%load the model: 
load shapemodel;
R_a = cell(5,1); t_a = R_a; s_a = R_a; b_a = R_a;
nbr_vects = 6;
P_x = P_X(:,1:nbr_vects);
P_y = P_Y(:,1:nbr_vects);
lambda = lambda(1:nbr_vects);

for i = 1:5
    xs = X_samples{i};
    ys = Y_samples{i};
    [x_al, y_al, R, t, s] = align_to(X_mean, Y_mean, xs, ys);
    b = shape_parameter(P_x, P_y, X_mean, Y_mean, x_al, y_al, lambda); 
    b = shape_parameter(P_x, P_y, X_mean, Y_mean, x_al, y_al);
    %b = 0;
    x_hat = X_mean + P_x*b;
    y_hat = Y_mean + P_y*b;
    if do_plot && ~show_nothing

        clf;
        plot_shape(x_al, y_al,x_hat, y_hat,1)
        test_xy = similarity_transformation(R, t, s, [xs, ys]')';
        hold on;
        plot(test_xy(:,1), test_xy(:,2), 'og')
    end
    
    %Save the parameters
    R_a{i} = R;
    t_a{i} = t;
    s_a{i} = s;
    b_a{i} = b;
end
%% Transform mean to picture using R, t, s, b and create edgmap to compare with
XY_transf = cell(5,1);
for i = 1:5
    [R_inv, t_inv, s_inv] = similarity_inv(R_a{i}, t_a{i}, s_a{i});
    xy_transf = similarity_transformation(R_inv,t_inv,s_inv,[x_hat, y_hat]')';
    
    I = interesting_images(:,:,i);
    

    gauss = @(x,y,b) 1/(2*pi*b^2)*exp(-(x.^2+y.^2)/(2*b^2));
    %dxdygauss = @(x,y,b) ((x.^2+y.^2 -2*b*ones(size(x)))/(b^2))
    dxdygauss = @(x,y,b) ((x.^2+y.^2 -2*b*ones(size(x)))/(b^2)).*gauss(x,y,b);
    dygauss = @(x,y,b) (y)/(b^2).*gauss(x,y,b);
    dxgauss = @(x,y,b) (x)/(b^2).*gauss(x,y,b);
    %dxdygauss = @(x,y,b) ((x*(-2/(2*b^2))).^2 + (y*(-2/(2*b^2))).^2 -4/(2*b^2))*gauss(x,y,b);
    std = 1;
    N = max(ceil(6*std)+1, 20); N = 10;
    [y, x] = ndgrid(-N:N,-N:N);
    Gaussy =  dygauss(x,y,std);
    Gaussx =  dxgauss(x,y,std);
    
%     I = [zeros(500,500)];
%     I(250:255,:) = 255;
    Igy = conv2(I, Gaussy, 'same');
    Igx = conv2(I, Gaussx, 'same');
     
   
    edgemaps(:,:,i) = (Igy.^2 + Igx.^2);
    do_plot = 1;
    show_nothing = 0;
    if do_plot && ~show_nothing
        clf;
        imagesc(I);
        colormap('gray')
        hold on
        plot(xy_transf(:,1), xy_transf(:,2),'or');
        plot(X_samples{i}, Y_samples{i}, 'xg')
        pause;
        imagesc(edgemaps(:,:,i));
        colormap('gray') 
            hold on
        plot(xy_transf(:,1), xy_transf(:,2),'or');
        plot(X_samples{i}, Y_samples{i}, 'xg')
        pause;
    end
    XY_transf{i} = xy_transf;
end

%% Find dx

i = 2;
edgemap = edgemaps(:,:,i);
xy_transf = XY_transf{i};
for j = 1:length(X_samples{i})
    [search_start, search_path] = edgedirection(xy_transf, j);
    
end