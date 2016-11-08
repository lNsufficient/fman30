function xp = parzen(x, X, s, n)
%PARZEN beräknar värdet för parzen i punkten x för alla kolonner i X
% X     - matris vars kolonner tillhör olika dataserier.
% s     - radie på parzen window
% n     - dimension


h = (2*pi*s^2)^(-n/2)*exp(-1/(2*s^2)*(norm2(X, x).^2)); 
xp = mean(h);
end

