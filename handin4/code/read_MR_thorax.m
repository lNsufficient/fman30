foldername = '../images/MR-thorax-transversal';

[im, info] = mydicomreadfolder(foldername);

imshow3D(im)

%%
%pixSpace beskriver physical distance in patient between center of each
%voxel in mm. 
pixSpace = str2double(strsplit(info.PixelSpacing, '\'));

pixSpace(3) = str2double(info.SliceThickness)/2 + str2double(info.SpacingBetweenSlices);
x = (1:size(im, 2))*pixSpace(1); %2 eftersom att kolumner svarar mot sidled
y = (1:size(im, 1))*pixSpace(2); %1 eftersom rader svarar mot y.
z = (1:size(im, 3))*pixSpace(3);
imageOrientation = info.ImageOrientationPatient
disp('så first row: går mot vänsterhand, first col: går mot ryggen')
disp('Därfär: ryggen är där y-värdena är som störst, vänster hand är där x-värden är som störst')
sliceDiff = info.SlicePositionDifferences
disp('så vi vet att den första bilden är nederst, sedan ökande bildnummer så ökas s i LPS')

transversal_index = round(size(im, 3)/2);
transversal_slice = im(:,:,transversal_index);
figure(1);
clf;
imagesc(x, y, transversal_slice)
colormap('gray');
colorbar;
title(sprintf('transversal, sett från fötter,\n höga y är patientens rygg, höga x är patientens vänster'))
xlabel('x (mm)');
ylabel('y (mm)');
% set(gca,'xcolor',[1 1 1],'ycolor',[1 1 1]);
% set(gca,'ticklength',[0.05 0.05]);

%coronal plane: konstant v�rde p� y. x har samma orientering och z ska �ka
%p� samma h�ll som det redan nu �kar, allts�
coronal_index = round(size(im, 1)/2);
coronal_slice = im(coronal_index, :,:);
coronal_slice = squeeze(coronal_slice);
coronal_slice = imrotate(coronal_slice, 90);
figure(2);
clf;
imagesc(x, fliplr(z), coronal_slice);
%imagesc(coronal_slice)
set(gca,'YDir','normal') %Detta gör så att höga z-värden kommer högst upp i bilden
colormap('gray');
colorbar;
title(sprintf('coronal, sett från näsan, vänster sida är \n för höga x, fötter är på låga z.'))
xlabel('x (mm)');
ylabel('z (mm)');

%sagital plane: konstant v�rde p� x, y har samma orientering som tidigare, samma med z)
sagital_index = round(size(im, 2)/2);
sagital_slice = im(:, sagital_index, :);
sagital_slice = squeeze(sagital_slice);
sagital_slice = imrotate(sagital_slice, 90);
figure(3);
clf;
%Eftersom att z ökar då kolummnvärdet ökar, så måste matrisen roteras för
%att få den rätt?
%imagesc(y, fliplr(z), sagital_slice');
%imagesc(sagital_slice)
%imagesc(y, z, sagital_slice);
%z måste flippas, så att de element högst upp till vänster i matrisen får
%höga z-värden, eftersom matrisen har roterats.
%imagesc(y, z, sagital_slice');
imagesc(y, fliplr(z), sagital_slice);
set(gca,'YDir','normal') %Detta gör så att höga z-värden kommer högst upp i bilden
colormap('gray');
colorbar;
title(sprintf('sagital, sett från pasientens vänster sida, \n höga y-värden ger rygg, höga z-värden är huvud '));
xlabel('y (mm)')
ylabel('z (mm)')
