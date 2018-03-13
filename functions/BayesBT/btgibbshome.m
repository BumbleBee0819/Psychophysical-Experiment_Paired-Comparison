function [pi_st, theta_st, a_st, stats] = btgibbshome(wh, lh, a, N_Gibbs, N_burn)

%
% BTGIBBSHOME runs a Gibbs sampler for the Bradley-Terry model with home advantage
% 	[pi_st, theta_st, a_st stats] = BTGIBBSHOME(wh, lh, a, N_Gibbs,N_burn)
%
% Requires the statistics toolbox
%--------------------------------------------------------------------------
% INPUTS:
%   - wh:   K*K matrix of integers
%           wh(i,j) is the number of times i beats j at home
%   - lh:   K*K matrix of integers
%           lh(i, j) is the number of times i looses to j at home
%   - a:    Scalar. Shape parameter for the gamma prior (default a = 1)
%            If a<0, then it is estimated with a vague prior
%   - N_Gibbs: Number of Gibbs iterations
%   - N_burn: Number of burn-in iterations
%
% OUTPUTS:
%   - pi_st gives the values of the normalized skills at each iteration
%   - theta_st gives the values of the home advantage parameter at each iteration
%   - a_st gives the values of the shape parameter at each iteration
%   - stats is a structure with some summary statistics on the parameters
%
% See also TEST_BT, BTGIBBS, BTGIBBSTIES, BTGIBBSHOMETIES
%--------------------------------------------------------------------------
% EXAMPLE
% wh = [0, 2, 1;
%     1, 0, 1;
%     4, 5, 0];
% lh = [0, 3, 1;
%     3, 0, 0;
%     1, 0, 0];
% a = 5;
% N_Gibbs = 1000;
% N_burn = 100;
% [pi_st, theta_st, a_st, stats] = btgibbshome(wh, lh, a, N_Gibbs, N_burn);
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
if a<0 
    estimate_a = true;
    a = 1;
else
    estimate_a = false;
end
b = K*a - 1;

lambda = ones(K, 1);
theta = 1;

N = wh+lh; % Number of games between i and j where i is at home
ak = a + sum(wh + lh', 2);
H = sum(sum(wh)); % Total number of home-field wins

[ind_i, ind_j, N_sparse] = find(N);

pi_st = zeros(N_Gibbs, K);
theta_st = zeros(N_Gibbs, 1);
a_st = zeros(N_Gibbs, 1);
pi_st(1, :) = lambda/sum(lambda);
theta_st(1) = theta;
a_st(1) = a;

for i=1:N_Gibbs
    % Sample the latent variables Z|lambda, theta
    Z = sparse(ind_i, ind_j, gamrnd(N_sparse,1./(theta*lambda(ind_i)+lambda(ind_j))), K, K);
    
    % Sample the skill rating parameters lambda|Z, theta
    sumZ = sum(Z, 2);
    bk = b + theta* sumZ + sum(Z)';
    lambda = gamrnd(ak,1./bk);
    
    % Sample the home advantage parameter theta|lambda, Z with a flat prior
    theta = gamrnd(H, 1./ (sum( lambda.*sumZ )) );
    
    if estimate_a
        % Sample a with a Metropolis-Hastings step
        % Flat prior on a
        anew = exp(.1*randn) * a;
        lograte = K * (gammaln(a) - gammaln(anew)) + (anew - a)*(K*log(b) + sum(log(lambda)));
        if rand<exp(lograte)
            a = anew;
        end
    end  
    
    % Store outputs
    pi_st(i, :) = lambda/sum(lambda);
    theta_st(i) = theta;
    a_st(i) = a;
end

% Get some summary statistics
stats.pi_mean = mean(pi_st(N_burn+1:N_Gibbs, :))';
stats.pi_std = std(pi_st(N_burn+1:N_Gibbs, :))';
stats.theta_mean = mean(theta_st(N_burn+1:N_Gibbs, :));
stats.theta_std = std(theta_st(N_burn+1:N_Gibbs, :));
stats.a_mean = mean(a_st(N_burn+1:N_Gibbs, :));
stats.a_std = std(a_st(N_burn+1:N_Gibbs, :));
