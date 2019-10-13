[![GitHub issues](https://img.shields.io/github/issues/Naereen/StrapDown.js.svg)](https://github.com/BumbleBee0819/PsychophysicsExperiment_PairedComparison/issues/)
[![Matlab](https://img.shields.io/badge/language-Matlab-red.svg)]()
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
![Total visitor](https://visitor-count-badge.herokuapp.com/total.svg?repo_id=paired_comparison)
![Visitors in today](https://visitor-count-badge.herokuapp.com/today.svg?repo_id=paired_comparison)



# In-lab Psychophysics Experiment: Paired Comparison
This folder contains the codes for conducting the in-lab paired comparison experiment and analyzing the data. We used these codes in our paper [Perceptual constancy of mechanical properties of cloth under variation of external forces
](https://dl.acm.org/citation.cfm?id=2931016). Codes in this repository are supposed to work as a template such that they should work for all paired comparison experiments with little modifications. See the project page [here](https://sites.google.com/site/wenyanbi0819/website-builder/sap16?authuser=0).

## Dependencies
The codes are written in Matlab. Codes in [Experiment](https://github.com/BumbleBee0819/PsychophysicsExperiment_PairedComparison/tree/master/Experiment) requires the [Psychtoolbox](http://psychtoolbox.org/credits/). Codes in [DataAnalysis](https://github.com/BumbleBee0819/PsychophysicsExperiment_PairedComparison/tree/master/DataAnalysis) requires the [BayesBT packages](http://www.stats.ox.ac.uk/~caron/code/bayesbt/index.html).

## References
If you use the codes, please cite the following papers.
```
1. Bi, W., Xiao, B., Jain, E., & Joerg, S. (2016, July). Perceptual constancy of mechanical properties of cloth under variation of external forces. In SAP (pp. 19-23).
2. Brainard, D. H., & Vision, S. (1997). The psychophysics toolbox. Spatial vision, 10, 433-436.
3. Pelli, D. G. (1997). The VideoToolbox software for visual psychophysics: Transforming numbers into movies. Spatial vision, 10(4), 437-442.
4. Kleiner, M., Brainard, D., Pelli, D., Ingling, A., Murray, R., & Broussard, C. (2007). What’s new in Psychtoolbox-3. Perception, 36(14), 1.
5. Caron, F., & Doucet, A. (2012). Efficient Bayesian inference for generalized Bradley–Terry models. Journal of Computational and Graphical Statistics, 21(1), 174-196.
```

## Usage
1. The experimental design is explained in [our paper](https://s3.amazonaws.com/academia.edu.documents/45589177/SAP_Wenyan_BeiXiao_Final_0512.pdf?AWSAccessKeyId=AKIAIWOWYYGZ2Y53UL3A&Expires=1506548175&Signature=%2BQ2eE17YiLQy0BIo3%2BSwmlllD9o%3D&response-content-disposition=inline%3B%20filename%3DPerceptual_Constancy_of_Mechanical_Prope.pdf).

<div class="image12">
    <p align="center">Experimental Interface</strong></p>
    <img src="https://github.com/BumbleBee0819/PsychophysicsExperiment_PairedComparison/blob/master/Experiment/Parameter%20Explanation/Experiment%20Interface.png" style="float:left">
</div>


2. To run the experiment, you need run the codes in [Experiment](https://github.com/BumbleBee0819/PsychophysicsExperiment_PairedComparison/tree/master/Experiment) with the following order:
   1. [GetParameters_PairedComparison.m](https://github.com/BumbleBee0819/PsychophysicsExperiment_PairedComparison/blob/master/Experiment/GetParameters_PairedComparison.m): This code must be run in the first place. It will generate all parameters for your display screen. You could check [here](https://github.com/BumbleBee0819/PsychophysicsExperiment_PairedComparison/tree/master/Experiment/Parameter%20Explanation) for the explanation of all parameters in this code.
   2. [GenerateConditionFil.m](https://github.com/BumbleBee0819/PsychophysicsExperiment_PairedComparison/blob/master/Experiment/GenerateConditionFil.m): This code will generate all condition files that are used in the experiment. For example, if you have 4 video stimuli, this code will generate [6 combinations](http://mathworld.wolfram.com/Combination.html) and randomize the presentation order of them. The generated condition file will be stored in different folders for [each participant](https://github.com/BumbleBee0819/PsychophysicsExperiment_PairedComparison/blob/master/Experiment/Bend_No_Flag/resultsFolder/wb/conditionOrderNewBend_No_Flagnew_1.txt).
   3. [ExperimentMainProcedure_SAP2016.m](https://github.com/BumbleBee0819/PsychophysicsExperiment_PairedComparison/blob/master/Experiment/ExperimentMainProcedure_SAP2016.m): After finishing the above two steps, execute this code to run the experiment. The collected data will be stored in different folders for [each participant](https://github.com/BumbleBee0819/PsychophysicsExperiment_PairedComparison/tree/master/Experiment/Bend_No_Flag/resultsFolder).
   
3. We provided codes for two types of [data analysis](https://github.com/BumbleBee0819/PsychophysicsExperiment_PairedComparison/tree/master/DataAnalysis).
   1. [PairRating_mainDataAnalysis.m](https://github.com/BumbleBee0819/PsychophysicsExperiment_PairedComparison/blob/master/DataAnalysis/PairRating_mainDataAnalysis.m): This code analyzed the data using [Bradley–Terry models](http://www.tandfonline.com/doi/full/10.1080/10618600.2012.638220). This code will generate the single perceptual score AND plot the perceptual score against the ground truth (individual plotting). [group_plot.m](https://github.com/BumbleBee0819/PsychophysicsExperiment_PairedComparison/blob/master/DataAnalysis/group_plot/group_plot.m) will do the group plotting. The output will be stored in [here](https://github.com/BumbleBee0819/PsychophysicsExperiment_PairedComparison/tree/master/Output/MainOutput).
   2. [LinearRegression_logparameter.m](https://github.com/BumbleBee0819/PsychophysicsExperiment_PairedComparison/blob/master/DataAnalysis/linear_logParameter/LinearRegression_logparameter.m): This code will do the regression plot of perceptual score v.s. the ground truth. The output will be stored in [here](https://github.com/BumbleBee0819/PsychophysicsExperiment_PairedComparison/tree/master/Output/Regression).
  
## Contact
If you have any questions, please contact "wb1918a@american.edu".
   
   

 
