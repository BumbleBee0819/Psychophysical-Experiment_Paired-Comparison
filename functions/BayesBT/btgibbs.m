function [pi_st, a_st, stats] = btgibbs(w, a, N_Gibbs, N_burn)

%
% BTGIBBS runs a Gibbs sampler for the Bradley-Terry model
%   [pi_st, a_st, stats] = BTGIBBS(w, a, N_Gibbs, N_burn)
%
% Requires the statistics toolbox
%--------------------------------------------------------------------------
% INPUTS:
%   - w:    K*K matrix of integers
%           w(i,j) is the number of times i beats j
%   - a 	Scalar. shape parameter for the gamma prior (default a = 1)
%           If a<0, then it is estimated with a vague prior
%   - N_Gibbs: Number of Gibbs iterations
%   - N_burn: Number of burn-in iterations
%
% OUTPUTS
%   - pi_st Matrix with values of the normalized skills at each iteration
%   - a_st gives the values of the shape parameter at each iteration
%   - stats is a structure with some summary statistics on the parameters
%
% See also TEST_BT, BTGIBBSTIES, BTGIBBSHOME, BTGIBBSHOMETIES
%--------------------------------------------------------------------------
% EXAMPLE
% w = [0, 2, 1;
%     1, 0, 1;
%     4, 5, 0];
% a = 5;
% N_Gibbs = 1000;
% N_burn = 100;
% [pi_st, a_st, stats] = btgibbs(w, a, N_Gibbs, N_burn);
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
if a<0 
    estimate_a = true;
    a = 1;
else
    estimate_a = false;
end
b = K*a - 1;

lambda = ones(K, 1);%btmm(w);
pi_st = zeros(N_Gibbs, K);
a_st = zeros(N_Gibbs, 1);

N = w+w'; % Number of comparisons between i and j
N = triu(N, 1);
ak = a + sum(w, 2);

if nargin<5
    N_burn = 1;
end

[ind_i, ind_j, N_sparse] = find(N);


pi_st(1, :) = lambda/sum(lambda);
a_st(1, :) = a;

for i=1:N_Gibbs    
    % Additional step for mixing on the scaling parameter (not necessary)
    lambda = lambda/sum(lambda)*gamrnd(K*a, 1/b);

    % Sample the latent variables Z|lambda
    Z = sparse(ind_i, ind_j, gamrnd(N_sparse,1./(lambda(ind_i)+lambda(ind_j))), K, K);
    
    % Sample the skill rating parameters lambda|Z
    bk = b + sum(Z)' + sum(Z, 2);
    lambda = gamrnd(ak, 1./bk);
    
    if estimate_a
        % Sample a with a Metropolis-Hastings step
        anew = exp(.1*randn) * a;
        lograte = K * (gammaln(a) - gammaln(anew)) + (anew - a)*(K*log(b) + sum(log(lambda)));
        if rand<exp(lograte)
            a = anew;
        end
   end  
    
    pi_st(i, :) = lambda/sum(lambda);
    a_st(i) = a;
end

% Get some summary statistics
stats.pi_mean = mean(pi_st(N_burn+1:N_Gibbs, :))';
stats.pi_std = std(pi_st(N_burn+1:N_Gibbs, :))';
stats.a_mean = mean(a_st(N_burn+1:N_Gibbs, :))';
stats.a_std = std(a_st(N_burn+1:N_Gibbs, :))';