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
disp('s� first row: g�r mot v�nsterhand, first col: g�r mot ryggen')
disp('D�rf�r: ryggen �r d�r y-v�rdena �r som st�rst, v�nster hand �r d�r x-v�rden �r som st�rst')
sliceDiff = info.SlicePositionDifferences
disp('s� vi vet att den f�rsta bilden �r nederst, sedan �kande bildnummer s� �kas s i LPS')

transversal_index = round(size(im, 3)/2);
transversal_slice = im(:,:,transversal_index);
figure(1);
clf;
imagesc(x, y, transversal_slice)
colormap('gray');
colorbar;
title('transversal, sett fr�n f�tter, h�ger sida �r patientens v�nster')
% set(gca,'xcolor',[1 1 1],'ycolor',[1 1 1]);
% set(gca,'ticklength',[0.05 0.05]);

%coronal plane: konstant v�rde p� y. x har samma orientering och z ska �ka
%p� samma h�ll som det redan nu �kar, allts�
coronal_index = round(size(im, 1)/2);
coronal_slice = im(coronal_index, :,:);
coronal_slice = squeeze(coronal_slice);
figure(2);
clf;
imagesc(x, z, coronal_slice);
colormap('gray');
colorbar;
title('coronal, sett fr�n n�san, v�nster sida �r f�r h�ga x, f�tter �r p� l�ga z.')

%sagital plane: konstant v�rde p� x, y har samma orientering som tidigare, samma med z)
sagital_index = round(size(im, 2)/2);
sagital_slice = im(:, sagital_index, :);
sagital_slice = squeeze(sagital_slice)
figure(3);
clf;
imagesc(x, z, sagital_slice);
colormap('gray');
colorbar;
title('coronal, sett fr�n n�san, v�nster sida �r f�r h�ga x, f�tter �r p� l�ga z.')

