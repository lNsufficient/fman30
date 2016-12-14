filePath_mr = '../images/MR-heart-single.dcm';
[mr] = mydicominfo(filePath);

filePath_ct = '../images/CT-thorax-single.dcm';
[ct] = mydicominfo(filePath);


disp('=======RESULTS======')
mr
ct


