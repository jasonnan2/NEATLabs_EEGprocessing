function [EEGset, ProcessVars] = preProcessing(rawFile, behFile, audioStart)
taskname = 'lion cage';
%The alignments of interest for EEG
indalign = [1 2];
ProcessVars = struct;
EEGset = cell(length(indalign),1);
for aligni = 1:length(indalign)
    switch indalign(aligni)
        case 1
            ProcessVars(aligni).alignnum = 1;
            ProcessVars(aligni).alignname = 'stimstd'; %calling the resp as stim (just to maintain the naming of baseline across tasks)

        case 2
            ProcessVars(aligni).alignnum = 2;
            ProcessVars(aligni).alignname = 'stimdev'; %calling the resp as stim (just to maintain the naming of baseline across tasks)
    end
    %%
    ProcessVars(aligni).timelim = [-1.5 1.5]; %+0.123;% for epoching, based on the time locking event
    ProcessVars(aligni).baseline = [];
    %initializing other processing variables
    ProcessVars(aligni).srate = 250;
    ProcessVars(aligni).cutoffFreq = [1 45];

    
    %% load EEG
    EEGmain = pop_loadxdf(rawFile);
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
    %[EEGset{aligni}, ProcessVars(aligni).rejTrials,ProcessVars(aligni).EpochTrials] = lion_cage.epoching(EEGmain, ProcessVars(aligni).timelim, ProcessVars(aligni).alignnum, taskname, audioStart);
    %EEGset{aligni}.setname = ProcessVars(aligni).alignname;
    %% Not using epoching
    EEGset{aligni}=EEGmain;
end

% chfile.timeAxis = EEGset{1}.times;
% flag_plot = 1;
% chfile.varhere = [];
% chfile.varhere(:,:,1,1) = mean(EEGset{1}.data,3); %avg across trials.. channels * time *freq * fac
% chfile.varhere(:,:,1,2) = mean(EEGset{2}.data,3); %avg across trials.. channels * time *freq * fac
% titlename = 'MMN- std and dev';
% brainepipeline_plotfn(flag_plot, chfile, 1, titlename)

end