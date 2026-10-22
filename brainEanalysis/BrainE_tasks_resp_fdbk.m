%% Source loc for resp and fdbk periods for GG, MF, LS, FO
clear all;close all;clc
cd(PATH_TO_PROJECT_FOLDER) % Enter Path Here
addpath (PATH_TO_EEGLAB) % Enter Path Here
eeglab
%% CHANGE HERE TO RUN PRE/POST RESP/FDBK and different freq bands

rawData = '/media/owner/data3/Jason/Active/PERMA/Cognitve_Input_Files'; % folder with all subjects raw data
results = '/media/owner/data3/Jason/Active/PERMA/Results/PermaPost_results'; % folder where preprocessed results are saved

condition = 'fdbk'; % Change here between fdbk/resp/stim
timepoint = 'post'; % change here between post and pre

runTasks = [1,2,3,5]; % change here to only run specific tasks: order here {'go_green','middle_fish','lost_star','lucky_door','face_off','two_tap','rest'};
files = pickfiles(rawData,{'.xdf'}); % Runs one master folder (group/timepoint) at once. Change 'post' to 'pre' or any identifier that can seperate out group/timepoint identifier
clustype = 1; % Change 1-3 for theta, alpha, beta
freqNames = {'theta','alpha','beta'};

%%

saveFileName = ['./sourceData/' freqNames{clustype} '/' timepoint '_' condition '.mat']; % Have each freq band in it's own folder - keep in sourceData folder

[saveDir, ~, ~] = fileparts(saveFileName);
if ~isempty(saveDir) && ~isfolder(saveDir)
    mkdir(saveDir);
end

if strcmp(condition, 'stim')
    stimFieldName = sprintf('all_task_%s',   timepoint);
    tri2run = 3;

elseif strcmp(condition,'resp') | strcmp(condition,'fdbk')
    accFieldName   = sprintf('accurate_%s_%s',   timepoint, condition);
    inaccFieldName = sprintf('inaccurate_%s_%s', timepoint, condition);
    tri2run = 1:2;
else 
    error('Condition must be set to fdbk, resp, or stim')
end

cndnNames = {condition};

%%
files = natsortfiles(char(files));
Nsubjects = size(files,1);

taskNames = {'go_green','middle_fish','lost_star','lucky_door','face_off','two_tap','rest'};
Ntasks = length(taskNames);

%src localization
solverType = 'bsbl';
saveFull = true;
account4artifacts = true;

src2roiReductionType = 'mpower';
templatefile = '/media/owner/data3/eeglab/plugins/BrainEAnalysis/headModel_templateFile_32chan.mat'; 
conductivity = [0.33, 0.022, 0.33];
orientation = true;
windowSize = (40/1000)*250; 

