function [im,info] = mydicomreadfolder(foldername)
%[im,info] = mydicomreadfolder(foldername)
%Reads all dicom files in a folder into an image volume.
%
%-im is a three dimensional array of image data
%-info is a struct containing suitable data for voxel sizes etc.
%
%See also MYDICOMINFO, MYDICOMREAD
%
%This function is just a stub and you need to write it.

%Stub written by Einar Heiberg

%Hint:
%To get all files called in a folder, use the function 
%f = dir([foldername filesep '*.dcm'])

%Hint: Consider preallocating data for the sake of speed.

%Hint: waitbar is a good way of updating regarding progress.

%--- Initialize
im = [];
info = [];

%If called without input argument then ask for folder.
if nargin==0
  foldername = uigetdir(pwd, 'Select a folder');
end;

%Display folder name
disp(sprintf('Reading the folder %s.',foldername)); %#ok<DSPS>

%--- From now on it is up to you :-)
f = dir([foldername filesep '*.dcm'])
first_file = sprintf('%s/%s',foldername, f(1).name);
first_info = mydicominfo(first_file);
rows = first_info.Rows;
cols = first_info.Columns;
N = length(f);
im = zeros(rows, cols, N);
for i = 1:N
    waitbar(i/N);
    current_file = sprintf('%s/%s', foldername, f(i).name);
    [in, im_t] = mydicomread(current_file);
    im(:,:,i) = im_t;
end
info = first_info;