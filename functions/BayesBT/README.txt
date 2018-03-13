**********************************
README FILE
**********************************
SUPPLEMENTARY MATERIAL for the paper
F. Caron and A. Doucet. Efficient Bayesian inference for generalized Bradley-Terry models. Journal of Computational and Graphical Statistics,  vol. 21(1), pp. 174-196, 2012.
This archive contains Matlab/Octave routines for implementing EM and Gibbs samplers for generalized Bradley-Terry (BT) models.
Tested on Matlab 2014a with statistics toolbox and Octave 3.6.4.

Author: Francois Caron, INRIA
Copyright INRIA 2011
**********************************

The following files are available:

* btem.m
EM algorithm for the classical BT model

* btgibbs.m
Gibbs sampler for the classical BT model

* btemhome.m
EM algorithm for the BT model with home advantage

* btgibbshome.m
Gibbs sampler for the BT model with home advantage

* btemties.m
EM algorithm for the BT model with ties

* btgibbsties.m
Gibbs sampler for the BT model with ties

* btemhometies.m
EM algorithm for the BT model with ties and home advantage

* btgibbshometies.m
Gibbs sampler for the BT model with ties and home advantage

* plackem.m
EM algorithm for the Plackett-Luce model

* plackgibbs.m
Gibbs sampler for the Plackett-Luce model

One can run the following tests 

* test_bt.m
Runs all the algorithms for Bradley-Terry models with or without home advantage and ties on simple examples

* test_plack.m
Runs the EM and Gibbs algorithms for Plackett-Luce model on a simple example