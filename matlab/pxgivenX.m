function p = pxgivenX(x,X,theta,sigma)
%pxgivenX beräknar sannolikheten i punkterna x utan användning av plug in 
%classifyer
% theta - row vector of integers (N1:N2) for example
% X     - data, collumn vector
% x     - evaluation value (row vector). 
p = zeros(size(x));
N = length(x);
THETA = ones(length(X),1)*theta;
XX = X*ones(1,length(theta));
diffs = XX - THETA;

THETA_x = ones(length(x),1)*theta;
x_theta = x'*ones(1,length(theta));

x_diffs = (x_theta - THETA_x);
x_exponents = x_diffs.^2;
exponent = ones(size(x_exponents,1),1)*sum(diffs.^2);


exponent_matrix = x_exponents+exponent;

p = sum(exp(-1/(2*sigma^2)*exponent_matrix),2);
c = sum(p);
p = p/c;

TOL = 1e-4;
if (min(p)/max(p) > TOL)
    disp('span of theta or x should be increased');
end
end

