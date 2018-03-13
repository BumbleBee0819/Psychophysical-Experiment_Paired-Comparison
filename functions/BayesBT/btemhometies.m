function [pi, theta, alpha, pi_st, theta_st, alpha_st, ell] = btemhometies(w, l, t, a, prec)

%
% BTEMHOMETIES runs a Gibbs sampler for the Bradley-Terry model with home advantage and ties
% 	[pi, theta, alpha, pi_st, theta_st, alpha_st, ell] = BTEMHOMETIES(w, l, t, a, prec)
%--------------------------------------------------------------------------
% INPUTS:
%   - w     K*K matrix of integers
%           w(i,j) is the number of times i beats j when i is at home
%   - l     K*K matrix of integers
%           l(i,j) is the number of times i looses to j when i is at home
%   - t     K*K matrix of integers
%           t(i,j) is the number of times i ties j when i is at home
%   - a 	Scalar. shape parameter for the gamma prior (default a = 1)
%           If a<0, then it is estimated with a vague prior
%   - prec 	Precision of the EM (default = 1e-8)
%
% OUTPUTS:
%   - pi_st gives the values of the normalized skills at each iteration
%   - theta_st gives the values of the ties parameter at each iteration
%   - alpha_st gives the values of the home advantage parameter at each iteration
%   - a_st gives the values of the shape parameter at each iteration
%   - stats is a structure with some summary statistics on the parameters
%
% See also TEST_BT, BTEM, BTEMHOME, BTEMTIES
%--------------------------------------------------------------------------
% EXAMPLE
% wh = [0, 2, 1;
%     1, 0, 1;
%     4, 5, 0];
% lh = [0, 3, 1;
%     3, 0, 0;
%     1, 0, 0];
% t = [0, 3, 1;
%     3, 0, 0;
%     1, 0, 0];
% a=5; prec = 1e-8;
% [pi_em, theta_em,alpha_em, ~, ~, ~, ell] = btemhometies(wh, lh, t, a, prec);
%--------------------------------------------------------------------------

%
% Reference:
% F. Caron and A. Doucet. Efficient Bayesian inference for generalized
% Bradley-Terry models. Journal of Computational and Graphical
% Statistics,  vol. 21(1), pp. 174-196, 2012.
%
% Copyright INRIA 2011
% Author: F. Caron (INRIA Bordeaux Sud-Ouest)
% Francois.Caron@inria.fr
% http://www.math.u-bordeaux1.fr/~fcaron/
%--------------------------------------------------------------------------

K = size(w, 1);
if nargin<5
    prec = 1e-8;
end
iter_max = 5000;
b = K*a - 1;

lambda = ones(K, 1);
pi_st = zeros(iter_max, K, 'single');
theta_st = zeros(iter_max, 1, 'single');
alpha_st = zeros(iter_max, 1, 'single');
ell = zeros(iter_max, 1, 'single');

s1 = w + t;
s2 = l + t;
ak = a - 1 + sum(s1 + s2', 2);

[ind_i1, ind_j1, s_sparse1] = find(s1);
[ind_i2, ind_j2, s_sparse2] = find(s2);

T = full(sum(sum(t))); % Total number of ties
H = sum(s_sparse1); % Number of ties and wins at home
change =realmax;

theta = 1.5; % Tie parameter
alpha = 1; % Home advantage parameter


iteration = 1; 
pi_st(iteration, :) = lambda/sum(lambda);
theta_st(iteration) = theta;
alpha_st(iteration) = alpha;  
% Compute log-posterior (not necessary)
temp1 = sparse(ind_i1, ind_j1, s_sparse1.*(log(lambda(ind_i1))-log(alpha*lambda(ind_i1)+theta*lambda(ind_j1))), K, K);
temp2 = sparse(ind_i2, ind_j2, s_sparse2.*(log(lambda(ind_j2))-log(alpha*theta*lambda(ind_i2)+lambda(ind_j2))), K, K);

ell(iteration) = sum(sum(s1))*log(alpha) + T*log(theta^2-1)...
    + sum(sum(temp1)) + sum(sum(temp2)) + (a-1)*sum(log(lambda)) -b*sum(lambda);
while norm(change)>prec  && iteration<iter_max 
    iteration = iteration + 1;
    
    % E step
    Z = sparse(ind_i1, ind_j1, s_sparse1./(alpha*lambda(ind_i1)+theta*lambda(ind_j1)), K, K);    
    U = sparse(ind_i2, ind_j2, s_sparse2./(alpha*theta*lambda(ind_i2)+lambda(ind_j2)), K, K);            
    
    % Maximize w.r.t. lambda given (theta, alpha)
    bk = b + sum(Z, 2) + theta*sum(Z)' + alpha*theta*sum(U, 2) + sum(U)';
    lambda_new = ak./bk;
    
    change = lambda_new/sum(lambda_new) - lambda/sum(lambda);
    lambda = lambda_new;    
    
    % Maximize w.r.t. alpha given (theta, lambda)
    % Flat prior on alpha
    alpha = H/(lambda' * (sum(Z, 2) + theta*sum(U, 2)));

    % Maximize w.r.t. theta given (alpha, lambda)
    % Flat prior on theta 
    c = lambda'*(sum(Z)' + alpha*sum(U, 2));
    theta = T/c * (1+sqrt(1+c^2/T^2));

    % Store outputs  
    pi_st(iteration, :) = lambda/sum(lambda);
    theta_st(iteration) = theta;
    alpha_st(iteration) = alpha;    
    
    % Compute log-posterior (not necessary)
    temp1 = sparse(ind_i1, ind_j1, s_sparse1.*(log(lambda(ind_i1))-log(alpha*lambda(ind_i1)+theta*lambda(ind_j1))), K, K);
    temp2 = sparse(ind_i2, ind_j2, s_sparse2.*(log(lambda(ind_j2))-log(alpha*theta*lambda(ind_i2)+lambda(ind_j2))), K, K);
    ell(iteration) = sum(sum(s1))*log(alpha) + T*log(theta^2-1)...
        + sum(sum(temp1)) + sum(sum(temp2)) + (a-1)*sum(log(lambda)) -b*sum(lambda);
end
pi_st = pi_st(1:iteration, :);
theta_st = theta_st(1:iteration, :);
alpha_st = alpha_st(1:iteration, :);
ell = ell(1:iteration, :);
pi = lambda/sum(lambda);