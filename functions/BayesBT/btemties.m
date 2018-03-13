function [pi, theta, pi_st, theta_st, ell] = btemties(w, t, a, prec, a_th, b_th)

%
% BTEMTIES runs an EM algorithm for the Bradley-Terry model with ties
%   [pi, theta, pi_st, theta_st, ell] = BTEMTIES(w, t, a, prec, a_th, b_th)
%--------------------------------------------------------------------------
% INPUTS:
%   - w:    K*K matrix of integers
%           w(i,j) is the number of times i beats j
%   - t:    K*K matrix of integers
%           t(i, j) is the number of times i ties j - t is symmetric
%   - a 	Scalar. shape parameter for the gamma prior (default a = 1)
%           If a<0, then it is estimated with a vague prior
%   - prec 	Precision of the EM (default = 1e-8)
%   - a_th  Positive scalar. Shape parameter for the gamma prior on the tie
%           parameter (Default=1)
%   - b_th  Positive scalar. Scale parameter for the gamma prior on the tie
%           parameter (Default=0)
%  
% OUTPUTS:
%   - pi is the MAP estimate of the normalized skill parameters
%   - theta is the MAP estimate of the scalar parameter for ties
%   - pi_st gives the values of the normalized skills at each iteration
%   - theta_st gives the values of the tie parameter at each iteration
%   - ell gives the log posterior at each iteration
%
% See also TEST_BT, BTEM, BTEMHOMETIES, BTEMHOME
%--------------------------------------------------------------------------
% EXAMPLE
% w = [0, 2, 1;
%     1, 0, 1;
%     4, 5, 0];
% t = [0, 3, 1;
%     3, 0, 0;
%     1, 0, 0];
% a = 5;
% prec = 1e-8;
% a_th = 2;
% b_th = 1;
% [pi_em, theta_em, junk, junk, ell] = btemties(w, t, a, prec, a_th, b_th);
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
b = K*a - 1;
lambda = ones(K, 1);
iter_max = 5000;
pi_st = zeros(iter_max, K);
theta_st = zeros(iter_max, 1);
ell = zeros(iter_max, 1);

s = w + t; 
ak = a - 1 + sum(s, 2);
change = realmax;

if nargin<4
    prec = 1e-8;
end
if nargin<5
    a_th = 1;
end
if nargin<6
    b_th = 0;
end

[ind_i, ind_j, s_sparse] = find(s);

T = sum(sum(t))/2; 
theta = 1;

iteration = 1; 
pi_st(iteration, :) = lambda/sum(lambda);
ell(iteration) = T*log(theta^2-1) ...
        + sum(sum(sparse( ind_i, ind_j, s_sparse.*log(lambda(ind_i)./(theta*lambda(ind_j)+lambda(ind_i))) , K, K)))...
        + (a_th - 1) * log(theta-1) - b_th * theta + (a-1)*sum(log(lambda)) - b*sum(lambda);
theta_st(iteration) =  theta;
while norm(change)>prec  && iteration<iter_max  
    iteration = iteration + 1;
    
    % E step
    temp = sparse(ind_i, ind_j, s_sparse./(lambda(ind_i)+theta*lambda(ind_j)), K, K)...
        + sparse( ind_i, ind_j, theta*s_sparse./(theta*lambda(ind_j)+lambda(ind_i)) , K, K)';

    % Maximize w.r.t. the skill parameters lambda
    bk = b + sum(temp, 2);  
    lambda_new = ak./bk;        
    
    change = lambda_new/sum(lambda_new)-lambda/sum(lambda);
    lambda = lambda_new;
    pi_st(iteration, :) = lambda/sum(lambda);
    
    % Maximize w.r.t. the tie parameter theta    
    temp = sparse(ind_i, ind_j, lambda(ind_j).*s_sparse./(lambda(ind_i) + theta*lambda(ind_j)), K, K);
    C = sum(sum(temp));
    theta = .5*(a_th - 1 + 2*T)/(C + b_th) ...
        * (1 + sqrt(1 + 4 *(C+b_th) * (a_th - 1 + C + b_th)/ (a_th - 1 + 2*T)^2));    

    theta_st(iteration) = theta;
    ell(iteration) = T*log(theta^2-1) ...
        + sum(sum(sparse( ind_i, ind_j, s_sparse.*log(lambda(ind_i)./(theta*lambda(ind_j)+lambda(ind_i))) , K, K)))...
        + (a_th - 1) * log(theta-1) - b_th * theta + (a-1)*sum(log(lambda)) - b*sum(lambda);
    
end
pi_st = pi_st(1:iteration, :);
theta_st = theta_st(1:iteration, :);
ell = ell(1:iteration, :);

pi = lambda/sum(lambda);