%% KS_OFCStim_BehaviorData.m
% Plotting and statistics of composite mood scores based on stimulation
% condition and patient trait (depressed/not depressed)
%
% Author: Kristin Sellers, 2017-2018
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
% All sham and 6mA, unpaired
traitSham_indices = intersect(allShamIndices,allTraitIndices);
nonTraitSham_indices = intersect(allShamIndices,allNonTraitIndices);
trait1mA_indices = intersect(all1mAIndices,allTraitIndices);
nonTrait1mA_indices =  intersect(all1mAIndices,allNonTraitIndices);
trait6mA_indices = intersect(all6mAIndices,allTraitIndices);
nonTrait6mA_indices =  intersect(all6mAIndices,allNonTraitIndices);

compositeScore_traitSham = CompositeScore(traitSham_indices);
compositeScore_nonTraitSham = CompositeScore(nonTraitSham_indices);
compositeScore_trait1mA = CompositeScore(trait1mA_indices);
compositeScore_nonTrait1mA =  CompositeScore(nonTrait1mA_indices);
compositeScore_trait6mA = CompositeScore(trait6mA_indices);
compositeScore_nonTrait6mA =  CompositeScore(nonTrait6mA_indices);

IMS_traitSham = IMS(traitSham_indices);
IMS_nonTraitSham = IMS(nonTraitSham_indices);
IMS_trait1mA = IMS(trait1mA_indices);
IMS_nonTrait1mA =  IMS(nonTrait1mA_indices);
IMS_trait6mA = IMS(trait6mA_indices);
IMS_nonTrait6mA =  IMS(nonTrait6mA_indices);

wordValence_traitSham = WordValence(traitSham_indices);
wordValence_nonTraitSham = WordValence(nonTraitSham_indices);
wordValence_trait1mA = WordValence(trait1mA_indices);
wordValence_nonTrait1mA =  WordValence(nonTrait1mA_indices);
wordValence_trait6mA = WordValence(trait6mA_indices);
wordValence_nonTrait6mA =  WordValence(nonTrait6mA_indices);

%%
% Sham vs 6mA, separating trait vs non-Trait
patientIDs_trait6mA = allIDs(trait6mA_indices);
patientIDs_nonTrait6mA = allIDs(nonTrait6mA_indices);
patientIDs_trait1mA = allIDs(trait1mA_indices);
patientIDs_nonTrait1mA = allIDs(nonTrait1mA_indices);

% Find index of sham for patients with 6mA stim
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

IMS_matchedSham_trait6mA = IMS(matchedSham_trait6mA_indices);
IMS_matchedSham_nonTrait6mA = IMS(matchedSham_nonTrait6mA_indices);
IMS_matchedSham_trait1mA = IMS(matchedSham_trait1mA_indices);
IMS_matchedSham_nonTrait1mA = IMS(matchedSham_nonTrait1mA_indices);

wordValence_matchedSham_trait6mA = WordValence(matchedSham_trait6mA_indices);
wordValence_matchedSham_nonTrait6mA = WordValence(matchedSham_nonTrait6mA_indices);
wordValence_matchedSham_trait1mA = WordValence(matchedSham_trait1mA_indices);
wordValence_matchedSham_nonTrait1mA = WordValence(matchedSham_nonTrait1mA_indices);

%%
% Differences between stim and sham, all subjects
diff_compositeScore_nonTrait1mA = compositeScore_nonTrait1mA - compositeScore_matchedSham_nonTrait1mA;
diff_compositeScore_nonTrait6mA = compositeScore_nonTrait6mA - compositeScore_matchedSham_nonTrait6mA;
diff_compositeScore_trait1mA = compositeScore_trait1mA - compositeScore_matchedSham_trait1mA;
diff_compositeScore_trait6mA = compositeScore_trait6mA - compositeScore_matchedSham_trait6mA;
allDiffs_compositeScore_1mA = [diff_compositeScore_nonTrait1mA; diff_compositeScore_trait1mA];
allDiffs_compositeScore_6mA = [diff_compositeScore_nonTrait6mA; diff_compositeScore_trait6mA];

diff_IMS_nonTrait1mA = IMS_nonTrait1mA - IMS_matchedSham_nonTrait1mA;
diff_IMS_nonTrait6mA = IMS_nonTrait6mA - IMS_matchedSham_nonTrait6mA;
diff_IMS_trait1mA = IMS_trait1mA - IMS_matchedSham_trait1mA;
diff_IMS_trait6mA = IMS_trait6mA - IMS_matchedSham_trait6mA;
allDiffs_IMS_1mA = [diff_IMS_nonTrait1mA; diff_IMS_trait1mA];
allDiffs_IMS_6mA = [diff_IMS_nonTrait6mA; diff_IMS_trait6mA];

