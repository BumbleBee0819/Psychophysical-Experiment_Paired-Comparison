function [pi, pi_st, ell] = btem(w, a, prec)

%
% BTEM runs a EM algorithm for the Bradley-Terry model
% 	[pi, pi_st, ell] = BTEM(w, a, prec)
%--------------------------------------------------------------------------
% INPUTS:
%   - w:    K*K matrix of integers
%           w(i,j) is the number of times i beats j
%   - a 	Scalar. shape parameter for the gamma prior (default a = 1)
%           If a<0, then it is estimated with a vague prior
%   - prec 	Precision of the EM (default = 1e-8)
%
% OUTPUTS:
%   - pi is the MAP estimate of the normalized skill parameters
%   - pi_st gives the values of the normalized skills at each iteration
%   - ell is the log posterior at each iteration
%
%  See also TEST_BT, BTEMHOME, BTEMTIES, BTEMHOMETIES
%--------------------------------------------------------------------------
% EXAMPLE
%a = 5; prec = 1e-8;
% w = [0, 2, 1;
%     1, 0, 1;
%     4, 5, 0];
% [pi, pi_st, ell] = btem(w, a, prec);
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



% wij denote the number of comparisons where i beats j, wi = sum(j,k;j!=i)wij,
% wij total number of winds of element i
% nij=wij+wji total number of comparisons between i and j
K = size(w, 1);
b = K*a - 1;
lambda = ones(K, 1);
iter_max = 5000;
pi_st = zeros(iter_max, K);
ell = zeros(iter_max, 1);

N = w + w'; % Number of comparisons between i and j
ak = a - 1 + sum(w, 2);
change = realmax;

[ind_i, ind_j, N_sparse] = find(N);

if nargin<4
    prec = 1e-8;
end

iteration = 1; 
pi_st(1, :) = lambda/sum(lambda);
temp = sparse(ind_i, ind_j, N_sparse./(lambda(ind_i)+lambda(ind_j)), K, K);
ell (iteration) = ak' * log(lambda) - b*sum(lambda) - sum(sum(temp));
while norm(change)>prec  && iteration<iter_max  
    
    iteration = iteration + 1;
    
    % E step
    temp = sparse(ind_i, ind_j, N_sparse./(lambda(ind_i)+lambda(ind_j)), K, K);
    bk = b + sum(temp)';
    
    % M step
    lambda_new = ak./bk;
    
    change = lambda_new/sum(lambda_new) - lambda/sum(lambda);
    lambda = lambda_new;
    pi_st(iteration, :) = lambda/sum(lambda);

    % Compute log posterior (not necessary)
    temp = sparse(ind_i, ind_j, N_sparse.*log(lambda(ind_i)+lambda(ind_j)), K, K);
    ell (iteration) = ak' * log(lambda) - b*sum(lambda) - sum(sum(temp));
end

pi_st = pi_st(1:iteration, :);
ell = ell(1:iteration, 1);
pi = lambda/sum(lambda);

