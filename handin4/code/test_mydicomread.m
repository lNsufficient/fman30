clear;

filePath_mr = '../images/MR-heart-single.dcm';
[mr, mr_im] = mydicomread(filePath_mr);

filePath_ct = '../images/CT-thorax-single.dcm';
[ct, ct_im] = mydicomread(filePath_ct);


disp('=======RESULTS======')
mr
subplot(1,2,1)
imagesc(mr_im)
colormap('gray')
colorbar;

pause;

ct
subplot(1,2,2)
imagesc(ct_im)
colormap('gray')
colorbar;
pause;


