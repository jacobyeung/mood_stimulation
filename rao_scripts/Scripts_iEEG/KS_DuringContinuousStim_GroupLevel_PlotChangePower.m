%% KS_DuringContinuousStim_GroupLevel_PlotChangePower.m
%
% Group-level plot of percent change in power (before to during, during to after)
% in different brain region
%
% Author: Kristin Sellers, 2017-2018
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

groupRegionNames = {'OFC','Insula','Amygdala','Hippocampus','Dorsal Cingulate',...
    'Ventral Cingulate'};
%%
% Frequency band information
theta = [4 8];
alpha = [8 12];
beta = [13 30];

freqInd = {theta, alpha, beta};
freqLabels = {'Theta','Alpha','Beta'};
%%
% Prepare matrices
group_meanBeforeStim = NaN(numFiles,length(groupRegionNames), length(freqInd));
group_meanDuringStim = NaN(numFiles,length(groupRegionNames), length(freqInd));
group_meanAfterStim = NaN(numFiles,length(groupRegionNames), length(freqInd));

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
    % For each region, calculate mean across relevant frequencies; then average across channels
    for iRegion = 1:length(groupRegionNames)
        clear selectChans
        currentRegionNumber = find(ismember(regionNames,groupRegionNames{iRegion}));
        
        if ~isempty(currentRegionNumber)
            selectChans = find(finalVerifiedRegions == currentRegionNumber);
        else
            selectChans = [];
        end
        
        for iFreq = 1:length(freqInd)
            clear currentFreqs
            currentFreqs = intersect(find(freqs >= freqInd{iFreq}(1)), find(freqs <= freqInd{iFreq}(2)));
            if ~isempty(selectChans)
                group_meanBeforeStim(iFile,iRegion,iFreq) = squeeze(nanmean(nanmean(meanBeforeStim(selectChans,currentFreqs),2),1));
                group_meanDuringStim(iFile,iRegion,iFreq) = squeeze(nanmean(nanmean(meanDuringStim(selectChans,currentFreqs),2),1));
                group_meanAfterStim(iFile,iRegion,iFreq) = squeeze(nanmean(nanmean(meanAfterStim(selectChans,currentFreqs),2),1));
            end
        end
    end
end

%%
% Percent change
percChange_duringBefore = ((group_meanDuringStim - group_meanBeforeStim) ./ group_meanBeforeStim) * 100;
percChange_afterDuring = ((group_meanAfterStim - group_meanDuringStim) ./ group_meanDuringStim) * 100;
percChange_afterBefore = ((group_meanAfterStim - group_meanBeforeStim) ./ group_meanBeforeStim) * 100;

meanPercChange_duringBefore = squeeze(nanmean(percChange_duringBefore,1));
meanPercChange_duringAfter = squeeze(nanmean(percChange_afterDuring,1));
meanPercChange_beforeAfter = squeeze(nanmean(percChange_afterBefore,1));

toPlot(:,:,1) = meanPercChange_duringBefore';
toPlot(:,:,2) = meanPercChange_duringAfter';

% Calculate sem
for iRegion = 1:length(groupRegionNames)
    currentNum = sum(~isnan(percChange_duringBefore(:,iRegion,1)));
    semPercChange_duringBefore(iRegion,:) = nanstd(squeeze(percChange_duringBefore(:,iRegion,:)),[],1) ./ sqrt(currentNum);
    semPercChange_afterDuring(iRegion,:) = nanstd(squeeze(percChange_afterDuring(:,iRegion,:)),[],1) ./ sqrt(currentNum);
    semPercChange_afterBefore(iRegion,:) = nanstd(squeeze(percChange_afterBefore(:,iRegion,:)),[],1) ./ sqrt(currentNum);
end

toPlotSEM(:,:,1) = semPercChange_duringBefore';
toPlotSEM(:,:,2) = semPercChange_afterDuring';

