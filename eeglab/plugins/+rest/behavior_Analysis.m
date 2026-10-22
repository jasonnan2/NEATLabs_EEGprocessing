function behoutput = behavior_Analysis(tabledata)
%find the actual working block

desiredblock = find(tabledata.Block < 2);
actualdata = tabledata(desiredblock,:);

%reaction time events
rtime = actualdata.ResponseTime;
rtime = rtime/1000;

COV_m = mean(rtime(rtime> 0));
COV_sd = std(rtime(rtime>0));
consistency(1) = (1-(COV_sd / COV_m));

behoutput.values = [ consistency];
behoutput.labels = {'CumPerf'};

end