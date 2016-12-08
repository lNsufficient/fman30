function edgemap = get_edgemap(I, std)
%GET_EDGEMAP Returns an edgemap for image I with standard deviation std

    gauss = @(x,y,b) 1/(2*pi*b^2)*exp(-(x.^2+y.^2)/(2*b^2));
    dygauss = @(x,y,b) (y)/(b^2).*gauss(x,y,b);
    dxgauss = @(x,y,b) (x)/(b^2).*gauss(x,y,b);
    
    N = max(ceil(6*std)+1, 20); N = 10;
    [y, x] = ndgrid(-N:N,-N:N);
    Gaussy =  dygauss(x,y,std);
    Gaussx =  dxgauss(x,y,std);
    
    Igy = conv2(I, Gaussy, 'same');
    Igx = conv2(I, Gaussx, 'same');
     
    edgemap = (Igy.^2 + Igx.^2);
end

