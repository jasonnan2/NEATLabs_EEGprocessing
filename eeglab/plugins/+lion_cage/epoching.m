function [EEG,rejTrials,EpochTrials] = epoching(EEG, timelim, flag_alignment, taskname, audioStart)
%flag_alignment: 1) trial onset based, 2) stimulus onset based, 3) response
%based, 4) feedback based

eventType = {EEG.event.type};
eventLatency = cell2mat({EEG.event.latency});

% Remove 0 and 99 events
indz = ismember(eventType,{'0','99'});
eventType(indz) = [];
eventLatency(indz) = [];

for k=1:length(eventType)
    eventType{k} = str2double(eventType{k});
end
eventType = cell2mat(eventType);
indnan = isnan(eventType);
eventType(indnan) = [];
eventLatency(indnan) = [];

%Now adjust the start time based on the alignment needed
if flag_alignment == 1 %stim / standard onset
    
    %%%%%%%%%%first obtain all the trials, with respect to the trial onset
    
    lion_cage_events = strfind(eventType, 1);
    startEvent = find(ismember(eventType,900));
    
    endEvent   = find(ismember(eventType,901));
    
    lion_cage_events = lion_cage_events(lion_cage_events > startEvent(1) & lion_cage_events < endEvent(end));
    
    if ~isempty(lion_cage_events)
    
    %finding the position of the target events
    Targetevents = [1];
    
    [new_two_tap_events,EpochTrials] = compute_events(lion_cage_events, eventType, Targetevents);
    
    new_two_tap_events = new_two_tap_events(EpochTrials);
    
    latency = {eventLatency(new_two_tap_events)};
    
    eventType = {[taskname '_std']};
    
    end
    
elseif flag_alignment == 2 %stim /  deviant onset
    
    
    %%%%%%%%%%first obtain all the trials, with respect to the trial onset
    
    lion_cage_events = strfind(eventType, 2);
    startEvent = find(ismember(eventType,900));
    
    endEvent   = find(ismember(eventType,901));
    
    lion_cage_events = lion_cage_events(lion_cage_events > startEvent(1) & lion_cage_events < endEvent(end));
    
    if ~isempty(lion_cage_events)
    
    %finding the position of the target events
    Targetevents = [2];
    
    [new_two_tap_events, EpochTrials] = compute_events(lion_cage_events, eventType, Targetevents);
    
    new_two_tap_events = new_two_tap_events(EpochTrials);
    
    latency = {eventLatency(new_two_tap_events)};
    
    eventType = {[taskname '_dev']};
    end
    
end

if isempty(lion_cage_events)
    
    latency_start = eventLatency(startEvent);
    latency_end = eventLatency(endEvent);
    
    
    latency = {latency_start + audioStart + 300 : 300 : latency_end};
    eventType = {taskname};
    EpochTrials = 1:length(latency);
    
    load('/home/pragathib/Codes/eeglab/plugins/BrainEAnalysis/LionCage_markers.mat');

    if flag_alignment == 1
        ind_std = find(mrk == 1);
        ind_std = ind_std(ind_std < length(EpochTrials));
        EpochTrials = EpochTrials(ind_std);
        latency = latency{ind_std};
    else
        ind_dev = find(mrk == 2);
        ind_dev = ind_dev(ind_dev < length(EpochTrials));
        EpochTrials = EpochTrials(ind_dev);
        latency = latency{ind_dev};
    end

end
    

EEG = eeg_addnewevents(EEG,latency, eventType);
EEG = pop_epoch( EEG, eventType, timelim, 'epochinfo', 'yes');
[EEG, rejTrials] = pop_autorej(EEG, 'nogui','on','eegplot','off');
end


