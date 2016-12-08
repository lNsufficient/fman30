function [search_start, search_direction] = edgedirection(xy, j)
%EDGEDIRECTION Returns starting point and direction to perform edge
%detection

search_start = xy(j,:);

j_start = j-1;
if j_start == 0
    j_start = size(xy,1);
end
j_end = j+1;
if j_end > size(xy,1)
    j_end =1;
end
perp_vec = xy(j_start,:) - xy(j_end,:);
search_direction = [-perp_vec(2); perp_vec(1)]; 
search_direction = search_direction/sqrt(sum(search_direction.^2));
%this makes sure that the scalar product is zero


end