diff_wordValence_nonTrait1mA = wordValence_nonTrait1mA - wordValence_matchedSham_nonTrait1mA;
diff_wordValence_nonTrait6mA = wordValence_nonTrait6mA - wordValence_matchedSham_nonTrait6mA;
diff_wordValence_trait1mA = wordValence_trait1mA - wordValence_matchedSham_trait1mA;
diff_wordValence_trait6mA = wordValence_trait6mA - wordValence_matchedSham_trait6mA;
allDiffs_wordValence_1mA = [diff_wordValence_nonTrait1mA; diff_wordValence_trait1mA];
allDiffs_wordValence_6mA = [diff_wordValence_nonTrait6mA; diff_wordValence_trait6mA];

%%
% Differences between stim and sham, mod-severe only
clear toTestA toTestB
plotType = 1; % 1 = CMS, 2 = IMS, 3 = word valence

if plotType == 1
    toTestA = diff_compositeScore_trait1mA;
    toTestB = diff_compositeScore_trait6mA;
elseif plotType == 2
    toTestA = diff_IMS_trait1mA;
    toTestB = diff_IMS_trait6mA;
elseif plotType == 3
    toTestA = diff_wordValence_trait1mA;
    toTestB = diff_wordValence_trait6mA;
end

toPlot = [nanmean(toTestA); nanmean(toTestB)];
toPlot_sem = [nanstd(toTestA)/sqrt(length(toTestA));...
    nanstd(toTestB)/sqrt(length(toTestB))];

figure
clf
set(gcf,'Position',[201.5000 133 276 420])
h = bar(toPlot);
hold on
nGroups = size(toPlot, 1);
nBars = size(toPlot, 2);
groupwidth = min(0.8, nBars/(nBars + 1.5));

for iBar = 1:nBars
    a = (1:nGroups) - groupwidth/2 + (2*iBar-1) * groupwidth / (2*nBars);
    errorbar(a, toPlot(:,iBar), toPlot_sem(:,iBar), 'k', 'linestyle', 'none');
end
set(gca,'XTick',[1 2])
set(gca,'XTickLabel',{'1mA','6mA'})
if plotType == 1
    ylabel('Difference Composite Score [Stim - Sham]')
elseif plotType == 2
    ylabel('Difference IMS [Stim - Sham]')
elseif plotType == 3
    ylabel('Difference Word Valence [Stim - Sham]')
end
cmap = colormap(bone);
colormap(flip(cmap,1))

% Non-parametric stats:
[p,h,stats] = signrank(toTestA, 0,'method','approximate')
[p,h,stats] = signrank(toTestB, 0, 'method','approximate')
[p,h,stats] = ranksum(toTestA,toTestB,'method','approximate')

%%
% Differences between stim and sham, min-mild only
clear toTestA toTestB
plotType = 1; % 1 = CMS, 2 = IMS, 3 = word valence

if plotType == 1
    toTestA = diff_compositeScore_nonTrait1mA;
    toTestB = diff_compositeScore_nonTrait6mA;
elseif plotType == 2
    toTestA = diff_IMS_nonTrait1mA;
    toTestB = diff_IMS_nonTrait6mA;
elseif plotType == 3
    toTestA = diff_wordValence_nonTrait1mA;
    toTestB = diff_wordValence_nonTrait6mA;
end

toPlot = [nanmean(toTestA); nanmean(toTestB)];
toPlot_sem = [nanstd(toTestA)/sqrt(length(toTestA));...
    nanstd(toTestB)/sqrt(length(toTestB))];

figure
clf
set(gcf,'Position',[201.5000 133 276 420])
h = bar(toPlot);
hold on
nGroups = size(toPlot, 1);
nBars = size(toPlot, 2);
groupwidth = min(0.8, nBars/(nBars + 1.5));

for iBar = 1:nBars
    a = (1:nGroups) - groupwidth/2 + (2*iBar-1) * groupwidth / (2*nBars);
    errorbar(a, toPlot(:,iBar), toPlot_sem(:,iBar), 'k', 'linestyle', 'none');
end
set(gca,'XTick',[1 2])
set(gca,'XTickLabel',{'1mA','6mA'})
if plotType == 1
    ylabel('Difference Composite Score [Stim - Sham]')
elseif plotType == 2
    ylabel('Difference IMS [Stim - Sham]')
elseif plotType == 3
    ylabel('Difference Word Valence [Stim - Sham]')
end
cmap = colormap(bone);
colormap(flip(cmap,1))

% Non-parametric stats:
[p,h,stats] = signrank(toTestA, 0,'method','approximate')
[p,h,stats] = signrank(toTestB, 0, 'method','approximate')
[p,h,stats] = ranksum(toTestA,toTestB,'method','approximate')
