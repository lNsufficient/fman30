function b = shape_parameter(P_x, P_y, x_mean, y_mean, x, y, lambda)
%SHAPE_PARAMETER
P = [P_x; P_y];
xy_mean = [x_mean; y_mean];
xy = [x; y];
b = P'*(xy- xy_mean);
if nargin > 6
    big_b = abs(b) > 3*sqrt(abs(lambda));
    b(big_b) = sign(b(big_b)).*lambda(big_b);
end
end

