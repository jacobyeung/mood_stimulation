%% KS_DuringContinuousStim_ArtifactRejection.m
% Script to remove stimulation artifact, apply patient/recording specific
% information, and preprocess ECoG data. For use with data collected using
% clinical system (Natus), TDT, or NeuroOmega. Can be used for OFC and non-OFC stimulation
% recordings.
%
% Input: Raw data, converted to .mat format, from clinical system (Natus), TDT, or
% NeuroOmega. For clinical and TDT data, requires clinical_elecs_all.mat or
% TDT_elecs_all.mat file with coordinates and labels for electrode
% locations. Electrode location information is included in NeuroOmega raw
% file.
%
% Output: Preprocessed iEEG data accounting for patient-specific anatomy,
% for subsequent spectral analysis, etc
%
% Author: Kristin Sellers, 2016-2018
%%
close all
clear all
clc
%%
% Select processing parameters
stimFreq = 100; % in Hz
removeOrReplace = 2; % 1 = replace bad data with zeros; 2 = remove bad data
currentStim = 'OFC_6mA';
dataType = 2; % 1 = clinical, 2 = TDT, 3 = NeuroOmega
rejectStimChans = 1; % 0 = do not reject stim channels; 1 = reject stim channels

% Select file to process
[fileName, filePathECOG] = uigetfile('*.mat','Select raw ECOG data');

% Extract relevant information
tempIndices = strfind(fileName,'_');
patientID = fileName(1:tempIndices(1)-1);

%%
% Determine if clinical, TDT, or NeuroOmega data
if dataType == 1 % Clinical
    temp = matfile([filePathECOG fileName]);
    Fs = temp.Fs;
    load([filePathECOG 'clinical_elecs_all.mat']);
elseif dataType == 2 % TDT
    load([filePathECOG fileName]);
    if strcmp(patientID,'EC175')
        load([filePathECOG 'TDT_elecs_special.mat']); % non-standard electrodes for continuous stim experiment
    else
        load([filePathECOG 'TDT_elecs_all.mat']);
    end
elseif dataType == 3 % NeuroOmega
    load([filePathECOG fileName]);
end

