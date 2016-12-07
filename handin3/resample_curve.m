function [x_s, y_s] = resample_curve(x, y, N)
%RESAMPLE_CURVE resamples the curve to N points
%   Does it by calculating curve length

coords = x+y*i;
diffs = [coords(1:end-1) - coords(2:end); coords(end) - coords(1)];
% diffs_y = [y(1:end-1) - y(2:end); y(end) - y(1)]
dists = abs(diffs);

cum_dists = cumsum(dists);
tot_length = cum_dists(end);
cum_dists = cum_dists - cum_dists(1);


length_N = tot_length/N;

points_N = zeros(N, 1);
points_N(1) = coords(1);

for j = 2:N
    point_distances = cum_dists-(length_N*(j-1)); 
    %We want to go where point_distances is zero
    
    %Notice the -1 here, makes sure that we go to the point just before we
    %reach the desired distance.
    j_start = find(point_distances > 0, 1)-1;
    
    if j_start < 1;
        disp('ERROR: j_start < 1');
    end
    %length of the line on which the next sampled point will be. 
    current_distance = dists(j_start);
    
    %point_distances(j_start)<0, hence minus sign here when calculating the
    %fraction of the line that we want to use.
    x = -point_distances(j_start)/current_distance;
    points_N(j) = coords(j_start)*(1-x) + coords(j_start+1)*x;
end

x_s = real(points_N);
y_s = imag(points_N);
end

