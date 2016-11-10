clear; %För att inte få med skräp.

s_model = [0.1 1 5]';
m_1 = 0;
m_2 = 1;

N_small = 10;
N_big = 1000;

X1_small = zeros(N_small,length(s_model));
X2_small = X1_small;

X1_big = zeros(N_big,length(s_model));
X2_big = X1_big;

for i = 1:size(s_model)
    X1_small(:,i) = normrnd(m_1, s_model(i), N_small,1);
    X2_small(:,i) = normrnd(m_2, s_model(i), N_small,1);
    X1_big(:,i) = normrnd(m_1, s_model(i), N_big, 1);
    X2_big(:,i) = normrnd(m_2, s_model(i), N_big, 1);
end

one_at_a_time = 1;
if one_at_a_time
    nn = 2;
    X1_small = X1_small(:,nn);
    X2_small = X2_small(:,nn);
    X1_big = X1_big(:,nn);
    X2_big = X2_big(:,nn);
end
s_parzen = [0.01, 0.1, 1, 10]';
j = 3;
s_parzen = s_parzen(j);
n = 1;

%h = @(x,X,s,n) (2*pi*s^2)^(-n/2)*exp(-1/(2*s^2)*(norm2(X, x).^2)); 
%||x-x'||^2 = (X-x).^2 ty x skalär. 
%parzen = @(x, X, s, d) mean(h(x,X,s,d));

clf;
do_pause = 0;
X1 = X1_small; X2 = X2_small;
%X1 = X1_big; X2 = X2_big;

r = logspace(-2,2);
do_plot = 1;
if do_plot
    figure(2);
end
r_opt = findOptimalRadius(X1, r, n, do_plot);

figure(1);
lower_limit = min(min(min(X1_big)),min(min(X2_big)));
lower_limit = min(min(min(X1_small)), lower_limit);
lower_limit = min(min(min(X2_small)), lower_limit);
upper_limit = max(max(max(X1_big)),max(max(X2_big)));
upper_limit = max(max(max(X1_small)),upper_limit);
upper_limit = max(max(max(X1_big)), upper_limit);
lower_limit = min(lower_limit, -2);
upper_limit = max(lower_limit, 3);
X = X1;
x_plot = linspace(lower_limit, upper_limit,5000);
[X1_parzen, x_plot] = parzenMatrix(X,s_parzen,n,0.1, x_plot, 'b');
if do_pause
    pause;
end
X = X2;
[X2_parzen, x_plot] = parzenMatrix(X,s_parzen,n,0.2, x_plot, 'r');
if do_pause
    pause;
end
X_sum = (X1_parzen+X2_parzen)/2;
plotMatrix(X_sum, x_plot, 'g');
% nbr_plots = size(X_sum,2);
% for i = 1:nbr_plots
%     subplot(nbr_plots, 1, i);
%     plot(x_plot, X_sum(:,i));
% end
if do_pause
    pause;
end
py1 = 0.5; py2 = 0.5;
Y1 = (X1_parzen)*py1./X_sum;
Y2 = (X2_parzen)*py2./X_sum;
plotMatrix(Y1, x_plot, 'b-.');
if do_pause
    pause;
end
plotMatrix(Y2, x_plot, 'r-.');
if do_pause
    pause;
end
j = 1;
x_regions = plugInXRegions(Y1(:,j), x_plot);
x_test = X1_big(:,j);
error = 0;
for i = 1:length(x_test)
    class = classify(x_test(i), x_regions);
    if class == -1
        error = error + (class==-1);
    end
end
x_test = X2_big(:,j);
for i = 1:length(x_test)
    class = classify(x_test(i), x_regions);
    if class == 1
        error = error + 1;
    end
end

plotMatrix(0.8*ones(size(X1_big)), X1_big, 'b.')
plotMatrix(0.9*ones(size(X2_big)), X2_big, 'r.')

r_opt
error
% lower_limit = min(min(min(X1_small)),min(min(X2_small)));
% upper_limit = max(max(max(X2_small)),max(max(X2_small)));
% X = X1_big;
% [X_parzen, x_plot] = parzenMatrix(X,s_parzen,n,1);
% pause;
% X = X2_big;
% [X_parzen, x_plot] = parzenMatrix(X,s_parzen,n,1);