function [trialset,tabledata] = behavior_events(tabledata, rejTrials, EpochTrials)
try
    tabledata = tabledata(EpochTrials,:); %first pooling the trials of interest
    tabledata(rejTrials,:) = []; %taking out the rejected trials in the pooled set
    
    desiredblock = find(tabledata.Block ~= 0);
    actualdata = tabledata(desiredblock,:);
    
    %performance events
    perf = actualdata.Accuracy;
    
    perf_inacc = desiredblock(find(perf == 0));
    perf_acc = desiredblock(find(perf == 1));
    
    trialset(1).ind = perf_inacc;
    trialset(1).condition = 'Inaccurate';
    
    trialset(2).ind = perf_acc;
    trialset(2).condition = 'Accurate';
    
    
    %reaction time events
    rtime = actualdata.ResponseTime;
    
    rtime_fast = desiredblock(find(rtime < median(rtime)));
    rtime_slow = desiredblock(find(rtime > median(rtime)));
    
    
    trialset(3).ind = rtime_fast;
    trialset(3).condition = 'RT fast';
    trialset(4).ind = rtime_slow;
    trialset(4).condition = 'RT slow';
    
    %stimulus based events, target and nonTarget trials
    stim = actualdata.Stimulus;
    
    Target = desiredblock(find(stim == 1 | stim == 2));
    NonTarget = desiredblock(find(stim == 21 | stim == 22 | stim == 23 | stim == 24 | stim == 25 | stim == 26 | stim == 27 | stim == 28 | stim == 29 | stim == 30));
    
    trialset(5).ind = Target;
    trialset(5).condition = 'Target';
    trialset(6).ind = NonTarget;
    trialset(6).condition = 'NonTarget';
    
    trialset(end+1).ind = desiredblock;
    trialset(end).condition = 'All Trials';
catch
    trialsetnow = 1:length(EpochTrials);
    trialsetnow = trialsetnow(EpochTrials);
    trialsetnow(rejTrials) = [];
    trialset.ind = 1:length(trialsetnow);
    trialset.condition = 'All Trials';
    actualdata = [];
end
end