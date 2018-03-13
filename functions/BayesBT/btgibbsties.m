function [pi_st, theta_st, a_st, stats] = btgibbsties(w, t, a, N_Gibbs, N_burn)

%
% BTGIBBSTIES runs a Gibbs sampler for the Bradley-Terry model with ties
%   [pi_st, theta_st, a_st, stats] = BTGIBBSTIES(w, t, a, N_Gibbs, N_burn)
%
% Requires the statistics toolbox
%--------------------------------------------------------------------------
% INPUTS
%   - w:    K*K matrix of integers
%           w(i,j) is the number of times i beats j
%   - t:    K*K matrix of integers
%           t(i, j) is the number of times i ties j - t is symmetric
%   - a 	Scalar. shape parameter for the gamma prior (default a = 1)
%           If a<0, then it is estimated with a vague prior
%   - N_Gibbs: Number of Gibbs iterations
%   - N_burn: Number of burn-in iterations
%
% OUTPUTS
%   - pi_st Matrix with values of the normalized skills at each iteration
%   - theta_st gives the values of the tie parameter at each iteration
%   - a_st gives the values of the shape parameter at each iteration
%   - stats is a structure with some summary statistics on the parameters
%
% See also TEST_BT, BTGIBBS, BTGIBBSHOME, BTGIBBSHOMETIES
%--------------------------------------------------------------------------
% EXAMPLE
% w = [0, 2, 1;
%     1, 0, 1;
%     4, 5, 0];
% t = [0, 3, 1;
%     3, 0, 0;
%     1, 0, 0];
% a = 5;
% N_Gibbs = 1000;
% N_burn = 100;
% [pi_st, theta_st, a_st, stats] = btgibbsties(w, t, a, N_Gibbs, N_burn);
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
lambda = ones(K, 1);

pi_st = zeros(N_Gibbs, K, 'single');
theta_st = zeros(N_Gibbs, 1);
a_st = zeros(N_Gibbs, 1);

s = w + t; 
ak = a + sum(s, 2);

[ind_i, ind_j, s_sparse] = find(s);
T = full(sum(sum(t)))/2;
theta = 1.5;

iteration = 1; 
pi_st(iteration, :) = lambda/sum(lambda);
for i=1:N_Gibbs
    % Additional step for mixing (not necessary)
    lambda = lambda/sum(lambda)*gamrnd(K*a, 1/b);
    
    % Sample the latent Z given (lambda,theta)
    Z = sparse(ind_i, ind_j, gamrnd(s_sparse, 1./(lambda(ind_i)+theta*lambda(ind_j))), K, K);
    
    % Sample lambda given (Z,theta)
    bk = b + sum(Z, 2) + theta*sum(Z)';
    lambda = gamrnd(ak, 1./bk);

    % Sample theta with a Metropolis-Hastings step
    theta_new = normrnd(theta, .1); % proposal
    if theta_new>1
        temp = lambda'*sum(Z)';
        lograte = full( T*log(theta_new^2-1) - theta_new*temp...
            -T*log(theta^2 - 1) + theta*temp);
        if rand<exp(lograte) % If accept
            theta = theta_new;
        end
    end
        
    if estimate_a
        % Sample a with a Metropolis-Hastings step
        anew = exp(.1*randn) * a;
        lograte = K * (gammaln(a) - gammaln(anew)) + (anew - a)*(K*log(b) + sum(log(lambda)));
        if rand<exp(lograte)
            a = anew;
        end
   end  
    
    % Store outputs    
    pi_st(i, :) = lambda/sum(lambda);
    theta_st(i, :) = theta;  
    a_st(i) = a;
end

% Get some summary statistics
stats.pi_mean = mean(pi_st(N_burn+1:N_Gibbs, :))';
stats.pi_std = std(pi_st(N_burn+1:N_Gibbs, :))';
stats.theta_mean = mean(theta_st(N_burn+1:N_Gibbs, :));
stats.theta_std = std(theta_st(N_burn+1:N_Gibbs, :));
stats.a_mean = mean(a_st(N_burn+1:N_Gibbs, :));
stats.a_std = std(a_st(N_burn+1:N_Gibbs, :));