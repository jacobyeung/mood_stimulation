function [splineData] = splineStimArtifact(data,artifactStarts,artifactEnds)
% 3/6/2018: Kristin Sellers
%
% Use cubic spline interpolation to replace identified stimulation
% artifact. Will ignore channels if first sample is NaN (assume full channel
% is nan if first sample is nan; checking if all elements are NaN is too slow)
%
% Input parameters:
% data = channels x samples
% artifactStarts = sample indices of where artifacts start
% artifactEnds = sample indices of where artifacts end
%%
% If only 1 channel, want channel x samples
if iscolumn(data)
    data = data';
end

splineData = data;

for iChan = 1:size(data,1)
    disp(['Spline interpolation: Channel ' num2str(iChan)])
    for iStim = 1:length(artifactStarts)
        if ~isnan(data(iChan,1))
            currentArtifactBounds = [artifactStarts(iStim) artifactEnds(iStim)];
            replacementValues = spline(currentArtifactBounds,splineData(iChan,currentArtifactBounds),artifactStarts(iStim):artifactEnds(iStim) );
            splineData(iChan,artifactStarts(iStim):artifactEnds(iStim)) = replacementValues;
            clear replacementValues
        end
    end
end

end