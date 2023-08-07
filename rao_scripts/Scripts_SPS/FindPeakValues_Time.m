function [peakValuesBefore,peakValuesAfter,peakTimesBefore,peakTimesAfter,percentChange]= FindPeakValues_Time(numPulses,ERP,normEvokedZ,testSamples,p,pulseAfter)

peakValuesBefore = nan(numPulses,size(ERP{1},1));
peakValuesAfter = nan(numPulses,size(ERP{1},1));
peakTimesBefore = nan(numPulses,size(ERP{1},1));
peakTimesAfter = nan(numPulses,size(ERP{1},1));

Trou_Val_Bef = nan(numPulses,size(ERP{1},1));
Trou_Val_Aft = nan(numPulses,size(ERP{1},1));
Trou_Time_Bef = nan(numPulses,size(ERP{1},1));
Trou_Time_Aft = nan(numPulses,size(ERP{1},1));
percentChange = nan(numPulses,size(ERP{1},1));

for iChannel = 1:size(ERP{1},1)
    for iPulse = 1:numPulses
        apeakBef = abs(squeeze(normEvokedZ{Pulse_Before}(iPulse,iChannel,testSamples)));
        [peakValuesBefore(iPulse,iChannel),peakTimesBefore(iPulse,iChannel)] = max(apeakBef); % Positive Peak time
        [Trou_Val_Bef(iPulse,iChannel),Trou_Time_Bef(iPulse,iChannel)] = min(apeakBef);% Negative trough time and amplitude
        
        apeakAft = abs(squeeze(normEvokedZ{pulseAfter}(iPulse,iChannel,testSamples)));
        [peakValuesAfter(iPulse,iChannel),peakTimesAfter(iPulse,iChannel)] = max(apeakAft);
        [Trou_Val_Aft(iPulse,iChannel),Trou_Time_Aft(iPulse,iChannel)] = min(apeakAft);
        
        percentChange(iPulse,iChannel) =((peakValuesAfter(iPulse,iChannel) - peakValuesBefore(iPulse,iChannel))/peakValuesBefore(iPulse,iChannel))*100;
    end
end



