function im_pulled = pullback(R, t, x_1, y_1, im)
%PULLBACK pullbacks the picture, painting black outside boundaries
[x_grid, y_grid] = meshgrid(1:x_1,1:y_1);
x_grid_vec = x_grid(:);
y_grid_vec = y_grid(:);
xy = [x_grid_vec'; y_grid_vec'];
new_xy_vec = rigid_transformation(R, t, xy);
%new_x_grid = reshape(new_xy_vec(1,:), y_1, x_1);
%new_y_grid = reshape(new_xy_vec(2,:), y_1, x_1);

im_pulled = interpolate(im, new_xy_vec, x_1, y_1);

end

