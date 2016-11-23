function [R, t, s] = rigid_registration(x, y)
%RIGID_REGISTRATION As described in lecture notes (euclidian transfs)
%x - 2xN matrix, x and y coordinates.
%y - 2xN matrix, x and y coordinates.

x_hat = mean(x,2);
y_hat = mean(y,2);

x_tilde = [x(1,:) - x_hat(1); x(2,:) - x_hat(2)];
y_tilde = [y(1,:) - y_hat(1); y(2,:) - y_hat(2)];

H = y_tilde*x_tilde'; %this is the same as \sum_i(y_i*x_i^T)

[U, ~, V] = svd(H);
R = U*diag([1 det(U*V')])*V';
t = y_hat - R*x_hat;

s = 1;
end

