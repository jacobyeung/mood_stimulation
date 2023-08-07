%% MB_PlotFigureS4.m
% Create plot for Figure S4
%
% Author: Maryam Bijanzadeh, 2017-2018
%%
close all
clear all
clc

patientID = 'EC155';
load('EC155_ERP.mat')

%% Set parameters
pulseBefore = 1;
pulseAfter = 2;
numPulses = 20;
searchOffset = 0.003;
testSamples = floor(Fs/2 + Fs*searchOffset + blankAfter + blankBefore): floor(Fs/2 + Fs*0.2);

[peakValuesBefore,peakValuesAfter,peakTimesBefore,peakTimesAfter,PercentChange]= FindPeakValues_Time(numPulses,ERP,normEvokedZ,testSamples,pulseBefore,pulseAfter);

%% Panel A
stimChans = [1 3];
chanNum = 2;

Plot_ERP_Bef_Aft_PeakVal_Perc_Wave(chanNum,stimChans,abs( zERP{pulseBefore}),abs( zERP{pulseAfter}),abs( SE_zERP{pulseBefore}),abs(SE_zERP{pulseAfter}),...
    Anatomy, patientID, searchOffset, blankAfter,blankBefore,Fs)


%% Panel B
plotChans = 1:4;

[G, H, P] = Plot_BeeSwarm(peakValuesBefore,peakValuesAfter,plotChans);

