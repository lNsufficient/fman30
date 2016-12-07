%% Load the images
clear;
load dmsa_images
interesting_images = dmsa_images(:,:,21:end);

do_show = 0;
if do_show
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
    

    if do_show 
        imagesc(images_thresh(:,:,i)) 
        colormap('gray')
        pause; 
        imagesc(images_close(:,:,i))
        pause;
    end       
end

%% Try to find the edges roughly so that sampling then can be done
images_edges = images_close*0;
for i = 1:5
    tmp_image = images_close(:,:,i);
    tmp_edge = edge(tmp_image)
    images_edges(:,:,i) = tmp_edge;
    imagesc(tmp_image)
    pause;
    imagesc(tmp_edge)
    pause;
end

%% Get some sample points from the edgemap
for i = 1:5
    [I, J] = find(images_edges(:,:,i));
end
