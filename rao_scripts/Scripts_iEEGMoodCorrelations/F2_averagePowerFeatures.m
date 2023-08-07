% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Omid Sani, Yuxiao Yang, Maryam Shanechi
%   Shanechi Lab, University of Southern California, 2018
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%F2_averagePowerFeatures Averages the power features in OFC channels around
% the time of each IMS report
%   Inputs:
%     - (1) featureValues: power features extracted from OFC channels. 
%                           Dim 1: time, Dim 2: band, Dim 3: channel
%     - (2) featureTime: feature times
%     - (3) IMSTimes: time of IMS reports
%   Outputs:
%     - (1) feats: average features values. Dim 1: IMS instance, Dim 2: frequency band
%
%   Usage example:
%       [feats] = F2_averagePowerFeatures(featureValues, featureTime, IMSTimes);

function feats = F2_averagePowerFeatures(featureValues, featureTime, IMSTimes)
    
    winAroundIMS = 2*60*[-1 1]; % Window around IMS to average the features [in seconds]
    
    feats = [];
    for i = 1:length(IMSTimes)
        timePeriod = IMSTimes(i) + winAroundIMS;
        includeInAverage = find(featureTime >= timePeriod(1) & featureTime <= timePeriod(2));
        for bi = 1:size(featureValues, 2) % For each frequency band
            bandFeatsAroundIMS = featureValues(includeInAverage, bi, :);
            thisFeatValue = mean( bandFeatsAroundIMS(:), 'omitnan' ); % Average feature over time and OFC channels
            feats(i, bi) = thisFeatValue;
        end
    end
    
end
