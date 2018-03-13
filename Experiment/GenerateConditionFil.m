% GenerateConditionFile.m
%
% This code is used to generate condition files for paired comparison experiment.
%
% Input: 1) number of conditions; 2) number of stimuli
% Output: Condition Files
%
%
% clear
clear; close all;


% Setup Path
curDir=(pwd);
cd ('..');
cd('functions');
if (~isempty(strfind(path,pwd))) == 0 
   addpath(genpath(pwd));
   savepath;
end

cd(curDir);


% Define Number of stimuli: nConds
defaultnConds = 3;
nConds = input('How many stimuli in this condition (default 3)?\n');
if (isempty(nConds))
    nConds = defaultnConds;
end


% Define Number of blocks: nBlock
defaultnBlock = 1;
nBlock= input(sprintf('There are %d trials in this experiment, you want to divide them into how many blocks (default 1)?\n', nchoosek(nConds,2)));
if (isempty(nBlock))
    nBlock = defaultnBlock;
end 


% Define subject:theSbj
defaultSbj = 'wb';
theSbj = input(sprintf('Enter subject name [%s]: ', defaultSbj), 's');
if (isempty(theSbj))
    theSbj = defaultSbj;
end 


% Read the existing Condition File:exptName
defaultExpt = 'Bend_No_Flag';
exptName = input(sprintf('Enter experiment name [%s]: ', defaultExpt), 's');
if (isempty(exptName))
    exptName = defaultExpt;
end


% Change the condition file name based on experiment. 
% Change the stim folder name based on experiment name.
% You need to change this to work for your experiment.
switch exptName
    case 'Bend_No_Flag'
        stimFileRoot = 'conditionOrderNewBend_No_Flag'; 
        stimFolder  = 'Bend_No_Flag_Stim';
    case 'Mass_No_Flag'
        stimFileRoot = 'conditionOrderNewMass_No_Flag';
        stimFolder  = 'Mass_No_Flag_Stim';   
    case 'Bend_Flag'
        stimFileRoot = 'conditionOrderNewBend_Flag';
        stimFolder  = 'Bend_Flag_Stim';
    case 'Mass_Flag'
        stimFileRoot = 'conditionOrderNewMass_Flag';
        stimFolder  = 'Mass_Flag_Stim'; 
    case 'Only_Flag'
        stimFileRoot = 'conditionOrderNewOnly_Flag';
        stimFolder  = 'Only_Flag_Stim';
        nConds=4;
        warning('nConds has been changed to 4');
    case 'Mass_Matte'
        stimFileRoot = 'conditionOrderNewMass_Matte';
        stimFolder  = 'Mass_Matte_Stim';
        nConds=12;
        warning('nConds has been changed to 12');
    case 'Mass_Shinny'
        stimFileRoot = 'conditionOrderNewMass_Shinny';
        stimFolder  = 'Mass_Shinny_Stim';
        nConds=12;
        warning('nConds has been changed to 12');
    case 'Bend_Matte'
        stimFileRoot = 'conditionOrderNewBend_Matte';
        stimFolder  = 'Bend_Matte_Stim';
        nConds=12;
        warning('nConds has been changed to 12');
    case 'Bend_Shinny'
        stimFileRoot = 'conditionOrderNewBend_Shinny';
        stimFolder  = 'Bend_Shinny_Stim';
        nConds=12;
        warning('nConds has been changed to 12');  
    otherwise
        %fprintf('Error! Create Stimuli Folder First!!\n');
        error ('Stimuli folder not found, create Stimuli Folder First!!')
end
        
% get the folder to contain the results for each participant
sbjDir = fullfile(exptName, 'resultsFolder',theSbj);
if ~exist(sbjDir, 'dir')
    mkdir(sbjDir);
end 


% Generate the file name ... 
testFileName = fullfile(exptName, [stimFileRoot, '.txt']);	
% conditionStruct = ReadStructsFromText(testFileName);
% put in new condition order and sample order.
[nItems_rand,randomOrder] = doublePerm(nConds);
clear list1 list2
list1 = nItems_rand(:,1);
list2 = nItems_rand(:,2);
nConditions = length(nItems_rand);



condition = 0;
TotalTrials = nchoosek(nConds,2);
TrialsInEachBlock = floor(TotalTrials/nBlock);
TrialsInLastBlock = TotalTrials-TrialsInEachBlock*(nBlock-1);

for iBlock = 1:(nBlock-1)      
    for nTrials = 1:TrialsInEachBlock
        condition = condition +1;
        curCon = randomOrder(condition);
        conditionStruct(nTrials).conditions = curCon;
        conditionStruct(nTrials).block = iBlock;
        conditionStruct(nTrials).stimFolder = stimFolder;
        conditionStruct(nTrials).sample1 = list1(condition);
        conditionStruct(nTrials).sample2 = list2(condition);
    end
    blockNumber = num2str(iBlock);
    % save the file into the subject folder
    newTestFileName = fullfile(sbjDir, [stimFileRoot, 'new_',blockNumber, '.txt']);
    fprintf('write condition file for subject,%s\n',theSbj);
    WriteStructsToText(newTestFileName , conditionStruct);
end  


iBlock = nBlock;
 for nTrials = 1:TrialsInLastBlock
        condition = condition +1;
        curCon = randomOrder(condition);
        conditionStruct(nTrials).conditions = curCon;
        conditionStruct(nTrials).block = iBlock;
        conditionStruct(nTrials).stimFolder = stimFolder;
        conditionStruct(nTrials).sample1 = list1(condition);
        conditionStruct(nTrials).sample2 = list2(condition);        
 end
blockNumber = num2str(iBlock);

% save the file into the subject folder
newTestFileName = fullfile(sbjDir, [stimFileRoot, 'new_',blockNumber, '.txt']);
fprintf('write condition file for subject,%s\n',theSbj);
WriteStructsToText(newTestFileName , conditionStruct);



