function [filtData] = butterworthNotchFilter(data,notchFreq,order,Fs)
% 3/6/2018: Kristin Sellers
%
% Input parameters:
% data = channels x samples
% notchFreq = frequency for centering notch filter, in Hz
% order = filter order
% Fs = data sampling rate, in Hz
%%
% If only 1 channel, want channel x samples
if iscolumn(data)
   data = data';
end

runOrder = order/2; % because implementing bandpass filter for notch

% Define filter parameters
Fc = [notchFreq-2 notchFreq+2];
Fn = Fs/2;
Wn = Fc/Fn;
[b1, a1] = butter(runOrder, Wn, 'stop');

% Run notch filter
for iChan = 1:size(data,1)
    filtData(iChan,:) = filtfilt(b1,a1,data(iChan,:));
end

end