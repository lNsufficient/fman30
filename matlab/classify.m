function y_class = classify(x_test, x_regions)
%CLASSIFY Summary of this function goes here
%   Detailed explanation goes here

[~, x_start_collumn] = find(x_regions<x_test, 1);
[~, x_end_collumn] = find(x_regions>x_test, 1);


if (x_start_collumn == x_end_collumn)
    y_class = 1;
else
    y_class = -1;
end

end

