function [trialset,tabledata] = behavior_events(tabledata, rejTrials, EpochTrials)
%find the actual working block
try
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
stim = actualdata.Stimulus;

Neutral  = desiredblock(find(stim == 1 | stim == 2));
Happy = desiredblock(find(stim == 3 | stim == 4));
Angry  = desiredblock(find(stim == 5 | stim == 6));
Sad = desiredblock(find(stim == 7 | stim == 8));

Male = desiredblock(find(stim == 1 | stim == 3 | stim == 5 | stim == 7 ));
Female = desiredblock(find(stim == 2 | stim == 4 | stim == 6 | stim == 8));

trialset(5).ind = Neutral;
trialset(5).condition = 'Neutral';
trialset(6).ind = Happy;
trialset(6).condition = 'Happy';
trialset(7).ind = Angry;
trialset(7).condition = 'Angry';
trialset(8).ind = Sad;
trialset(8).condition = 'Sad';

trialset(9).ind = Male;
trialset(9).condition = 'Male';
trialset(10).ind = Female;
trialset(10).condition = 'Female';


%Stim present in the upper / lower face

Upper = desiredblock(find(stim == 21 | stim == 22));
Lower = desiredblock(find(stim == 23 | stim == 24));

%left /right
Left = desiredblock(find(stim == 21 | stim == 23));
Right = desiredblock(find(stim == 22 | stim == 24));

trialset(11).ind = Upper;
trialset(11).condition = 'Upper';
trialset(12).ind = Lower;
trialset(12).condition = 'Lower';
trialset(13).ind = Left;
trialset(13).condition = 'Left';
trialset(14).ind = Right;
trialset(14).condition = 'Right';

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