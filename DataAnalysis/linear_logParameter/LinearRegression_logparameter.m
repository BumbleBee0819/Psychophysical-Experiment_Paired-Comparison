% Regression Plot: logperceptual against ground truth
% 11/26/2015: WB wrote it
clear all; close all; 
clc;
%
curDir=pwd;
cd('../..');
cd('functions');
if (~isempty(strfind(path,pwd))) == 0 
   addpath(genpath(pwd));
   savepath;
end
cd (curDir);

% 
defaultExpt = 'BendDemo';
expName = input(sprintf('Enter experiment name [%s]: ', defaultExpt), 's');
if (isempty(expName))
    expName = defaultExpt;
end


dataFilename = [expName,'.txt'];
%Mass_LogParameter
dataStruct = ReadStructsFromText(dataFilename);


for i = 1:28
  Y(i,1) = dataStruct(i).PerceptualScore;
  X(i,1) = dataStruct(i).PhysicalScore;
end

figure1 = figure()
plotregression(X,Y,'Regression');

%if expName == 'Bend'
%    axis([-1.5 2.5 -0.05 0.15])
%elseif expName == 'Mass'
%    axis([-1 0.2 -0.04 0.1])
%end


output = [expName,'_Regression.eps'];
cd('../../Output') 
cd('Regression')
saveas(figure1, output);
cd(curDir)
