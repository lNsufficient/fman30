function indices =  insideBoundsIndices(xy, x_max, y_max)
%UNTITLED3 Just finds the indices where 0 < xy(1,:) <= x_max and
% 0 < xy(2,:) <= y_max

i1 = find(xy(1,:) > 0 & xy(1,:) <= x_max);
i2 = find(xy(2,:) > 0 & xy(2,:) <= y_max);

indices = intersect(i1, i2);

end

