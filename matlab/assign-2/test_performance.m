function [nbr_close, good_indices] = test_performance(R, t, s, k1_m, k2_m, t_dist)
%TEST_PERFORMANCE Tests the transformation on the given data to see how
%many points are located at an euclidian distance less than t when done.
if s == 1
    k1_r = rigid_transformation(R, t, k1_m);
else
    k1_r = similarity_transformation(R, t, s, k1_m);
end

%k1_r = similarity_transformation(R, t, s, k1_m);

dist = sqrt(sum((k1_r - k2_m).^2));
good_indices = find(dist < t_dist);
nbr_close = length(good_indices);

end

