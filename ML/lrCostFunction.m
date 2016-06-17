function [J, grad] = lrCostFunction(theta, X, y, lambda)
%LRCOSTFUNCTION Compute cost and gradient for logistic regression with 
%regularization
%   J = LRCOSTFUNCTION(theta, X, y, lambda) computes the cost of using
%   theta as the parameter for regularized logistic regression and the
%   gradient of the cost w.r.t. to the parameters. 

% Initialize some useful values
m = length(y); % number of training examples

% You need to return the following variables correctly 
J = 0;
grad = zeros(size(theta));

theta_reg = theta;
theta_reg(1) = 0;
h = sigmoid(X * theta);

J = (-y' * log(h) - (1 - y)' * log(1 - h)) / m + (lambda / (2 * m)) * sum(theta_reg .^ 2);
grad = (X' * (h - y)) / m + (lambda / m) * theta_reg;

grad = grad(:);

end