%%
% Patient/recording specific information
if dataType == 1 % Clinical
    originalChans = 1:length(anatomy); % including non ECoG channels
    if strcmp(patientID, 'EC162')
        nonGridChans = 1:110; % out of original 'anatomy'
        rawData = temp.rawData;
        artifactBufferBefore = ceil((0.0008)*Fs); % Number of samples before first stim artifact and after last stim artifact to call artifact
        artifactBufferAfter = ceil((0.0026)*Fs);
        stimChanNames = {'OF3','OF4'};
        if strcmp(currentStim,'6mA')
            threshold = 10000; % for artifact detection
            plotChan = 72; % for visualization
        end
        verifiedChanNames = {'OF1','OF2','OF3','OF4',...
            'A1','A2','A3','H1','H2','H3','IFB1','IFB2','IFB3',};
        verifiedRegions = [1 1 1 1 2 2 2 3 3 3 4 4 4];
        regionNames = {'OFC','Amygdala','Hippocampus','Insula'};
    elseif strcmp(patientID, 'EC153')
        nonGridChans = 65:136; % out of original 'anatomy'
        rawData = temp.rawData;
        artifactBufferBefore = ceil((0.0008)*Fs); % Number of samples before first stim artifact and after last stim artifact to call artifact
        artifactBufferAfter = ceil((0.0026)*Fs);
        
        if strcmp(currentStim,'6mA')
            threshold = -1600; % for artifact detection
            plotChan = 6; % for visualization
            stimChanNames = {'OFA3','OFB3'};
        elseif strcmp(currentStim,'MedOFC_3mA')
            threshold = 3000; % for artifact detection
            plotChan = 1; % for visualization
            stimChanNames = {'OFA1','OFB1'};
        elseif strcmp(currentStim,'MedOFC_6mA')
            threshold = 3000; % for artifact detection
            plotChan = 1; % for visualization
            stimChanNames = {'OFA1','OFB1'};
        elseif strcmp(currentStim,'VentralCingulate_3mA')
            threshold = 2000; % for artifact detection
            plotChan = 55; % for visualization
            stimChanNames = {'VC1','VC2'};
        elseif strcmp(currentStim,'VentralCingulate_6mA')
            threshold = 3000; % for artifact detection
            plotChan = 55; % for visualization
            stimChanNames = {'VC1','VC2'};
        end
        verifiedChanNames = {'OFCA1','OFCA2','OFCA3','OFCA4','OFCB1','OFCB2','OFCB3','OFCB4',...
            'AD2','AD3','AD4','HD2','HD3','HD4',...
            'VC1','VC2','DC1','DC2','DC3','INS1','INS2','INS3','INS4','INS5'};
        verifiedRegions = [1 1 1 1 1 1 1 1 2 2 2 3 3 3 4 4 5 5 5 6 6 6 6 6];
        regionNames = {'OFC','Amygdala','Hippocampus','Ventral Cingulate','Dorsal Cingulate','Insula'};
    elseif strcmp(patientID, 'EC151')
        nonGridChans = 65:136; % out of original 'anatomy'
        rawData = temp.rawData;
        artifactBufferBefore = ceil((0.0008)*Fs); % Number of samples before first stim artifact and after last stim artifact to call artifact
        artifactBufferAfter = ceil((0.0026)*Fs);
        stimChanNames = {'OFC6','OFC7'};
        if strcmp(currentStim,'1mA')
            threshold = 3000; % for artifact detection
            plotChan = 5; % for visualization
        end
        verifiedChanNames = {'OFC1','OFC2','OFC3','OFC4','OFC5','OFC6','OFC7','INS3'};
        verifiedRegions = [1 1 1 1 1 1 1 2];
        regionNames = {'OFC','Insula'};
        
    elseif strcmp(patientID, 'EC137')
        nonGridChans = 65:146; % out of original 'anatomy'
        rawData = temp.rawData;
        artifactBufferBefore = ceil((0.0008)*Fs); % Number of samples before first stim artifact and after last stim artifact to call artifact
        artifactBufferAfter = ceil((0.0026)*Fs);
        
        if strcmp(currentStim,'6mA')
            threshold = 3000; % for artifact detection
            plotChan = 1; % for visualization
            stimChanNames = {'OFA3','OFB3'};
        elseif strcmp(currentStim,'1mA')
            threshold = 1000; % for artifact detection
            plotChan = 45; % for visualization
            stimChanNames = {'OFA3','OFB3'};
        elseif strcmp(currentStim,'Area25') % aka VentralCingulate
            threshold = 3500; % for artifact detection
            plotChan = 65; % for visualization
            stimChanNames = {'ICD2','ICD3'};
            artifactBufferBefore = ceil((0.0008)*Fs); % Number of samples before first stim artifact and after last stim artifact to call artifact
            artifactBufferAfter = ceil((0.003)*Fs);
        elseif strcmp(currentStim,'SuperiorCingulate') % aka DorsalCingulate
            threshold = 6000; % for artifact detection
            plotChan = 54; % for visualization
            stimChanNames = {'SCD3','SCD4'};
            artifactBufferBefore = ceil((0.0008)*Fs); % Number of samples before first stim artifact and after last stim artifact to call artifact
            artifactBufferAfter = ceil((0.003)*Fs);
        end
        verifiedChanNames = {'OFA1','OFA2','OFA3','OFA4','OFB1','OFB2','OFB3','OFB4',...
            'AD1','AD2','AD3','AD4','HD2','HD3','HD4','HD5','HD6',...
            'SCD2','SCD3','SCD4','ICD1','ICD2','ID6','ID7'};
        verifiedRegions = [1 1 1 1 1 1 1 1 2 2 2 2 2 2 2 2 2 3 3 3 4 4 5 5];
        regionNames = {'OFC','Hippocampus','Superior Cingulate','Inferior Cingulate','Insula'};
        
    elseif strcmp(patientID, 'EC133')
        nonGridChans = 65:192; % out of original 'anatomy'
        rawData = temp.rawData;
        plotChan = 74; % for visualization
        artifactBufferBefore = ceil((0.0008)*Fs); % Number of samples before first stim artifact and after last stim artifact to call artifact
        artifactBufferAfter = ceil((0.0026)*Fs);
        
        if strcmp(currentStim,'6mA')
            stimChanNames = {'OFG45','OFG48'};
            threshold = -4000; % for artifact detection
            artifactBufferBefore = ceil((0.0008)*Fs); % Number of samples before first stim artifact and after last stim artifact to call artifact
            artifactBufferAfter = ceil((0.0028)*Fs);
        elseif strcmp(currentStim,'1mA')
            stimChanNames = {'OFG45','OFG48'};
            threshold = 1000; % for artifact detection
        elseif strcmp(currentStim,'DorsalCingulate')
            stimChanNames = {'CD3','CD4'};
            plotChan = 45; % for visualization
            threshold = 2800; % for artifact detection
        elseif strcmp(currentStim,'Insula')
            stimChanNames = {'ID2','ID3'};
            plotChan = 55; % for visualization
            threshold = 4500; % for artifact detection
        end
        
        verifiedChanNames = {'OFG1','OFG2','OFG3','OFG4','OFG5','OFG6','OFG7',...
            'OFG8','OFG9','OFG10','OFG11','OFG12','OFG13','OFG14','OFG15',...
            'OFG16','OFG17','OFG18','OFG19','OFG20','OFG21','OFG22','OFG23',...
            'OFG24','OFG25','OFG26','OFG27','OFG28','OFG29','OFG30','OFG31',...
            'OFG32','OFG33','OFG34','OFG35','OFG36','OFG37','OFG38','OFG39',...
            'OFG40','OFG41','OFG42','OFG43','OFG44','OFG45','OFG46','OFG47',...
            'OFG48','OFG49','OFG50','OFG51','OFG52','OFG53','OFG54','OFG55',...
            'OFG56','OFG57','OFG58','OFG59','OFG60','OFG61','OFG62','OFG63',...
            'OFG64','AD1','AD2','AD3','AD4','AD5','AD6','HD1','HD2','HD3',...
            'HD4','CD3','CD4','ID1','ID2','ID3','ID4','ID5'};
        verifiedRegions = [1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1,...
            1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1,...
            1 1 1 1 2 2 2 2 2 2 3 3 3 3 4 4 5 5 5 5 5];
        regionNames = {'OFC','Amygdala','Hippocampus','Cingulate','Insula'};
        
    elseif strcmp(patientID,'EC129')
        nonGridChans = 65:154; % out of original 'anatomy'
        rawData = temp.rawData;
        plotChan = 25; % for visualization
        if strcmp(currentStim,'6mA')
            stimChanNames = {'OFA3','OFP3'};
            threshold = -2000; % for artifact detection
            artifactBufferBefore = ceil((0.0008)*Fs); % Number of samples before first stim artifact and after last stim artifact to call artifact
            artifactBufferAfter = ceil((0.0026)*Fs);
        elseif strcmp(currentStim,'DorsalCingulate')
            stimChanNames = {'CD1','CD2'};
            threshold = 4500; % for artifact detection
            plotChan = 62; % for visualization
        elseif strcmp(currentStim,'VentralCingulate')
            stimChanNames = {'CV1','CV2'};
            threshold = 4000; % for artifact detection
            plotChan = 58; % for visualization
        end
        
        verifiedChanNames = {'OFA2','OFA3','OFA4','OFP2','OFP3','OFP4',...
            'AD1','AD2','HD1','HD2','HD3','AD3','AD4','CV1','CV2','CD2','CD3'};
        verifiedRegions = [1 1 1 1 1 1 2 2 3 3 3 3 3 4 4 5 5];
        regionNames = {'OFC','Amygdala','Hippocampus','Ventral Cingulate','Dorsal Cingulate'};
        
    elseif strcmp(patientID,'EC125')
        nonGridChans = 65:146; % out of original 'anatomy'
        plotChan = 51; % for visualization
        
        artifactBufferBefore = ceil((0.0008)*Fs); % Number of samples before first stim artifact and after last stim artifact to call artifact
        artifactBufferAfter = ceil((0.0026)*Fs);
        if strcmp(currentStim,'6mA')
            stimChanNames = {'AOF3','POF3'};
            rawData = temp.during6mA;
            threshold = 5000; % for artifact detection
        elseif strcmp(currentStim,'1mA')
            rawData = temp.during1mA;
            stimChanNames = {'AOF3','POF3'};
            threshold = 3000; % for artifact detection
            plotChan = 52; % for visualization
        elseif strcmp(currentStim,'VentralCingulate')
            rawData = temp.rawData;
            stimChanNames = {'IC3','IC4'};
            threshold = 2300; % for artifact detection
            plotChan = 46; % for visualization
        end
        
        verifiedChanNames = {'AOF1','AOF2','AOF4','POF1','POF2',...
            'POF4','AD2','AD3','AD4','HD1','HD2','HD3',...
            'SC3','SC4','IC2','IC3','IND1','IND2','IND3','IND4','IND5'};
        verifiedRegions = [1 1 1 1 1 1 2 2 2 3 3 3 4 4 5 5 6 6 6 6 6];
        regionNames = {'OFC','Amygdala','Hippocampus','SuperiorCingulate',...
            'InferiorCingulate','Insula'};
        
    elseif strcmp(patientID,'EC122')
        nonGridChans = [65:106 109:118 121:124]; % out of original 'anatomy'
        plotChan = 35;
        rawData = temp.rawData;
        rawData([43 44 55 56],:) = []; % Nan and EKG channels were kept in when rawData was extracted
        selectAnatomy = temp.selectAnatomy;
        selectAnatomy([43 44 55 56],:) = []; % Nan and EKG channels were kept in when rawData was extracted
        artifactBufferBefore = ceil((0.0007)*Fs); % Number of samples before first stim artifact and after last stim artifact to call artifact
        artifactBufferAfter = ceil((0.0015)*Fs);
        if strcmp(currentStim,'Insula')
            stimChanNames = {'ID3','ID5'};
            threshold = 15000; % for artifact detection
        end
        
        verifiedChanNames = {'OFS1','OFS2','OFS3','OFS4','AD2','AD3','AD4','HD1','HD2','HD3',...
            'ID1','ID2','ID3','ID4','ID5','ID6'};
        verifiedRegions = [1 1 1 1 2 2 2 3 3 3 4 4 4 4 4 4];
        regionNames = {'OFC','Amygdala','Hippocampus','Insula'};
        
    elseif strcmp(patientID,'EC108')
        nonGridChans = 65:188; % out of original 'anatomy'
        rawData = temp.rawData;
        plotChan = 83; % for visualization
        artifactBufferBefore = ceil((0.0008)*Fs); % Number of samples before first stim artifact and after last stim artifact to call artifact
        artifactBufferAfter = ceil((0.0026)*Fs);
        
        if strcmp(currentStim,'6mA')
            threshold = 5000; % for artifact detection
        elseif strcmp(currentStim,'1mA')
            threshold = 800; % for artifact detection
        end
        
        stimChanNames = {'OF7','OF31'};
        verifiedChanNames = {'OF1','OF2','OF3','OF4','OF5','OF6','OF7','OF8',...
            'OF9','OF10','OF11','OF12','OF13','OF14','OF15','OF16','OF17',...
            'OF18','OF19','OF20','OF21','OF22','OF23','OF24','OF25','OF26',...
            'OF27','OF28','OF29','OF30','OF31','OF32','AD1','AD2','AD3','AD4',...
            'HD1','HD2','CD3','CD4','ID5'};
        verifiedRegions = [1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1,...
            1 1 1 1 1 2 2 2 2 3 3 4 4 5];
        regionNames = {'OFC','Amygdala','Hippocampus','Cingulate','Insula'};
        
    elseif strcmp(patientID,'EC105')
        nonGridChans = 65:144; % out of original 'anatomy'
        rawData = temp.rawData;
        plotChan = 74; % for visualization
        artifactBufferBefore = ceil((0.0007)*Fs); % Number of samples before first stim artifact and after last stim artifact to call artifact
        artifactBufferAfter = ceil((0.0015)*Fs);
        
        if strcmp(currentStim,'6mA')
            stimChanNames = {'OFMG4','OFMG12'};
            threshold = 5000; % for artifact detection
            artifactBufferBefore = ceil((0.0008)*Fs); % Number of samples before first stim artifact and after last stim artifact to call artifact
            artifactBufferAfter = ceil((0.002)*Fs);
        elseif strcmp(currentStim,'1mA')
            stimChanNames = {'OFMG4','OFMG12'};
            threshold = 1500; % for artifact detection
        elseif strcmp(currentStim,'1mA_MedOFC')
            stimChanNames = {'OFMG5','OFMG13'};
            threshold = 8000; % for artifact detection
            plotChan = 6; % for visualization
        elseif strcmp(currentStim,'3mA_MedOFC')
            stimChanNames = {'OFMG5','OFMG13'};
            threshold = 8000; % for artifact detection
            plotChan = 6; % for visualization
        elseif strcmp(currentStim,'6mA_MedOFC')
            stimChanNames = {'OFMG5','OFMG13'};
            threshold = 8000; % for artifact detection
            plotChan = 6; % for visualization
        end
        
        verifiedChanNames = {'OFMG1','OFMG2','OFMG3','OFMG4','OFMG5',...
            'OFMG6','OFMG7','OFMG8','OFMG9','OFMG10','OFMG11','OFMG12',...
            'OFMG13','OFMG14','OFMG15','OFMG16','AD1','AD2','AD3','AD4',...
            'HD2','HD3','HD4','CD3','CD4','ID3','ID4','ID5'};
        verifiedRegions = [1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 2 2 2 2 3 3 3 4 4 5 5 5];
        regionNames = {'OFC','Amygdala','Hippocampus','Dorsal Cingulate','Insula'};
        
    elseif strcmp(patientID,'EC99')
        nonGridChans = 1:110; % out of original 'anatomy'
        rawData = temp.rawData;
        
        artifactBufferBefore = ceil((0.0008)*Fs); % Number of samples before first stim artifact and after last stim artifact to call artifact
        artifactBufferAfter = ceil((0.002)*Fs);
        
        if strcmp(currentStim,'6mA_Right') % These electrodes not in right OFC
            stimChanNames = {'ROF3','ROF5'};
            plotChan = 103; % for visualization
            threshold = 8000; % for artifact detection
        end
        
        verifiedChanNames = {'ROF1','ROF2','RH1','RH2','RH3','RH4','RC1','RC2',...
            'RI1','RI2','RI3','LH1','LH2','LH3','LH4','LC1','LC2','LI1','LI2','LI3'};
        verifiedRegions = [1 1 2 2 2 2 3 3 4 4 4 5 5 5 5 6 6 7 7 7];
        regionNames = {'Right OFC','Right Hippocampus','Right Dorsal Cingulate','Right Insula',...
            'Left Hippocampus','Left Dorsal Cingulate','Left Insula'};
    end
    
