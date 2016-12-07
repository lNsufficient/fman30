function [h1, h2, h3] = plot_shape(a_x, a_y, b_x, b_y, is_open, plot_bars)
%PLOT_SHAPE plots the shapes

if nargin == 2
    h1 = plot([a_x; a_x(1)], [a_y; a_y(1)], 'k');
else
    if nargin < 5
        is_open = 0;
        plot_bars = 1;
    elseif nargin < 6
        plot_bars = 1;
    end


    if is_open
        a_x = [a_x; a_x(1)];
        a_y = [a_y; a_y(1)];
        b_x = [b_x; b_x(1)];
        b_y = [b_y; b_y(1)];
    end

    h1 = plot(a_x, a_y, 'k');
    hold on;
    h2 = plot(b_x, b_y, 'r');
    if plot_bars
        h3 = plot([a_x, b_x]', [a_y, b_y]', 'g');
    end
    hold off;

end

