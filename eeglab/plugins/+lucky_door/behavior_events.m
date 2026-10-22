function [trialset, tabledata] = behavior_events(tabledata, rejTrials, EpochTrials)
try
    %find the actual working block
    
    %Taking away the beh data trials whose EEG has been rejected
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
    
    
    %stimulus based events, Match probe and nonMatch probe
    ChoiceSeries = actualdata.ChoiceSeries;
    
    %Block 1 and Block 2 separately
    
    RareL = desiredblock(strfind(ChoiceSeries,'RareL'));
    RareG = desiredblock(strfind(ChoiceSeries,'RareG'));
    
    trialset(5).ind = RareL;
    trialset(5).condition = 'RareL';
    trialset(6).ind = RareG;
    trialset(6).condition = 'RareG';
    
    
    %trial feedback
    ChoiceValue = actualdata.ChoiceValue;
    
    ChoiceValue_neg = desiredblock(find(ChoiceValue < 0));
    ChoiceValue_pos = desiredblock(find(ChoiceValue > 0));
    
    trialset(5).ind = ChoiceValue_neg;
    trialset(5).condition = 'ChoiceValue_neg';
    trialset(6).ind = ChoiceValue_pos;
    trialset(6).condition = 'ChoiceValue_pos';
    
    
    %cum feedback
    
    CumValue = actualdata.CumulativeValue;
    
    CumValue_neg = desiredblock(find(CumValue < 0));
    CumValue_pos = desiredblock(find(CumValue > 0));
    
    trialset(5).ind = CumValue_neg;
    trialset(5).condition = 'Cumulative Value_neg';
    trialset(6).ind = CumValue_pos;
    trialset(6).condition = 'Cumulative Value_pos';
    
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