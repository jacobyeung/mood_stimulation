% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Omid Sani, Yuxiao Yang, Maryam Shanechi
%   Shanechi Lab, University of Southern California, 2018
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%F1_extractPowerFeatures Extracts power features from preprocessed ECoG data 
%   Inputs:
%     - (1) prepRawData: Preprocessed ECoG data from OFC channels. Columns are channels.
%     - (2) time: column vector representing time of samples.
%     - (3) Fs: sampling rate of preprocessed data (in Hz)
%   Outputs:
%     - (1) secAllFeatures: features values. Dim 1: time, Dim 2: band,
%                                            Dim 3: channel
%     - (2) featTime: feature times
%
%   Usage example:
%       [featureValues, featureTime] = F1_extractPowerFeatures(rawData, time);

function [featureValues, featureTime] = F1_extractPowerFeatures(prepRawData, time, Fs)

    bands = [4 8; 8 12; 12 30]; % Frequency bands
    timeStep = 10;    % Power estimation time step/window (in seconds)
    
    featureTime = [];
    featureValues = [];
    % Compute samples in each time step
    numOfSteps = floor( size(prepRawData, 1) / (timeStep * Fs)); % Step count
    
    if numOfSteps > 0 % If enough samples for at least one step
        stepSamples = round( size(prepRawData, 1)/numOfSteps ); % Number of samples in each step

        winEndSamples = stepSamples:stepSamples:size(prepRawData, 1);    
        winStartSamples = winEndSamples-stepSamples+1;
        
        featureValues = nan(length(winStartSamples), size(bands, 1), size(prepRawData, 2));
        
        for bi = 1:size(bands, 1)
            band = bands(bi, :);

            for wi = 1:length(winStartSamples)
                winSampleInd = winStartSamples(wi) + (0:(stepSamples-1)); 
                
				[tempRes] = KS_processingHilbertTransform_filterbankGUI(prepRawData(winSampleInd, :)', Fs, band);
				% KS_processingHilbertTransform_filterbankGUI computes the power each band using Hilbert transform
				
                tempRes.envData = tempRes.envData.^2;             % Take square of analytical amplitude
                winBandPower = mean(mean(tempRes.envData, 2), 3); % Mean over time and freq
                featureValues(wi, bi, :) = winBandPower;
            end
        end
        featureValues = pow2db(featureValues + eps); % Take log from powers
        featureTime = time(winEndSamples(:));
    end

end
