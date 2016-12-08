function dx = get_dx(edgemap, xy_transf, l, search_str)
%GET_DX Summary of this function goes here
%   Detailed explanation goes here
dx = zeros(size(xy_transf));
for j = 1:length(dx)
    [search_start, search_path] = edgedirection(xy_transf, j);
    x = linspace(-l,l);
    edge_line = [search_path(1)*x + search_start(1); search_path(2)*x + search_start(2)];
    line_vals = interp2(edgemap, edge_line(1,:), edge_line(2,:));
    if nargin > 3 
        if strcmp(search_str, 'absmax')
            [~, ind] = max(abs(line_vals));
        elseif strcmp(search_str, 'absmin');
            [~, ind] = min(abs(line_vals));
        end
    end
    dx(j,:) = edge_line(:,ind)' - xy_transf(j,:);
end
end

