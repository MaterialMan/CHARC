function Y = RBF(X,w)

Y = exp(-Beta.*norm(X - w).^2);

