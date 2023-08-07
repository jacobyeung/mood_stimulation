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
clc
%%
% Load preprocessed stim data
currentStim = '6mA';

[stimFileName, stimFilePathECOG] = uigetfile('*preprocessed*FreqBands*.mat','Select preprocessed stim ECOG data');
load([stimFilePathECOG stimFileName])

patientID = stimFileName(1:5);

for iChan = 1:numVerifiedChans
    display(['Hilbert Stim Data: Chan ' num2str(iChan) ' of ' num2str(numVerifiedChans)])
    clear tempHilbertFilter
    [tempHilbertFilter,freqs] = KSedits_processingHilbertTransform_filterbankGUI(preprocessedStimData(iChan,:),dsFs,[4 200]);
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
meanBeforeStim = squeeze(nanmean(beforeStim,3));
%% During Stim
duringStim = power_stim(:,:,stimStartSample:stimEndSample);

% Average across time
meanDuringStim = squeeze(nanmean(duringStim,3));
%% After Stim
afterStim = power_stim(:,:,stimEndSample + 1:end);

% Average across time
meanAfterStim = squeeze(nanmean(afterStim,3));

%%
saveFileName = [stimFilePathECOG patientID '_TimeAveragedSpectraPower_' currentStim '.mat'];
save(saveFileName,'meanBeforeStim','meanDuringStim','meanAfterStim',...
    'freqs','finalVerifiedRegions','finalVerifiedChanNames','currentStim','regionNames',...
    'stimStartSample','stimEndSample','dsFs','Fs','numVerifiedChans','-v7.3')
