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
N = size(Xcoord,1);

%% Align the training data

X_first = Xcoord(:,1);
Y_first = Ycoord(:,1);
[Xc, Yc] =align_to(X_first,Y_first,Xcoord, Ycoord);
X_mean = mean(Xc, 2);
Y_mean = mean(Yc, 2);
TOL = 1e-7;

mean_diffs = inf;
do_plot = 1;
if do_plot
    figure(1)
    axis 'equal';
end
RES = [];
[X_mean,Y_mean]=align_to(X_first,Y_first,X_mean,Y_mean);

while sum(mean_diffs)>TOL
    [Xc,Yc]=align_to(X_mean,Y_mean,Xc,Yc);
    X_mean_old = X_mean; Y_mean_old = Y_mean;
    X_mean = mean(Xc,2); Y_mean = mean(Yc,2);
    [X_mean,Y_mean]=align_to(X_first,Y_first,X_mean,Y_mean);
    mean_diffs = [X_mean - X_mean_old, Y_mean-Y_mean_old];
    mean_diffs = sqrt(sum((mean_diffs.^2),2));
    if do_plot
        figure(1);
        %clf;
        plot(X_mean, Y_mean, 'ro');
        hold on;
        plot(X_mean_old, Y_mean_old, 'gx');
        pause;
    end
    RES = [RES; sum(mean_diffs)];
end
X_mean_plot = [X_mean; X_mean(1)]; Y_mean_plot = [Y_mean; Y_mean(1)];

figure(2);
clf;
plot(X_mean_plot, Y_mean_plot, 'b')
hold on;
plot(Xc', Yc', 'o')
axis 'equal';

%%
figure(5);
for i = 1:size(Xc,2);
    clf;
    plot(X_mean_plot, Y_mean_plot, ':b');
    hold on;
    plot([Xc(:,i); Xc(1,i)], [Yc(:,i); Yc(1,i)],'r')
    pause;
end

%% Get the model
M = size(Xc,2);
oneX = ones(1,M);
dx = Xc - X_mean*oneX;
dy = Yc - Y_mean*oneX;
dX = [dx; dy];
S = 1/M*(dX*dX');

% k = 7;
% [P, lambda] = eigs(S, k);
[P, lambda] = eig(S, 'vector');
[lambda, I] = sort(lambda, 1, 'descend');
figure(3)
plot(lambda,'x');

figure(4)
clf;
plot(X_mean_plot, Y_mean_plot, 'r')
hold on;
axis 'equal'

P_X = P(1:N, :);
P_Y = P(N+1:2*N,:);
P_X_plot = [P_X; P_X(1,:)];
P_Y_plot = [P_Y; P_Y(1,:)];
k = length(lambda)
x_lim = [min(min(P_X_plot)), max(max(P_X_plot))];
y_lim = [min(min(P_Y_plot)), max(max(P_Y_plot))];
limits = [62, 90, 45, 83];
a =  14;

for i = 1:k
    figure(4);
    clf;
    plot(X_mean_plot, Y_mean_plot, ':b')
    hold on;
    plot(X_mean_plot + a*P_X_plot(:,i), Y_mean_plot + a*P_Y_plot(:,i),'r');
    %axis 'equal'
    axis(limits)
    pause;
end
hold off;