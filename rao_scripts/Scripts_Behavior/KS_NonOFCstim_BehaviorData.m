%% KS_NonOFCstim_BehaviorData.m
% Plotting of composite mood score for stimulation in multiple brain
% regions
%
% Author: Kristin Sellers, 2017-2018
%%
close all
clear all
clc

load('KS_NonOFCStim_BehaviorData.mat')

%%
patientsToExclude = {};
for iPatient = 1:length(Patient)
    temp_allIDs{iPatient} = num2str(Patient{iPatient});
end
indicesToExclude = find(ismember(temp_allIDs,patientsToExclude));

IMS(indicesToExclude) = [];
StimCond(indicesToExclude) = [];
StimLevel(indicesToExclude) = [];
StimSite(indicesToExclude) = [];
Trait(indicesToExclude) = [];
WordValence(indicesToExclude) = [];
Patient(indicesToExclude) = [];
CompositeScore(indicesToExclude) = [];

%%
allStimSites = {'LateralOFC','MedialOFC','Insula','Amygdala','VentralCingulate','DorsalCingulate'};
siteIdentifier = [];

for iStimSite = 1:length(StimSite)
    currentIdentifier = find(ismember(allStimSites,StimSite{iStimSite}));
    siteIdentifier = [siteIdentifier currentIdentifier];
end

allPatients = unique(Patient);

%%
groupLateralOFC_1mA = [];
groupLateralOFC_6mA = [];
groupMedOFC = [];
groupInsula = [];
groupAmygdala = [];
groupVentralCingulate = [];
groupDorsalCingulate = [];

groupLateralOFC_sham = [];
groupMedOFC_sham = [];
groupInsula_sham = [];
groupAmygdala_sham = [];
groupVentralCingulate_sham = [];
groupDorsalCingulate_sham = [];

includedInSham = [];
groupSham = [];
counter = 1;
for iScore = 1:length(CompositeScore)
    if strfind(StimCond{iScore},'6mA')
        switch siteIdentifier(iScore)
            case 1
                groupLateralOFC_6mA = [groupLateralOFC_6mA CompositeScore(iScore)];
            case 2
                groupMedOFC = [groupMedOFC CompositeScore(iScore)];
            case 3
                groupInsula = [groupInsula CompositeScore(iScore)];
            case 4
                groupAmygdala = [groupAmygdala CompositeScore(iScore)];
            case 5
                groupVentralCingulate = [groupVentralCingulate CompositeScore(iScore)];
            case 6
                groupDorsalCingulate = [groupDorsalCingulate CompositeScore(iScore)];
        end
    elseif strfind(StimCond{iScore},'1mA')
        groupLateralOFC_1mA = [groupLateralOFC_1mA CompositeScore(iScore)];
    elseif strfind(StimCond{iScore},'Sham')
        switch siteIdentifier(iScore)
            case 1
                groupLateralOFC_sham = [groupLateralOFC_sham CompositeScore(iScore)];
            case 2
                groupMedOFC_sham = [groupMedOFC_sham CompositeScore(iScore)];
            case 3
                groupInsula_sham = [groupInsula_sham CompositeScore(iScore)];
            case 4
                groupAmygdala_sham = [groupAmygdala_sham CompositeScore(iScore)];
            case 5
                groupVentralCingulate_sham = [groupVentralCingulate_sham CompositeScore(iScore)];
            case 6
                groupDorsalCingulate_sham = [groupDorsalCingulate_sham CompositeScore(iScore)];
        end
        
        % Only include sham from this patient if it hasn't already been
        % included
        if ~ismember(Patient{iScore},includedInSham)
            includedInSham{counter} = Patient{iScore};
            groupSham = [groupSham CompositeScore(iScore)];
            counter = counter + 1;
        end
    end
end

%%
% Find paired sham for lateral OFC stim
groupLateralOFC_1mA_Sham = [];
groupLateralOFC_6mA_Sham = [];

% Find which samples are lateral OFC stim
OFCstimIndices = find(siteIdentifier == 1);
OFCpatients = unique(Patient(OFCstimIndices));

groupLateralOFC_1mA_new = [];
groupLateralOFC_6mA_new = [];

for iOFCpatient = 1:length(OFCpatients)
    
    currentPatient = OFCpatients(iOFCpatient);
    
    currentIndices = intersect(find(strcmp(Patient,currentPatient)),find(strcmp(StimSite,'LateralOFC')));
    currentShamIndex = currentIndices(strcmp(StimCond(currentIndices),'Sham')); % Index out of OFCstimIndices of sham for this patient
    
    for iIndex = 1:length(currentIndices)
        switch StimCond{currentIndices(iIndex)}
            case '1mA'
                groupLateralOFC_1mA_new = [groupLateralOFC_1mA_new CompositeScore(currentIndices(iIndex))];
                groupLateralOFC_1mA_Sham = [groupLateralOFC_1mA_Sham CompositeScore(currentShamIndex)];
            case '6mA'
                groupLateralOFC_6mA_new = [groupLateralOFC_6mA_new CompositeScore(currentIndices(iIndex))];
                groupLateralOFC_6mA_Sham = [groupLateralOFC_6mA_Sham CompositeScore(currentShamIndex)];
        end
    end
end

%%
% Plot diffs, with errorbars
diff1mA = groupLateralOFC_1mA_new - groupLateralOFC_1mA_Sham;
diff6mA = groupLateralOFC_6mA_new - groupLateralOFC_6mA_Sham;
diffMedOFC = groupMedOFC - groupMedOFC_sham;
diffAmygdala = groupAmygdala - groupAmygdala_sham;
diffInsula = groupInsula - groupInsula_sham;
diffVentralCingulate = groupVentralCingulate - groupVentralCingulate_sham;
diffDorsalCingulate = groupDorsalCingulate - groupDorsalCingulate_sham;

toPlotDiffs = [nanmean(diff1mA),...
    nanmean(diff6mA),...
    nanmean(diffMedOFC),...
    nanmean(diffAmygdala),...
    nanmean(diffInsula),...
    nanmean(diffVentralCingulate),...
    nanmean(diffDorsalCingulate)];

toPlot_sem = [std(diff1mA)/sqrt(length(diff1mA))...
    std(diff6mA)/sqrt(length(diff6mA))...
    std(diffMedOFC)/sqrt(length(diffMedOFC))...
    std(diffAmygdala)/sqrt(length(diffAmygdala))...
    std(diffInsula)/sqrt(length(diffInsula))...
    std(diffVentralCingulate)/sqrt(length(diffVentralCingulate))...
    std(diffDorsalCingulate)/sqrt(length(diffDorsalCingulate))];
%%
figure
clf
set(gcf,'Position',[817 52 341 566])
h = bar(toPlotDiffs,'k');
hold on
errorbar(toPlotDiffs, toPlot_sem, 'r', 'linestyle', 'none');
ylim([-20 28])
set(gca,'XTick',1:7)
set(gca,'XTickLabel',{'Lateral OFC 1mA','Lateral OFC 6mA',...
    'Medial OFC','Amygdala','Insula','Ventral Cingulate','Dorsal Cingulate'})
set(gca,'XTickLabelRotation',45)
ylabel('Difference in Composite Score [Stim - Sham]')

