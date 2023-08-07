function [G, H, P] = Plot_BeeSwamp(peakValuesBefore,peakValuesAfter,plotChans)

G = figure;
a = 1;
for k = 1:3:numel(plotChans)*3+1
    if a < numel(plotChans)+1
        
        h =scatter(repmat(k,20,1),peakValuesBefore(:,plotChans(a)),'go');
        set(h,'MarkerEdgeColor',[0 153 0]/256)
        hold on
        scatter(repmat(k+0.5,20,1),peakValuesAfter(:,plotChans(a)),'mo')
        h1 = plot([ k-0.5 k+0.5],repmat (mean(peakValuesBefore(:,plotChans(a))),1,2),'Color',[0 153 0]/256);
        h2 = plot([ k k+1],repmat (mean(peakValuesAfter(:,plotChans(a))),1,2),'-m');
        
        [H(a), P(a)] = ranksum(peakValuesBefore(:,plotChans(a)), peakValuesAfter(:,plotChans(a)));
        a = a+1
    end
end


set(gca,'Xtick',[1:3:numel(plotChans)*3+1])
set(gca,'XtickLabel',{'OFC1',  'OFC2' ,'OFC3','OFC4'},'Fontsize',14)
ylabel ('Peak Amplitude(z-score)','Fontsize',14)

legend([h1, h2],{'Before Non-OFC Continuous Stim','After Non-OFC Continuous Stim'},'Location','NorthWest')

