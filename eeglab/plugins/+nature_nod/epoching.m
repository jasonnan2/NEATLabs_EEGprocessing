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

nature_nod_events = strfind(eventType, 10);
startEvent = find(ismember(eventType,410001));
if isempty(startEvent)
startEvent = find(ismember(eventType,[410001]));
end
endEvent = find(ismember(eventType,410401));
if isempty(endEvent)
endEvent = find(ismember(eventType,[410401]));
end
if endEvent < startEvent
endEvent = length(eventType);
end
nature_nod_events = nature_nod_events(nature_nod_events > startEvent(end) & nature_nod_events < endEvent(end));

%Now adjust the start time based on the alignment needed
if flag_alignment == 1 %trial onset

 EpochTrials = ~isnan(nature_nod_events);
 
 latency = {eventLatency(nature_nod_events)};
 eventType = {[taskname]};
    
elseif flag_alignment == 2 %stim onset
    
    %finding the position of the target events
 Targetevents = [1:3, 21:24]; 

 [new_nature_nod_events,EpochTrials] = compute_events(nature_nod_events, eventType, Targetevents);

 new_nature_nod_events = new_nature_nod_events(EpochTrials);
 
 latency = {eventLatency(new_nature_nod_events)};
 eventType = {[taskname '_stim']};
    
elseif flag_alignment == 3 %resp onset
    
    %finding the position of the target events
 Targetevents = [11 12 13];

 [new_nature_nod_events,EpochTrials] = compute_events(nature_nod_events, eventType, Targetevents);

 new_nature_nod_events = new_nature_nod_events(EpochTrials);

 latency = {eventLatency(new_nature_nod_events)};

 eventType = {[taskname '_resp']};
    
elseif flag_alignment == 4 %feedback onset
    
    %finding the position of the target events

 Targetevents = [14, 15];

 [new_nature_nod_events,EpochTrials] = compute_events(nature_nod_events, eventType, Targetevents);

 new_nature_nod_events = new_nature_nod_events(EpochTrials);

 latency = {eventLatency(new_nature_nod_events)};

 eventType = {[taskname '_fdbk']};
    
end

EEG = eeg_addnewevents(EEG,latency, eventType);
EEG = pop_epoch( EEG, eventType, timelim, 'epochinfo', 'yes');
try
[EEG, rejTrials] = pop_autorej(EEG, 'nogui','on','eegplot','off');
catch
 rejTrials = [];
end
end
