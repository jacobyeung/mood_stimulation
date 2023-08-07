function Plot_ERP_Bef_Aft_PeakVal_Perc_Wave(ChanNum,stimChan,zERP_Bef, zERP_Aft, SE_zERP_Bef,SE_zERP_Aft, anatomy, patientID, searchOffset, blankAfter,blankBefore,...
    Fs)

TimeEra = [Fs/2+1 :Fs/2+1+blankBefore+blankAfter+searchOffset*Fs];
zERP_Bef(:,TimeEra) = nan;
zERP_Aft(:,TimeEra) = nan;

for PlotChan = ChanNum
    figure(PlotChan)
    D = patch([ [1:TimeEra(1)-1] fliplr([1:TimeEra(1)-1]) ],[zERP_Bef(PlotChan,1:TimeEra(1)-1)+SE_zERP_Bef(PlotChan,1:TimeEra(1)-1) fliplr(zERP_Bef(PlotChan,1:TimeEra(1)-1)-SE_zERP_Bef(PlotChan,1:TimeEra(1)-1))],[204 255 153]/255);
    hold on
    D1 = patch([ [TimeEra(end)+1:size(zERP_Bef,2)] fliplr([TimeEra(end)+1:size(zERP_Bef,2)]) ],[zERP_Bef(PlotChan,TimeEra(end)+1:size(zERP_Bef,2))+SE_zERP_Bef(PlotChan,TimeEra(end)+1:size(zERP_Bef,2)) fliplr(zERP_Bef(PlotChan,TimeEra(end)+1:size(zERP_Bef,2))-SE_zERP_Bef(PlotChan,TimeEra(end)+1:size(zERP_Bef,2)))],[204 255 153]/255);
    
    set(D,'EdgeColor','none'); set(D1,'EdgeColor','none'); alpha (0.5);
    plot(zERP_Bef(PlotChan,:),'Color',[0 153 0]/255)
    
    D = patch([ [1:TimeEra(1)-1] fliplr([1:TimeEra(1)-1]) ],[zERP_Aft(PlotChan,1:TimeEra(1)-1)+SE_zERP_Aft(PlotChan,1:TimeEra(1)-1) fliplr(zERP_Aft(PlotChan,1:TimeEra(1)-1)-SE_zERP_Aft(PlotChan,1:TimeEra(1)-1))],[255,192,203]/255);
    hold on
    D1 = patch([ [TimeEra(end)+1:size(zERP_Aft,2)] fliplr([TimeEra(end)+1:size(zERP_Aft,2)]) ],[zERP_Aft(PlotChan,TimeEra(end)+1:size(zERP_Aft,2))+SE_zERP_Aft(PlotChan,TimeEra(end)+1:size(zERP_Aft,2)) fliplr(zERP_Aft(PlotChan,TimeEra(end)+1:size(zERP_Aft,2))-SE_zERP_Aft(PlotChan,TimeEra(end)+1:size(zERP_Aft,2)))],[255,192,203]/255);
    
    set(D,'EdgeColor','none'); set(D1,'EdgeColor','none'); alpha (0.5);
    plot(zERP_Aft(PlotChan,:),'Color',[199,21,133]/256)
    
    title([ patientID '-Chan='  anatomy{PlotChan,1}])
    if any(PlotChan == stimChan)
        title([patientID '-Chan=' num2str(PlotChan) ' ' anatomy{PlotChan,1}, 'StimChan'])
    end
    
    set(gca,'Xtick',Fs/2+1+ [  -Fs/20 0  Fs/10 Fs/5 ])
    set(gca,'Xticklabel',[  -50 0 100 200 ]) % Time in ms
    Y=get(gca,'Ylim');set(gca,'xlim',Fs/2+1+ [ -Fs/20 Fs/5])
    plot([Fs/2+1 Fs/2+1], [ Y(1) Y(2)],'k')% Blanking starts
    plot([Fs/2+1+blankBefore+blankAfter+searchOffset*Fs Fs/2+1+blankBefore+blankAfter+searchOffset*Fs], [ Y(1) Y(2)],'k')
    xlabel('Time from stim onet(ms)','FontSize',14)
    ylabel('ZScore','FontSize',14)
    set(gca,'Fontsize',14)
end