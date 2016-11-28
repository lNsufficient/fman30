%% Section 5 
% A lot of code taken from main_dmsa
clear

% Load the DMSA images
load dmsa_images

% Load the manual segmentations
% Columns 1-20: the right kidney of patient 1-20
% Columns 21-40: the mirrored left kidney of patient 1-20
% Each row is a landmark position
load models

% Extract x- and y-coordinates
Xcoord=real(models);
Ycoord=imag(models);

%% Align the training data

[Xc, Yc] =align_to(Xcoord(:,1),Ycoord(:,1),Xcoord, Ycoord);
X_mean = mean(Xc, 2);
Y_mean = mean(Yc, 2);
TOL = 1e-1;

mean_diffs = inf;
do_plot = 1;
if do_plot
    figure(1)
    axis 'equal';
end
while sum(mean_diffs)>TOL
    [X_mean,Y_mean]=align_to(Xc(:,1),Yc(:,1),X_mean,Y_mean);
    [Xc,Yc]=align_to(X_mean,Y_mean,Xc,Yc);
    X_mean_old = X_mean; Y_mean_old = Y_mean;
    X_mean = mean(Xc,2); Y_mean = mean(Yc,2);
    mean_diffs = [X_mean - X_mean_old, Y_mean-Y_mean_old];
    mean_diffs = sqrt(sum((mean_diffs.^2),2));
    if do_plot
        figure(1);
        %clf;
        plot(X_mean, Y_mean, 'go');
        hold on;
        plot(X_mean_old, Y_mean_old, 'rx');
    end
end
X_mean_plot = [X_mean; X_mean(1)]; Y_mean_plot = [Y_mean; Y_mean(1)];

figure(2);
clf;
plot(X_mean_plot, Y_mean_plot, 'b')
hold on;
plot(Xc', Yc', 'o')
axis 'equal';

%% Get the model

%dx =
%S =