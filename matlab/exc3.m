clear;

X1 = [ 177 179 166 184 171]';
X2 = [ 179 187 186 191 197]';

theta_1 = mean(X1);
theta_2 = mean(X2);

s = 10;

x = -100:3000;

px1 = normpdf(x, theta_1,s);
px2 = normpdf(x, theta_2,s);

theta = 100:300;
p = pxgivenX(x,X1,theta,s);

px = px1/2+px2/2;
clf;
plot(x, px1, 'b');
hold on;
plot(x, px2, 'r');
plot(x, px, 'g');
plot(X1, 0.02, 'ob')
plot(X2, 0.01, 'or')

ptheta1 = px1*(1/2)./px;
ptheta2 = px2*(1/2)./px;



plot(x, ptheta1, 'b');
plot(x, ptheta2, 'r');

plot(x, p,'k')