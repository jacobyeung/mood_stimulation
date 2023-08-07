%% KS_PlotBDI.m
% Script to create figure showing BDI scores for all patients
%
% Author: Kristin Sellers, 3/13/2018
%%
close all
clear all
clc

load('KS_TraitScores.mat')

BDI_cutoff = 19.5;
maxBDI = 63;

%%
% Determine indices of patients who have behavior (will plot those data points filled in)
patientsWithBehavior = {'EC81','EC82','EC84','EC87','EC91','EC92','EC96','EC99',...
    'EC105','EC108','EC125','EC129','EC133','EC142','EC150','EC151','EC152','EC162','EC175'};

indices_patientsWithBehavior = find(ismember(Patient,patientsWithBehavior));
indices_patientsWithoutBehavior = setdiff(1:length(BDI),indices_patientsWithBehavior);
%%
toPlot = 0.02 .* rand(1,length(BDI));

figure
clf
set(gcf,'Position',[360 198 230 420])
scatter(toPlot(indices_patientsWithoutBehavior),BDI(indices_patientsWithoutBehavior),50,'ks')
hold on
scatter(toPlot(indices_patientsWithBehavior),BDI(indices_patientsWithBehavior),50,'ks','filled')
line([-0.01 0.04],[BDI_cutoff BDI_cutoff],'Color','k','LineWidth',2)
xlim([-0.03 0.06])
ylim([0 38])
ylabel('BDI')








