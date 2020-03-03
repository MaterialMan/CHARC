
function Rsq = rsquared(x,y)

Bbar = mean(x);
SStot = sum((x - Bbar).^2);
SSreg = sum((y - Bbar).^2);
SSres = sum((x - y).^2);
R2 = 1 - SSres/SStot;
R = corrcoef(x,y);
Rsq = R(1,2).^2;
