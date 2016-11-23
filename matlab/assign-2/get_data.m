function [theta, d] = get_data(R, t)
%GET_DATA Finds interesting data about the R and t matrix

theta = acosd(R(1,1));

if R(2,1) < 0
    theta = - theta;
end

d = sqrt(t(1).^2+t(2).^2);

end

