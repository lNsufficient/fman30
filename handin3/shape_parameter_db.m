function b = shape_parameter_db(P_x, P_y, dx, lambda)
%SHAPE_PARAMETER
P = [P_x; P_y];
dx = [dx(:,1); dx(:,2)]; %i stället för x_mean skickar man dx.
b = P'*(dx);
    if  nargin > 3
        big_b = abs(b) > 3*sqrt(abs(lambda));
        b(big_b) = sign(b(big_b)).*lambda(big_b);
    end
end

