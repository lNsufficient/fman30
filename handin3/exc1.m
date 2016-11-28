%exc1

load man_seg

% Extract x- and y-coordinates
Xmcoord=real(man_seg);
Ymcoord=imag(man_seg);

diffs = [man_seg(1:end-1) - man_seg(2:end); man_seg(end) - man_seg(1)];
diffs_lengths = abs(diffs);
total_length = sum(diffs_lengths);
M = length(man_seg);
sum_length = zeros(M+1,1);
for i = 2:M+1
    sum_length(i) = sum_length(i-1) + diffs_lengths(i-1);
%    sum_length(i) = sum(diffs_lengths(1:i-1)); 
end


N = 14;
length_N = total_length/N;

points_N = zeros(N,1);
points_N(1) = man_seg(1);
new_dists = zeros(N,1);

for i = 2:N
    point_distances = sum_length-(length_N*(i-1));
    j_start = find(point_distances > 0, 1)-1;
    
    if j_start < 1;
        disp('ERROR: j_start < 1');
    end
    current_distance = diffs_lengths(j_start);
    x = -point_distances(j_start)/current_distance;
    points_N(i) = man_seg(j_start)*(1-x) + man_seg(j_start+1)*x;
    %for testing purposes:
    new_sum_length(i) = sum_length(j_start)+current_distance*x;
end
new_dists = abs(new_sum_length(1:end-1)- new_sum_length(2:end));

coarse_dists = abs(points_N(1:end-1)-points_N(2:end));

plot(man_seg,'r*')
hold on;
plot(points_N,'go')
plot(man_seg(1),'bo')
axis 'equal';