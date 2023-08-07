function [chansRejectedData,allRejectedChans,selectAnatomy] = manuallyRejectChannels(dataToPlot,dataToRejectFrom,selectAnatomy,Fs)
% 3/6/2018: Kristin Sellers
%
% Determine stimulation artifact times based on first peak exceeding a
% predefined threshold
%
% Input parameters:
% dataToPlot = data used for plotting, to determine which channels should
% be removed (may be filtered to aid visualization)
% dataToRejectFrom = data which will have channels removed
% selectAnatomy = Channel order information (select channels from 'anatomy' in clinical_elecs_all or TDT_elecs_all)
% Fs = data sampling rate, in Hz
%
% Note: This function requires EEGLAB functions
%%
originalSelectAnatomy = selectAnatomy;

display('Select channels to reject...')
eegplot(dataToPlot,'srate',Fs,...
    'winlength',30,'wincolor',[1 0 0],...
    'title','Determine channels to remove');
uiwait

% Indicate what channels to reject rejection of bad channels
dlgTitle = 'Channels To Remove';
prompt = {'Channels to remove:'};
numLines = 1;
tempChansToRemove = inputdlg(prompt,dlgTitle,numLines);

if ~isempty(tempChansToRemove)
    chansToRemove = sort(str2num(tempChansToRemove{:}));
    selectAnatomy(chansToRemove,:) = [];
    dataToPlot(chansToRemove,:) = [];
end
eegplot(dataToPlot,'srate',Fs,...
    'winlength',30,'wincolor',[1 0 0],...
    'title','Data after first set of channels removed');
uiwait

dlgTitle = 'Channels To Remove (second round)';
prompt = {'Channels to remove (second round):'};
numLines = 1;
tempChansToRemove2 = inputdlg(prompt,dlgTitle,numLines);
if ~isempty(tempChansToRemove2)
    chansToRemove2 = sort(str2num(tempChansToRemove2{:}));
    selectAnatomy(chansToRemove2,:) = [];
    dataToPlot(chansToRemove2,:) = [];
end
eegplot(dataToPlot,'srate',Fs,...
    'winlength',30,'wincolor',[1 0 0],...
    'title','Final channel selection');

% Determine what channels were removed
allRejectedChans = [];
for iChan = 1:length(originalSelectAnatomy)
    if ~ismember(originalSelectAnatomy(iChan), selectAnatomy)
        allRejectedChans = [allRejectedChans iChan];
    end
end

% Remove these channels from data which did not have notch filtering done
chansRejectedData = dataToRejectFrom;
chansRejectedData(allRejectedChans,:) = [];
end