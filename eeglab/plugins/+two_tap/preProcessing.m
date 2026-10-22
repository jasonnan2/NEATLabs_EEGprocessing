



function [EEGset, ProcessVars] = preProcessing(rawFile, behFile)
taskname = 'twotap';
%The alignments of interest for EEG
indalign = [1];
ProcessVars = struct;
EEGset = cell(length(indalign),1);
for aligni = 1:length(indalign)
    switch indalign(aligni)
        case 1
            ProcessVars(aligni).alignnum = 1;
            ProcessVars(aligni).alignname = 'stim'; %calling the resp as stim (just to maintain the naming of baseline across tasks)
    end
    %%
    ProcessVars(aligni).timelim = [-4 0];% for epoching, based on the time locking event
    ProcessVars(aligni).baseline = [];
    %initializing other processing variables
    ProcessVars(aligni).srate = 250;
    ProcessVars(aligni).cutoffFreq = [1 45];
    
    %% load EEG
    %load(rawFile);
    try
        EEGmain = pop_loadxdf(rawFile);
    catch
        load(rawFile)
    end
    EEGmain.data = double(EEGmain.data);
    EEGmain = pop_resample( EEGmain, ProcessVars(aligni).srate);
    EEGmain = pop_eegfiltnew(EEGmain, ProcessVars(aligni).cutoffFreq(1), ProcessVars(aligni).cutoffFreq(2), 826,0,[],0);
    EEGmain = pop_reref( EEGmain, []);
    ind = find(ismember({EEGmain.chanlocs.labels},'TIMESTAMP'));
    if ~isempty(ind)
        EEGmain = pop_select(EEGmain,'nochannel',ind);
    end
    try %#ok
        EEGmain = pop_chanedit(EEGmain, 'eval','chans = pop_chancenter( chans, [],[]);');
    end
    %channel file specification, locate, find theta (using cartesian 2 polar
    %conversions for every channel
    xyz = [cell2mat({EEGmain.chanlocs.X})' cell2mat({EEGmain.chanlocs.Y})' cell2mat({EEGmain.chanlocs.Z})'];
    xyz = bsxfun(@minus,xyz,mean(xyz));
    for k=1:EEGmain.nbchan
        EEGmain.chanlocs(k).X = xyz(k,1);
        EEGmain.chanlocs(k).Y = xyz(k,2);
        EEGmain.chanlocs(k).Z = xyz(k,3);
        [EEGmain.chanlocs(k).theta, EEGmain.chanlocs(k).radius] = cart2pol(xyz(k,1), xyz(k,2), xyz(k,3));
        EEGmain.chanlocs(k).theta = -EEGmain.chanlocs(k).theta*180/pi;
    end
    %% epoching in the time period mentioned, parsing the behavior events and perform behavior analysis
    [EEGset{aligni}, ProcessVars(aligni).rejTrials,ProcessVars(aligni).EpochTrials] = two_tap.epoching(EEGmain, ProcessVars(aligni).timelim, ProcessVars(aligni).alignnum, taskname);
    EEGset{aligni}.setname = ProcessVars(aligni).alignname;
    %load behaviorfile
    try
        behtabledata = readtable(behFile,'Sheet',3);
    catch
        behtabledata = readtable(behFile);
    end
    [ProcessVars(aligni).behOutput] = two_tap.behavior_Analysis(behtabledata); %, rejTrials, EpochTrials);
    %collect different trial groups / conditions
    [ProcessVars(aligni).trialset, ProcessVars(aligni).behtabledata] = two_tap.behavior_events(behtabledata, ProcessVars(aligni).rejTrials, ProcessVars(aligni).EpochTrials);
    
    %% Glm analysis vars
    %finding the indices of the eegepoch that belongs to a condition (here,
    %all trials)
    trialsetind = ProcessVars(aligni).trialset(end).ind;
    %GLM for the all expt block
    %calculate the design matrix
    %removes the reaction time entries that are 0
    indblock = find(behtabledata(trialsetind,:).Block < 3 & behtabledata(trialsetind,:).ResponseTime > 100); %Modified by SJ November 2025
    behdata = behtabledata(trialsetind(indblock),:);
    %no categorical variables
    %continuous performance variable
    rtime = behdata.ResponseTime./1000;
    %rtime = rtime(rtime>500); %Added by SJ November 2025
    speed = log10(rtime); 
    perf = [speed];
    %The design matrix here
    perf_discrete = zeros(size(perf));
    perf_discrete(abs(perf-mean(perf)) < std(perf)) = 1;    
    ProcessVars(aligni).Xglm{1} = [perf perf_discrete];
    ProcessVars(aligni).trialsetind{1} = trialsetind; %the set of trials in the epoched EEG
    ProcessVars(aligni).blockind{1} = indblock; %the block mask
end

end