function Y = RBF(X,Beta,w)

Y = exp(-Beta.*norm(X - w).^2);

