function [pi_st, a_st, stats] = plackgibbs(X, a, N_Gibbs, N_burn, K)

%
% PLACKGIBBS runs a Gibbs sampler for the Plackett-Luce model
%   [pi_st, a_st, stats] = PLACKGIBBS(X, a, N_Gibbs, N_burn, K)
%
% Requires the Statistics toolbox
%--------------------------------------------------------------------------
% INPUTS:
%   - X:    Nx3, where each row contains
%           Column 1:  individual ID (1 through K)
%           Column 2:  contest ID (1 through n)
%           Column 3:  rank 
%   - a:    Scalar 
%           If a>0, it gives the shape parameter for the gamma prior
%           If a<0, the parameter is estimated with a vague prior and  
%           (-a) gives the starting value
%   - N_Gibbs: Number of iterations of the Gibbs Sampler
%   - N_burn: Number of burn-in iterations
%   - K:     Integer. Total number of individuals to be ranked 
%           (might be higher than the number of individuals in X)
%
% OUTPUTS:
%   - pi_st: N_Gibbs*K matrix
%           with the normalized skill ratings parameters at each iteration
%   - a_st: Vector of length N_Gibbs with the hyperparameter a at each iteration
%   - stats is a structure which returns some summary statistics
%           pi_mean, pi_std: mean and standard deviation for pi
%           a_mean, a_std: mean and std for a
%
% See also PLACKEM, TEST_PLACK
%--------------------------------------------------------------------------
% EXAMPLE
% X = [1   1   1;  2   1   2; 3   1   3; 2   2   1; 1   2   2; 3   2   3];
% a = 5; N_Gibbs = 1000; N_burn = 100;
% [pi_gibbs, a_gibbs, stats]  = plackgibbs(X, a, N_Gibbs, N_burn); 
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

b = 1; % Any positive value
if a<0 
    estimate_a = true;
    a = -a;
else
    estimate_a = false;
end

if nargin<5     
    K = max(X(:,1));  % K = total # of individuals
elseif K<max(X(:,1))
    K = max(X(:,1));  % K = total # of individuals
end
n = max(X(:,2)); % N = total # of contests
P = max(X(:,3));  % P = largest # of individuals per contest

rho = zeros(n, P); % rho(i,j) = individual who places j in race i
rho2 = zeros(n, K); % rho2(i,j) = place of individual j in race i

for i=1:size(X,1) 
   rho(X(i,2), X(i,3)) = X(i,1);
   rho2(X(i,2), X(i,1)) = sub2ind([n, P], X(i,2), X(i,3));%X(i,3) + P*(X(i,2)-1);
end
% r2=r;

pi_st = zeros(N_Gibbs, K);
a_st = zeros(N_Gibbs, 1);

w = zeros(K, 1); % w(i) = # times i placed higher than last
p = sum(rho>0, 2); % p(i) = # individuals in race i

for i=1:n
   tmp = rho(i, 1:(p(i)-1));
   w(tmp) = 1+w(tmp);
end

pp = sub2ind([n, P], 1:n, p'); % Indices in rho of lastplace finishers
% pause

lambda = ones(K,1); % (unscaled) initial lambda vector
pi_st(1, :) = lambda/sum(lambda);

% Gibbs sampler
for i=1:N_Gibbs
   S = zeros(size(rho));
   S(rho>0) = lambda(rho(rho>0));
   S = cumsum(S(:, P:-1:1), 2);
   S = S(:, P:-1:1);
   S(pp) = 0; % Remove elements at the last place
   S(S>0) = 1./S(S>0);  
   %  S(i,j) = ( \sum_{k=j}^{p(i)} lambda_{rho(i,j)} )^-1 
   % for i=1,...,n and j = 1,...,p(i)-1
   
   Z = zeros(size(S));
   Z(S>0) = exprnd(S(S>0));
   
   S2 = cumsum(Z, 2);
   %  S2(i,j) = \sum_{k=1}^{j} Z(i,j) 
   % for i=1,...,n and j = 1,...,p(i)-1
   
   r2 = zeros(n, K);
   r2(rho2>0) = S2(rho2(rho2>0));
   % Here r2(k, i) = \sum_{j=1}^{p(i)-1} \delta_{i,j,k} Z(i,j)
   sr2 = sum(r2)';   
   
   lambda = gamrnd(a + w, 1./(b + sr2));
   lambda(isnan(lambda)) = 0;
   
   if estimate_a
        % Sample a with a Metropolis-Hastings step
        % Flat prior on a
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
stats.a_mean = mean(a_st(N_burn+1:N_Gibbs, :));
stats.a_std = std(a_st(N_burn+1:N_Gibbs, :));