elseif dataType == 2 % TDT
    if strcmp(patientID,'EC175')
        originalChans = 1:length(selectAnatomy);
    else
        originalChans = 1:length(anatomy); % including non ECoG channels
    end
    indices = strfind(fileName,'_');
    block = fileName(indices(1) + 1: indices(2) - 1);
    
    if strcmp(patientID,'EC175')
        switch block
            case '1mA'
                threshold = -350;
                artifactBufferBefore = ceil((0.0006)*Fs); % Number of samples before first stim artifact and after last stim artifact to call artifact
                artifactBufferAfter = ceil((0.0006)*Fs);
        end
        stimChanNames = {'OFA3','OFB3'};
        plotChan = 1;
        
        verifiedChanNames = {'OFA1','OFA2','OFA3','OFB1','OFB2','OFB3',...
            'AD1','AD2','AD3','AD4',...
            'HD2','HD3','HD4','HD5',...
            'ID1','ID2','ID3','ID4','ID5',...
            'CD3','CD4'};
        verifiedRegions = [1 1 1 1 1 1 2 2 2 2 3 3 3 3 4 4 4 4 4 5 5];
        regionNames = {'OFC','Amygdala','Hippocampus','Insula','DorsalCingulate'};
        
    elseif strcmp(patientID,'EC142') % rawData has grid channels removed already
        switch block
            case 'B28' % Insula
                artifactBufferBefore = ceil((0.0022)*Fs); % Number of samples before first stim artifact and after last stim artifact to call artifact
                artifactBufferAfter = ceil((0.0022)*Fs);
                stimChanNames = {'INS2','INS3'};
                threshold = 1200;
                plotChan = 85; % for visualization
            case 'B29' % Ventral Cingulate
                artifactBufferBefore = ceil((0.0022)*Fs); % Number of samples before first stim artifact and after last stim artifact to call artifact
                artifactBufferAfter = ceil((0.0028)*Fs);
                stimChanNames = {'VC2','VC3'};
                threshold = 2000; % for artifact detection
                plotChan = 67; % for visualization
            case 'B30' % Amygdala
                artifactBufferBefore = ceil((0.0022)*Fs); % Number of samples before first stim artifact and after last stim artifact to call artifact
                artifactBufferAfter = ceil((0.0028)*Fs);
                stimChanNames = {'AD1','AD2'};
                threshold = 900; % for artifact detection
                plotChan = 40; % for visualization
            case 'B31' % 6mA OFC
                artifactBufferBefore = ceil((0.0022)*Fs); % Number of samples before first stim artifact and after last stim artifact to call artifact
                artifactBufferAfter = ceil((0.0028)*Fs);
                stimChanNames = {'OFA3','OFB3'};
                threshold = 2000; % for artifact detection
                plotChan = 7; % for visualization
            case 'B32' % Medial OFC 6mA
                artifactBufferBefore = ceil((0.0022)*Fs); % Number of samples before first stim artifact and after last stim artifact to call artifact
                artifactBufferAfter = ceil((0.0028)*Fs);
                stimChanNames = {'OFA1','OFB1'};
                threshold = 1500; % for artifact detection
                plotChan = 7; % for visualization
        end
        verifiedChanNames = {'OFA1','OFA2','OFA3','OFB1','OFB2','OFB3',...
            'AD1','AD2','AD3','AD4','AD5',...
            'HD1','HD2','HD3',...
            'INS1','INS2','INS3','INS4','INS5',...
            'VC1','VC2','DC2','DC3'};
        verifiedRegions = [1 1 1 1 1 1 2 2 2 2 2 3 3 3 4 4 4 4 4 5 5 6 6];
        regionNames = {'OFC','Amygdala','Hippocampus','Insula','Ventral Cingulate','Dorsal Cingulate'};
    end
    % Scale to uV
    rawData = rawData * 1e6;
