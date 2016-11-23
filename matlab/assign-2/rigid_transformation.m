function y = rigid_transformation(R, t, x)
%RIGID_ROTATION applies R and t to each collumn in x in order to get y
%y = R*x + t for a collumn;
% 
% Rx = R*x;
% y = [Rx(1,:) + t(1); Rx(2,:)+t(2)];

y = similarity_transformation(R,t,1,x);
end

