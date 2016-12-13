foldername = '../images/MR-thorax-transversal';

[im, info] = mydicomreadfolder(foldername);

imshow3D(im)
%pixSpace beskriver physical distance in patient between center of each
%voxel in mm. 
pixSpace = str2double(strsplit(info.PixelSpacing, '\'));

pixSpace(3) = str2double(info.SliceThickness)/2 + str2double(info.SpacingBetweenSlices);
x = (1:size(im, 2))*pixSpace(1); %2 eftersom att kolumner svarar mot sidled
y = (1:size(im, 1))*pixSpace(2); %1 eftersom rader svarar mot y.
z = (1:size(im, 3))*pixSpace(3);
imageOrientation = info.ImageOrientationPatient
disp('så first row: går mot vänsterhand, first col: går mot ryggen')
disp('Därför: ryggen är där y-värdena är som störst, vänster hand är där x-värden är som störst')
sliceDiff = info.SlicePositionDifferences
disp('så vi vet att den första bilden är nederst, sedan ökande bildnummer så ökas s i LPS')

transversal_index = round(size(im, 3)/2);
transversal_slice = im(:,:,transversal_index);
figure(1);
clf;
imagesc(x, y, transversal_slice)
colormap('gray');
colorbar;
title('transversal, sett från fötter, höger sida är patientens vänster')
% set(gca,'xcolor',[1 1 1],'ycolor',[1 1 1]);
% set(gca,'ticklength',[0.05 0.05]);

%coronal plane: konstant värde på y. x har samma orientering och z ska öka
%på samma håll som det redan nu ökar, alltså
coronal_index = round(size(im, 1)/2);
coronal_slice = im(coronal_index, :,:);
coronal_slice = squeeze(coronal_slice);
figure(2);
clf;
imagesc(x, z, coronal_slice);
colormap('gray');
colorbar;
title('coronal, sett från näsan, vänster sida är för höga x, fötter är på låga z.')

%sagital plane: konstant värde på x, y har samma orientering som tidigare, samma med z)
sagital_index = round(size(im, 2)/2);
sagital_slice = im(:, sagital_index, :);
sagital_slice = squeeze(sagital_slice)
figure(3);
clf;
imagesc(x, z, sagital_slice);
colormap('gray');
colorbar;
title('coronal, sett från näsan, vänster sida är för höga x, fötter är på låga z.')

