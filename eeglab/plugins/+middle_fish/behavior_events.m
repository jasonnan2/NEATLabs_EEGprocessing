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
    
    
    %stimulus based events, target congruent and incongruent trials
    stim = actualdata.Stimulus;
    
    congruent = desiredblock(find(stim == 1 | stim == 2 | stim == 3 | stim == 4));
    incongruent = desiredblock(find(stim == 5 | stim == 6 | stim == 7 | stim == 8));
    
    trialset(5).ind = congruent;
    trialset(5).condition = 'Congruent';
    trialset(6).ind = incongruent;
    trialset(6).condition = 'Incongruent';
    
    
    %responses- different ones
    stim = actualdata.Stimulus;
    
    congruent = desiredblock(find(stim == 1 | stim == 2 | stim == 5 | stim == 6));
    incongruent = desiredblock(find(stim == 3 | stim == 4 | stim == 7 | stim == 8));
    
    trialset(5).ind = congruent;
    trialset(5).condition = 'Left Target';
    trialset(6).ind = incongruent;
    trialset(6).condition = 'Right Target';
    
    
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
