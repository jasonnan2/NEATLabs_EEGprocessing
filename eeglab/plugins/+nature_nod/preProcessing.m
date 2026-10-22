function [EEGset, ProcessVars] = preProcessing(rawFile, behFile)
taskname = 'nature_nod'; %saxton changed 7/23
%The alignments of interest for EEG
indalign = [2, 3]; %[2 4];
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
    end
    %%
    if any(ismember([1,2],ProcessVars(aligni).alignnum))
        ProcessVars(aligni).timelim = [-1 1.8];% for epoching, based on the time locking event
    else
        ProcessVars(aligni).timelim = [-0.5 0.5];% for epoching, based on the time locking event other than stim, say, feedback
    end
    ProcessVars(aligni).baseline = [-750 -550];
    %initializing other processing variables
    ProcessVars(aligni).srate = 250;
    ProcessVars(aligni).cutoffFreq = [1 45];
   
    %% load EEG
    load(rawFile); 
    %EEGmain = pop_xdfload(rawFile);
    
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
   [EEGset{aligni}, ProcessVars(aligni).rejTrials,ProcessVars(aligni).EpochTrials] = nature_nod.epoching(EEGmain, ProcessVars(aligni).timelim, ProcessVars(aligni).alignnum, taskname); %saxton changed 7/23
    EEGset{aligni}.setname = ProcessVars(aligni).alignname;
    %load behaviorfile
    try
        behtabledata = readtable(behFile,'Sheet',6); %saxton changed 7/24
    catch
        behtabledata = readtable(behFile);
    end
    [ProcessVars(aligni).behOutput] = nature_nod.behavior_Analysis(behtabledata); %, rejTrials, EpochTrials);
    %collect different trial groups / conditions
    [ProcessVars(aligni).trialset, ProcessVars(aligni).behtabledata] = nature_nod.behavior_events(behtabledata, ProcessVars(aligni).rejTrials, ProcessVars(aligni).EpochTrials);
    
    %% Glm analysis vars
    %finding the indices of the eegepoch that belongs to a condition (here,
    %all trials)
    trialsetind = ProcessVars(aligni).trialset(end).ind;
    %GLM for the all expt block
    %calculate the design matrix
    indblock = find(behtabledata(trialsetind,:).Block ~= 0);
    %indblock = find(behtabledata(trialsetind,:).Block ==-1); % 09/12/2025 nature nod task has block == -1 in brainE for all trials
                    
    behdata = behtabledata(trialsetind(indblock),:);
    %categorical variables
    trialtype = behdata.Stimulus;
    trialtype(find(ismember(trialtype,[1]))) = 1; %control %saxton changed 7/23
    trialtype(find(ismember(trialtype,[2]))) = 2; %pleasant
    trialtype(find(ismember(trialtype,[3]))) = 3; %unpleasant
    
    categoryvar = [];
    
    %saxton changed 7/23
%pleasant
trialtype_dummy = trialtype; trialtype_dummy(trialtype_dummy == 1) = -1; trialtype_dummy(trialtype_dummy == 2) = 1; trialtype_dummy(trialtype_dummy == 3) = 0;
categoryvar(:,1) = trialtype_dummy;

%unpleasant
trialtype_dummy = trialtype; trialtype_dummy(trialtype_dummy == 1) = -1; trialtype_dummy(trialtype_dummy == 3) = 1; trialtype_dummy(trialtype_dummy == 2) = 0;
categoryvar(:,2) = trialtype_dummy;
    
    %continuous performance variable
    acc = behdata.Accuracy;
    acc(acc == 0) = -1;
    rtime = behdata.ResponseTime./1000;
    rtime(rtime == -.001) = 1.001; %Ceiling the nogo trials wo the max reaction time
    %subtract mean neutral RT
    mrtime_control = mean(rtime(trialtype == 1)); %saxton changed 7/23 (neutral -> control)
    speed = log10(1 ./ rtime) - log10(1 / mrtime_control); %for no-resp or resp-inhibited trials, the value expected will be log10(1/1.0001) = -0.000434 
    %find performance relative to neutral stim
    perf = [acc.*speed];
    
    % Xglm = [trialtype, acc, speed, trialtype.*acc.*speed];
    %The design matrix here
    % Xglm = [categoryvar.*perf]; %perf weighted category variable (block1 go, block1 nogo block2 go, block2 nogo)
    ProcessVars(aligni).Xglm{1} = [categoryvar(:,1:end) perf];
    ProcessVars(aligni).trialsetind{1} = trialsetind; %the trial inds from the epoched EEG
    ProcessVars(aligni).blockind{1} = indblock; %the block mask

end

end