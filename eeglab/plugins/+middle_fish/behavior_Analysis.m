function behoutput = behavior_Analysis(tabledata)
%find the actual working block
desiredblock = find(tabledata.Block ~= 0);
actualdata = tabledata(desiredblock,:);

%performance events
perf = actualdata.Accuracy;

%reaction time events
rtime = actualdata.ResponseTime;
rtime = rtime/1000;

%stimulus based events, target congruent and incongruent trials
stim = actualdata.Stimulus;

%Cong / incong..
%distraction cost on accuracys
nhits_cong = find(perf == 1 & (stim == 1 | stim == 2 | stim == 3 | stim == 4));
nfalarms_cong = find(rtime > 0 & perf == 0 & (stim == 1 | stim == 2 | stim == 3 | stim == 4));
ncong = find(stim == 1 | stim == 2 | stim == 3 | stim == 4);

nhits_incong = find(perf == 1 & (stim == 5 | stim == 6 | stim == 7 | stim == 8));
nfalarms_incong = find(rtime > 0 & perf == 0 & (stim == 5 | stim == 6 | stim == 7 | stim == 8));
nincong = find(stim == 5 | stim == 6 | stim == 7 | stim == 8);

dprime_cong(1) = dprime(length(nhits_cong)/length(ncong),length(nfalarms_cong)/length(ncong));
dprime_incong(1) = dprime(length(nhits_incong)/length(nincong),length(nfalarms_incong)/length(nincong));

dprime_acc = dprime_incong - dprime_cong;

rtimepool = find(rtime>0);
COV_m_cong = mean(rtime(intersect(ncong,rtimepool)));
COV_sd_cong = std(rtime(intersect(ncong,rtimepool)));
COV_m_incong = mean(rtime(intersect(nincong,rtimepool)));
COV_sd_incong = std(rtime(intersect(nincong,rtimepool)));
distractorCost_consistency = [(1-(COV_sd_incong / COV_m_incong)) - (1-(COV_sd_cong / COV_m_cong))]; %[-1 1]

speed_cong = log10(1 / COV_m_cong);
speed_incong = log10(1 / COV_m_incong);

speed = speed_incong - speed_cong;

dprime_acc = dprime_acc / 4.65; %dprime_acc = (1 + dprime_acc)/2;
%distractorCost_consistency = (1 + distractorCost_consistency)/2;
CumPerf = mean([dprime_acc; distractorCost_consistency; speed],1);

behoutput.values = [dprime_acc, distractorCost_consistency, speed, CumPerf];
behoutput.labels = {'dprime_acc', 'distractorCost_consistency', 'speed', 'CumPerf'};
end