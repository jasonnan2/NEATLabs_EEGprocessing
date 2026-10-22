function behoutput = behavior_Analysis(tabledata)

%find the actual working block
desiredblock = find(tabledata.Block ~= 0);
actualdata = tabledata(desiredblock,:);

%performance events
perf = actualdata.Accuracy;
%reaction time events
rtime = actualdata.ResponseTime;
rtime = rtime/1000;

%stimulus based events, target and nonTarget trials
stim = actualdata.Stimulus;

%memory level:
level = stim(1);

%Accuracy:
nhits = find(perf == 1 & (stim == 1 | stim == 2 | stim == 3 | stim == 4 | stim == 5 | stim == 6 | stim == 7 | stim == 8 ));
nd = find(stim == 1 | stim == 2 | stim == 3 | stim == 4 | stim == 5 | stim == 6 | stim == 7 | stim == 8 );
nfalarms = find(rtime > 0 & perf == 0 & (stim == 1 | stim == 2 | stim == 3 | stim == 4 | stim == 5 | stim == 6 | stim == 7 | stim == 8));

dprime_acc(1) = dprime(length(nhits)/length(nd),length(nfalarms)/length(nd));


COV_m = mean(rtime(rtime>0));
COV_sd = std(rtime(rtime>0));
consistency(1) = (1-(COV_sd / COV_m)); %[0 1]*100

speed = log10(1 / COV_m);


% speed = speed / 10;
level = level / 8;
dprime_acc = dprime_acc / 4.65;

CumPerf = mean([level; dprime_acc; consistency; speed],1);

behoutput.values = [level, dprime_acc, consistency, speed, CumPerf];
behoutput.labels = {'level', 'dprime_acc', 'consistency', 'speed', 'CumPerf'};

end