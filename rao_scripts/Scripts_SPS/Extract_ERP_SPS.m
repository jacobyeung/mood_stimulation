function [ERP,zERP,normEvoked_allChans,normEvokedZ, SE_ERP, SE_zERP,blankAfter,blankBefore,Fs, Anatomy,selectChansLabels,selectChansRegions,removeChans] = Extract_ERP_SPS(RawData,Fs,Anatomy,peakDetectionChannel,patientID)

% Inputs
% Data = the matrix of raw data, channels x samples
% Fs = sampling frequency
% anatomy = channel locations
% peakDetectionChannel = channel to use for detecting timing of stimulation

% Output
% ERP: Mean ERPs after single pulses
% zERP: Zscored ERPs after single pulse
% normEvoked_allChans: ERPs after each single pulse
% normEvokedZ: Zscored ERPs after each signle pulse
% SE_ERP: Standard error of ERPs across trials
% SE_zERP: Standard error of zERP across trials
% blankBefore: Number of samples blanked before the peak of the stimulation artifact
% blankAfter: Number of samples blanked after the peak of the stimulation artifact
% selectChansLabels,selectChansRegions,removeChans are related to the
% badChanels and selectedChannels
%%  Extract the pulse times corresponding to each single pulse train in the data

% Determine stim times
apeak = RawData(peakDetectionChannel,:);
[peakValues,peakIndices] = findpeaks(abs(apeak));

% Set threshold for each patient
switch patientID
    case 'EC137'
        thresholdValue=34000;
    case 'EC139'
        thresholdValue=34000;
    case 'EC150'
        thresholdValue=2000;
    case 'EC153'
        thresholdValue= 20000;
    case 'EC155'
        thresholdValue= 34000;
end

selectIndices = peakIndices(peakValues > thresholdValue);

minDiff = Fs - 0.04*Fs; % Stimulation is at 1Hz
maxDiff = Fs + 0.04*Fs;

PulseTime = [];
% This part extracts all Pulse times except the last one in each pulse
% trains.
for i= 1 : length(selectIndices)-1
    if ((selectIndices(i+1) - selectIndices(i)) > minDiff) &&((selectIndices(i+1) - selectIndices(i) )< maxDiff) % if difference between current index and next index is less than minDiff, remove next index
        PulseTime = [PulseTime selectIndices(i)]; % Removed a value, thus need to re-test this same index again (because it will have a new value)
    end
end

if diff( PulseTime(end-1:end)) < minDiff
    PulseTime(end) = [];
end

if diff(PulseTime(end-1:end)) > Fs*2
    PulseTime(end) = [];
end

numPulses = 20;
% Extracts the last Pulse
EndSamples = find(diff(PulseTime)>maxDiff);
Pulse = cell(1,round(numel(PulseTime)/EndSamples(1)));

if EndSamples(1) <   numPulses % Pulse_Num=20 for each pulse train
    for i= 1: numel(Pulse)
        if i == 1
            Pulse{i} = PulseTime(1:EndSamples(1));
        elseif i == numel(Pulse)
            Pulse{i} = PulseTime(EndSamples(i-1)+1:end);
        else
            Pulse{i} = PulseTime(EndSamples(i-1)+1:EndSamples(i));
        end
    end
    
end

for i = 1:numel(Pulse)
    Pulse{i} = [Pulse{i} Pulse{i}(end)+Fs/1]; % The pulses are at 1 Hz , but if they are faster then that should be divided by the Pulse Freq
end

%%
% If required, manually select bad channels to remove for each recording
removeChans = [];
selectChans = setdiff(1:size(RawData,1), removeChans);
selectChansLabels = Anatomy(selectChans,1);
selectChansRegions = Anatomy(selectChans,4);
RawData(removeChans,:) = [];

%% Reformat the data into cells

SelectData = cell(1,numel(Pulse));
Pulse_Match = cell (1,numel(Pulse)) ; % this is similar as Pulse but matched samples as SelectData
% here we are just putting each train of data in one cell
% It includes 1sec before the first pulse and 1 sec after the last pulse

for i=1:numel(Pulse)
    SelectData{i} = RawData(:,Pulse{i}(1)-Fs:Pulse{i}(end)+Fs);
    Pulse_Match{i} = Pulse{i}-(Pulse{i}(1)-Fs) ; % The pulses are at 1 Hz, but if they are faster then that should be divided by the Pulse Freq
end

%% Stim blanking/ Artifact rejection by replacing the values from blank before to blank after by the averages of the two timepoints

