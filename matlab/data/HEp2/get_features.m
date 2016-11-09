function [F, STR] = get_features(image, mask)

X = image(mask);
i = 0;

i = i + 1;
F(i) = mean(X);
STR{i} = 'mean intensity';

% i = i + 1;
% F(i) = median(X);
% STR{i} = 'median intensity';

i = i + 1;
F(i) = var(X);
STR{i} = 'variance for intensity';


i = i + 1;
F(i) = std(X);
STR{i} = 'standard deviation';

N = 5;
h = hist(X, N);
j = 1;
stopi = i + N;
while (i < stopi)
    i = i+1;
    F(i) = h(j);
    STR{i} = 'histogram values';
    j = j+1;
end

i = i+1;
F(i) = mode(X);
STR{i} = 'mode';

% i = i + 1;
% F(i) = sqrt(sum(X.^2));
% STR{i} = 'two norm';

% i = i + 1;
% F(i) = mean(abs(X));
% STR{i} = 'mean of abs';
    
% i = i + 1;
% F(i) = median(abs(X));
% STR{i} = 'median of abs';

% i = i + 1;
% F(i) = (mean(X.^2))^(1/2);
% STR{i} = 'mean of X.^2';

% i = i + 1;
% F(i) = mean(X.^3);
% STR{i} = 'mean of X.^3';

% i = i + 1;
% F(i) = max(X) - min(X);
% STR{i} = 'max minus min';

% i = i + 1;
% F(i) = cov(X);
% STR{i} = 'covariance';


% i = i + 1;
% F(i) = max(X)/F(1);
% STR{i} = 'max over mean';
% 
% i = i + 1;
% F(i) = min(X)/F(1);
% STR{i} = 'min over mean';


% i = i + 1;
% F(i) = min(X)/max(X);
% STR{i} = 'min over max';
%  



% Need to name all features.
assert(numel(F) == numel(STR));