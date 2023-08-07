function [stimIndices] = determineStimTimes(data,threshold,stimFreq,Fs)
% 3/6/2018: Kristin Sellers
%
% Determine stimulation artifact times based on first peak exceeding a
% predefined threshold
%
% Input parameters:
% data = 1 channel x samples
% threshold = voltage for threshold to detect artifacts
% stimFreq = frequency of stimulation, in Hz
% Fs = data sampling rate, in Hz
%
% Note: This function will not work if Chronux is on the path (Chronux has a different 'findpeaks')
%%

if threshold > 0
    [peakValues,peakIndices] = findpeaks(data);
    stimIndices = peakIndices(peakValues > threshold); % Only keep peaks greater than threshold
else
    [peakValues,peakIndices] = findpeaks(-data);
    stimIndices = peakIndices(peakValues > -threshold); % Only keep peaks greater than threshold
end

minDiff = ((1/stimFreq)/2 )*Fs; % Minimun difference between adjacent stimIndices must be at least 1/2 the samples between each stim pulse

iLoop = 1;
while (iLoop + 1 < length(stimIndices))
    if (stimIndices(iLoop+1) - stimIndices(iLoop) < minDiff) % if difference between current index and next index is less than minDiff, remove next index
        stimIndices(iLoop+1) = []; % Removed a value, thus need to re-test this same index again (because it will have a new value)
    else
        iLoop = iLoop + 1; % If no value was removed, move on to test next index
    end
end

if diff(stimIndices(end-1:end)) < minDiff
    stimIndices(end) = [];
end

end