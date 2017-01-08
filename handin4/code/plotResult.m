

[X,Z,Y] = meshgrid((1:dimensions(1))*pixSpace(1),(dimensions(3):-1:1)*pixSpace(3),(-dimensions(2):-1)*pixSpace(2));

fv = isosurface(Z,X, -Y, T, a);
figure(5)
% subplot(1,2,1)
% lighting gouraud
% p = patch(fv);
% p.FaceColor = [.5 .5 .5];
% p.EdgeColor = 'black';
% daspect([1 1 1]); view(3); axis tight
% title([num2str(length(p.Faces)) ' Faces'])
% camlight; lighting phong
% subplot(1,2,2)
p = patch(fv);
p.FaceColor = [.5 .5 .5];
p.EdgeColor = 'black';
daspect([aspect_ratio(1), aspect_ratio(3), aspect_ratio(2)]); view(3); axis tight
reducepatch(p, .15) % keep 15 percent of the faces 
title([num2str(length(p.Faces)) ' Faces'])
xlabel('x')
ylabel('z')
zlabel('y')
camlight; lighting phong
cameratoolbar