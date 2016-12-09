function b = shape_parameter(P_x, P_y, x_mean, y_mean, x, y, lambda)
%SHAPE_PARAMETER
P = [P_x; P_y];
if or(nargin == 3, nargin==4);
    dx = [x_mean(:,1); x_mean(:,2)]; %i stället för x_mean skickar man dx.
    if nargin == 4
        use_lambda = 1;
    else
        use_lambda = 0;
        lambda = y_mean; %last argument is lambda
    end
else
    xy_mean = [x_mean; y_mean];
    xy = [x; y];
    dx = xy- xy_mean;
    use_lambda = 0;
end
b = P'*(dx);
lambda_t = 3*sqrt(abs(min(lambda)));
    if or(nargin > 6, use_lambda)
%         big_b = abs(b) > 3*sqrt(abs(lambda));
%         b(big_b) = sign(b(big_b)).*lambda(big_b);
        big_b = abs(b) > lambda_t;
        b(big_b) = sign(b(big_b))*lambda_t;

    end
end

