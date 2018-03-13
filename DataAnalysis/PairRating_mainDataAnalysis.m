% Analyse pair-wise rating resutls to get a single perceptual rating score.


% pi_em is the final perceptual score
clear all; close all; 
clc;

workDir = pwd;
cd('../..');
cd('functions');
if (~isempty(strfind(path,pwd))) == 0 
   addpath(genpath(pwd));
   savepath;
end

cd ('..');


% prepare the data

% Define subject
curDir  = pwd;
defaultSbj = 'wb';
theSbj = input(sprintf('Enter subject name [%s]: ', defaultSbj), 's');
if (isempty(theSbj))
    theSbj = defaultSbj;
end

subjects ={theSbj};
subjectDir = theSbj;


% Define experiment
defaultExpt = 'Bend_No_Flag';
exptName = input(sprintf('Enter experiment name [%s]: ', defaultExpt), 's');
if (isempty(exptName))
    exptName = defaultExpt;
end

dataDir = ['Experiment/',exptName,'/','resultsFolder/'];
stimDir = ['Experiment/',exptName,'/','Bend_No_Flag_Stim/'];
sbjDataDir = ['Experiment/',exptName,'/','ResultsFolder','/',subjectDir];


% Define Number of stimuli: nConds
defaultnConds = 3;
nConds = input('How many stimuli in this condition (default 3)?\n');
if (isempty(nConds))
    nConds = defaultnConds;
end

nTrials = nchoosek(nConds,2);



% load all the data
cd(dataDir)
cd(subjectDir)
filenameroot = [theSbj,'*.txt'];
dataFileNames = dir(filenameroot);  % Number of blocks 
for i = 1:length(dataFileNames)
    filename = dataFileNames(i).name;
    theSubjectData{i,:} = ReadStructsFromText(filename); 
end
cd(curDir)

%% genreate the confusion matrix, a n by n matrix containing how many times left fabric is judged 
% more stiff than the right fabric.
wm = zeros(defaultnConds,defaultnConds);
ranking = zeros(defaultnConds,1);
for n = 1: length(theSubjectData)
    for i = 1:length(theSubjectData{n})
        res=(theSubjectData{n}(i).response)-4;
        stimname1 = theSubjectData{n}(i).stim1;
        if stimname1(5)~='_'
            trialstim1=str2double(stimname1((5:6)));
        else
            trialstim1=str2double(stimname1(6));
        end
        
        stimname2 = theSubjectData{n}(i).stim2;
        if stimname2(5)~='_'
            trialstim2=str2double(stimname2((5:6)));
        else
            trialstim2=str2double(stimname2(6));
        end
      
        if res>0
            wm(trialstim2,trialstim1) =  wm(trialstim2,trialstim1) + res;
            ranking(trialstim2) = ranking(trialstim2)+res;
        else
            wm(trialstim1,trialstim2) =  wm(trialstim1,trialstim2) - res; 
            ranking(trialstim1) = ranking(trialstim1)-res;
        end 
    end
end

figure1=figure;
imagesc(wm)
colormap(gray);
colorbar
output = [exptName(1:4),'_',theSbj,'Matrix.eps'];
cd('Output') 
cd('MainOutput')
print(figure1,'-r300','-depsc2',output);
cd(curDir)
%%
% transform the pair-rating to ranking
a = 5;
prec = 1e-8;
N_Gibbs = 1000;
N_burn = 100;
[pi_em, junk, ell] = btem(wm, a, prec);
figure2=figure('name', 'logposterior_EM');
plot(ell)
xlabel('Iterations')
ylabel('Log posterior')
output = [exptName(1:4),'_',theSbj,'logposterior_EM.eps'];
cd('Output') 
cd('MainOutput')
print(figure2,'-r300','-depsc2',output);
cd(curDir)

%%
figureh = figure;
% Not display the plot
% set(figureh, 'visible','off');
[value, index]=sort(pi_em);


plot(pi_em(1:defaultnConds),'bo-');

% The following code is used to analyze our data of SAP 2016
%plot(pi_em(1:7),'go-');
%hold on
%plot(pi_em(8:14),'ro-');
%hold on
%plot(pi_em(15:21),'ko-');
%hold on
%plot(pi_em(22:28),'bo-');
%axis([1 7 0 0.15])


xlabel('Physical Score')
ylabel('Perceptual Score')
title('2D embedding sized by values in bs');
%legend('wind 250','wind 350','wind 450','wind 550')
output = [exptName(1:4),'_',theSbj,'_ranking.eps'];
cd('Output') 
cd('MainOutput/IndividualOutput')
print(figureh,'-r300','-depsc2',output);
cd(curDir)



