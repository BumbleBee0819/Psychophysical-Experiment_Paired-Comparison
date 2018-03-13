function [pi, pi_st, ell] = plackem(X, a, prec, K)

%
% PLACKEM runs an EM algorithm for Plackett-Luce models
% [pi, pi_st, ell] = plackem(X, a, prec, K)
%
%--------------------------------------------------------------------------
% INPUTS:
%   - X:    Nx3 matrix, where each row contains
%           Column 1:  individual ID (1 through K)
%           Column 2:  contest ID (1 through n)
%           Column 3:  rank 
%   - a:    Positive scalar. Shape parameter for the gamma prior (Default=1)
%   - prec: Precision in the EM (Default=1e-8)
%   - K: 	Integer. Total number of individuals to be ranked 
%           (optional, might be higher than the number of individuals in X)
%
% OUTPUTS:
%   - pi: 	MAP estimate of the normalized skill parameters%
%   - pi_st: Matrix with the normalized skill ratings parameters at each iteration
%   - ell:  Log posterior at each iteration
%
% See also PLACKGIBBS, TEST_PLACK
%--------------------------------------------------------------------------
% EXAMPLE
% X = [1   1   1;  2   1   2; 3   1   3; 2   2   1; 1   2   2; 3   2   3];
% a = 5; 
% [pi_em, ~, ell] = plackem(X, a);
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

if nargin<3
    prec = 1e-8;
    if nargin<2
        a = 1; % Corresponds to MLE estimate
    end
end
if a<0
    error('Scale parameter a has to be positive');
end

if nargin<4     
    K = max(X(:,1));  % K = total # of individuals
elseif K<max(X(:,1))
    K = max(X(:,1));  % K = total # of individuals
end
n = max(X(:,2)); % N = total # of contests
P = max(X(:,3));  % P = largest # of individuals per contest

b = K*a - 1;

iter_max = 10000;
pi_st = zeros(iter_max, K);
ell = zeros(iter_max, 1);

rho = zeros(n, P); % rho(i,j) = individual who places j in race i
rho2 = zeros(n, K); % rho2(i,j) = place of individual j in race i

for i=1:size(X,1) 
   rho(X(i,2), X(i,3)) = X(i,1);
   rho2(X(i,2), X(i,1)) = sub2ind([n, P], X(i,2), X(i,3));%X(i,3) + P*(X(i,2)-1);
end

w = zeros(K, 1); % w(i) = # times i placed higher than last
p = sum(rho>0, 2); % p(i) = # individuals in race i

for i=1:n
   tmp = rho(i, 1:(p(i)-1));
   w(tmp) = 1+w(tmp);
end

pp = sub2ind([n, P], 1:n, p'); % Indices in rho of lastplace finishers

lambda = 1/K*ones(K,1); % initial lambda vector
pi_st(1, :) = lambda/sum(lambda);

dlambda = 1;
iterations = 1;
while norm(dlambda)>prec  && iterations<iter_max  
   iterations = iterations+1;
   
   S = zeros(size(rho));
   S(rho>0) = lambda(rho(rho>0));
   S = cumsum(S(:, P:-1:1), 2);
   S = S(:, P:-1:1);
   S(pp) = 0; % Remove elements at the last place
   S(S>0) = 1./S(S>0);  
   %  S(i,j) = ( \sum_{k=j}^{p(i)} lambda_{rho(i,j)} )^-1 
   % for i=1,...,n and j = 1,...,p(i)-1
   
   % To calculate the log-posterior (not necessary)
   ell(iterations - 1) = (a - 1 +w)'*log(lambda) - b*sum(lambda) ...
       + sum(sum(log(S(S>0))));
   
   S2 = cumsum(S, 2);
   %  S2(i,j) = \sum_{k=1}^{j} S(i,j) 
   % for i=1,...,n and j = 1,...,p(i)-1
 
   r2 = zeros(n, K);
   r2(rho2>0) = S2(rho2(rho2>0));
   % Here r2(k, i) = \sum_{j=1}^{p(i)-1} \delta_{i,j,k} S(i,j)
   sr2 = sum(r2)';  
   newlambda = (a-1+w) ./ (b+sr2);
   newlambda(isnan(newlambda)) = 0;

   dlambda = newlambda/sum(newlambda)-lambda/sum(lambda);
   
   lambda = newlambda;
   
   pi_st(iterations, :) = lambda/sum(lambda);
end
pi_st = pi_st(1:iterations, :);
ell = ell(1:(iterations-1));
pi = lambda/sum(lambda);