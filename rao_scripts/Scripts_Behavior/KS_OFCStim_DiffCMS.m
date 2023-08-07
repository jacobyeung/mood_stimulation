%% KS_OFCStim_DiffCMS.m
% Plotting of composite mood scores per patient
%
% Author: Kristin Sellers, 2018
%%
close all
clear all
clc

load('KS_OFCStim_BehaviorData.mat')
allPatientIDs = Patient;

%%
patientsToExclude = {};
for iPatient = 1:length(allPatientIDs)
    temp_allIDs{iPatient} = num2str(allPatientIDs{iPatient});
end
indicesToExclude = find(ismember(temp_allIDs,patientsToExclude));

IMS(indicesToExclude) = [];
StimCond(indicesToExclude) = [];
Trait(indicesToExclude) = [];
WordValence(indicesToExclude) = [];
allPatientIDs(indicesToExclude) = [];
CompositeScore(indicesToExclude) = [];
IMS_NaNFilledWithValence(indicesToExclude) = [];

%%
tempIndices = strfind(StimCond,'Sham');
allShamIndices = find(not(cellfun('isempty',tempIndices)));

tempIndices1mA = strfind(StimCond,'1mA');
all1mAIndices = find(not(cellfun('isempty',tempIndices1mA)));

tempIndices6mA = strfind(StimCond,'6mA');
all6mAIndices = find(not(cellfun('isempty',tempIndices6mA)));

allTraitIndices = find(Trait == 1);
allNonTraitIndices = find(Trait == 0);

%%
for iPatient = 1:length(allPatientIDs)
    allIDs{iPatient} = num2str(allPatientIDs{iPatient});
end
allPatients = unique(allIDs);
%%
trait1mA_indices = intersect(all1mAIndices,allTraitIndices);
nonTrait1mA_indices =  intersect(all1mAIndices,allNonTraitIndices);
trait6mA_indices = intersect(all6mAIndices,allTraitIndices);
nonTrait6mA_indices =  intersect(all6mAIndices,allNonTraitIndices);

compositeScore_trait1mA = CompositeScore(trait1mA_indices);
compositeScore_nonTrait1mA =  CompositeScore(nonTrait1mA_indices);
compositeScore_trait6mA = CompositeScore(trait6mA_indices);
compositeScore_nonTrait6mA =  CompositeScore(nonTrait6mA_indices);


%%
% Extracting sham matched with each stim condition
patientIDs_trait6mA = allIDs(trait6mA_indices);
patientIDs_nonTrait6mA = allIDs(nonTrait6mA_indices);
patientIDs_trait1mA = allIDs(trait1mA_indices);
patientIDs_nonTrait1mA = allIDs(nonTrait1mA_indices);

% Find index of sham for patients with 1mA and 6mA stim
matchedSham_trait6mA_indices = [];
matchedSham_nonTrait6mA_indices = [];
matchedSham_trait1mA_indices = [];
matchedSham_nonTrait1mA_indices = [];

for iShamIndex = 1:length(allShamIndices)
    if ismember(allIDs(allShamIndices(iShamIndex)), patientIDs_trait6mA)
        matchedSham_trait6mA_indices = [matchedSham_trait6mA_indices allShamIndices(iShamIndex)];
    end
    if ismember(allIDs(allShamIndices(iShamIndex)), patientIDs_nonTrait6mA)
        matchedSham_nonTrait6mA_indices = [matchedSham_nonTrait6mA_indices allShamIndices(iShamIndex)];
    end
    if ismember(allIDs(allShamIndices(iShamIndex)), patientIDs_trait1mA)
        matchedSham_trait1mA_indices = [matchedSham_trait1mA_indices allShamIndices(iShamIndex)];
    end
    if ismember(allIDs(allShamIndices(iShamIndex)), patientIDs_nonTrait1mA)
        matchedSham_nonTrait1mA_indices = [matchedSham_nonTrait1mA_indices allShamIndices(iShamIndex)];
    end
end

compositeScore_matchedSham_trait6mA = CompositeScore(matchedSham_trait6mA_indices);
compositeScore_matchedSham_nonTrait6mA = CompositeScore(matchedSham_nonTrait6mA_indices);
compositeScore_matchedSham_trait1mA = CompositeScore(matchedSham_trait1mA_indices);
compositeScore_matchedSham_nonTrait1mA = CompositeScore(matchedSham_nonTrait1mA_indices);

%%
allStim = [compositeScore_trait1mA; compositeScore_nonTrait1mA; compositeScore_trait6mA; compositeScore_nonTrait6mA];
allSham = [compositeScore_matchedSham_trait1mA; compositeScore_matchedSham_nonTrait1mA; compositeScore_matchedSham_trait6mA; compositeScore_matchedSham_nonTrait6mA];

%%
% Sort by length
[shortList,indexAll] = sort(allSham);
sortedAll = allStim(indexAll);
sortedAllSham = allSham(indexAll);
%%
% Plot
offset = linspace(1, 5, length(sortedAll));

figure
clf
set(gcf,'Position',[360 198 560 258])
hold on
for iData = 1:length(sortedAll)
    line([sortedAllSham(iData) sortedAll(iData)],[offset(iData) offset(iData)],'Color','k','LineWidth',2)
    scatter(sortedAllSham(iData),offset(iData),25,'k','filled')
    scatter(sortedAll(iData),offset(iData),25,'r','filled')
end
xlabel('CMS')
title('All OFC Stim')
xlim([0 100])
ylim([0.9 5.1])