elseif dataType == 3 % NeuroOmega data
    if strcmp(patientID,'EC150')
        if strcmp(currentStim,'DorsalCingulate_Left')
            artifactBufferBefore = ceil((0.0008)*Fs);
            artifactBufferAfter = ceil((0.0008)*Fs);
            stimChanNames = {'L Dorsal Cingulate 1','L Dorsal Cingulate 2'};
            threshold = 4000; % for artifact detection
            plotChan = 1; % for visualization
        elseif strcmp(currentStim,'Insula_Left')
            artifactBufferBefore = ceil((0.0008)*Fs);
            artifactBufferAfter = ceil((0.0008)*Fs);
            stimChanNames = {'L Insula 2','L Insula 3'};
            threshold = 3000; % for artifact detection
            plotChan = 1; % for visualization
        elseif strcmp(currentStim,'VentralCingulate_Left')
            artifactBufferBefore = ceil((0.0003)*Fs);
            artifactBufferAfter = ceil((0.0008)*Fs);
            stimChanNames = {'L Ventral Cingulate 1','L Ventral Cingulate 2'};
            threshold = 5000; % for artifact detection
            plotChan = 21; % for visualization
        end
        % Use only electrodes which are ipsilateral to stimulation
        if contains(currentStim,'Right') % right hemisphere stimulation
            verifiedChanNames = {'R OFC 1','R OFC 2','R OFC 3','R OFC 4',...
                'R OFC 5','R OFC 6','R OFC 7',...
                'R Amygdala 1','R Amygdala 2',...
                'R Hippocampus 1','R Hippocampus 2','R Hippocampus 3','R Hippocampus 4','R Hippocampus 5',...
                'R Ventral Cingulate 1',...
                'R Insula 1','R Insula 2','R Insula 3'};
            verifiedRegions = [1 1 1 1 1 1 1 2 2 3 3 3 3 3 4 5 5 5];
            regionNames = {'OFC','Amygdala','Hippocampus','Ventral Cingulate','Insula'};
        elseif contains(currentStim,'Left') % left hemisphere stimulation
            verifiedChanNames = {'L OFC 1','L OFC 2','L OFC 3','L OFC 4',...
                'L OFC 5','L OFC 6','L OFC 7',...
                'L Hippocampus 1','L Hippocampus 2','L Hippocampus 3','L Hippocampus 4','L Hippocampus 5',...
                'L Ventral Cingulate 1','L Ventral Cingulate 2',...
                'L Dorsal Cingulate 1','L Dorsal Cingulate 2',...
                'L Insula 2','L Insula 3','L Insula 4','L Insula 5'};
            verifiedRegions = [1 1 1 1 1 1 1 2 2 2 2 2 3 3 4 4 5 5 5 5];
            regionNames = {'OFC','Hippocampus','Ventral Cingulate','Dorsal Cingulate','Insula'};
        end
    elseif strcmp(patientID,'EC152')
        if strcmp(currentStim,'1mA')
            artifactBufferBefore = ceil((0.0003)*Fs); % Number of samples before first stim artifact and after last stim artifact to call artifact
            artifactBufferAfter = ceil((0.0008)*Fs);
            stimChanNames = {'OFC3','OFC7'};
            threshold = 4000; % for artifact detection
            plotChan = 5; % for visualization
        end
        verifiedChanNames = {'OFC2','OFC3','OFC4','OFC6','OFC7','OFC8',...
            'Amygdala 2','Amygdala 3','Amygdala 4',...
            'Hippocampus 1','Hippocampus 2','Hippocampus 3'};
        verifiedRegions = [1 1 1 1 1 1 2 2 2 3 3 3];
        regionNames = {'OFC','Amygdala','Hippocampus'};
    elseif strcmp(patientID,'EC155')
        if strcmp(currentStim,'1mA')
            artifactBufferBefore = ceil((0.0003)*Fs); % Number of samples before first stim artifact and after last stim artifact to call artifact
            artifactBufferAfter = ceil((0.0008)*Fs);
            stimChanNames = {'OFC 3','OFC 4'};
            threshold = 3000; % for artifact detection
            plotChan = 1; % for visualization
        end
        verifiedChanNames = {'OFC 1','OFC 2','OFC 3','OFC 4',...
            'Amygdala 1','Amygdala 2','Amygdala 3',...
            'Hippocampus 1','Hippocampus 2','Hippocampus 3',...
            'Insula 1','Insula 2','Insula 3',...
            'Dorsal Cingulate 2','Dorsal Cingulate 3'};
        verifiedRegions = [1 1 1 1 2 2 2 3 3 3 4 4 4 5 5];
        regionNames = {'OFC','Amygdala','Hippocampus','Insula','Dorsal Cingulate'};
        
    end
