function [trialset,tabledata] = behavior_events(tabledata, rejTrials, EpochTrials)
%find the actual working block
%changed trial numbers due to deletion of some catagories (e.g sad)
try
%Taking away the beh data trials whose EEG has been rejected
tabledata = tabledata(EpochTrials,:); %first pooling the trials of interest
tabledata(rejTrials,:) = []; %taking out the rejected trials in the pooled set


%desiredblock = find(tabledata.Block ~= 0);
desiredblock = find(tabledata.Block >= 0); %We change this line of code to include the Practice Trials specifically for the Nature nod task


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

%saxton changed 7/23
Control = desiredblock(find(stim == 1));
Pleasant = desiredblock(find(stim == 2));
Unpleasant = desiredblock(find(stim == 3));

trialset(5).ind = Control;
trialset(5).condition = 'Control';
trialset(6).ind = Pleasant;
trialset(6).condition = 'Pleasant';
trialset(7).ind = Unpleasant;
trialset(7).condition = 'Unpleasant';


%Stim present in the upper / lower image

Upper = desiredblock(find(stim == 21 | stim == 22));
Lower = desiredblock(find(stim == 23 | stim == 24));

%left /right image
Left = desiredblock(find(stim == 21 | stim == 23));
Right = desiredblock(find(stim == 22 | stim == 24));

%saxton changed 7/23
trialset(8).ind = Upper;
trialset(8).condition = 'Upper';
trialset(9).ind = Lower;
trialset(9).condition = 'Lower';
trialset(10).ind = Left;
trialset(10).condition = 'Left';
trialset(11).ind = Right;
trialset(11).condition = 'Right';
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