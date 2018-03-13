function [nItems_rand,randomorder] = doublePerm(nConds)
%clear all;
%nConds = 24;
k = 2;
temp = nchoosek(1:1:nConds,k);
j = 1;
for i = 1:size(temp,1)
    elements = temp(i,:,:);
    nItems(j,:)   = [elements(1),elements(2)];
    j= j+1;
end

nTrials = length(nItems);
% Randomize the trials and then seperate them into blocks
randomorder=randperm(nTrials);  
for kk = 1:nTrials
    nItems_rand(kk,:) = nItems(randomorder(kk),:);
end
