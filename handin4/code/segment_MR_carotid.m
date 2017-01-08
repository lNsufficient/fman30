restar = 0;

if restart
clear;
foldername = '../images/MR-carotid-coronal';
[im, info] = mydicomreadfolder(foldername);
end

%% Show result
% imshow3D(im)
%% Perform Segmentation

%The left on the picture is the right side of the patient
%Because along the first row, x is increasing
%Along the first collumn, z is decreasing, meaning that the feet is in the
%bottom of the image. 
choise = 1; %left carotid
%choise = 2; %right carotid

if choise == 1;
start_left = [367; 278; 30]; %Obtained using imshow3d and clicking on a point. 
intensityatseed = im(start_left(2), start_left(1), start_left(3));
std = 1.2;
N = max(round(6*std), 20);
gauss_filter = fspecial('gaussian', [N N], std); %Blurring each induvidual picture. 
blurredIm = imfilter(im, gauss_filter, 'same');
blurredIntensityatseed =  blurredIm(start_left(2), start_left(1), start_left(3));
speed = abs(blurredIm-blurredIntensityatseed).^2;
speed = abs(blurredIm-intensityatseed).^2;
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
elseif choise == 2;
    
    
end
%%
imshow3D(speed)

%%
if restart
T=msfm3d(speed, [start_left(2); start_left(1); start_left(3)], true, true);
end
%%
a = 500;
imshow3D(T<a);

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