end

%%
if ~exist('selectAnatomy','var')
    % Remove non-relevant channels (e.g. grid)
    rejectChans = [];
    for iChan = nonGridChans
        if isempty(anatomy{iChan,4})
            rejectChans = [rejectChans iChan];
        end
    end
    
    rejectChans_fromAnatomy = [rejectChans setdiff(originalChans, nonGridChans)]; % remove channels above and grid channels
    selectAnatomy = anatomy;
    selectAnatomy(rejectChans_fromAnatomy,:) = [];
end

for iStimChan = 1:length(stimChanNames)
    if ~isempty(find(ismember(selectAnatomy(:,1),stimChanNames(iStimChan))))
        stimChans(iStimChan) = find(ismember(selectAnatomy(:,1),stimChanNames(iStimChan)));
    else
        stimChans = [];
    end
end

% Don't automatically reject stim chans; incorporate flag from above
if rejectStimChans == 1
    rawData(stimChans,:) = [];
    selectAnatomy(stimChans,:) = [];
end
numChannels = size(rawData,1);

originalSelectAnatomy = selectAnatomy;

%%
% Ensure proper data is included
stimTimeBase = 1/Fs:1/Fs:size(rawData,2)/Fs;

figure
clf
plot(stimTimeBase, rawData(plotChan,:));
xlabel('Time [s]')
title(selectAnatomy{plotChan,1})
%%
% Determine stim artifact indices
stimIndices = determineStimTimes(rawData(plotChan,:),threshold,stimFreq,Fs);

