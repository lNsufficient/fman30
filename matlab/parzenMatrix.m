function [X_parzen, x] = parzenMatrix(X, s_parzen, n, plot_val, low, upp)
%PARZENMATRIX beräknar parzen för hela X-matrisen, kolummvis
%   X           - matris vars kolonner innehåller olika dataserier
%   s_parzen    - radie på parzen-window
%   n           - dimension
if nargin > 4
    x = linspace(low,upp);
else
    x = linspace(min(min(X)),max(max(X)));
end
X_collumns = size(X,2);
X_parzen = zeros(length(x), X_collumns);
for i =1:length(x)
    xi = x(i);
    X_parzen(i,:) = parzen(xi, X, s_parzen, n);
end

%Valde att inte använda plotmatrix här för att slippa 
if nargin > 3
    for k = 1:X_collumns
        subplot(X_collumns,1,k)
        plot(x, X_parzen(:,k));
        hold on;
        tmp_plot_val = plot_val*max(X_parzen(:,k));
        plot(X(:,k), tmp_plot_val*ones(size(X(:,k))), 'o');
    end
end
end

