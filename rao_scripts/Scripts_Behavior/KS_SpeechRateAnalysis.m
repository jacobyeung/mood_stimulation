%% KS_SpeechRateAnalysis.m
% Statistics and plotting to compare speech rate during sham and 6mA OFC
% stimulation
%
% Author: Kristin Sellers, 2017-2018
%%
close all
clear all
clc

load('KS_SpeechRate_6mA.mat')
%%
% Separate trait / non-trait
trait = {'EC82','EC84','EC87','EC99','EC125','EC142','EC150','EC151','EC175'};
nonTrait = {'EC81','EC91','EC92','EC96','EC129','EC133','EC162'};

traitIndices = [];
nonTraitIndices = [];
for iPatient = 1:length(Patient)
    if ismember(Patient{iPatient},trait)
        traitIndices = [traitIndices iPatient];
    elseif ismember(Patient{iPatient},nonTrait)
        nonTraitIndices = [nonTraitIndices iPatient];
    end
end

trait_ShamRate = ShamRate(traitIndices);
trait_StimRate = OFCrate(traitIndices);
nonTrait_ShamRate = ShamRate(nonTraitIndices);
nonTrait_StimRate = OFCrate(nonTraitIndices);

%%
% All patients together: Boxplot of sham speech rates and OFC speech rates
figure
clf
set(gcf,'Position',[360 198 305 420])
boxplot([ShamRate OFCrate],'Colors','kkk')
ylabel('Speech Rate')
set(gca,'XTick',[1 2])
set(gca,'XTickLabel',{'Sham','6mA OFC Stim'})
%%
% All patients together: Bar plot of differences in speech rate, for each patient
diffRates = OFCrate - ShamRate;

figure
clf
bar(diffRates,'k')
set(gca,'XTick',1:length(Patient))
set(gca,'XTickLabel',Patient)
set(gca,'XTickLabelRotation',45)
ylabel('Speech Rate [Stim - Sham]')

%%
% Trait patients
figure
clf
set(gcf,'Position',[360 198 305 420])
boxplot([trait_ShamRate trait_StimRate],'Colors','kkk')
ylabel('Speech Rate')
set(gca,'XTick',[1 2])
set(gca,'XTickLabel',{'Sham','6mA OFC Stim'})
title('Trait patients')
ylim([0.25 3.75])

[p,h,stats] = ranksum(trait_ShamRate,trait_StimRate,'method','approximate')

%%
% Non-trait patients
figure
clf
set(gcf,'Position',[360 198 305 420])
boxplot([nonTrait_ShamRate nonTrait_StimRate],'Colors','kkk')
ylabel('Speech Rate')
set(gca,'XTick',[1 2])
set(gca,'XTickLabel',{'Sham','6mA OFC Stim'})
title('Non-Trait patients')
ylim([0.25 3.75])

[p,h,stats] = ranksum(nonTrait_ShamRate,nonTrait_StimRate,'method','approximate')

%%
% Compare trait and non-trait patients: Sham
groupingVariable = [ones(1,length(nonTrait_ShamRate)) ones(1,length(trait_ShamRate)) + 1];

figure
clf
set(gcf,'Position',[360 198 305 420])
boxplot([nonTrait_ShamRate; trait_ShamRate],groupingVariable,'Colors','kkk')
ylabel('Speech Rate')
set(gca,'XTick',[1 2])
set(gca,'XTickLabel',{'Non-Trait','Trait'})
title('Sham')
ylim([0.25 3.75])

[p,h,stats] = ranksum(nonTrait_ShamRate,trait_ShamRate,'method','approximate')

%%
% Compare trait and non-trait patients: Stim
groupingVariable = [ones(1,length(nonTrait_StimRate)) ones(1,length(trait_StimRate)) + 1];

figure
clf
set(gcf,'Position',[360 198 305 420])
boxplot([nonTrait_StimRate; trait_StimRate],groupingVariable,'Colors','kkk')
ylabel('Speech Rate')
set(gca,'XTick',[1 2])
set(gca,'XTickLabel',{'Non-Trait','Trait'})
title('Stim')
ylim([0.25 3.75])

[p,h,stats] = ranksum(nonTrait_StimRate,trait_StimRate,'method','approximate')

