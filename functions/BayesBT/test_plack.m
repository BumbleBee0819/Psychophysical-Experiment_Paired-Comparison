%
% TEST_PLACK tests inference algorithms for the Plackett-Luce model
%--------------------------------------------------------------------------

close all
clear all

% Race 1: 1 - 2 - 3 
% Race 2: 2 - 1 - 3
% Race 3: 1 - 2 - 3
X = [
    1   1   1;
    2   1   2;
    3   1   3;
    2   2   1;
    1   2   2;
    3   2   3;
    1   3   1;
    2   3   2;
    3   3   3];

a = 5;
prec = 1e-8;

%% EM algorithm
[pi_em, junk, ell] = plackem(X, a, prec);
pi_em
figure('name', 'EM Plackett-Luce')
plot(ell)
xlabel('Iterations')
ylabel('Log-posterior')


%% Gibbs sampler
N_Gibbs = 1000;
N_burn = 100;
[pi_gibbs, a_gibbs, stats]  = plackgibbs(X, a, N_Gibbs, N_burn); 
stats.pi_mean