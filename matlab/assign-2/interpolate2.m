function im_new = interpolate(im, xy, x_new, y_new)
%INTERPOLATE calculates new im_new where im_new(xy_new(:,i)) is
%interpolation of im(xy(:,i))
%First tried to do this using vectors, but it required too much memory.

y_max = size(im,1);
x_max = size(im,2);

xy11 = ceil(xy);
xy00 = floor(xy);
xy10 = [ceil(xy(1,:)); floor(xy(2,:))];
xy01 = [floor(xy(1,:)); ceil(xy(2,:))];

ind11 = insideBoundsIndices(xy11, x_max, y_max);
ind10 = insideBoundsIndices(xy10, x_max, y_max);
ind01 = insideBoundsIndices(xy01, x_max, y_max);
ind00 = insideBoundsIndices(xy00, x_max, y_max);

%distances in 1 norm
d11 = sum(abs(xy11 - xy));
d01 = sum(abs(xy01 - xy));
d10 = sum(abs(xy10 - xy));
d00 = sum(abs(xy00 - xy));

%weights - they will be zero for out of bounds
w11 = 0*d11;
w01 = w11;
w10 = w11;
w00 = w11;

w11(ind11) = 1 - d11(ind11)/2;
w01(ind01) = 1 - d01(ind01)/2;
w10(ind10) = 1 - d10(ind10)/2;
w00(ind00) = 1 - d00(ind00)/2;

C = -1;
im11 = C*ones(1,x_new*y_new);
im00 = im11;
im01 = im11;
im10 = im11;

% im11(ind11) = im(xy11(:,ind11));
% im10(ind10) = im(xy10(:,ind10));
% im01(ind01) = im(xy01(:,ind01));
% im00(ind00) = im(xy00(:,ind00));

im11(ind11) = im(xy11(2,ind11),xy11(1,ind11));
im10(ind10) = im(xy10(2,ind10),xy10(1,ind10));
im01(ind01) = im(xy01(2,ind01),xy01(1,ind01));
im00(ind00) = im(xy00(2,ind00),xy00(1,ind00));

im_new = im11.*w11 + im01.*w01 + im10.*w10 + im00.*w00;
im_new = reshape(im_new,y_new,x_new);
end

