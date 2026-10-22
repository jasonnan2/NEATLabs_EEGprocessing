function [EEGset, ProcessVars] = preProcessing(rawFile, behFile)
taskname = 'lost_star';
%The alignments of interest for EEG
indalign = [3]; %[2 4];
ProcessVars = struct;
EEGset = cell(length(indalign),1);
for aligni = 1:length(indalign)
    switch indalign(aligni)
        case 1
            ProcessVars(aligni).alignnum = 1;
            ProcessVars(aligni).alignname = 'tria';
        case 2
            ProcessVars(aligni).alignnum = 2;
            ProcessVars(aligni).alignname = 'stim';
            
        case 3
            ProcessVars(aligni).alignnum = 3;
            ProcessVars(aligni).alignname = 'resp';
            
        case 4
            ProcessVars(aligni).alignnum = 4;
            ProcessVars(aligni).alignname = 'fdbk';
            
        case 5
            ProcessVars(aligni).alignnum = 5;
            ProcessVars(aligni).alignname = 'prbe';
    end
    %%
    if any(ismember([1,2],ProcessVars(aligni).alignnum))
        ProcessVars(aligni).timelim = [-1 6.5];% for epoching, based on the time locking event
    else
        ProcessVars(aligni).timelim = [-0.5 0.5];% for epoching, based on the time locking event other than stim, say, feedback
    end
    ProcessVars(aligni).baseline = [-750 -550];
    %initializing other processing variables
    ProcessVars(aligni).srate = 250;
    ProcessVars(aligni).cutoffFreq = [1 45];
    
    %% load EEG
    load(rawFile); 
    %EEGmain = pop_loadxdf(rawFile);
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
    [EEGset{aligni}, ProcessVars(aligni).rejTrials,ProcessVars(aligni).EpochTrials] = lost_star.epoching(EEGmain, ProcessVars(aligni).timelim, ProcessVars(aligni).alignnum, taskname);
    EEGset{aligni}.setname = ProcessVars(aligni).alignname;
    %load behaviorfile
    try
        behtabledata = readtable(behFile,'Sheet',2);
    catch
        behtabledata = readtable(behFile);
    end
    [ProcessVars(aligni).behOutput] = lost_star.behavior_Analysis(behtabledata); %, rejTrials, EpochTrials);
    %collect different trial groups / conditions
    [ProcessVars(aligni).trialset, ProcessVars(aligni).behtabledata] = lost_star.behavior_events(behtabledata, ProcessVars(aligni).rejTrials, ProcessVars(aligni).EpochTrials);
    
    %% Glm analysis vars
    %finding the indices of the eegepoch that belongs to a condition (here,
    %all trials)
    trialsetind = ProcessVars(aligni).trialset(end).ind;
    %GLM for the all expt block
    %calculate the design matrix
    indblock = find(behtabledata(trialsetind,:).Block ~= 0);
    behdata = behtabledata(trialsetind(indblock),:);
    %categorical variables
    trialtype = behdata.Stimulus;
    % trialtype_dummy = dummyvar(logical(trialtype)); %the stim threshold
    % categoryvar = [trialtype_dummy];
    %continuous performance variable
    acc = behdata.Accuracy;
    acc(acc == 0) = -1;
    rtime = behdata.ResponseTime./1000;
    rtime(rtime == -.001) = 1.001; %Ceiling the nogo trials wo the max reaction time
    speed = log10(1 ./ rtime); %for no-resp or resp-inhibited trials, the value expected will be log10(1/1.0001) = -0.000434
    perf = [acc.*speed];
    % Xglm = [trialtype, acc, speed, trialtype.*acc.*speed];
    %The design matrix here
    % Xglm = [categoryvar.*perf]; %perf weighted category variable (block1 go, block1 nogo block2 go, block2 nogo)
    ProcessVars(aligni).Xglm{1} = [perf ];
    ProcessVars(aligni).trialsetind{1} = trialsetind; %the set of trials in the epoched EEG
    ProcessVars(aligni).blockind{1} = indblock; %the block mask
end

end