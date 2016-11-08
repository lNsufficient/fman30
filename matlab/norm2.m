function norms = norm2(X, a)
%NORM2 beräknar 2-norm för alla element i A = X-a.
% X matris
% a skalär
diff = X-a;
norms = abs(diff); %ty 1-dimensionell 2-norm.
end

