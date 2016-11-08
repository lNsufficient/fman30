function x_regions = plugInXRegions(Y, x_plot)
%PLUGINXREGIONS Hittar intervall där klassen är mest trolig
% Y     - p(y|x)
% x_plot- platser där Y har evaluerats.

limit = 0.5;
x_okay = (Y > limit);
x_edges = [x_okay(1:end-1) - x_okay(2:end)];
x_end = x_plot(find(x_edges>0));
x_start = x_plot(find(x_edges<0)+1); %måste addera 1 här för att se till 
%att Y är större än limit.
if (isempty(x_start))
    x_start = [-inf, x_start];
elseif(min(x_end) < min(x_start))
    x_start = [-inf, x_start];
end

if (isempty(x_end))
    x_end = [x_end, inf];
elseif(max(x_start) > max(x_end))
    x_end = [x_end, inf];
end

x_regions = [x_start; x_end];

end

