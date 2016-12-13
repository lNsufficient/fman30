testFolder = '../images/MR-carotid-coronal';

[im, info] = mydicomreadfolder(testFolder);

figure(1)
clf;
imshow3D(im)

% for i =  1:size(im, 3)
%     imagesc(im(:,:,i))
%     title(sprintf('Bild nr %d', i));
%     colormap('gray')
%     pause;
% end