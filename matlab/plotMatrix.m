function plotMatrix(X, x_plot, s)
%PLOTMATRIX plottar helt enkelt
if nargin < 3
    s = '';
end
    nbr_plots = size(X,2);
    for i = 1:nbr_plots
        subplot(nbr_plots, 1, i);
        plot(x_plot, X(:,i),s);
    end
end

