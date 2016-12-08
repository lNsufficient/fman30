function dx = get_dx(edgemap, xy_transf )
%GET_DX Summary of this function goes here
%   Detailed explanation goes here
dx = zeros(size(xy_transf));
for j = 1:length(dx)
    [search_start, search_path] = edgedirection(xy_transf, j);
    l = 3;
    x = linspace(-l,l);
    edge_line = [search_path(1)*x + search_start(1); search_path(2)*x + search_start(2)];
    line_vals = interp2(edgemap, edge_line(1,:), edge_line(2,:));
    [~, max_ind] = max(line_vals);
    dx(j,:) = edge_line(:,max_ind)' - xy_transf(j,:);
end
end

