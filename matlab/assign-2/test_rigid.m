%Testing rigid_registration for 
R = [0, -1; 1, 0];
t = [1; 1];

x = [1 0; 1 1]';
%which corresponds to (when y = Rx+t)
y1 = [1 2; 0 2]';
y2 = [R*x(:,1) + t, R*x(:,2)+t];
y3 = rigid_transformation(R,t,x);

[R1, t1] = rigid_registration(x,y1);

diffs = [y2 - y1, y1-y3, R1-R, t-t1];
should_be_zero = sum(sum(abs(diffs)))

x = [1:100; 0*(100:-1:1)];
y = rigid_transformation(R,t,x);
[Rbig,tbig] = rigid_registration(x,y);
R_and_t = [R, t]