function [pi_st, theta_st, alpha_st, a_st, stats] = btgibbshometies(w, l, t, a, N_Gibbs, N_burn)

%
% BTGIBBSHOMETIES runs a Gibbs sampler for the Bradley-Terry model with home advantage and ties
% [pi_st, theta_st, alpha_st, a_st, stats] = BTGIBBSHOMETIES(w, l, t, a, N_Gibbs, N_burn)
%
% Requires the statistics toolbox
%--------------------------------------------------------------------------
% INPUTS:
%   - w     K*K matrix of integers
%           w(i,j) is the number of times i beats j when i is at home
%   - l     K*K matrix of integers
%           l(i,j) is the number of times i looses to j when i is at home
%   - t     K*K matrix of integers
%           t(i,j) is the number of times i ties j when i is at home
%   - a 	Shape parameter for the gamma prior (default a = 1)
%           If a<0, then it is estimated with a vague prior
%   - N_Gibbs: Number of Gibbs iterations
%   - N_burn: Number of burn-in iterations
%
% OUTPUTS:
%   - pi_st gives the values of the normalized skills at each iteration
%   - theta_st gives the values of the ties parameter at each iteration
%   - alpha_st gives the values of the home advantage parameter at each iteration
%   - a_st gives the values of the shape parameter at each iteration
%   - stats is a structure with some summary statistics on the parameters
%
% See also TEST_BT, BTGIBBS, BTGIBBSHOME, BTGIBBSTIES
%--------------------------------------------------------------------------
% EXAMPLE
% w = [0, 2, 1;
%     1, 0, 1;
%     4, 5, 0];
% l = [0, 3, 1;
%     3, 0, 0;
%     1, 0, 0];
% t = [0, 3, 1;
%     3, 0, 0;
%     1, 0, 0];
% a = 5;
% N_Gibbs = 1000;
% N_burn = 100;
% [pi_st, theta_st, alpha_st, a_st, stats] = btgibbshometies(w, l, t, a, N_Gibbs, N_burn);
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
alpha_st = zeros(N_Gibbs, 1);
a_st = zeros(N_Gibbs, 1);

s1 = w + t;
s2 = l + t;
ak = a + sum(s1 + s2', 2);

[ind_i1, ind_j1, s_sparse1] = find(s1);
[ind_i2, ind_j2, s_sparse2] = find(s2);

T = full(sum(sum(t))); % Total number of ties
H = sum(s_sparse1); % Number of ties and wins at home

theta = 1.5;
alpha = 1;

pi_st(1, :) = lambda/sum(lambda);
theta_st(1) = theta;
alpha_st(1) = alpha;
a_st(1) = a;

for i=1:N_Gibbs
    % Additional step for mixing (not necessary)
    lambda = lambda/sum(lambda)*gamrnd(K*a, 1/b);
    
    % Sample the latent Z given (lambda,theta)
    Z = sparse(ind_i1, ind_j1, gamrnd(s_sparse1, 1./(alpha*lambda(ind_i1)+theta*lambda(ind_j1))), K, K);
    
    % Sample the latent U given (lambda,theta)
    U = sparse(ind_i2, ind_j2, gamrnd(s_sparse2, 1./(alpha*theta*lambda(ind_i2)+lambda(ind_j2))), K, K);
        
    % Sample lambda given (Z, U, theta, alpha)
    bk = b + sum(Z, 2) + theta*sum(Z)' + alpha*theta*sum(U, 2) + sum(U)';
    lambda = gamrnd(ak, 1./bk);
    
    % Sample alpha given (Z, U, lambda)
    alpha = gamrnd(H, 1/(lambda' * (sum(Z, 2) + theta*sum(U, 2))));

    % Sample theta given (Z, U, lambda) with a Metropolis-Hastings step
    theta_new = normrnd(theta, .1); % proposal
    if theta_new>1
        temp = lambda'*(sum(Z)' + alpha*sum(U)');
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
    alpha_st(i, :) = alpha;  
    a_st(i) = a;
end

% Get some summary statistics
stats.pi_mean = mean(pi_st(N_burn+1:N_Gibbs, :))';
stats.pi_std = std(pi_st(N_burn+1:N_Gibbs, :))';
stats.theta_mean = mean(theta_st(N_burn+1:N_Gibbs, :));
stats.theta_std = std(theta_st(N_burn+1:N_Gibbs, :));
stats.alpha_mean = mean(alpha_st(N_burn+1:N_Gibbs, :));
stats.alpha_std = std(alpha_st(N_burn+1:N_Gibbs, :));
stats.a_mean = mean(a_st(N_burn+1:N_Gibbs, :));
stats.a_std = std(a_st(N_burn+1:N_Gibbs, :));
