function [trialset, tabledata] = behavior_events_mad(tabledata, rejTrials, EpochTrials)

%load behavioral data
% fullFileName1 = fullfile(pathname,behfilename);
%
% tabledata = readtable(fullFileName1);
try
    %Taking away the beh data trials whose EEG has been rejected
    tabledata = tabledata(EpochTrials,:); %first pooling the trials of interest

    med = median(tabledata.ResponseTime);
    madRT = mad(tabledata.ResponseTime);
    
    tabledata(rejTrials,:) = []; %taking out the rejected trials in the pooled set
    
    desiredblock = find(tabledata.Block < 3);
    attendedPresses = behTbl.Accuracy==1 & behTbl.ResponseTime<med+madRT & behTbl.ResponseTime>med-madRT;
    slowPresses = behTbl.Accuracy==1 & behTbl.ResponseTime>med+madRT;
    trialset(1).ind = attendedPresses;
    trialset(1).condition = 'RT fast';
    trialset(2).ind = slowPresses;
    trialset(2).condition = 'RT slow';
    
    trialset(end+1).ind = desiredblock;
    trialset(end).condition = 'All Trials';
    
catch
    
    trialsetnow = 1:length(EpochTrials);
    trialsetnow = trialsetnow(EpochTrials);
    trialsetnow(rejTrials) = [];
    trialset.ind = 1:length(trialsetnow);   
    trialset.condition = 'All Trials';
end
end