% Remove inappropraitely detected stimIndices
if strcmp(patientID,'EC133') && strcmp(currentStim,'Insula')
    stimIndices(stimIndices > 1311777) = [];
elseif strcmp(patientID,'EC122') && strcmp(currentStim,'Insula')
    stimIndices(stimIndices > 2322375) = [];
elseif strcmp(patientID,'EC153') && strcmp(currentStim,'6mA')
    stimIndices(stimIndices > 371646) = [];
    stimIndices(stimIndices < 122989) = [];
elseif strcmp(patientID,'EC153') && strcmp(currentStim,'MedOFC_3mA')
    stimIndices(stimIndices > 687075) = [];
    stimIndices(stimIndices < 425534) = [];
elseif strcmp(patientID,'EC153') && strcmp(currentStim,'MedOFC_6mA')
    stimIndices(stimIndices > 515797) = [];
elseif strcmp(patientID,'EC153') && strcmp(currentStim,'VentralCingulate_6mA')
    stimIndices(stimIndices > 418373) = [];
end

artifactStarts = stimIndices - artifactBufferBefore;
artifactEnds = stimIndices + artifactBufferAfter;

%%
% Verify stim artifact identification
toPlot = rawData(plotChan,:);
figure;
clf
plot(toPlot)
hold on

