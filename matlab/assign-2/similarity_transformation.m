function y = similarity_transformation(R, t, s, x)
%SIMILARITY_ROTATION applies R, t and s to each collumn in x in order to get y
%y = R*x + t for a collumn;

sRx = s*R*x;
y = [sRx(1,:) + t(1); sRx(2,:)+t(2)];

end


