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

go_green_events = strfind(eventType, 10);
startEvent = find(ismember(eventType,1000));
if isempty(startEvent)
    startEvent = find(ismember(eventType,[100]));
    startEvent(1) = [];
end
endEvent   = find(ismember(eventType,101));

go_green_events = go_green_events(go_green_events > startEvent(1) & go_green_events < endEvent(end));

%Now adjust the start time based on the alignment needed
if flag_alignment == 1 %trial onset
    
    EpochTrials = ~isnan(go_green_events);
    
    latency = {eventLatency(go_green_events)};
    eventType = {taskname};
    
elseif flag_alignment == 2 %stim onset
    
    %finding the position of the target events
    Targetevents = [1,2,21:30];
    
    [new_go_green_events,EpochTrials] = compute_events(go_green_events, eventType, Targetevents);
    
    new_go_green_events = new_go_green_events(EpochTrials);
    
    latency = {eventLatency(new_go_green_events)};
    
    eventType = {[taskname '_stim']};
    
elseif flag_alignment == 3 %resp onset
    
    %finding the position of the target events
    Targetevents = [11, 12, 13];
    
    [new_go_green_events,EpochTrials] = compute_events(go_green_events, eventType, Targetevents);
    
    new_go_green_events = new_go_green_events(EpochTrials);
    
    latency = {eventLatency(new_go_green_events)};
    
    eventType = {[taskname '_resp']};
    
else %flag == 4, feedback onset
    
    %finding the position of the target events
    Targetevents = [14, 15];
    
    [new_go_green_events,EpochTrials] = compute_events(go_green_events, eventType, Targetevents);
    
    new_go_green_events = new_go_green_events(EpochTrials);
    
    latency = {eventLatency(new_go_green_events)};
    
    eventType = {[taskname '_fdbk']};
end

EEG = eeg_addnewevents(EEG,latency, eventType);
EEG = pop_epoch( EEG, eventType, timelim, 'epochinfo', 'yes');
[EEG, rejTrials] = pop_autorej(EEG, 'nogui','on','eegplot','off');
end

