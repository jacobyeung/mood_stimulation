%% KS_DuringContinuousStim_GroupLevel_Power.m
%
% Group-level plots and statistics on time-averaged power changes
% (before, during, and after continuous stimulation)
%
% Author: Kristin Sellers 2017-2018
%%
close all
clear all
clc
%%
[fileName_temp, filePath] = uigetfile('*TimeAveragedSpectraPower*.mat','Select files', 'MultiSelect', 'on');

if ~isa(fileName_temp,'cell')
    fileName{1} = fileName_temp;
    numFiles = 1;
else
    fileName = fileName_temp;
    numFiles = length(fileName);
end

for iFile = 1:numFiles
    tempInd = strfind(fileName{iFile},'_');
    allPatientIDs{iFile} = fileName{iFile}(1:tempInd(1)-1);
    clear tempInd;
end

groupRegionNames = {'OFC','Amygdala','Hippocampus','Dorsal Cingulate',...
    'Ventral Cingulate','Insula'};

%%
theta = [4 8];
alpha = [8 12];
beta = [13 30];
gamma = [30 50];

freqInd = {theta, alpha, beta, gamma};
freqLabels = {'Theta','Alpha','Beta','Gamma'};
%%
counter = 0;
for iFile = 1:numFiles
    clear meanBeforeStim meanDuringStim meanAfterStim
    
    patientID = allPatientIDs{iFile};
    load([filePath fileName{iFile}])
    %%
    % For some patients, specify which cingulate region
    if strcmp(patientID,'EC108')
        regionNames = {'OFC','Amygdala','Hippocampus','Dorsal Cingulate','Insula'};
    elseif strcmp(patientID,'EC125')
        regionNames = {'OFC','Amygdala','Hippocampus','Dorsal Cingulate','Ventral Cingulate','Insula'};
    elseif strcmp(patientID,'EC133')
        regionNames = {'OFC','Amygdala','Hippocampus','Dorsal Cingulate','Insula'};
    end
    currentRegions = 1:length(regionNames);
    %%
    % For stereo patients, select regions that are ipsilateral to stim
    if ~isempty(strfind(fileName{iFile},'Right'))
        currentRegions = [];
        for iRegion = 1:length(regionNames)
            if ~isempty(strfind(regionNames{iRegion},'Right'))
                currentRegions = [currentRegions iRegion];
                newRegionNames{iRegion} = strrep(regionNames{iRegion},'Right ',[]);
            else
                newRegionNames{iRegion} = regionNames{iRegion};
            end
        end
        regionNames = newRegionNames;
    elseif ~isempty(strfind(fileName{iFile},'Left'))
        currentRegions = [];
        for iRegion = 1:length(regionNames)
            if ~isempty(strfind(regionNames{iRegion},'Left'))
                currentRegions = [currentRegions iRegion];
                newRegionNames{iRegion} = strrep(regionNames{iRegion},'Left ',[]);
            else
                newRegionNames{iRegion} = regionNames{iRegion};
            end
        end
        regionNames = newRegionNames;
    end
    %%
    % Standardize cingulate naming
    for iRegion = 1:length(regionNames)
        if strcmp(regionNames{iRegion},'Superior Cingulate')
            regionNames{iRegion} = 'Dorsal Cingulate';
        elseif strcmp(regionNames{iRegion},'Inferior Cingulate')
            regionNames{iRegion} = 'Ventral Cingulate';
        end
    end
    %%
    % Calculate mean across relevant frequencies; then average across OFC channels
    OFCregionNumber = find(ismember(regionNames,'OFC'));
    if ~isempty(OFCregionNumber)
        selectChans = find(finalVerifiedRegions == OFCregionNumber);
    else
        selectChans = [];
    end
    if ~isempty(selectChans)
        counter = counter + 1;
        selectFiles{counter} = fileName{iFile};
    end
    for iFreq = 1:length(freqInd)
        currentFreqs = intersect(find(freqs >= freqInd{iFreq}(1)), find(freqs <= freqInd{iFreq}(2)));
        if ~isempty(selectChans)
            group_meanBeforeStim(counter,iFreq) = squeeze(nanmean(nanmean(meanBeforeStim(selectChans,currentFreqs),2),1));
            group_meanDuringStim(counter,iFreq) = squeeze(nanmean(nanmean(meanDuringStim(selectChans,currentFreqs),2),1));
            group_meanAfterStim(counter,iFreq) = squeeze(nanmean(nanmean(meanAfterStim(selectChans,currentFreqs),2),1));
        end
    end
end
%%
clc
iFreq = 1; % User selects which frequency to test
[p,h,stats] = signrank(group_meanBeforeStim(:,iFreq), group_meanDuringStim(:,iFreq))

[p,h,stats] = signrank(group_meanAfterStim(:,iFreq), group_meanDuringStim(:,iFreq))

%%
% Percent change: Before and During
group_percentChange_duringBefore = ((group_meanDuringStim - group_meanBeforeStim) ./ group_meanBeforeStim) * 100;
mean_percentChange_duringBefore = nanmean(group_percentChange_duringBefore,1);

for iFreq = 1:3
    figure
    clf
    set(gcf,'Position',[365 192.5000 242 405])
    hold on
    for iSample = 1:size(group_percentChange_duringBefore,1)
        line([0.5 1.5],[0 group_percentChange_duringBefore(iSample,iFreq)],'Color',[0.5 0.5 0.5],'LineWidth',1.5);
    end
    line([0.25 0.75],[0 0],'Color','k','LineWidth',3.5);
    line([1.25 1.75],[mean_percentChange_duringBefore(iFreq) mean_percentChange_duringBefore(iFreq)],'Color','k','LineWidth',3.5);
    set(gca,'XTick',[0.5 1.5])
    set(gca,'XTickLabel',{'Before','During'})
    ylabel('Power [Percent Change]')
    ylim([-60 130])
    suptitle(freqLabels{iFreq})
    figureSaveName = [filePath 'Figures\' freqLabels{iFreq}];
end

freqToTest = 1; % User selects which frequency to test
[p,h,stats] = signrank(squeeze(group_percentChange_duringBefore(:,freqToTest)))
%%
% Percent change: During and After
group_percentChange_afterDuring = ((group_meanAfterStim - group_meanDuringStim) ./ group_meanDuringStim) * 100;
mean_percentChange_afterDuring = nanmean(group_percentChange_afterDuring,1);

for iFreq = 1:3
    figure
    clf
    set(gcf,'Position',[365 192.5000 242 405])
    hold on
    for iSample = 1:size(group_percentChange_afterDuring,1)
        line([0.5 1.5],[0 group_percentChange_afterDuring(iSample,iFreq)],'Color',[0.5 0.5 0.5],'LineWidth',1.5);
    end
    line([0.25 0.75],[0 0],'Color','k','LineWidth',3.5);
    line([1.25 1.75],[mean_percentChange_afterDuring(iFreq) mean_percentChange_afterDuring(iFreq)],'Color','k','LineWidth',3.5);
    set(gca,'XTick',[0.5 1.5])
    set(gca,'XTickLabel',{'During','After'})
    ylabel('Power [Percent Change]')
    ylim([-60 130])
    suptitle(freqLabels{iFreq})
    figureSaveName = [filePath 'Figures\' freqLabels{iFreq}];
end

freqToTest = 1; % User selects which frequency to test
[p,h,stats] = signrank(squeeze(group_percentChange_afterDuring(:,freqToTest)))



