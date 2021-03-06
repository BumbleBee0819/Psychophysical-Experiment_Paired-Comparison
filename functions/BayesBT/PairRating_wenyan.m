% Analyse pair-wise rating resutls to get a single perceptual rating score.
% Method is used in Bouman, Xiao, Battaglia, & Freeman, 2013
% 03/25/2016 modified by Wenyan Bi.

clear all; close all;  
% prepare the data 
% Define subject
curDir  = pwd;
defaultSbj = 'wb';
theSbj = input(sprintf('Enter subject name [%s]: ', defaultSbj), 's');
if (isempty(theSbj)),
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

dataDir = [exptName,'/','resultsFolder/'];
stimDir = [exptName,'/','Bend_No_Flag_Stim/'];
sbjDataDir = [exptName,'/','ResultsFolder','/',subjectDir];

nStimu= 28;
nTrials = nchoosek(nStimu,2);

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
%% genreate the confusion matrix, a 28 by 28 matrix containing how many times left fabric is judged 
% more stiff than the right fabric.
wm = zeros(28,28);
ranking = zeros(28,1);
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
figure;
imagesc(wm)
colormap(gray);
colorbar
[value, index] = sort(ranking);

%%
% EM
a = 5;
prec = 1e-8;
N_Gibbs = 1000;
N_burn = 100;
[pi_em, junk, ell] = btem(wm, a, prec);
figure('name', 'logposterior EM');
plot(ell)
xlabel('Iterations')
ylabel('Log posterior')
%%
figureh = figure;
[value, index]=sort(pi_em);
plot(index(1:7),pi_em(1:7),'go');
hold on
plot(index(8:14),pi_em(8:14),'ro-');
hold on
plot(index(15:21),pi_em(15:21),'ko-');
hold on
plot(index(22:28),pi_em(22:28),'bo-');
axis([1 7 0 0.15])
legend('wind 250','wind 350','wind 450','wind 550')
output = [theSbj,'ranking.esp'];
cd(sbjDataDir) 
print(figureh,'-r300','-depsc2',output);
cd(curDir)

%%
bendingstiffness = [0.05, 0.25, 0.5, 5, 10, 80,150];
r1 = corrcoef(pi_em(1:7),log(bendingstiffness));
r2 = corrcoef(pi_em(8:14),log(bendingstiffness));
r3 = corrcoef(pi_em(15:21),log(bendingstiffness));
r4 = corrcoef(pi_em(22:28),log(bendingstiffness));



%%
% %% generate matrix A and b (see Bouman's paper for the meaning of A and b).
% % in bouman's paper, solve the linear regression Ax=b;
% responseA = zeros(nTrials,nStimu);   
% responseb = zeros(nTrials,1);
% k = 0; 
% for n = 1: length(theSubjectData)
%     for i = 1:length(theSubjectData{n})
%         k = k +1; 
%         %matrix b
%         res=(theSubjectData{n}(i).response)-3;
%         responseb(k)=res;
%         
%         %matrix a
%         stimname1 = theSubjectData{n}(i).stim1;
%         if stimname1(5)~='_'
%             trialstim1=str2double(stimname1((5:6)));
%         else
%             trialstim1=str2double(stimname1(6));
%         end
%         responseA(k,trialstim1)= -1;
%         
%         
%         stimname2 = theSubjectData{n}(i).stim2;
%         if stimname2(5)~='_'
%             trialstim2=str2double(stimname2((5:6)));
%         else
%             trialstim2=str2double(stimname2(6));
%         end
%         
%         responseA(k,trialstim2)= 1;
%     end
% end
% 
% % calculate matrix x;
% % x is the single perceptual score of each stim
% percepscore = zeros(nStimu,1);
% percepscore=mldivide(responseA,responseb);
% 
% % Grouped by material properties
% % 7 is the number of how many parameters we chose, in the bend experiment,
% % we used 0.05, 0.25, 0.5, 5, 10, 80, 150
% groupscore = zeros (7,1);  % wind collapsed
% blockwindscore = zeros (7,4);  % Grouped by material properties with wind as block
% for i = 1:length(groupscore)
%         A=[percepscore(i),percepscore(1*7+i),percepscore(2*7+i),percepscore(3*7+i)];
%         groupscore(i)= mean(A);
%         for j = 1:4
%             blockwindscore(i,j) = A(j);
%         end
% end
% 
% % %plot x-axis is the physical parameter, y-axis is the perceptual parameter
% % PsyBend = [0.05; 0.25; 0.5; 5; 10; 80; 150];
% % 
% % %% wind collapsed
% % figureh = figure;
% % output = [theSbj,'allwindscollapsed.png'];
% % plot (log(PsyBend),  groupscore,'ro-')
% % hold on
% % title ('Perceptual Score vs Log Physical parameter');
% % xlabel('Log Physical parameter');
% % ylabel ('Perceptual Scores');
% % grid on;
% % cd(sbjDataDir)
% % print(figureh,'-r300','-dpng',output);
% % cd(curDir)
% % %% seperate by wind
% % figureh = figure;
% % output = [theSbj,'individualwinds.png'];
% % colors = ['r','b','g','k'];
% % for i = 1:4
% %     plot(log(PsyBend), blockwindscore(:,i),[colors(i),'o-'])
% %     hold on
% %  
% % end
% % legend('wind 250','wind 350','wind 450','wind 550')
% % grid on
% % title ('Perceptual Score vs Log Physical parameter');
% % xlabel('Log physical parameter');
% % ylabel ('Perceptual Scores');
% % cd(sbjDataDir) 
% % print(figureh,'-r300','-dpng',output);
% % cd(curDir)
% % 
% % 
% % 
% %     
% % 
