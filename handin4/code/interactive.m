function [varargout] = interactive(arg,varargin)
%Simple interactive medical image segmentation tool. 
%
%Part of assignment in the course Medical Image Analysis
%FMAN30, Centre of Mathematical Sciences, Engineering Faculty, Lund University.

%Einar Heiberg

if nargin==0
  %Called with no input arguments then initialize
  init;
else
  %Call the appropriate subfunction
  [varargout{1:nargout}] = feval(arg,varargin{:}); % FEVAL switchyard  
end;

%------------
function init
%------------
global GUI

GUI = []; %Start out clean;

GUI.Fig = openfig('interactive.fig');

%Extract handles
GUI.Handles = guihandles(GUI.Fig);

%Initialize
GUI.IM = []; %Loaded by open_Callback
GUI.Info = []; %Set by open_Callback
GUI.SPEED = [];
GUI.MAP = [];
GUI.Slider1 = 0; %Updated later by slider_Callback
GUI.Slider2 = 0;
GUI.Slider3 = 0; 
GUI.ArrivalTime = 0;
GUI.XSeed = []; %Updated by load_Callback and xxx
GUI.YSeed = [];

%Get values from sliders
slider_Callback;

%Make the images invisible
set(GUI.Handles.imaxes,'visible','off');
set(GUI.Handles.mapaxes,'visible','off');

return;

%---------------------
function open_Callback %#ok<DEFNU>
%---------------------
%Called when user clicks on open button
global GUI

%Ask for filename
[filename, pathname] = uigetfile('*.dcm', 'Pick a DICOM file');

[info,im] = mydicomread([pathname filesep filename]);

%Test if mydicomread is not implemted yet
if isempty(im)
  msgbox('mydicomread does not seem to be implemented yet. Loading standard image.');
  
  %MR case
  %load('images/testmr.mat'); %Just load one file
  %im = im(1:100,:);
  
  %CT
  load('images/testct.mat'); %Just load one file
  
end;

%Store data
GUI.Info = info;
GUI.IM = double(im);

%Make the images visible
set(GUI.Handles.imaxes,'visible','on');
set(GUI.Handles.mapaxes,'visible','on');

%--- Display the data

%Consider to change here to get correct image proportions..
GUI.Handles.image = image(getimage,'parent',GUI.Handles.imaxes);
axis(GUI.Handles.imaxes,'image','off');

%Add seed point
GUI.XSeed = round(size(GUI.IM,2)/2);
GUI.YSeed = round(size(GUI.IM,1)/2);

hold(GUI.Handles.imaxes,'on');
GUI.Handles.seedpoint = plot(GUI.Handles.imaxes,GUI.XSeed,GUI.YSeed,'yo');
hold(GUI.Handles.imaxes,'off');

%Set callback for button down
set(GUI.Handles.image,'ButtonDownFcn','interactive(''buttondown_Callback'')');

%Calculate speed image and update
calculatespeedimage; %Store into GUI
update_Callback;

%---------------------
function im = getimage
%---------------------
%Returns the loaded image as RGB image with/without overlay
global GUI

minvalue = min(GUI.IM(:));
maxvalue = max(GUI.IM(:));

%If constant image return zero image
if isequal(minvalue,maxvalue)
  im = uint8(zeros([size(GUI.IM) 3]));
  return;  
end;

%Calculate the RGB images
imr = uint8(255*(GUI.IM-minvalue)/(maxvalue-minvalue));
img = imr;
imb = imr;

%Apply overlay
if get(GUI.Handles.overlaycheckbox,'value')    
  if ~(isempty(GUI.MAP) || isempty(GUI.Thres))
    overlay = (GUI.MAP<GUI.Thres);
    imb(overlay) = uint8(255);
  end;
end;

%Return make it a n*m*3 array
im = cat(3,imr,img,imb);

%-----------------------
function update_Callback
%-----------------------
global GUI

if isempty(GUI.SPEED) || isempty(GUI.MAP)
  return;
end;

%Get the position of the listbox selector
v = get(GUI.Handles.displaylistbox,'value');

%The two different display options
switch v
  case 1
    %Display the speed image
    imagesc(GUI.SPEED,'parent',GUI.Handles.mapaxes);    
  case 2
    %Display 1/speed image
    imagesc(1./GUI.SPEED,'parent',GUI.Handles.mapaxes);        
  case 3
    %Display arrival time map
    imagesc(GUI.MAP,'parent',GUI.Handles.mapaxes);    
  otherwise
    error('Unknown option.');
