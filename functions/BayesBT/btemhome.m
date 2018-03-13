function [pi, theta, pi_st, theta_st, ell] = btemhome(wh, lh, a, prec, a_th, b_th)

% 
% BTEMHOME runs a EM algorithm for the Bradley-Terry model with home advantage
% 	[pi, theta, pi_st, theta_st, ell] = BTEMHOME(wh, lh, a, prec, a_th, b_th)
%--------------------------------------------------------------------------
% INPUTS:
%   - wh:   K*K matrix of integers
%           wh(i,j) is the number of times i beats j at home
%   - lh:   K*K matrix of integers
%           lh(i, j) is the number of times i looses to j at home
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
%   - theta_st gives the values of the home advantage parameter at each
%           iteration
%   - ell is the log-posterior (unnormalized) at each iteration
%
% See also TEST_BT, BTEM, BTEMHOMETIES, BTEMTIES
%--------------------------------------------------------------------------
% EXAMPLE
% wh = [0, 2, 1;
%     1, 0, 1;
%     4, 5, 0];
% lh = [0, 3, 1;
%     3, 0, 0;
%     1, 0, 0];
% a = 5; prec = 1e-8;
% a_th = 2;
% b_th = 1;
% [pi_em, theta_em, junk, junk, ell] = btemhome(wh, lh, a, prec, a_th, b_th);
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

K = size(wh, 1);
b = K*a - 1;
lambda = ones(K, 1);
iter_max = 5000;

pi_st = zeros(iter_max, K);
theta_st = zeros(iter_max, 1);
ell = zeros(iter_max, 1);


N = wh+lh; % Number of games between i and j where i is at home
ak = a - 1 + sum(wh + lh', 2);
H = sum(sum(wh)); % Total number of home-field wins
change =realmax;

[ind_i, ind_j, N_sparse] = find(N);

if nargin<4
    prec = 1e-8;
end
if nargin<5
    a_th = 1;
end
if nargin<6
    b_th = 0;
end
    
theta = 1.5;
iteration = 1; 

% log-posterior (not necessary)
Z2 = sparse(ind_i, ind_j, N_sparse.*log(theta*lambda(ind_i)+lambda(ind_j)), K, K);
ell(iteration) = (a_th - 1 + H)*log(theta) - b_th * theta...
    + log(lambda)' * (a - 1 + sum(wh + lh', 2)) - b*sum(lambda) - sum(sum(Z2));
pi_st(iteration, :) = lambda/sum(lambda);
theta_st(iteration) = theta;
while norm(change)>prec  && iteration<iter_max  
    iteration = iteration + 1;

    % E step
    Z = sparse(ind_i, ind_j, N_sparse./(theta*lambda(ind_i)+lambda(ind_j)), K, K);
        
    % Maximize w.r.t lambda
    sumZ = sum(Z, 2);
    bk = b + theta* sumZ + sum(Z)';
    lambda_new = ak./bk;
    
    % Maximize w.r.t. theta
    Z = sparse(ind_i, ind_j, N_sparse./(theta*lambda_new(ind_i)+lambda_new(ind_j)), K, K);
    sumZ = sum(Z, 2);
    theta = (a_th - 1 + H) / (b_th + sum( lambda_new.*sumZ));
    
    change = lambda_new/sum(lambda_new) - lambda/sum(lambda);
    lambda = lambda_new;
    
    pi_st(iteration, :) = lambda/sum(lambda);
    theta_st(iteration) = theta;
    
    % log-posterior (not necessary)
    Z2 = sparse(ind_i, ind_j, N_sparse.*log(theta*lambda(ind_i)+lambda(ind_j)), K, K);
    ell(iteration) = (a_th - 1 + H)*log(theta) - b_th * theta...
        + log(lambda)' * (a - 1 + sum(wh + lh', 2)) - b*sum(lambda) - sum(sum(Z2));
end
pi_st = pi_st(1:iteration, :);
theta_st = theta_st(1:iteration, 1);
ell = ell(1:iteration, 1);

pi = lambda/sum(lambda);