%% MB_PlotFigure4E.m
% Create plot for Figure 4E
%
% Author: Maryam Bijanzadeh, 2017-2018
%%
close all
clear all
clc

load('SPS_Group.mat')

%%
for iData = 1:length(patientID)
    [H(iData), P(iData)] = ranksum (peakValuesBefore(:,iData), peakValuesAfter(:,iData));
end

Ind = find(P < 0.06);

%%
% Create figure
G = figure;

Ind = [ 8     9    13    22    ] ;

a = 1;
for iData = 1:numel(Ind)
    h = scatter(repmat(a,20,1),peakValuesBefore(:,Ind(iData)),'go');
    set(h,'MarkerEdgeColor',[0 153 0]/256)
    hold on
    scatter(repmat(a+0.5,20,1),peakValuesAfter(:,Ind(iData)),'mo')
    h1 = plot([ a-0.5 a+0.5],repmat (mean(peakValuesBefore(:,Ind(iData))),1,2),'k','Linewidth',2);
    h2 = plot([ a a+0.5+0.5],repmat (mean(peakValuesAfter(:,Ind(iData))),1,2),'k','Linewidth',2);
    a=a+3;
end

set(gca,'Xtick',[1:3:10])
set(gca,'XtickLabel',{'EC137',  'EC139' ,'EC150','EC153'},'Fontsize',14)
ylabel ('Voltage[z-score]','Fontsize',14)
legend([h1, h2],{'Before Continuous stim','After Continuous stim'})



