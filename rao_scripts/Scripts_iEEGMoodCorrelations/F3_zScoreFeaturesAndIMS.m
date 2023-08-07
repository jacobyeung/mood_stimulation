% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Omid Sani, Yuxiao Yang, Maryam Shanechi
%   Shanechi Lab, University of Southern California, 2018
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%F3_zScoreFeaturesAndIMS z-scores average features around IMS, and the IMS
% scores
%   Inputs:
%     - (1) feats: average features values. Dim 1: IMS instance, Dim 2: frequency band
%     - (2) IMSValues: score of IMS reports
%   Outputs:
%     - (1) subjDataStruct: a structure containing the z-scored powers and 
%  							the z-scored IMS scores
%
%   Usage example:
%       subjDataStruct = F3_zScoreFeaturesAndIMS(feats, IMSValues)

function subjDataStruct = F3_zScoreFeaturesAndIMS(feats, IMSValues)

    thisIMSValsZ = zScoreData( IMSValues(:) );
    thisFeatValsZ = zScoreData( feats );

    subjDataStruct = struct( ...
        'IMSValsZ', thisIMSValsZ, ...
        'FeatValsZ', thisFeatValsZ ...
    );

end

function newData = zScoreData(data)

    dataMean = mean(data, 1, 'omitnan'); 
    dataStd = std(data, 0, 1, 'omitnan');

    newData = (data - repmat(dataMean, [size(data, 1), 1])) ./ repmat(dataStd, [size(data, 1), 1]);

end
