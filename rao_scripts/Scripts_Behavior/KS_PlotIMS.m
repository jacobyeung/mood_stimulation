%% KS_PlotIMS.m
% Boxplots of all IMS scores for all patients
%
% Author: Kristin Sellers, 3/23/2018
%%
close all
clear all
clc

load('KS_AllNormIMS.mat')
allPatients = unique(Patient);

patientsOrdered = {'EC81','EC82','EC84','EC87','EC91','EC92','EC96','EC99',...
    'EC108','EC113','EC122','EC125','EC129','EC133','EC137','EC139','EC142',...
    'EC150','EC151','EC152','EC153','EC155','EC162','EC175'};

%%
% Mean IMS for each patient
for iPatient = 1:length(allPatients)
    averageIMS(iPatient) = nanmedian(normIMS(strcmp(allPatients{iPatient},Patient)));
end

%%
% Re-organize IMS score to match order in patientsOrdered
allIMS_ordered = [];
allPatients_ordered = [];
for iPatient = 1:length(patientsOrdered)
    clear currentPatient currentIMS
    currentPatient = patientsOrdered(iPatient);
    currentIMS = normIMS(strcmp(currentPatient,Patient));
    allIMS_ordered = [allIMS_ordered; currentIMS];
    allPatients_ordered = [allPatients_ordered; repmat(currentPatient,length(currentIMS),1)];
end

%%
figure
clf
set(gcf,'Position',[365 296 977 427])
boxplot(allIMS_ordered,allPatients_ordered,'Colors','kkk')
set(gca,'XTickLabelRotation',45)
ylabel('IMS')
ylim([-5 100])
