%% KS_DuringContinuousStim_TimeAveragedSpectra.m
%
% Use preprocessed data from during continuous stimulation to calculate
% spectra; average spectra before stimulation, during stimulation, and
% after stimulation
%
% Author: Kristin Sellers, 2017-2018
%%
close all
clear all
% clc
%%
directory_path = '../../OFC_data';
% Load preprocessed stim data

[stimFileName, stimFilePathECOG] = uigetfile('*preprocessed*FreqBands*.mat','Select preprocessed stim ECOG data');


patientID = stimFileName(1:5);
disp([stimFilePathECOG stimFileName]);
split_name = split(stimFileName, '_');

matchingIndices = cellfun(@(s) contains(s, 'mA'), split_name);
if isempty(matchingIndices)
    close all;
    exit;
end
currentStim =  split_name(matchingIndices);

currentStim = currentStim{1};

rest_of_name = strjoin(split_name(3:end), '_');


load([stimFilePathECOG '/' stimFileName])



% Goes channel by channel, not at all at once
for iChan = 1:numVerifiedChans
    display(['Hilbert Stim Data: Chan ' num2str(iChan) ' of ' num2str(numVerifiedChans)])
    clear tempHilbertFilter
    [tempHilbertFilter,freqs] = KSedits_processingHilbertTransform_filterbankGUI(preprocessedStimData(iChan,:),dsFs,[4 80]);
    hilbertAA_stim(iChan,:,:) = squeeze(tempHilbertFilter.envData)';
end
power_stim = hilbertAA_stim.^2;

%%
% Time-averaged spectrum for before, during, and after stimulation
stimStartSample = floor((plotStimStart/Fs)*dsFs);
stimEndSample = floor((plotStimEnd/Fs)*dsFs);

%% Before Stim
beforeStim = power_stim(:,:,1:stimStartSample - 1);

% Average across time
meanBeforeStim = squeeze(mean(beforeStim,3));
%% During Stim
duringStim = power_stim(:,:,stimStartSample:stimEndSample);

% Average across time
meanDuringStim = squeeze(mean(duringStim,3));
%% After Stim
afterStim = power_stim(:,:,stimEndSample + 1:end);

% Average across time
meanAfterStim = squeeze(mean(afterStim,3));

%%
saveFileName = [stimFilePathECOG 'v7_' patientID '_TimeAveragedSpectraPower_' rest_of_name];
save(saveFileName, 'power_stim', 'meanBeforeStim','meanDuringStim','meanAfterStim',...
    'freqs','finalVerifiedRegions','finalVerifiedChanNames','regionNames',...
    'stimStartSample','stimEndSample','dsFs','Fs','numVerifiedChans','-v7')
