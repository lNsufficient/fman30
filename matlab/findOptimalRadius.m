function r_opt = findOptimalRadius(X, r, d, do_plot)
%FINDOPTIMALRADIUS beräknar optimal radie mha cross-validation
nbr_r = length(r);
m = length(X);
%indices = 1:m;
L = zeros(size(r));
h0 = (2*pi)^(-1/2);
rdh0 = r.^(-d)*h0/m;
for i = 1:nbr_r
    tmp_r = r(i);
    y_r = parzenMatrix(X, tmp_r, d, 0, X, '');
    tmp_rdh0 = rdh0(i);
    L(i) = m*log(m/(m-1)) + sum(log(y_r-tmp_rdh0));
end
inf_indices = find(abs(L) == inf);
%L(inf_indices) = min(L);
TOL = 1e-7;
imag_indices = find(abs(imag(L)) > TOL);
%L(imag_indices) = min(L);
bad_indices = union(imag_indices, inf_indices);
l_indices = setdiff(1:nbr_r, bad_indices);
L = L(l_indices);
[~, i_max] = max(L);
r = r(l_indices);
r_opt = r(i_max);

if do_plot
clf;
semilogx(r, L);
hold on;
semilogx([r_opt r_opt], [min(L) max(L)]);
end
end

