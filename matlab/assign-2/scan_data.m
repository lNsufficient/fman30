


%do_load = 0;


%% Save the directory strings
if coll == 1
    directory = '/home/edvard/fman30/matlab/assign-2-data/Collection 1';
    d1String = sprintf('%s/%s', directory,'/HE');
    d2String = sprintf('%s/%s', directory,'/p63AMACR');
    ext1String = '.bmp';
    ext2String = ext1String;
elseif coll == 2
    directory = '/home/edvard/fman30/matlab/assign-2-data/Collection 2';
    d1String = sprintf('%s/%s', directory,'/HE');
    d2String = sprintf('%s/%s', directory,'/TRF');
    ext1String = '.jpg';
    ext2String = '.tif';
end

%% Load the images
%following is taken from benchmark_inl4 imageanalysis
a = dir(d1String);
if coll == 1
    total_nbr_images = 29;
elseif coll == 2
    total_nbr_images = 12;
end
X1 = [];
X2 = [];
imagei = 1;
for ii = 1:length(a)
    [path,fname1,ext] = fileparts([d1String filesep a(ii).name]);
    if strcmp(ext,ext1String)
        if coll == 1
            fname2 = fname1;
        elseif coll == 2
            fname2 = sprintf('%s%s',fname1(1:length(fname1)-2),'TRF');
        end
        im1 = ((imread([d1String filesep fname1 ext1String])));
        im2 = ((imread([d2String filesep fname2 ext2String])));
        im1 = single(rgb2gray(im1));
        if coll == 1
            im2 = single(rgb2gray(im2));
        elseif coll == 2
            im2 = double(im2);
            im2 = imcomplement(histeq(uint8(im2*255/max(max(im2)))));
            %im2 = histeq(im2)*double(255/max(max(im2)));
            im2 = single(im2);
        end
        if isempty(X1)
            X1 = cell(total_nbr_images,1);
            X2 = cell(total_nbr_images,1);
        end
        X1{imagei} = imresize(im1,0.5);
        X2{imagei} = imresize(im2,0.5);
        imagei = imagei + 1;
    end
end
str = sprintf('data%d', coll);
save(str);
