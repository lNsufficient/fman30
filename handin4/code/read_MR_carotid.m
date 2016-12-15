clear;
foldername = '../images/MR-carotid-coronal';

[im, info] = mydicomreadfolder(foldername);
%%
%imshow3D(im)
%%
ImageOrientationPatient = info.ImageOrientationPatient
disp('i första raden, ökar x, i första kolonnen minskar z.')
disp('när bildnummer ökar, så minskar y. Den första bilden är närmast ryggen')

coronal_index = round(size(im, 3)/2);
coronal_im = im(:,:,coronal_index);
%coronal_im = squeeze(coronal_im)

figure(7)
imagesc(coronal_im)
colormap('gray');
xlabel('x, mm, höga x-värden är vänster sida av pasient')
ylabel('z, mm, höga z-värden är fötter')
%%
dimensions(1) = size(im,1);
dimensions(2) = size(im,3);
dimensions(3) = size(im,2);
pixSpace([1,3]) = str2double(strsplit(info.PixelSpacing, '\'));
pixSpace(2) = str2double(info.SliceThickness)/2 + str2double(info.SpacingBetweenSlices);
sizes_in_mm_xyz= dimensions.*pixSpace;
x = [pixSpace(1), sizes_in_mm_xyz(1)];
y = [pixSpace(2), sizes_in_mm_xyz(2)];
z = [pixSpace(3), sizes_in_mm_xyz(3)];
%% Cutplanes
%Coronal plane
coronal_index = round(dimensions(2)/2);
coronal_cut = im(:,:,coronal_index);

figure(4)
imagesc(x, z, coronal_cut)
colormap('gray')
title('CUTPLANE framifrån näsan')
xlabel('x, mm, höga x-värden är vänster sida av pasient')
ylabel('z, mm, höga z-värden är fötter')
colorbar

%Sagital plane
sagital_index = round(dimensions(1)/2);
sagital_cut = im(:,sagital_index,:);
sagital_cut = squeeze(sagital_cut);

figure(5)
imagesc(y, z, sagital_cut)
imagesc(sagital_cut)
colormap('gray')
title('sagital cut sett från höger sida')
xlabel('y, mm, höga y-värden är framåt mot magen')
ylabel('z, mm, höga z-värden är fötter')
colorbar;

%transverse plane
transverse_index = round(dimensions(3)/2);
transverse_cut = im(transverse_index,:,:);
transverse_cut = squeeze(transverse_cut);
transverse_cut = imrotate(transverse_cut, 90);

figure(6)
imagesc(x, y, transverse_cut)
colormap('gray')
size(transverse_cut)
colorbar

title('sett från fötter')
xlabel('x, mm, höga x vid vänsterhand')
ylabel('y, mm, höga y vid magen')

%% Maxprojections

%Coronal plane
coronal_max = max(im, [], 3);

figure(4)
imagesc(x, z, coronal_max)
colormap('gray')
title('set framifrån näsan')
xlabel('x, mm, höga x-värden är vänster sida av pasient')
ylabel('z, mm, höga z-värden är fötter')
colorbar

%Sagital plane
sagital_max = max(im, [], 2);
sagital_max = squeeze(sagital_max);

figure(5)
imagesc(y, z, sagital_max)
imagesc(sagital_max)
colormap('gray')
title('sagital sett från höger sida')
xlabel('y, mm, höga y-värden är framåt mot magen')
ylabel('z, mm, höga z-värden är fötter')
colorbar;

%transverse plane
transverse_max = max(im, [], 1);
transverse_max = squeeze(transverse_max);
transverse_max = imrotate(transverse_max, 90);

figure(6)
imagesc(x, y, transverse_max)
colormap('gray')
size(transverse_max)
colorbar

title('sett från fötter')
xlabel('x, mm, höga x vid vänsterhand')
ylabel('y, mm, höga y vid magen')