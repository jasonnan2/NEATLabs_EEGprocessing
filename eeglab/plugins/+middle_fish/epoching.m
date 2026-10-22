% %%% for checking: 
% flag_alignment = ProcessVars(aligni).alignnum;
% timelim = ProcessVars(aligni).timelim;
% EEG = EEGmain;

function [EEG,rejTrials,EpochTrials] = epoching(EEG, timelim, flag_alignment, taskname)
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

%%%%%%%%%%first obtain all the trials, with respect to the trial onset

middle_fish_events = strfind(eventType, 10);
startEvent = find(ismember(eventType,200001));

if isempty(startEvent)
    startEvent = find(ismember(eventType,[2001]));
end
if isempty(startEvent)
    startEvent = find(ismember(eventType,[200]));
    startEvent(1) = [];
end

endEvent   = find(ismember(eventType,200201));
if isempty(endEvent)
    endEvent = find(ismember(eventType,201));
end
middle_fish_events = middle_fish_events(middle_fish_events > startEvent(1) & middle_fish_events < endEvent(end));

%Now adjust the start time based on the alignment needed
if flag_alignment == 1 %trial onset
    
    EpochTrials = ~isnan(middle_fish_events);
    
    latency = {eventLatency(middle_fish_events)};
    eventType = {[taskname]};
    
elseif flag_alignment == 2 %stim onset
    
    %finding the position of the target events
    Targetevents = [1:8];
    
    [new_middle_fish_events,EpochTrials] = compute_events(middle_fish_events, eventType, Targetevents);
    
    new_middle_fish_events = new_middle_fish_events(EpochTrials);
    
    latency = {eventLatency(new_middle_fish_events)};
    
    eventType = {[taskname '_stim']};
    
elseif flag_alignment == 3 %resp onset
    
    %finding the position of the target events
    Targetevents = [11:13];
    
    [new_middle_fish_events,EpochTrials] = compute_events(middle_fish_events, eventType, Targetevents);
    
    new_middle_fish_events = new_middle_fish_events(EpochTrials);
    
    latency = {eventLatency(new_middle_fish_events)};
    
    eventType = {[taskname '_resp']};
    
else %flag == 4, feedback onset
    
    %finding the position of the target events
    Targetevents = [14, 15];
    
    [new_middle_fish_events,EpochTrials] = compute_events(middle_fish_events, eventType, Targetevents);
    
    new_middle_fish_events = new_middle_fish_events(EpochTrials);
    
    latency = {eventLatency(new_middle_fish_events)};
    
    eventType = {[taskname '_fdbk']};
end

EEG = eeg_addnewevents(EEG,latency, eventType);
EEG = pop_epoch( EEG, eventType, timelim, 'epochinfo', 'yes');
[EEG, rejTrials] = pop_autorej(EEG, 'nogui','on','eegplot','off');
end


