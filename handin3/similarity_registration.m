function [R, t, s] = similarity_registration(x,y)
%SIMILARITY_REGISTRATION As described in lecture notes (euclidian transfs)
%x - 2xN matrix, x and y coordinates.
%y - 2xN matrix, x and y coordinates.

x_hat = mean(x,2);
y_hat = mean(y,2);

x_tilde = [x(1,:) - x_hat(1); x(2,:) - x_hat(2)];
y_tilde = [y(1,:) - y_hat(1); y(2,:) - y_hat(2)];

H = y_tilde*x_tilde'; %this is the same as \sum_i(y_i*x_i^T)

[U, ~, V] = svd(H);
R = U*diag([1 det(U*V')])*V';
yRx_SUM = sum(sum(y_tilde.*(R*x_tilde)));
xx_SUM = sum(sum(x_tilde.^2));
s = yRx_SUM/xx_SUM;

t = y_hat - s*R*x_hat;
end

