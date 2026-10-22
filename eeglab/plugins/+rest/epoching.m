
% timelim = ProcessVars(aligni).timelim;
% flag_alignment = ProcessVars(aligni).alignnum; 
% EEG = EEGmain;
% New LSL code
function [EEG,rejTrials,EpochTrials] = epoching(EEG, timelim, flag_alignment, taskname)
%flag_alignment: 1) trial onset based, 2) stimulus onset based, 3) response
%based, 4) feedback based

eventType = {EEG.event.type};
eventLatency = cell2mat({EEG.event.latency});


% % Remove 0 and 99 events
% indz = ismember(eventType,{'0','99'});
% eventType(indz) = [];
% eventLatency(indz) = [];

for k=1:length(eventType)
    eventType{k} = str2double(eventType{k});
end
eventType = cell2mat(eventType);
% indnan = isnan(eventType);
% eventType(indnan) = [];
% eventLatency(indnan) = [];

%%%%%%%%%%first obtain all the trials, with respect to the trial onset

startEvent = find(ismember(eventType,700000));
if isempty(startEvent)
    startEvent = find(ismember(eventType, 700000));
end 
endEvent   = find(ismember(eventType,700701));

if isempty(endEvent)
    endEvent = find(ismember(eventType, 700701));
end 

rest_events = [startEvent(1) endEvent(end)];


%% Dealing with pauses 

pause_event=find(eventType==700702);
resume_event=find(eventType==700703);

pause_index=eventLatency(pause_event); 
resume_index=eventLatency(resume_event); 

data=EEG.data(:,eventLatency(rest_events(1)):eventLatency(rest_events(2)));
time=[1:eventLatency(rest_events(2))-eventLatency(rest_events(1))];

num_pauses=length(pause_index);

if num_pauses~=0
    placeholder_index=cumsum(resume_index-pause_index+1);
    remove_idx=ones(1,round(placeholder_index(end)));
    remove_idx(1)=pause_index(1);
    remove_idx(1+placeholder_index(1:num_pauses-1))=pause_index(2:num_pauses)-resume_index(1:num_pauses-1);
    remove_idx=round(cumsum(remove_idx)); % index of all data points during pause
    data(:,remove_idx)=[]; % remove all the paused data points
    time(remove_idx)=[];
end
EEG.data=data;
EEG.times=time;

EEG.pnts = size(EEG.data,2);
%%% Update EPOCH event markers
EEG.event=EEG.event(rest_events(1):rest_events(2));
% Resetting latency to match new data
old_latency = [EEG.event.latency]; 
for num_event=1:size(EEG.event,2)
    EEG.event(num_event).latency = EEG.event(num_event).latency-min(old_latency)+1;
end

EEG.trials = size(EEG.data,3);
EEG.xmax=EEG.pnts/EEG.srate;

%This function requires data epochs
% [EEG, rejTrials] = pop_autorej(EEG, 'nogui','on','eegplot','off');
rejTrials = [];
EpochTrials = [];
end


