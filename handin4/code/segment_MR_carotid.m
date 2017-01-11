restart = 0;

if restart
clear;
foldername = '../images/MR-carotid-coronal';
[im, info] = mydicomreadfolder(foldername);
end

%% Show result
% figure(1); imshow3D(im)
%% Perform Segmentation

%The left on the picture is the right side of the patient
%Because along the first row, x is increasing
%Along the first collumn, z is decreasing, meaning that the feet is in the
%bottom of the image. 
choise = 1; %left carotid
%choise = 2; %right carotid
choise = 3;

if choise == 1;
start_left = [367; 278; 30]; %Obtained using imshow3d and clicking on a point. 
elseif choise == 2;
start_right = [137; 257; 30]; %Obtained using imshow3d and clicking on a point.      
start_left = start_right; 
elseif choise == 3;
    start_right = [137; 257; 30];
    start_left = [367; 278; 30];
    extra_left = [467; 123; 30];
    %extra_left_buttom = [331; 410; 30];
    start_left = [start_left, start_right, extra_left];
end
intensityatseed = im(start_left(2), start_left(1), start_left(3));
std = 1.2;
N = max(round(6*std), 20);
gauss_filter = fspecial('gaussian', [N N], std); %Blurring each induvidual picture. 
blurredIm = imfilter(im, gauss_filter, 'same');
blurredIntensityatseed =  blurredIm(start_left(2), start_left(1), start_left(3));
speed = abs(blurredIm-blurredIntensityatseed).^2;
% if choise == 1
%     speed = abs(blurredIm-intensityatseed).^2;
% elseif choise == 2
%     speed = (max(0, intensityatseed-blurredIm)).^2;
% end
speed = (max(0, intensityatseed-blurredIm)).^2;
%GUI.SPEED = blurredIm - abs(blurredIm-blurredIntensityatseed);
%GUI.SPEED = GUI.SPEED - min(min(GUI.SPEED));
TOL = 10^8;
max_non_inf = max(max(speed(~isinf(speed))));
speed(isinf(speed)) = max_non_inf;
speed = max_non_inf - speed;
speed = speed./max_non_inf;
exponent = 30;
speed = speed.^exponent;
TOL_small = 1e-8; %Smallest speed that will make it travel;
speed(speed < TOL_small) = TOL_small;

%%
% figure(2); imshow3D(speed)

%%
newSpeed = 1;
if newSpeed
    if choise == 1 || choise == 2
        T=msfm3d(speed, [start_left(2); start_left(1); start_left(3)], true, true);
    elseif choise == 3
        T=msfm3d(speed, [start_left(2,:); start_left(1,:); start_left(3,:)], true, true);
    end
end
%%
if choise == 1;
    a = 500;
elseif choise == 2;
    a = 500;
elseif choise == 3;
    a = 500;
end
figure(3);  imshow3D(T<a);
%% Calculate geometry
dimensions(1) = size(im,2);
dimensions(2) = size(im,3);
dimensions(3) = size(im,1);
pixSpace([1,3]) = str2double(strsplit(info.PixelSpacing, '\'));
pixSpace(2) = str2double(info.SliceThickness)/2 + str2double(info.SpacingBetweenSlices);
sizes_in_mm_xyz= dimensions.*pixSpace;
x = [pixSpace(1), sizes_in_mm_xyz(1)];
y = [pixSpace(2), sizes_in_mm_xyz(2)];
z = [pixSpace(3), sizes_in_mm_xyz(3)];

aspect_ratio = pixSpace./pixSpace(1);
aspect_ratio = 1./aspect_ratio; %på så vis har 1 steg på y-axeln motsvarand 1.57 steg på x-/z-axeln

%% Showing the result
plotResult;


%%

%     %Multiply Speedimage with laplacian edgemap, zeros at edges
%     std = GUI.Slider2/10+0.01;
%     N = max(round(6*std), 20);
%     gauss_filter_lap = fspecial('gaussian', N, std);
%     laplace_filter = fspecial('laplacian');
%     blurredLap_gauss = imfilter(GUI.IM, gauss_filter_lap, 'same');
%     blurredLap = imfilter(blurredLap_gauss, laplace_filter, 'same');
%     a = 4;
%     blurredLap = 1./(1 + exp(a*blurredLap));
%     GUI.SPEED = GUI.SPEED*(GUI.Slider3).*blurredLap.^60*(1-GUI.Slider3);
%     %GUI.SPEED = GUI.SPEED*(GUI.Slider3) - edge(blurredLap_gauss)*(1-GUI.Slider3);
%     %GUI.SPEED = GUI.SPEED.^(GUI.Slider3).*blurredLap.^(1-GUI.Slider3);
%     GUI.SPEED = GUI.SPEED +0.01;
%     %GUI.SPEED = -blurredLap;