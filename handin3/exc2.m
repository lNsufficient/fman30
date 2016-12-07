%% SHAPE MODEL
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

%% Align everything

%1. Align each shape to the first:
X_first = Xcoord(:,1);
Y_first = Ycoord(:,1);
[Xc, Yc] =align_to(X_first,Y_first,Xcoord, Ycoord);
% ------ Done: 1. Align each shape to the first:

TOL = 1e-7;

mean_diffs = inf;
do_plot = 0;
if do_plot
    figure(1)
    axis 'equal';
end
RES = inf;

%2. Calculate the mean of the transformed shapes (by calculating the mean
%value for each point)
X_mean = mean(Xc, 2);
Y_mean = mean(Yc, 2);
% ------ Done: 2. Calculate the mean of the transformed shapes 


while RES(end)>TOL
    %3. Align the mean shape to the first (to guarantee convergence)
    [X_mean,Y_mean]=align_to(X_first,Y_first,X_mean,Y_mean);
    % ------ Done: 3. Align the mean shape to the first
    
    
    %4. Align each shape to the mean shape
    [Xc,Yc]=align_to(X_mean,Y_mean,Xc,Yc);
    % ----- Done: 4. Align each shape to the mean shape
    
    
    %save the old means to compare
    X_mean_old = X_mean; Y_mean_old = Y_mean;
    
    %5. Update the mean shape
    X_mean = mean(Xc,2); Y_mean = mean(Yc,2);
    % ----- Done: 5. Update the mean shape
    
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
    RES = [RES; sum(mean_diffs)]
    
    %Following was added to make sure that the exact instructions of the
    %slides were followed
    %5. Update the mean shape
%    X_mean = mean(Xc,2); Y_mean = mean(Yc,2);
    % ----- Done: 5. Update the mean shape
end
X_mean_plot = [X_mean; X_mean(1)]; Y_mean_plot = [Y_mean; Y_mean(1)];

figure(2);
clf;
%plot(X_mean_plot, Y_mean_plot, 'b')
plot_shape(X_mean, Y_mean);
hold on;
plot(Xc', Yc', 'o')
axis 'equal';

%%
do_plot = 1;
if do_plot
    x_limits = [min(min(Xc)), max(max(Xc))];
    y_limits = [min(min(Yc)), max(max(Yc))];
    limits = [x_limits, y_limits];
    figure(5);
    for i = 1:size(Xc,2);
        clf;
        plot_shape(X_mean, Y_mean, Xc(:,i), Yc(:,i), 1, 1);
%         plot(X_mean_plot, Y_mean_plot, ':b');
%         hold on;
%         plot([Xc(:,i); Xc(1,i)], [Yc(:,i); Yc(1,i)],'r')
        axis(limits)
        pause;
    end
end
%% Get the model data
M = size(Xc,2);
oneX = ones(1,M);
dx = Xc - X_mean*oneX;
dy = Yc - Y_mean*oneX;
dX = [dx; dy];
S = 1/M*(dX*dX');

%% Get the modes
k = 7;
[P, lambda] = eigs(S, k);
[P, lambda] = eig(S, 'vector');
[lambda, I] = sort(lambda, 1, 'descend');
P = P(:,I);
P_X = P(1:N, :);
P_Y = P(N+1:2*N,:);

figure(3)
plot(lambda,'x');

%% Plot the modes

figure(4)
clf;
plot(X_mean_plot, Y_mean_plot, 'r')
hold on;
axis 'equal'


P_X_plot = [P_X; P_X(1,:)];
P_Y_plot = [P_Y; P_Y(1,:)];
k = length(lambda);

a =  14;
modes_X = bsxfun(@plus,a*P_X,X_mean);
modes_Y = bsxfun(@plus,a*P_Y,Y_mean);

% modes_X_plot = bsxfun(@plus,a*P_X_plot,X_mean_plot)
% modes_Y_plot = bsxfun(@plus,a*P_Y_plot,Y_mean_plot)

%x_lim = [min(min(X_mean_plot + a*P_X_plot)), max(max(X_mean_plot + a*P_X_plot))];
%y_lim = [min(min(Y_mean_plot + a*P_Y_plot)), max(max(Y_mean_plot + a*P_Y_plot))];
x_lim = [min(min(modes_X)), max(max(modes_X))];
y_lim = [min(min(modes_Y)), max(max(modes_Y))];

limits = [x_lim, y_lim];


for i = 1:k
    figure(4);
    clf;
    plot_shape(X_mean, Y_mean, modes_X(:,i), modes_Y(:,i), 1, 1);
    axis(limits)
    pause;
%     plot(X_mean_plot, Y_mean_plot, ':b')
%     hold on;
%     plot(X_mean_plot + a*P_X_plot(:,i), Y_mean_plot + a*P_Y_plot(:,i),'r');
%     %axis 'equal'

%     pause;
end
hold off;

%% Save the model
save('shapemodel.mat', 'P_X', 'P_Y', 'lambda', 'X_mean', 'Y_mean')