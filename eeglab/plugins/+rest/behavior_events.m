function [trialset, tabledata] = behavior_events(tabledata, rejTrials, EpochTrials)

%load behavioral data
% fullFileName1 = fullfile(pathname,behfilename);
%
% tabledata = readtable(fullFileName1);
try
    %Taking away the beh data trials whose EEG has been rejected
    tabledata = tabledata(EpochTrials,:); %first pooling the trials of interest
    tabledata(rejTrials,:) = []; %taking out the rejected trials in the pooled set
    
    
    %find the actual working block
    desiredblock = find(tabledata.Block < 2);
    actualdata = tabledata(desiredblock,:);
    
    %reaction time events
    rtime = actualdata.ResponseTime;
    
    rtime_fast = desiredblock(find(rtime < median(rtime)));
    rtime_slow = desiredblock(find(rtime > median(rtime)));
    
    
    trialset(1).ind = rtime_fast;
    trialset(1).condition = 'RT fast';
    trialset(2).ind = rtime_slow;
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