%%
% Change power across regions, no error bars
figure
clf
set(gcf,'Position',[632 349 1092 420])
set(gcf,'PaperPositionMode','auto')
set(gcf, 'PaperOrientation', 'landscape');
for iFreq = 1:length(freqInd)
    subplot(1,length(freqInd),iFreq)
    bar(squeeze(toPlot(iFreq,:,:)),'FaceColor','k')
    hold on
    
    set(gca,'XTick',[1 2 3 4 5 6])
    set(gca,'XTickLabelRotation',45)
    set(gca,'XTickLabel',groupRegionNames)
    
    ylabel('Power [% Change]')
    title(freqLabels{iFreq})
    axis tight
    ylim([-30 25])
end

% Change power across regions, with error bars
figure
clf
set(gcf,'Position',[632 349 1092 420])
set(gcf,'PaperPositionMode','auto')
set(gcf, 'PaperOrientation', 'landscape');
for iFreq = 1:length(freqInd)
    subplot(1,length(freqInd),iFreq)
    
    h = bar(squeeze(toPlot(iFreq,:,:)),'FaceColor','k');
    hold on
    nGroups = size(toPlot, 2);
    nBars = size(toPlot, 3);
    groupwidth = min(0.8, nBars/(nBars + 1.5));
    
    for iBar = 1:nBars
        a = (1:nGroups) - groupwidth/2 + (2*iBar-1) * groupwidth / (2*nBars);
        errorbar(a, squeeze(toPlot(iFreq,:,iBar)), squeeze(toPlotSEM(iFreq,:,iBar)), 'k', 'linestyle', 'none');
    end
    
    set(gca,'XTick',[1 2 3 4 5 6])
    set(gca,'XTickLabelRotation',45)
    set(gca,'XTickLabel',groupRegionNames)
    
    ylabel('Power [% Change]')
    title(freqLabels{iFreq})
    axis tight
    ylim([-30 40])
end
%%
% Plot percent change between before-after with error bars
toPlot = meanPercChange_beforeAfter';
toPlotSEM = semPercChange_afterBefore';

figure
clf
set(gcf,'Position',[632 349 1092 420])
set(gcf,'PaperPositionMode','auto')
set(gcf, 'PaperOrientation', 'landscape');
for iFreq = 1:3
    subplot(1,3,iFreq)
    
    h = bar(squeeze(toPlot(iFreq,:,:)),'FaceColor','k');
    hold on
    nGroups = size(toPlot, 2);
    nBars = size(toPlot, 3);
    groupwidth = min(0.8, nBars/(nBars + 1.5));
    
    for iBar = 1:nBars
        a = (1:nGroups) - groupwidth/2 + (2*iBar-1) * groupwidth / (2*nBars);
        errorbar(a, squeeze(toPlot(iFreq,:,iBar)), squeeze(toPlotSEM(iFreq,:,iBar)), 'k', 'linestyle', 'none');
    end
    
    set(gca,'XTick',[1 2 3 4 5 6])
    set(gca,'XTickLabelRotation',45)
    set(gca,'XTickLabel',groupRegionNames)
    
    ylabel('Power [% Change]')
    title(freqLabels{iFreq})
    axis tight
    ylim([-30 40])
end

%%
% Non-parametric stats, before to during:
clc
iRegion = 1;
iFreq = 1;

[p,h,stats] = signrank(squeeze(percChange_duringBefore(:,iRegion,iFreq)),0,'method','approximate');
disp(['Z = ' num2str(stats.zval) ' , p = ' num2str(p) ])

% Non-parametric stats, during to after:
[p,h,stats] = signrank(squeeze(percChange_afterDuring(:,iRegion,iFreq)),0,'method','approximate');
disp(['Z = ' num2str(stats.zval) ' , p = ' num2str(p) ])

% Non-parametric stats, before to after:
[p,h,stats] = signrank(squeeze(percChange_afterBefore(:,iRegion,iFreq)),0,'method','approximate');
disp(['Z = ' num2str(stats.zval) ' , p = ' num2str(p) ])