scatter(artifactStarts,zeros(1,length(artifactStarts)) ,'g')
scatter(artifactEnds,zeros(1,length(artifactEnds)),'r')

%%
% Plot distribution of diffs between artifactStarts and artifactEnds -- will help to see if
% there are missing start times
diffStarts = diff(artifactStarts);
diffEnds = diff(artifactEnds);
durations = artifactEnds - artifactStarts;

figure
clf
subplot(1,3,1)
hist(diffStarts,50)
xlabel('Samples')
title('Diffs: Artifact Starts')
subplot(1,3,2)
hist(diffEnds,50)
xlabel('Samples')
title('Diffs: Artifact Ends')
subplot(1,3,3)
hist(durations,50)
xlabel('Samples')
title('Artifact Durations')

%%
% Artifact removal
stimRemovedData = splineStimArtifact(rawData,artifactStarts,artifactEnds);

%%
% Bandpass filtering [2 250] -- should remove large transient from stim onset and
% offset
filterOrder = 4;
passBand = [2 250];
disp('Bandpass filtering data: [2-250]Hz')
filtStimRemovedData = butterworthBPFilter(stimRemovedData,passBand,filterOrder,Fs);

%%
% Notch filter in order to determine channels to reject. However,
% apply the channel rejections to these rejections to filtStimRemovedData
notchFreq = 60;
filterOrder = 4;
disp('60Hz (and harmonics) notch filtering')
dataToPlot = filtStimRemovedData;
while notchFreq < 250 % changed from Fs/2, since bandpass is at 250Hz
    dataToPlot = butterworthNotchFilter(dataToPlot,notchFreq,filterOrder,Fs);
    notchFreq = notchFreq + 60; % get harmonics
end

%%
% Manually rejected channels
[chansRejectedData,allRejectedChans,selectAnatomy] = manuallyRejectChannels(dataToPlot,filtStimRemovedData,selectAnatomy,Fs);
clear dataToPlot

%%
% CAR across all remaining channels
disp('CAR rereferencing')
reref = nanmean(chansRejectedData,1);
rerefStimRemovedData = bsxfun(@minus,chansRejectedData,reref);

clear chansRejectedData
%%
% Pull out anatomically verified channels
counter = 0;
for iVerifiedChan = 1:length(verifiedChanNames)
    if sum(ismember(selectAnatomy(:,1),verifiedChanNames(iVerifiedChan))) == 1
        counter = counter + 1;
        verifiedChans(counter) = find(ismember(selectAnatomy(:,1),verifiedChanNames(iVerifiedChan)));
        finalVerifiedChanNames{counter} = verifiedChanNames{iVerifiedChan};
        finalVerifiedRegions(counter) = verifiedRegions(iVerifiedChan);
    end
end

selectECOG = rerefStimRemovedData(verifiedChans,:);
selectVerifiedAnatomy = selectAnatomy(verifiedChans,:);
numVerifiedChans = length(selectVerifiedAnatomy);

