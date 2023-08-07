%% MB_CalculateERP.m
% Script to extract and calculate ERPs from single-pulse-stimulation
% experiments
%
% Author: Maryam Bijanzadeh, 2017-2018
%%
close all
clear all
clc

% Select file to process
[fileName, filePathECOG] = uigetfile('*.mat','Select raw SPS data');
load([filePathECOG fileName])

% Extract relevant information
tempIndices = strfind(fileName,'_');
patientID = fileName(1:tempIndices(1)-1);

%% Obtain ERPs after single pulses
switch patientID
    case 'EC137'
        artifactChan = 2;
    case 'EC139'
        artifactChan = 2;
    case 'EC152'
        artifactChan = 1;
    case 'EC150'
        artifactChan = 7;
    case 'EC153'
        artifactChan = 1;
    case 'EC155'
        artifactChan = 1;
end

[ERP,zERP,normEvoked_allChans,normEvokedZ, SE_ERP, SE_zERP,blankAfter,blankBefore,Fs] = Extract_ERP_SPS(RawData,Fs,Anatomy,artifactChan,patientID);

%%
% Obtain the peak value of the rectified zScored ERP 13 ms after each pulse train

% Select which SPS train should be used for each patient
if strcmp(patientID,'EC153')
    pulseBefore = 1; % Before OFC continuous stimulation
    pulseAfter = 6; % After end of OFC continuous stimulation
else
    pulseBefore=1; % Before OFC continuous stimulation
    pulseAfter=2; % After OFC continuous stimulation
end

numPulses = 20;
searchOffset = 0.003; % in seconds
testSamples = floor(Fs/2 + Fs*searchOffset + blankAfter + blankBefore): floor(Fs/2 + Fs*0.2); % Look for peak in ERP from searchOffset after stim to 200ms after stim

% Find the maximum postivie amplitude in each trial befor and after stim
[peakValuesBefore,peakValuesAfter,peakTimesBefore,peakTimesAfter,percentChange] = FindPeakValues_Time(numPulses,ERP,normEvokedZ,testSamples,pulseBefore,pulseAfter);

%%
% Plot the average ERP for each OFC channel
switch patientID
    case 'EC137'
        stimChans = [3 7]; % Out of all channels
        chanNums = 1:8; % All OFC channels
    case 'EC139'
        stimChans = [3 4];
        chanNums = 1:4;
    case 'EC152'
        stimChans = [3 7];
        chanNums = 1:8;
    case 'EC150'
        stimChans = [5 6];
        chanNums = 1:7;
    case 'EC153'
        stimChans = [3 7];
        chanNums = 1:8;
    case 'EC155'
        stimChans = [1 3 ];
        chanNums = 1:4;
end

Plot_ERP_Bef_Aft_PeakVal_Perc_Wave(chanNums,stimChans,abs( zERP{pulseBefore}),abs( zERP{pulseAfter}),abs( SE_zERP{pulseBefore}),abs(SE_zERP{pulseAfter}),...
    Anatomy,patientID,searchOffset,blankAfter,blankBefore,Fs)

%%
% Save processed data
save([patientID ,'_ERP.mat'], 'ERP','zERP','SE_zERP','SE_ERP','pulseBefore','pulseAfter','blankAfter','blankBefore','normEvoked_allChans','normEvokedZ','-v7.3')



