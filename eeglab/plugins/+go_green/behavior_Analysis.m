function behoutput = behavior_Analysis(tabledata)

%find the actual working block
desiredblock = find(tabledata.Block == 1);
actualdata = tabledata(desiredblock,:);

%performance events
perf = actualdata.Accuracy;
%reaction time events
rtime = actualdata.ResponseTime;
rtime = rtime/1000;

%stimulus based events, target and nonTarget trials
stim = actualdata.Stimulus;

%go green:
%Accuracy per block:
nhits = find(perf == 1 & (stim == 1 | stim == 2));
ndhits = find(stim == 1 | stim == 2);
nfalarms = find(perf == 0 & (stim == 21 | stim == 22 | stim == 23 | stim == 24 | stim == 25 | stim == 26 | stim == 27 | stim == 28 | stim == 29 | stim == 30));
ndfalarms = find(stim == 21 | stim == 22 | stim == 23 | stim == 24 | stim == 25 | stim == 26 | stim == 27 | stim == 28 | stim == 29 | stim == 30);

dprime_acc(1) = dprime(length(nhits)/length(ndhits),length(nfalarms)/length(ndfalarms));


COV_m = mean(rtime(rtime> 0));
COV_sd = std(rtime(rtime>0));
consistency(1) = (1-(COV_sd / COV_m));

speed(1) = log10(1 / COV_m);

%2nd block

desiredblock = find(tabledata.Block == 2);
actualdata = tabledata(desiredblock,:);


%performance events
perf = actualdata.Accuracy;
%reaction time events
rtime = actualdata.ResponseTime;
rtime = rtime/1000;

%stimulus based events, target and nonTarget trials
stim = actualdata.Stimulus;

%go green:
%Accuracy per block:
nhits = find(perf == 1 & (stim == 1 | stim == 2));
ndhits = find(stim == 1 | stim == 2);
nfalarms = find(perf == 0 & (stim == 21 | stim == 22 | stim == 23 | stim == 24 | stim == 25 | stim == 26 | stim == 27 | stim == 28 | stim == 29 | stim == 30));
ndfalarms = find(stim == 21 | stim == 22 | stim == 23 | stim == 24 | stim == 25 | stim == 26 | stim == 27 | stim == 28 | stim == 29 | stim == 30);

dprime_acc(2) = dprime(length(nhits)/length(ndhits),length(nfalarms)/length(ndfalarms));


COV_m = mean(rtime(rtime>0));
COV_sd = std(rtime(rtime>0));
consistency(2) = (1-(COV_sd / COV_m));

speed(2) = log10(1 / COV_m);


dprime_acc = dprime_acc ./ 4.65;

CumPerf = mean([dprime_acc; consistency; speed],1);

% speed = speed ./ 10; %[0 1] scale
behoutput.values = [dprime_acc, consistency, speed, CumPerf];
behoutput.labels = {'dprime_acc block 1', 'dprime_acc block 2', 'consistency block 1', 'consistency block 2', 'speed block 1', 'speed block 2', 'CumPerf block 1', 'CumPerf block 2'};


end