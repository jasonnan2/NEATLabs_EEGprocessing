function behoutput = behavior_Analysis(tabledata)
%find the actual working block
%saxton changed 7/23 (changed variables from happy, sad, angry, neutral to
%pleasent, unpleasent, and control
%desiredblock = find(tabledata.Block ~= 0);
desiredblock = find(tabledata.Block >= 0); %We change this line of code to include the Practice Trials specifically for the Nature nod task

actualdata = tabledata(desiredblock,:);


%performance events
perf = actualdata.Accuracy;
%reaction time events
rtime = actualdata.ResponseTime;
rtime = rtime/1000;

%stimulus based events, target and nonTarget trials
stim = actualdata.Stimulus;

%Accuracy per block:
nhits_control = find(perf == 1 & stim == 1);
nd_control = find(stim == 1);
nfalarms_control = find(rtime > 0 & perf == 0 & stim == 1);

nhits_pleasant = find(perf == 1 & stim == 2);
nd_pleasant = find(stim == 2);
nfalarms_pleasant = find(rtime > 0 & perf == 0 & stim == 2);

nhits_unpleasant = find(perf == 1 & stim == 3);
nd_unpleasant = find(stim == 3);
nfalarms_unpleasant = find(rtime > 0 & perf == 0 & stim == 3);

dprime_acc_control = dprime(length(nhits_control)/length(nd_control),length(nfalarms_control)/length(nd_control));
dprime_acc_pleasant = dprime(length(nhits_pleasant)/length(nd_pleasant),length(nfalarms_pleasant)/length(nd_pleasant));
dprime_acc_unpleasant = dprime(length(nhits_unpleasant)/length(nd_unpleasant),length(nfalarms_unpleasant)/length(nd_unpleasant));

rtimepool = find(rtime>0);
COV_m = mean(rtime(intersect(nd_control, rtimepool)));
COV_sd = std(rtime(intersect(nd_control, rtimepool)));
consistency_control = (1-(COV_sd / COV_m)); %[0 1]*100
speed_control = log10(1 / COV_m);

COV_m = mean(rtime(intersect(nd_pleasant, rtimepool)));
COV_sd = std(rtime(intersect(nd_pleasant, rtimepool)));
consistency_pleasant = (1-(COV_sd / COV_m)); %[0 1]*100
speed_pleasant = log10(1 / COV_m);

COV_m = mean(rtime(intersect(nd_unpleasant, rtimepool)));
COV_sd = std(rtime(intersect(nd_unpleasant, rtimepool)));
consistency_unpleasant = (1-(COV_sd / COV_m)); %[0 1]*100
speed_unpleasant = log10(1 / COV_m);

dprime_acc_control = dprime_acc_control / 4.65;
dprime_acc_pleasant = dprime_acc_pleasant / 4.65;
dprime_acc_unpleasant = dprime_acc_unpleasant / 4.65;

CumPerf(1) = mean([dprime_acc_control; consistency_control; speed_control],1) ; %control
CumPerf(2) = mean([dprime_acc_pleasant; consistency_pleasant; speed_pleasant],1) ; %pleasant
CumPerf(3) = mean([dprime_acc_unpleasant; consistency_unpleasant; speed_unpleasant],1) ; %unpleasant


behoutput.values = [dprime_acc_control, dprime_acc_pleasant, dprime_acc_unpleasant, consistency_control, consistency_pleasant, consistency_unpleasant, speed_control, speed_pleasant, speed_unpleasant, CumPerf];
behoutput.labels = {'dprime_acc_control', 'dprime_acc_pleasant', 'dprime_acc_unpleasant', 'consistency_control', 'consistency_pleasant', 'consistency_unpleasant', 'speed_control', 'speed_pleasant', 'speed_unpleasant', 'CumPerf-control','CumPerf-pleasant','CumPerf-unpleasant'};

end