clear all; close all;
clc;

workDir=pwd;
cd('../..');
cd('functions');
if (~isempty(strfind(path,pwd))) == 0 
   addpath(genpath(pwd));
   savepath;
end

cd (workDir);



default_expName = 'Bend_group';
expName = input(sprintf('ExpName: Bend_group? or Mass_group? (default: Bend_group).\n'),'s');
if (isempty(expName))
    expName = default_expName;
end 



switch expName
    case 'Bend_group'
        dataFilename = 'average_bending_demo.txt';
    case 'Mass_group'
        dataFilename = 'average_mass_demo.txt';
end

dataStruct = ReadStructsFromText(dataFilename);


for i = 1:length(dataStruct)
  W(i,1) = dataStruct(i).wind;
  Para(i,1) = dataStruct(i).parameter;
  % Participant a~g 
  Y(i,1) = dataStruct(i).a;
  Y(i,2) = dataStruct(i).b;
  Y(i,3) = dataStruct(i).c;
  Y(i,4) = dataStruct(i).d;
  Y(i,5) = dataStruct(i).e;
  Y(i,6) = dataStruct(i).f;
  Y(i,7) = dataStruct(i).g;

  Average(i,1) = ((Y(i,1)+ Y(i,2)+ Y(i,3)+ Y(i,4)+Y(i,5)+Y(i,6)+Y(i,7)))/7;
  ErrorBar(i,1) = std(Y(i,:))/sqrt(7);
  %ste(i,1) = ErrorBar(i,1)/sqrt(7);
end


cd ('../..')
cd('Output/MainOutput/IndividualOutput')
figureh = figure;
% Not display the plot
set(figureh, 'visible','off');
errorbar(Para(1:7),Average(1:7),ErrorBar(1:7));
hold on
errorbar(Para(8:14),Average(8:14),ErrorBar(8:14));
hold on
errorbar(Para(15:21),Average(15:21),ErrorBar(15:21));
hold on
errorbar(Para(22:28),Average(22:28),ErrorBar(22:28));
axis([1 7 0 0.15]);
legend('wind 250','wind 350','wind 450','wind 550');


switch expName
    case 'Bend_group'
        output = ['average_bending.eps']; 
    case 'Mass_group'
        output = ['average_mass.eps']; 
end

print(figureh,'-r300','-depsc2',output);
cd(workDir)