clear rerefStimRemovedData

%%
% Notch filter data
notchFreq = 60;
filterOrder = 4; % To make a 4th order filter
disp('60Hz notch filtering')
filtData = selectECOG;
while notchFreq < 250 % changed from Fs/2, since bandpass is at 250Hz
    filtData = butterworthNotchFilter(filtData,notchFreq,filterOrder,Fs);
    notchFreq = notchFreq + 60; % get harmonics
end

%%
% Filter at stimulation frequency
disp('Stim frequency notch filtering')
filterOrder = 4;
filtData = butterworthNotchFilter(filtData,stimFreq,filterOrder,Fs);

disp('Stim frequency notch filtering: Harmonic')
filterOrder = 4;
filtData = butterworthNotchFilter(filtData,stimFreq*2,filterOrder,Fs);

%%
% Manually select bad periods of data
manuallyRejectTimeSegments(filtData,Fs);
cleanedData = filtData;

if ~exist('tempMarkedRejection','var')
    tempMarkedRejection = [];
end
if removeOrReplace == 1 % Replacing bad data with zeros
    if ~isempty(tempMarkedRejection)
        for iRejection = 1:size(tempMarkedRejection,1)
            cleanedData(:,tempMarkedRejection(iRejection,3):tempMarkedRejection(iRejection,4)) = 0;
        end
        rejectionTimes = sortrows(tempMarkedRejection);
    end
    
elseif removeOrReplace == 2 % Removing bad data -- time is no longer accurate
    % Need to sort rejectionTimes so they are early to late
    rejectionTimes = sortrows(tempMarkedRejection);
    
    if ~isempty(tempMarkedRejection)
        for iRejection = size(rejectionTimes,1):-1:1
            cleanedData(:,rejectionTimes(iRejection,3):rejectionTimes(iRejection,4)) = [];
        end
    end
end
eegplot(cleanedData,'srate',Fs,...
    'winlength',30,'wincolor',[1 0 0],...
    'title','Cleaned Data');

%%
% Adjust stim start/end time if necessary
if removeOrReplace == 1
    plotStimStart = stimIndices(1);
    plotStimEnd = stimIndices(end);
elseif removeOrReplace == 2
    % Because time was deleted, need to adjust stimIndices
    subtractFromStart = 0;
    subtractFromEnd = 0;
    stimStart = stimIndices(1);
    stimEnd = stimIndices(end);
    
    for iRejectionTime = 1:size(rejectionTimes,1)
        % Adjust stim start time
        if rejectionTimes(iRejectionTime,3) < stimStart && rejectionTimes(iRejectionTime,4) < stimStart
            subtractFromStart = subtractFromStart + (rejectionTimes(iRejectionTime,4) - rejectionTimes(iRejectionTime,3) + 1);
        elseif rejectionTimes(iRejectionTime,3) < stimStart && rejectionTimes(iRejectionTime,4) > stimStart
            subtractFromStart = subtractFromStart + (rejectionTimes(iRejectionTime,3) - stimStart);
        end
        
        % Adjust stim end time
        if rejectionTimes(iRejectionTime,3) < stimEnd && rejectionTimes(iRejectionTime,4) < stimEnd
            subtractFromEnd = subtractFromEnd + (rejectionTimes(iRejectionTime,4) - rejectionTimes(iRejectionTime,3) + 1);
        elseif rejectionTimes(iRejectionTime,3) < stimEnd && rejectionTimes(iRejectionTime,4) > stimEnd
            subtractFromEnd = subtractFromEnd + (rejectionTimes(iRejectionTime,3) - stimEnd);
        end
    end
    
    plotStimStart = stimIndices(1) - subtractFromStart;
    plotStimEnd = stimIndices(end) - subtractFromEnd;
end
%%
% Downsample to 512 Hz, if sampling rate higher than 2kHz
if Fs > 2000
    dsFs = 512;
    preprocessedStimData = changeFs(cleanedData,dsFs,Fs);
else
    dsFs = Fs;
    preprocessedStimData = cleanedData;
end

%%
% Plot fully preprocessed data
eegplot(preprocessedStimData,'srate',dsFs,...
    'winlength',30,'title','Preprocessed Stim Data')
%%
% Save preprocessed data
saveFileName = [filePathECOG patientID '_preprocessedDuringContinuous_' currentStim '_FreqBands.mat'];
save(saveFileName,'preprocessedStimData','selectVerifiedAnatomy','dsFs','patientID','stimFreq','rejectionTimes',...
    'Fs','allRejectedChans','removeOrReplace','numVerifiedChans','regionNames','finalVerifiedRegions',...
    'finalVerifiedChanNames','artifactBufferBefore','artifactBufferAfter','artifactStarts','artifactEnds',...
    'plotStimStart','plotStimEnd','-v7.3')