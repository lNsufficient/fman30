function [X_new, Y_new] = align_to(X0, Y0, X, Y)
%ALIGN_TO Returns X_new and Y_new, the result when each collumn in X and Y
%is pairwise aligned to X0, Y0.
N = size(X,2);
y = [X0'; Y0'];

for i = 1:N
    x_tmp = [X(:,i)'; Y(:,i)'];
    [R, t, s] = similarity_registration(x_tmp, y);
    sRx = s*R*x_tmp;
    x_new = [sRx(1,:) + t(1); sRx(2,:) + t(2)];
    X_new(:,i) = x_new(1,:)';
    Y_new(:,i) = x_new(2,:)';
end

