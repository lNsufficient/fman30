function intensity = interpolatePixel(im, x, y)
%INTERPOLATEPIXEL Interpolates the intensity for the double "indices" x,y

x0 = floor(x);
y0 = floor(y);
x1 = ceil(x);
y1 = ceil(y);

[x_max, y_max] = size(im);

if (x0 < 1 || y0 < 1 || x1 > x_max || y1 > y_max)
    intensity = 0;
else
    if and((x0 == x),(y0 == y))
        intensity = im(x0,y0);
    else
        xy = [[x0; y0], [x0; y1], [x1;y0], [x1; y1]];
%         goodInd = (xy(1,:)>0).*(xy(2,:)>0).*(xy(1,:)<= x_max).*(xy(2,:)<=y_max);
%         badInd = find([1 1 1 1] - goodInd);
% 
%         if ~isempty(badInd)
%             xy(:,badInd) = [];
%         end
        w = [(1-(x-x0))*(1-(y-y0)), (1-(x-x0))*(y-y0), (x-x0)*(1-(y-y0)),(x-x0)*(y-y0)];
 %       p = 2
        intensity = 0;
        if ~isempty(xy)    
 %           diffs = [xy(1,:) - x; xy(2,:) - y];
 %           normDiffs = (sum(abs(diffs).^p)).^(1/p);
 %           w = abs(sum(normDiffs)-normDiffs)
 %           w = w/sum(w);
            for i = 1:size(xy,2)
                intensity = intensity + im(xy(2,i),xy(1,i))*w(i);
            end
        end
    end
    if isnan(intensity)
        disp('interpolate NaN intensity')
    end
end