end;

%Update the standard image
set(GUI.Handles.image,'cdata',getimage);

colorbar('peer',GUI.Handles.mapaxes);
axis(GUI.Handles.mapaxes,'image','off');

%---------------------------
function buttondown_Callback %#ok<DEFNU>
%---------------------------
global GUI

if isempty(GUI.IM)
  return;
end;

type = get(GUI.Fig,'SelectionType');

p = get(GUI.Handles.imaxes,'CurrentPoint');
y = p(3);
x = p(1);

switch type
  case 'normal' 
    %Left click
    GUI.XSeed = round(x);
    GUI.YSeed = round(y);
    set(GUI.Handles.seedpoint,'xdata',round(x),'ydata',round(y));    
    calculatespeedimage; %Store into GUI
    update_Callback;
  case 'alt'
    %Right click

    %Extract speed
    yedge = round(y);
    xedge = round(x);
    GUI.Thres = GUI.MAP(yedge,xedge);
    
    %Update slider & text
    maxvalue = max(GUI.MAP(:));
    percentage = 100*GUI.Thres/maxvalue;
    set(GUI.Handles.arrivalslider,'value',percentage);
    set(GUI.Handles.arrivaltext,'string',sprintf('%0.5g',GUI.ArrivalTime));
    
    %figure(22);
    %imagesc(GUI.MAP<GUI.Thres);
end;

%Update graphically
update_Callback;

%-----------------------
function slider_Callback
%-----------------------
%This function is called when the user changes the slider

global GUI

GUI.Slider1 = get(GUI.Handles.slider1,'value');
GUI.Slider2 = get(GUI.Handles.slider2,'value');
GUI.Slider3 = get(GUI.Handles.slider3,'value');
GUI.ArrivalTime = get(GUI.Handles.arrivalslider,'value');

%Calculate the threshold
maxarrival = max(GUI.MAP(:));
GUI.Thres = (GUI.ArrivalTime/100)*maxarrival;

%Update edit boxes
set(GUI.Handles.slider1text,'string',sprintf('%0.5g',GUI.Slider1));
set(GUI.Handles.slider2text,'string',sprintf('%0.5g',GUI.Slider2));
set(GUI.Handles.slider3text,'string',sprintf('%0.5g',GUI.Slider3));
set(GUI.Handles.arrivaltext,'string',sprintf('%0.5g',GUI.ArrivalTime));

%If no image present the do no more.
if isempty(GUI.IM)
  return;
end;

calculatespeedimage; %Store into GUI
update_Callback;

%----------------------
function close_Callback %#ok<DEFNU>
%----------------------
%Close the user interface
global GUI

close(GUI.Fig);

%---------------------------
function calculatespeedimage
%---------------------------
%Calculate speed image. Here, use your imagination to calculate a good
%speed image based on image intensity at the seed, slider settings,
%and different features from the image.

global GUI

%%%% --- Calculate speed image
%Replace this code. This is likely going to be several lines of code
%involving one or more sliders and mix pre-processing such as filtering,
%edge detection or whatever you can come up with. Note that your function
%may very well be nonlinear. Remember the speed function should be high for
%values that you want to include and low were you want the expansion to 
%stop/slow down. Have fun!

%Calculate the intensity at the seed in case it is useful.
intensityatseed = GUI.IM(GUI.YSeed,GUI.XSeed);

 GUI.SPEED = (GUI.IM-intensityatseed)*GUI.Slider1;