%% %%correct  / incorrect
subjectcoll={};
for subject= 1:Nsubjects
    accurate2 = [];inaccurate2=[]; alltask=[];
    tabledata2 = [];
    rawFile = deblank(files(subject,:));
    [pathName, rawFileName] = fileparts(rawFile);
    disp(['Processing subject ' rawFileName ' ' num2str(subject) '/' num2str(Nsubjects)]);
    
    for taski= runTasks
        
        inaccurate1 = []; accurate1=[]; tempvar_3=[];
        
        try
            
            tscoreAct = zeros(3,68);
            
            task = taski;
            block = 1;
            
            
            %Focusing on ERS and ERD
            if task == 1
                pcfile.tfinfo{1} = [-1000 1000 3 8];
                pcfile.tfinfo{2} = [-1000 1000 8 12];
                pcfile.tfinfo{3} = [-1000 1000 13 30];
                
            elseif task == 6
                pcfile.tfinfo{1} = [-1000 1000 3 8];
                pcfile.tfinfo{2} = [-1000 1000 8 12];
                pcfile.tfinfo{3} = [-1000 1000 13 30];
                
            elseif task == 3
                pcfile.tfinfo{1} = [-1000 1000 3 8];
                pcfile.tfinfo{2} = [-1000 1000 8 12];
                pcfile.tfinfo{3} = [-1000 1000 13 30];
                
            elseif task == 5
                pcfile.tfinfo{1} = [-1000 1000 3 8];
                pcfile.tfinfo{2} = [-1000 1000 8 12];
                pcfile.tfinfo{3} = [-1000 1000 13 30];
                
            elseif task == 2
                pcfile.tfinfo{1} = [-1000 1000 3 8];
                pcfile.tfinfo{2} = [-1000 1000 8 12];
                pcfile.tfinfo{3} = [-1000 1000 13 30];
                
            elseif task == 4
                pcfile.tfinfo{1} = [-1000 1500 3 8];
                pcfile.tfinfo{2} = [-1000 1500 8 12];
                pcfile.tfinfo{3} = [-1000 1500 13 30];
            end
            
            disp(['Processing task' num2str(task)]);
            
            
            % Create task folder if needed
            subjectTaskFolder = fullfile(results,rawFileName,taskNames{task});
            
            
            EEGmain = struct;
            EEGmain_baseline = struct;
            
            specName = 'tmapStr_newpeak_flank';
            if task == 1
                specName1 = 'nogo1_extd';
            elseif task == 5
                specName1 = '.';
            elseif task == 4
                specName1 = '_ch_';
            else
                specName1 = '.';
            end
            
            %pipeline settings, block info is present

            processvarFiles = pickfiles(subjectTaskFolder, {'processvars', specName1, taskNames{task}, rawFileName, '_', cndnNames{1} ,'.mat'});
            if isempty(processvarFiles)
                if task == 1
                    specName1 = [];
                    specName1 = '_nogo1_';
                    processvarFiles = pickfiles(subjectTaskFolder, {'processvars', specName1, taskNames{task}, '_', cndnNames{1}, '.mat'});
                end
            else
            end
            load(processvarFiles,'pipelineSettings');
            trialsetind = pipelineSettings.trialsetind{block};
            blockind = (pipelineSettings.blockind{block});
            
            if task == 1 
            trialsetind = [pipelineSettings.trialsetind{1}];
                try
                    blockind = [pipelineSettings.blockind{1};pipelineSettings.blockind{2}];
                catch
                    blockind = [pipelineSettings.blockind{1}];
                end
            end
            
            
            RTall = pipelineSettings.behtabledata.ResponseTime;
            accall = pipelineSettings.behtabledata.Accuracy;
            
            
            pebFiles = pickfiles(subjectTaskFolder,{'peb_cleaned_', specName1 '.set',cndnNames{1}});
            
            EEGmain = pop_loadset(deblank(pebFiles));
            
            EEGmainref = EEGmain;
            
            
            %now iterate through all the freq bands, filter, and save the
            %activity
            
            trialsfac = 1; %factor to be multiplied with every trial
            faci_tilda = 1;
            
            acc = find(accall(trialsetind(blockind)) == 1);
            inacc = find(accall(trialsetind(blockind)) == 0);
            
            trialsind{1} = trialsetind(acc);
            trialsind{2} = trialsetind(inacc);
            trialsind{3} = trialsetind(blockind);

            filename = ['brainmap_']; 

            EEG = EEGmain;
            tfinfoarr = pcfile.tfinfo{clustype};
            
            timesind1 = find(EEG.times > tfinfoarr(1));
            timesind1 = timesind1(1);
            timesind2 = find(EEG.times < tfinfoarr(2));
            timesind2 = timesind2(end);
            
            %adding the following to save the pop
            %inverse solution
            if (timesind2 - timesind1) < 80
                timesind2 = timesind1 + 80;
            end
            
            freqind1 = tfinfoarr(3); freqind2 = tfinfoarr(4);
            fileEEGsrc =  pickfiles(results, {filename});
            %%% edits by Jason
            lowbound = [3,8,13];
            highbound = [8 12 30];
            
            freqind1 = lowbound(clustype);
            freqind2 = highbound(clustype);
            %%% end of edits
            EEGfilt = pop_eegfiltnew(EEGmain, freqind1, freqind2, 826,0,[],0);
            EEG=EEGfilt;
             for tri = tri2run
                 trialtype = trialsind{tri};
                 if tri == 1
                     EEG = EEGmain; 
                     EEG.data = EEG.data(:,timesind1:timesind2,trialtype(trialtype < size(EEG.data,3)));
                     if size(EEG.data,3)==0
                        EEG = EEGfilt;
                        behTbl = pipelineSettings.behtabledata;
                        behTbl(pipelineSettings.rejTrials,:)=[];
                        behTbl = behTbl(behTbl.Block>0,:);
                        EEG.data = EEG.data(:,timesind1:timesind2,behTbl.Accuracy==1);
                     end
                     
                     EEG.data = nanmean(EEG.data,3);
                     if ~all(isnan(EEG.data),'all')
                     EEG.times = EEGmain.times(timesind1:timesind2);
                     EEG.trials = size(EEG.data,3); %length(trialsind{facii});
                     EEG.pnts = length(EEG.times);
                     
                     EEG.epoch = [];
                     EEG.etc.subjectNames = rawFileName;
                     
                     EEG = pop_forwardModel(EEG, templatefile, conductivity, orientation);
                     EEG = pop_pebp(EEG,saveFull, account4artifacts, src2roiReductionType);
                     
                     %need flanks to avoid edge
                     %artifacts while taking
                     %envelope (each side flank
                     %is of 500 msec in
                     %length(125 samples) in 256
                     %sampling rate
                     flanklen = 125;
                     %                                                     flankact = reshape(randsample(EEG.etc.src.act(:),size(EEG.etc.src.act,1)*(flanklen)),[size(EEG.etc.src.act,1), flanklen]);
                     %                                                     flankactFull = reshape(randsample(EEG.etc.src.actFull(:),size(EEG.etc.src.actFull,1)*(flanklen)),[size(EEG.etc.src.actFull,1), flanklen]);
                     %                                                 flanki_s = randi(size(EEG.etc.src.act,2)*size(EEG.etc.src.act,3)-flanklen-1,[68,1]); flankact = EEG.etc.src.act(:,flanki_s:flanki_s+flanklen-1);
                     
                     EEG1 = EEG; EEG2 = [];
                     flanki_s = randi(size(EEG.etc.src.act,2)*size(EEG.etc.src.act,3)-flanklen-1,[68,1]); flankact = EEG.etc.src.act(:,flanki_s:flanki_s+flanklen-1);
                     
                     %                         if subi == 1
                     EEG1.etc.src.act(:,1:end+flanklen*2,1) = envelope(cat(2,flankact,EEG.etc.src.act(:,:,1),flankact)',1,'peak')';
                     %                         else
                     %                             EEG1.etc.src.act(:,:,subi) = envelope(cat(2,flankact,EEG.etc.src.act(:,1:end,subi),flankact)',1,'peak')';
                     %                         end
                     %restoring the time
                     %length
                     accurate1 = EEG1.etc.src.act(:,flanklen+1:end-flanklen,1);
                     EEG2.etc.src.act(:,:,1) = accurate1;
                     
                     EEG.etc.src.act = EEG2.etc.src.act; clear EEG1 EEG2;
                     else
                         accurate1 = nan(68,250);
                     end
                     
                 elseif tri==2
                     EEG = EEGmain;                        
                     EEG.data = permute([permute(EEG.data(:,timesind1:timesind2,trialtype(trialtype < size(EEG.data,3))),[3 1 2]).*trialsfac],[2 3 1]);
                     if size(EEG.data,3)==0
                        EEG = EEGfilt;
                        behTbl = pipelineSettings.behtabledata;
                        behTbl(pipelineSettings.rejTrials,:)=[];
                        behTbl = behTbl(behTbl.Block>0,:);
                        EEG.data = EEG.data(:,timesind1:timesind2,behTbl.Accuracy==0);
                     end
                     
                     EEG.data = nanmean(EEG.data,3);
                     if ~all(isnan(EEG.data),'all')
                     EEG.times = EEGmain.times(timesind1:timesind2);
                     EEG.trials = size(EEG.data,3); %length(trialsind{facii});
                     EEG.pnts = length(EEG.times);
                     
                     EEG.epoch = [];
                     EEG.etc.subjectNames = rawFileName;
                     
                     EEG = pop_forwardModel(EEG, templatefile, conductivity, orientation);
                     EEG = pop_pebp(EEG,saveFull, account4artifacts, src2roiReductionType);
                     
                     %need flanks to avoid edge
                     %artifacts while taking
                     %envelope (each side flank
                     %is of 500 msec in
                     %length(125 samples) in 256
                     %sampling rate
                     flanklen = 125;
                     EEG1 = EEG; EEG2 = [];
                     flanki_s = randi(size(EEG.etc.src.act,2)*size(EEG.etc.src.act,3)-flanklen-1,[68,1]); flankact = EEG.etc.src.act(:,flanki_s:flanki_s+flanklen-1);
                     
                     EEG1.etc.src.act(:,1:end+flanklen*2,1) = envelope(cat(2,flankact,EEG.etc.src.act(:,:,1),flankact)',1,'peak')';

                     inaccurate1 = EEG1.etc.src.act(:,flanklen+1:end-flanklen,1);
                     EEG2.etc.src.act(:,:,1) = inaccurate1;
                     
                     EEG.etc.src.act = EEG2.etc.src.act; clear EEG1 EEG2;
                     else
                         inaccurate1 = nan(68,250);
                     end
                 elseif tri==3
                     EEG = EEGmain;
                     EEG.data = permute([permute(EEG.data(:,timesind1:timesind2,trialtype(trialtype < size(EEG.data,3))),[3 1 2]).*trialsfac],[2 3 1]);
                     if size(EEG.data,3)==0
                        EEG = EEGfilt;
                        behTbl = pipelineSettings.behtabledata;
                        behTbl(pipelineSettings.rejTrials,:)=[];
                        behTbl = behTbl(behTbl.Block>0,:);
                        EEG.data = EEG.data(:,timesind1:timesind2,behTbl.Accuracy==0);
                     end
                     
                     EEG.data = nanmean(EEG.data,3);
                     if ~all(isnan(EEG.data),'all')
                     EEG.times = EEGmain.times(timesind1:timesind2);
                     EEG.trials = size(EEG.data,3); %length(trialsind{facii});
                     EEG.pnts = length(EEG.times);
                     
                     EEG.epoch = [];
                     EEG.etc.subjectNames = rawFileName;
                     
                     EEG = pop_forwardModel(EEG, templatefile, conductivity, orientation);
                     EEG = pop_pebp(EEG,saveFull, account4artifacts, src2roiReductionType);
                     
                     %need flanks to avoid edge
                     %artifacts while taking
                     %envelope (each side flank
                     %is of 500 msec in
                     %length(125 samples) in 256
                     %sampling rate
                     flanklen = 125;
                     EEG1 = EEG; EEG2 = [];
                     flanki_s = randi(size(EEG.etc.src.act,2)*size(EEG.etc.src.act,3)-flanklen-1,[68,1]); flankact = EEG.etc.src.act(:,flanki_s:flanki_s+flanklen-1);
                     
                     EEG1.etc.src.act(:,1:end+flanklen*2,1) = envelope(cat(2,flankact,EEG.etc.src.act(:,:,1),flankact)',1,'peak')';

                     tempvar_3 = EEG1.etc.src.act(:,flanklen+1:end-flanklen,1);
                     EEG2.etc.src.act(:,:,1) = tempvar_3;
                     
                     EEG.etc.src.act = EEG2.etc.src.act; clear EEG1 EEG2;
                     else
                         tempvar_3 = nan(68,250);
                     end
                 end
             end

            accurate2(:,:,taski) = accurate1;      
            inaccurate2(:,:,taski) = inaccurate1;
            alltask(:,:,taski) = tempvar_3;
            clear accurate1 inaccurate1 tempvar_3
        catch ME
            ME.message
            
        end
    end

    if ~isempty(accurate2)
        sourceResults.(accFieldName)(:,:,:,subject) = accurate2;
    end
    if ~isempty(inaccurate2)
        sourceResults.(inaccFieldName)(:,:,:,subject) = inaccurate2;
    end

    if ~isempty(alltask)
        sourceResults.(stimFieldName)(:,:,:,subject) = alltask;
    end

    clear accurate2 inaccurate2 alltask
                        
    sourceResults.subjectcoll(subject) = {rawFileName};
end
save(saveFileName, '-struct', 'sourceResults');



















