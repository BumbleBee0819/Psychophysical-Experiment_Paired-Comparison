%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MainExperiment.m for fabric tactile visual experiment.
%
% This code can call different types of experiments, including
% paired-comparison and scaling. 
%

%==================== Initialization =====================================%
clc;clear all;

%Screen ('Preference','SkipSyncTests',1);
%% Initial Setup
% get function path
curDir=(pwd);
cd ('..');
cd('functions');
if (~isempty(strfind(path,pwd))) == 0 
   addpath(genpath(pwd));
   savepath;
end
cd(curDir);


% get psychtoolbox path
addpath(genpath('/Applications/Psychtoolbox'));

% Check for Opengl compatibility, abort otherwise:
AssertOpenGL;

% Initializing sound
% Reseed the random-number generator for each expt.
rand('state', sum(100 * clock));

% Make sure keyboard mapping is the same on all supported operating systems
% Apple MacOS/X, MS-Windows and GNU/Linux:
KbName('UnifyKeyNames');

% Init keyboard responses (caps doesn't matter)
%advancestudytrial = KbName('n');
% Anytime during the experiment, press 'e' to quit.
targetexitname = 'e';
targetcontinuename = 'c';

% target key for exit and continue
targetexit = KbName(targetexitname);
targetcontinue = KbName(targetcontinuename);

%% =============================== Input ===================================%

% Define subject
defaultSbj = 'wb';
theSbj = input(sprintf('Enter subject name [%s]: ', defaultSbj), 's');
if (isempty(theSbj))
    theSbj = defaultSbj;
end

% Define experiment
defaultExpt = 'Bend_No_Flag';
exptName = input(sprintf('Enter experiment name [%s]: ', defaultExpt), 's');
if (isempty(exptName))
    exptName = defaultExpt;
end
% 

% Ask for the block name.
defaultBlock= '1'; % Block 1-5
blockNumber = input(sprintf('Which number of block to run [%s]: ',defaultBlock),'s');
if(isempty(blockNumber))
    blockNumber = defaultBlock; 
end
blockNumber = str2num(blockNumber); %#ok<ST2NM>


% change the condition file name based on experiment.
% change the stim folder name based on experiment name.
switch exptName
    case 'Bend_No_Flag'
        stimFileRoot = ['conditionOrderNewBend_No_Flagnew','_',num2str(blockNumber)];
        stimFolder  = 'Bend_No_Flag_Stim';
    case 'Mass_No_Flag'
        stimFileRoot = ['conditionOrderNewMass_No_Flagnew','_',num2str(blockNumber)];
        stimFolder  = 'Mass_No_Flag_Stim';   
    case 'Bend_Flag'
        stimFileRoot = ['conditionOrderNewBend_Flagnew','_',num2str(blockNumber)];
        stimFolder  = 'Bend_Flag_Stim';
    case 'Mass_Flag'
        stimFileRoot = ['conditionOrderNewMass_Flagnew','_',num2str(blockNumber)];
        stimFolder  = 'Mass_Flag_Stim'; 
    case 'Mass_Matte'
        stimFileRoot = ['conditionOrderNewMass_Mattenew','_',num2str(blockNumber)];
        stimFolder  = 'Mass_Matte_Stim';
    case 'Mass_Shinny'
        stimFileRoot = ['conditionOrderNewMass_Shinnynew','_',num2str(blockNumber)];
        stimFolder  = 'Mass_Shinny_Stim';
    case 'Bend_Matte'
        stimFileRoot = ['conditionOrderNewBend_Mattenew','_',num2str(blockNumber)];
        stimFolder  = 'Bend_Matte_Stim';
    case 'Bend_Shinny'
        stimFileRoot = ['conditionOrderNewBend_Shinnynew','_',num2str(blockNumber)];
        stimFolder  = 'Bend_Shinny_Stim';
    otherwise
         %fprintf('Error! Create Stimuli Folder First!!\n');
        error ('Stimuli folder not found, create Stimuli Folder First!!')
end
        
conditionNameRoot = 'vid_';  

%=========================== File handling ===============================%
% Reseed the random-number generator for each expt.
% Define filenames of input files and result file:
curDir = pwd;
rootDir = curDir;
exptDir = fullfile(rootDir, exptName);
stimDir = fullfile(exptDir, stimFolder);
dataDir = fullfile(exptDir, 'resultsFolder');
subjectDir = fullfile(dataDir, theSbj);
%setDir = fullfile(exptDir, setName);
%setFile = fullfile(setDir, sprintf('%s_%s', exptName, setName));


%=== Read condition file information. This part needs to be modified. ====%
if (~exist(exptDir, 'dir'))
    mkdir(exptDir);
end
if (~exist(stimDir, 'dir'))
    mkdir(stimDir);
end
if (~exist(dataDir, 'dir'))
    mkdir(stimDir);
end
if (~exist(subjectDir, 'dir'))
    mkdir(subjectDir);
end

testFileName = fullfile(subjectDir, [stimFileRoot,'.txt'])
fprintf('using condition file,%s\n',testFileName);

conditionStruct = ReadStructsFromText(testFileName)
nConditions = length(conditionStruct);
expDate = date;
expTime = clock;

taskName = 'PairedComparison_1';
save('SAP2016_Path.mat');



% Run experiments
PairedComparison;



