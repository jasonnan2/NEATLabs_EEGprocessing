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

lucky_door_events = strfind(eventType, 10);
startEvent = find(ismember(eventType,800001));

if isempty(startEvent)
    startEvent = find(ismember(eventType,[8001]));
end

endEvent   = find(ismember(eventType,800801));
if isempty(endEvent)
    endEvent = find(ismember(eventType,[801]));
end

lucky_door_events = lucky_door_events(lucky_door_events > startEvent(1) & lucky_door_events < endEvent(end));

%Now adjust the start time based on the alignment needed
if flag_alignment == 1 %trial onset
    
    EpochTrials = ~isnan(lucky_door_events);
    
    latency = {eventLatency(lucky_door_events)};
    eventType = {[taskname]};
    
elseif flag_alignment == 2 %stim onset
    
    %finding the position of the target events
    Targetevents = [1:3];
    
    [new_lucky_door_events,EpochTrials] = compute_events(lucky_door_events, eventType, Targetevents);
    
    new_lucky_door_events = new_lucky_door_events(EpochTrials);
    
    latency = {eventLatency(new_lucky_door_events)};
    
    eventType = {[taskname '_stim']};
    
elseif flag_alignment == 3 %resp onset
    
    %finding the position of the target events
    Targetevents = [11, 12, 13];  %21 or 22 for the choice door response?
    
    [new_lucky_door_events,EpochTrials] = compute_events(lucky_door_events, eventType, Targetevents);
    
    new_lucky_door_events = new_lucky_door_events(EpochTrials);
    
    latency = {eventLatency(new_lucky_door_events)};
    
    eventType = {[taskname '_resp']};
    
elseif flag_alignment == 4 %feedback onset
    
    %finding the position of the target events
    Targetevents = [14, 15];
    
    [new_lucky_door_events,EpochTrials] = compute_events(lucky_door_events, eventType, Targetevents);
    
    new_lucky_door_events = new_lucky_door_events(EpochTrials);
    
    latency = {eventLatency(new_lucky_door_events)};
    
    eventType = {[taskname '_fdbk']};
    
elseif flag_alignment == 5 %Coin Tally feedback onset
    
    %finding the position of the target events
    Targetevents = [16];
    
    [new_lucky_door_events,EpochTrials] = compute_events(lucky_door_events, eventType, Targetevents);
    
    new_lucky_door_events = new_lucky_door_events(EpochTrials);
    
    latency = {eventLatency(new_lucky_door_events)};
    
    eventType = {[taskname '_Totalfdbk']};
    
elseif flag_alignment == 7 %Choice
    
    %finding the position of the target events
    Targetevents = [21, 22];
    
    [new_lucky_door_events,EpochTrials] = compute_events(lucky_door_events, eventType, Targetevents);
    
    new_lucky_door_events = new_lucky_door_events(EpochTrials);
    
    latency = {eventLatency(new_lucky_door_events)};
    
    eventType = {[taskname '_Choice']};
    
end

EEG = eeg_addnewevents(EEG,latency, eventType);
EEG = pop_epoch( EEG, eventType, timelim, 'epochinfo', 'yes');
try
[EEG, rejTrials] = pop_autorej(EEG, 'nogui','on','eegplot','off');
catch
    rejTrials = [];
end
end
