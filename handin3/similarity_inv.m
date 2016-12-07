function [R_i, t_i, s_i]= similarity_inv(R,t,s)
%SIMILARITY_INV returns inverse transformation parameters
t_i = -R'*t/s;
s_i = 1/s;
R_i = R';
end

