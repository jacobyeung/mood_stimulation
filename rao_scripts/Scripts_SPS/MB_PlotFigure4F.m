%% MB_PlotFigure4F.m
% Create plot for Figure 4F
%
% Author: Maryam Bijanzadeh, 2017-2018
%%

close all
clear all
clc

patientID = 'EC153';
load('EC153_ERP.mat')

%% Initialization
pulseBefore = 1;
pulseAfter = 6;
numPulses = 20;
searchOffset = 0.003;
testSamples = floor(Fs/2 + Fs*searchOffset+blankAfter+blankBefore): floor(Fs/2 + Fs*0.2);
[peakValueBefore,peakValueAfter,peakTimeBefore,peakTimeAfter,percentChange]= FindPeakValues_Time(numPulsesPulse_Num,ERP,normEvokedZ,testSamples,pulseBefore,pulseAfter);

%% plot Figure 4D
stimChans = [3 7];
chanNum=8;

Plot_ERP_Bef_Aft_PeakVal_Perc_Wave(chanNum,stimChans,abs( zERP{pulseBefore}),abs( zERP{pulseAfter}),abs( SE_zERP{pulseBefore}),abs(SE_zERP{pulseAfter}),...
    Anatomy, patientID, searchOffset, blankAfter,blankBefore,Fs)

