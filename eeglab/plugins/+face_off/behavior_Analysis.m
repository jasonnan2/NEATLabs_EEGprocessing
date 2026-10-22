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

%Accuracy per block:
nhits_neutral = find(perf == 1 & (stim == 1 | stim == 2 ));
nd_neutral = find(stim == 1 | stim == 2 );
nfalarms_neutral = find(rtime > 0 & perf == 0 & (stim == 1 | stim == 2 ));

nhits_happy = find(perf == 1 & (stim == 3 | stim == 4 ));
nd_happy = find(stim == 3 | stim == 4 );
nfalarms_happy = find(rtime > 0 & perf == 0 & (stim == 3 | stim == 4 ));

nhits_angry = find(perf == 1 & (stim == 5 | stim == 6 ));
nd_angry = find(stim == 5 | stim == 6 );
nfalarms_angry = find(rtime > 0 & perf == 0 & (stim == 5 | stim == 6 ));

nhits_sad = find(perf == 1 & (stim == 7 | stim == 8 ));
nd_sad = find(stim == 7 | stim ==  8);
nfalarms_sad = find(rtime > 0 & perf == 0 & (stim == 7 | stim == 8 ));

dprime_acc_neutral = dprime(length(nhits_neutral)/length(nd_neutral),length(nfalarms_neutral)/length(nd_neutral));
dprime_acc_happy = dprime(length(nhits_happy)/length(nd_happy),length(nfalarms_happy)/length(nd_happy));
dprime_acc_angry = dprime(length(nhits_angry)/length(nd_angry),length(nfalarms_angry)/length(nd_angry));
dprime_acc_sad = dprime(length(nhits_sad)/length(nd_sad),length(nfalarms_sad)/length(nd_sad));


rtimepool = find(rtime>0);
COV_m = mean(rtime(intersect(nd_neutral, rtimepool)));
COV_sd = std(rtime(intersect(nd_neutral, rtimepool)));
consistency_neutral = (1-(COV_sd / COV_m)); %[0 1]*100
speed_neutral = log10(1 / COV_m);

COV_m = mean(rtime(intersect(nd_happy, rtimepool)));
COV_sd = std(rtime(intersect(nd_happy, rtimepool)));
consistency_happy = (1-(COV_sd / COV_m)); %[0 1]*100
speed_happy = log10(1 / COV_m);

COV_m = mean(rtime(intersect(nd_angry, rtimepool)));
COV_sd = std(rtime(intersect(nd_angry, rtimepool)));
consistency_angry = (1-(COV_sd / COV_m)); %[0 1]*100
speed_angry = log10(1 / COV_m);

COV_m = mean(rtime(intersect(nd_sad, rtimepool)));
COV_sd = std(rtime(intersect(nd_sad, rtimepool)));
consistency_sad = (1-(COV_sd / COV_m)); %[0 1]*100
speed_sad = log10(1 / COV_m);

dprime_acc_neutral = dprime_acc_neutral / 4.65;
dprime_acc_happy = dprime_acc_happy / 4.65;
dprime_acc_angry = dprime_acc_angry / 4.65;
dprime_acc_sad = dprime_acc_sad / 4.65;

CumPerf(1) = mean([dprime_acc_neutral; consistency_neutral; speed_neutral],1) ; %neutral
CumPerf(2) = mean([dprime_acc_happy; consistency_happy; speed_happy],1) ; %happy
CumPerf(3) = mean([dprime_acc_angry; consistency_angry; speed_angry],1) ; %angry
CumPerf(4) = mean([dprime_acc_sad; consistency_sad; speed_sad],1) ; %sad


behoutput.values = [dprime_acc_neutral, dprime_acc_happy, dprime_acc_angry, dprime_acc_sad, consistency_neutral, consistency_happy, consistency_angry, consistency_sad, speed_neutral, speed_happy, speed_angry, speed_sad, CumPerf];
behoutput.labels = {'dprime_acc_neutral', 'dprime_acc_happy', 'dprime_acc_angry', 'dprime_acc_sad', 'consistency_neutral', 'consistency_happy', 'consistency_angry', 'consistency_sad', 'speed_neutral', 'speed_happy', 'speed_angry', 'speed_sad', 'CumPerf-neutral','CumPerf-happy','CumPerf-angry','CumPerf-sad'};

end