% Starts and finishes for stim blanking
blankBefore = floor(Fs*0.005); % Blank 5ms samples before stim peak
blankAfter = floor(0.01*Fs); % Blank 10ms after stim peak
stimStarts = cell(1,numel(Pulse));  stimEnds = cell(1,numel(Pulse));

for i = 1:numel(Pulse)
    stimStarts{i} = Pulse_Match{i} - blankBefore;
    stimEnds{i} = Pulse_Match{i} + blankAfter;
end

% Stim blanking
blankedData =  SelectData;

for k = 1:numel(Pulse)
    for iStim = 1:length(stimStarts{k})
        replacementValues = ( SelectData{k}(:,stimStarts{k}(iStim)) +   SelectData{k}(:,stimEnds{k}(iStim)))/2;
        blankedData{k}(:,stimStarts{k}(iStim):stimEnds{k}(iStim)) = repmat(replacementValues,1,stimEnds{k}(iStim)-stimStarts{k}(iStim)+1);
        clear replacementValues
    end
end

%% Filter data
BP_filtData = blankedData;

[z_H,p_H,T_H] = butter(4,2*1/Fs,'high'); % high pass above 1 hz
[sos_H,G_H] = zp2sos(z_H,p_H,T_H);

[z_L,p_L,T_L] = butter(8,2*100/Fs,'low'); % low pass below 100 hz
[sos_L,G_L] = zp2sos(z_L,p_L,T_L);

for k = 1:numel(Pulse)
    if (size(BP_filtData{k},1)<size(BP_filtData{k},2))
        BP_filtData{k} = BP_filtData{k}';
    end
    
    BP_filtData{k} = filtfilt(sos_H,G_H,BP_filtData{k}); % high pass filter above 1 Hz
    BP_filtData{k} = filtfilt(sos_L,G_L,BP_filtData{k}); % low pas filter below 100 Hz
    
    total_time = tic;
    notchFreq = 60 ;
    
    while notchFreq <= 200 % notch filter
        step_time = tic;
        
        [z,p,T] = butter(2, [notchFreq-5 notchFreq+5]/ (Fs/2), 'stop');
        [sos,G] = zp2sos(z,p,T);
        
        BP_filtData{k} = filtfilt(sos,G,BP_filtData{k});
        
        fprintf('Done for Notch Freq = %d. It took %f (second). Total elapsed time %f (min) \n',...
            notchFreq, toc(step_time), toc(total_time)/60);
        notchFreq = notchFreq + 60 ; % get harmonics
    end
    BP_filtData{k} = BP_filtData{k}';
end

%% Align trials
stimTrials{k} = cell(1,numel(Pulse));
MidData = [];
for k = 1:numel(Pulse_Match)
    for iStim = 1:length(Pulse_Match{k})
        MidData(iStim,:,:) =  BP_filtData{k}(:,Pulse_Match{k}(iStim)-floor(Fs*0.5):Pulse_Match{k}(iStim) + floor(Fs*0.5)); %500ms before and 500ms after
    end
    stimTrials{k} = MidData;
end

%% Obtaining ZSCore

% Normalize on a trial-by-trial basis, average PER ELECTRODE

% Baseline = -300 to -100 relative to stim start; 200 to 400ms into trial
% This is treating each pulse train by its own baseline, for example the pulses after
% might have different baseline from before conditioning period

normEvoked_allChans = cell(1,numel(Pulse));
normEvokedZ = cell(1,numel(Pulse));
ERP = cell(1,numel(Pulse));
zERP = cell(1,numel(Pulse));
SE_ERP = cell(1,numel(Pulse));
SE_zERP = cell(1,numel(Pulse));

baselineTime = floor(Fs*0.2):floor(Fs*0.4);

for k = 1:numel(Pulse)
    meanBaseline = squeeze(nanmean(stimTrials{k}(:,:,baselineTime),3));
    stdBaseline = squeeze(nanstd(stimTrials{k}(:,:,baselineTime),1,3));
    
    normEvoked_allChans{k} = bsxfun(@minus, stimTrials{k}, meanBaseline);
    normEvokedZ{k} = bsxfun(@rdivide, normEvoked_allChans{k}, stdBaseline);
    
    ERP{k} = squeeze(nanmean(normEvoked_allChans{k},1));
    zERP{k} = squeeze(nanmean(normEvokedZ{k},1));
    
    SE_ERP{k} = squeeze(std(normEvoked_allChans{k},0,1)./sqrt(numPulses));
    SE_zERP{k} = squeeze(std(normEvokedZ{k},0,1)./sqrt(numPulses));
    
end


