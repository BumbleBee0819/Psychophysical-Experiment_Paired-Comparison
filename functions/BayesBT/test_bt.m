%
% TEST_BT tests EM and Gibbs algorithms for the Bradley-Terry models
% (classical, with ties, with ties and home advantage)
%--------------------------------------------------------------------------

close all
clear all

a = 5;
prec = 1e-8;
N_Gibbs = 1000;
N_burn = 100;


%%  Bradley-Terry
%%%%%%%%%%%%%%%%%%
w = [0, 2, 1;
    1, 0, 1;
    4, 5, 0];
% EM
[pi_em, junk, ell] = btem(w, a, prec);
figure('name', 'logposterior EM');
plot(ell)
xlabel('Iterations')
ylabel('Log posterior')

%%
% Gibbs with hyperparameter a fixed
[pi_st, a_st, stats] = btgibbs(w, a, N_Gibbs, N_burn);
stats.pi_mean
% Gibbs with hyperparameter a estimated
[pi_st, a_st, stats] = btgibbs(w, -1, N_Gibbs, N_burn);
stats.pi_mean
stats.a_mean

%% Bradley-Terry with ties
%%%%%%%%%%%%%%%%%%%%%%%%%%
w = [0, 2, 1;
    1, 0, 1;
    4, 5, 0];
t = [0, 3, 1;
    3, 0, 0;
    1, 0, 0];

% EM
a_th = 2;
b_th = 1;
[pi_em, theta_em, junk, junk, ell] = btemties(w, t, a, prec, a_th, b_th);
pi_em
theta_em
figure('name', 'logposterior EM ties');
plot(ell)
xlabel('Iterations')
ylabel('Log posterior')

%%
% Gibbs with hyperparameter a fixed
[pi_st, theta_st, a_st, stats] = btgibbsties(w, t, a, N_Gibbs, N_burn);
stats.pi_mean
stats.theta_mean

% Gibbs with hyperparameter a estimated
[pi_st, theta_st, a_st, stats] = btgibbsties(w, t, -1, N_Gibbs, N_burn);
stats.pi_mean
stats.theta_mean
stats.a_mean

%% Bradley-Terry with home advantage
%%%%%%%%%%%%%%%%%%%%%%%%%%
wh = [0, 2, 1;
    1, 0, 1;
    4, 5, 0];
lh = [0, 3, 1;
    3, 0, 0;
    1, 0, 0];
% EM
a_th = 2;
b_th = 1;
[pi_em, theta_em, junk, junk, ell] = btemhome(wh, lh, a, prec, a_th, b_th);
pi_em
theta_em
figure('name', 'logposterior EM home advantage');
plot(ell)
xlabel('Iterations')
ylabel('Log posterior')

% Gibbs with hyperparameter a fixed
[pi_st, theta_st, a_st, stats] = btgibbshome(wh, lh, a, N_Gibbs, N_burn);
stats.pi_mean
stats.theta_mean

% Gibbs with hyperparameter a estimated
[pi_st, theta_st, a_st, stats] = btgibbshome(wh, lh, -1, N_Gibbs, N_burn);
stats.pi_mean
stats.theta_mean
stats.a_mean

%% Bradley-Terry with home advantage and ties
%%%%%%%%%%%%%%%%%%%%%%%%%%
% EM
[pi_em, theta_em,alpha_em, junk, junk, junk, ell] = btemhometies(wh, lh, t, a, prec);
figure('name', 'logposterior EM home advantage + ties');
plot(ell)
xlabel('Iterations')
ylabel('Log posterior')


% Gibbs with hyperparameter a fixed
[pi_st, theta_st, alpha_st, a_st, stats] = btgibbshometies(wh, lh, t, a, N_Gibbs, N_burn);
stats.pi_mean
stats.theta_mean
stats.alpha_mean

% Gibbs with hyperparameter a estimated
[pi_st, theta_st, alpha_st, a_st, stats] = btgibbshometies(wh, lh, t, -1, N_Gibbs, N_burn);
stats.pi_mean
stats.theta_mean
stats.alpha_mean
stats.a_mean