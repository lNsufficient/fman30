function [X_parzen, x] = parzenMatrix(X, s_parzen, n, plot_val, x, s)
%PARZENMATRIX beräknar parzen för hela X-matrisen, kolummvis
%   X           - matris vars kolonner innehåller olika dataserier
%   s_parzen    - radie på parzen-window
%   n           - dimension
if nargin > 4
    x = x;
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

if (nargin > 3 && plot_val ~= 0)
    if nargin > 5
        str = sprintf('o%s',s);
    end
    for k = 1:X_collumns
        subplot(X_collumns,1,k)
        plot(x, X_parzen(:,k), s);
        hold on;
        tmp_plot_val = plot_val*max(X_parzen(:,k));
        plot(X(:,k), plot_val*ones(size(X(:,k))), str);
    end
end
end