%Just anything for now, replace here!
image_case =3;
if image_case == 1

   

    std = GUI.Slider1/100+0.2;

    N = max(round(6*std), 20);
    gauss_filter = fspecial('gaussian', N, std);


    blurredIm = imfilter(GUI.IM, gauss_filter, 'same');
    %blurredIm = imfilter(GUI.IM, gauss_lap, 'same');
    blurredIntensityatseed =  blurredIm(GUI.YSeed,GUI.XSeed);
    GUI.SPEED =  abs(blurredIm-blurredIntensityatseed).^2;
    GUI.SPEED = abs(blurredIm-intensityatseed).^2;
    %GUI.SPEED = blurredIm - abs(blurredIm-blurredIntensityatseed);
    %GUI.SPEED = GUI.SPEED - min(min(GUI.SPEED));
    TOL = 10^8;
    max_non_inf = max(max(GUI.SPEED(~isinf(GUI.SPEED))));
    GUI.SPEED(isinf(GUI.SPEED)) = max_non_inf;
    GUI.SPEED = GUI.SPEED./max_non_inf;
    GUI.SPEED = 1 - GUI.SPEED;
    exponent = 30;
    GUI.SPEED = (GUI.SPEED).^exponent;
    %GUI.SPEED(GUI.SPEED<TOL) = TOL;
    %GUI.SPEED = GUI.SPEED./max(max(GUI.SPEED));


    %Multiply Speedimage with laplacian edgemap, zeros at edges
    std = GUI.Slider2/10+0.01;
    N = max(round(6*std), 20);
    gauss_filter_lap = fspecial('gaussian', N, std);
    laplace_filter = fspecial('laplacian');
    blurredLap_gauss = imfilter(GUI.IM, gauss_filter_lap, 'same');
    blurredLap = imfilter(blurredLap_gauss, laplace_filter, 'same');
    a = 4;
    blurredLap = 1./(1 + exp(a*blurredLap));
    GUI.SPEED = GUI.SPEED*(GUI.Slider3).*blurredLap.^60*(1-GUI.Slider3);
    %GUI.SPEED = GUI.SPEED*(GUI.Slider3) - edge(blurredLap_gauss)*(1-GUI.Slider3);
    %GUI.SPEED = GUI.SPEED.^(GUI.Slider3).*blurredLap.^(1-GUI.Slider3);
    GUI.SPEED = GUI.SPEED +0.01;
    %GUI.SPEED = -blurredLap;
elseif image_case == 2
    GUI.SPEED = 1./(GUI.IM-intensityatseed).^2;
elseif image_case == 3
    GUI.SPEED =GUI.IM.^2;
    GUI.SPEED = GUI.SPEED - min(min(GUI.SPEED));
    GUI.SPEED = GUI.SPEED./max(max(GUI.SPEED));
    %GUI.SPEED(GUI.SPEED < GUI.Slider1) = 0;
    %GUI.SPEED(GUI.SPEED > 0) = 100;
    se3 = strel('disk',1);
    %GUI.SPEED = imclose(GUI.SPEED, se3);
    
    GUI.SPEED = GUI.SPEED.^2
    
    lap_filt = fspecial('laplacian');
    
    std = GUI.Slider2/10;
    N = round(max(std*6, 20));
    gauss_filt = fspecial('gaussian', N, std);
    extraMap = imfilter(GUI.IM, gauss_filt, 'same');
    
    extraMap = imfilter(extraMap, lap_filt, 'same');
    extraMap = abs(extraMap);
    
    extraMap = extraMap-min(min(extraMap));
    extraMap = extraMap./max(max(extraMap));
    extraMap = extraMap.^(1/2);
    
    x = 1:size(GUI.IM, 2);
    y = 1:size(GUI.IM, 1);
    
    [X, Y] = ndgrid(x, y);
    distMap = sqrt((X-GUI.XSeed).^2 + (Y - GUI.YSeed).^2);
    %extraMap = -extraMap;
    
    GUI.SPEED = GUI.SPEED*(GUI.Slider3) + extraMap*(1 - GUI.Slider3);
    %GUI.SPEED = imfilter(GUI.SPEED, gauss_filt, 'same')
    %GUI.SPEED = GUI.SPEED./distMap
end

tic;
switch get(GUI.Handles.methodlistbox,'value')
  case 1
    %Full code
    GUI.MAP = msfm2d(GUI.SPEED,[GUI.YSeed;GUI.XSeed],true,true); %Call the fast marching code.
  case 2
    %No curve    
    GUI.MAP = msfm2d(GUI.SPEED,[GUI.YSeed;GUI.XSeed],false,true); %Call the fast marching code.    
  case 3
    %No cross
    GUI.MAP = msfm2d(GUI.SPEED,[GUI.YSeed;GUI.XSeed],true,false); %Call the fast marching code.        
  case 4
    GUI.MAP = msfm2d(GUI.SPEED,[GUI.YSeed;GUI.XSeed],false,false); %Call the fast marching code.            
  case 5
    startind = round(GUI.XSeed)*size(GUI.IM,1)+round(GUI.YSeed); %Calculate startindex
    try
      GUI.MAP = fastmarch(single(1./GUI.SPEED),single(startind),1e10); %Call the fast marching code.    
    catch me
      error('The function fastmarch does not seem to be compiled.');
    end;
end;
t = toc;
set(GUI.Handles.calculationtimetext,'string',sprintf('Calculation time: %0.5g [s]',t));
