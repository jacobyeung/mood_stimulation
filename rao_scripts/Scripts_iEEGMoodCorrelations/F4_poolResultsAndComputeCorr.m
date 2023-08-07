% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Omid Sani, Yuxiao Yang, Maryam Shanechi
%   Shanechi Lab, University of Southern California, 2018
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%F4_poolResultsAndComputeCorr Pools z-scored data from different subjects and
% computes correlation
%   Inputs:
%     - (1) allRes: The output of "F3_zScoreFeaturesAndIMS" for all subjects 
% 				put together in one array. 
% 				Contains the z-scored features and z-scored IMS from each 
%               subject in the following fields:
%                 'IMSValsZ': z-scored IMS scores
%                 'FeatValsZ': z-scored OFC power values. Dim 1 is data point 
% 			 				and Dim 2 is different frequency bands	
%   Outputs:
%     - (none) 
% 
%   Usage example:
%       F4_poolResultsAndComputeCorr(allRes)

function F4_poolResultsAndComputeCorr(allRes)

	% Collect the z-scored features and IMS
	allIMSZ = [];
	allFeatZ = [];
	for i = 1:length(allRes)
		thisRes = allRes(i);
		
		allIMSZ = cat(1, allIMSZ, thisRes.IMSValsZ);     % z-scored IMS scores
		allFeatZ = cat(1, allFeatZ, thisRes.FeatValsZ);  % z-scored OFC power values
	end

	for bi = 1:size(allFeatZ, 2) % For each frequency band
		x = allFeatZ(:, bi);
		y = allIMSZ;
		[rho, pVal] = corr(x, y, 'type', 'pearson');
		fprintf('Correlation in band #%d: rho = %.3g, P-value = %.3g\n', bi, rho, pVal);
	end
    
end
