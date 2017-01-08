fv = isosurface(T, a);
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
daspect([1 1 1]); view(3); axis tight
reducepatch(p, .15) % keep 15 percent of the faces 
title([num2str(length(p.Faces)) ' Faces'])
camlight; lighting phong
cameratoolbar