%% BrainE LuckyDoor analysis for Scalp EEG signals
clear all;close all;clc
cd(PATH_TO_PROJECT_FOLDER) % Enter Path Here
addpath (PATH_TO_EEGLAB) % Enter Path Here
eeglab
%% Simple Project definitions

rawData = '/media/owner/data3/Jason/Active/PERMA/Cognitve_Input_Files'; % folder with all subjects raw data
results = '/media/owner/data3/Jason/Active/PERMA/Results/PermaPost_results'; % folder where preprocessed results are saved
files11 = pickfiles(rawData,{'post','.xdf'}); % Runs one master folder (group/timepoint) at once. Change 'post' to 'pre' or any identifier that can seperate out group/timepoint identifier
templatefile = '/media/owner/data3/eeglab/plugins/BrainEAnalysis/headModel_templateFile_32chan.mat'; % Change to the headModel_templateFile you used for preprocessing
nChans = 32; % number of channels you are using for EEG. If you have projects where people have different number of EEG channels you'll have to run this seperatly

saveFileName = 'LuckyDoor_scalp_post.mat'; % change to whatever you want, but have .mat at the end
%%
files = char(files11); 
files = natsortfiles(char(files));

Nsubjects = size(files,1);

taskNames = {'go_green','middle_fish','lost_star','lucky_door','face_off','two_tap','rest'};
Ntasks = length(taskNames);

%src localization
solverType = 'bsbl';
saveFull = true;
account4artifacts = true;

src2roiReductionType = 'mpower';
conductivity = [0.33, 0.022, 0.33];
orientation = true;
windowSize = (40/1000)*250; %EEG.srate;

hm = headModel.loadFromFile(templatefile);
T = hm.indices4Structure(hm.atlas.label);
T = double(T)';
P = sparse(bsxfun(@rdivide,T, sum(T,2)))';

%%
% size freq x chan x time  x Subjects
GLbias=nan(4,nChans,500,Nsubjects);
EVloss=nan(4,nChans,500,Nsubjects); 
EVgain=nan(4,nChans,500,Nsubjects);

for subject= 1:Nsubjects
    
    rawFile = deblank(files(subject,:));
    [pathName, rawFileName] = fileparts(rawFile);
    disp(['Processing subject ' rawFileName ' ' num2str(subject) '/' num2str(Nsubjects)]);
        

    try

        task = 4;
        block = 1;
        pcfile.tfinfo{1} = [-1000 1500 3 7];
        pcfile.tfinfo{2} = [-1000 1500 8 12];
        pcfile.tfinfo{3} = [-1000 1500 13 30];
        pcfile.tfinfo{4} = [-1000 1500 1 45];

        disp(['Processing task' num2str(task)]);


        % Create task folder if needed
        subjectTaskFolder = fullfile(results,rawFileName,taskNames{task});
        
        EEGmain = struct;
        EEGmain_baseline = struct;
        specName1 = '_ch_';
        %pipeline settings, block info is present
        processvarFiles = pickfiles(subjectTaskFolder, {'processvars', specName1, taskNames{task}, rawFileName, '_stim.mat'});
        

        load(processvarFiles,'pipelineSettings');
        trialsetind = pipelineSettings.trialsetind{block};
        blockind = (pipelineSettings.blockind{block});

        bl = unique(pipelineSettings.behtabledata.Block(abs(pipelineSettings.behtabledata.ChoiceValue) == 30));
        ex = unique(pipelineSettings.behtabledata.Block(abs(pipelineSettings.behtabledata.ChoiceValue) == 20));
        choice_b1_rarel = contains(pipelineSettings.behtabledata.ChoiceSeries,'RareL') & (pipelineSettings.behtabledata.Block == bl(end));
        choice_ex_rarel = contains(pipelineSettings.behtabledata.ChoiceSeries,'RareL') & (pipelineSettings.behtabledata.Block == ex(end));

        %baseline (sameEV) RareL
        trialsind{1} = (trialsetind(blockind(choice_b1_rarel(trialsetind(blockind)))));

        %diffEV RareL
        trialsind{2} = (trialsetind(blockind(choice_ex_rarel(trialsetind(blockind)))));

        choice_b1_rareg = contains(pipelineSettings.behtabledata.ChoiceSeries,'RareG') & (pipelineSettings.behtabledata.Block == bl(end));
        choice_ex_rareg = contains(pipelineSettings.behtabledata.ChoiceSeries,'RareG') & (pipelineSettings.behtabledata.Block == ex(end));

        %sameEV RareG
        trialsind{3} = (trialsetind(blockind(choice_b1_rareg(trialsetind(blockind)))));

        %diffEV RareG
        trialsind{4} = (trialsetind(blockind(choice_ex_rareg(trialsetind(blockind)))));
 

        RTall = pipelineSettings.behtabledata.ResponseTime;

        pebFiles = pickfiles(subjectTaskFolder,{'peb_cleaned_ch_epoch_ch', taskNames{task},rawFileName, 'stim.set'});

        EEGmain = pop_loadset(deblank(pebFiles));

        if EEGmain.nbchan<nChans
            error([rawFile ' has less channels than indicated'])
        end
        EEGmainref = EEGmain; % store clean EEGmain

        %now iterate through all the freq bands, filter, and save the
        %activity



        for f=1:4 % iterate frequency
            EEGmain=EEGmainref;
            tfinfoarr = pcfile.tfinfo{f};
            timesind1 = find(EEGmain.times > tfinfoarr(1));
            timesind1 = timesind1(1);
            timesind2 = find(EEGmain.times < tfinfoarr(2));
            timesind2 = timesind2(end);

            %adding the following to save the pop
            %inverse solution
            if (timesind2 - timesind1) < 80
                timesind2 = timesind1 + 80;
            end
            freqind1 = tfinfoarr(3); freqind2 = tfinfoarr(4);
            EEGfilt = pop_eegfiltnew(EEGmain, freqind1, freqind2, 826,0,[],0);

            for tri = 1:4

                EEG=EEGfilt;
                trialtype = trialsind{tri};

                EEG.data = permute([permute(EEG.data(:,timesind1:timesind2,trialtype(trialtype < size(EEG.data,3))),[3 1 2])],[2 3 1]);
                broadband = permute([permute(EEGmain.data(:,timesind1:timesind2,trialtype(trialtype < size(EEGmain.data,3))),[3 1 2])],[2 3 1]);

                EEG.data = nanmean(EEG.data,3);
                EEG.times = EEGmain.times(timesind1:timesind2);
                EEG.trials = size(EEG.data,3); %length(trialsind{facii});
                EEG.pnts = length(EEG.times);

                EEG.epoch = [];
                EEG.etc.subjectNames = rawFileName;

                tempData(f,:,:,tri)=EEG.data; clear EEG

            end
        end
            GLbias(:,:,:,subject) = tempData(:,:,:,1) - tempData(:,:,:,3);      
            EVloss(:,:,:,subject) = tempData(:,:,:,2) - tempData(:,:,:,1);         
            EVgain(:,:,:,subject) = tempData(:,:,:,4) - tempData(:,:,:,3);
            alltemp(:,:,:,:,subject)=tempData;
            clear tempData
    catch ME
        ME.message
    end
    
    subjectcoll{subject} = rawFileName;
end

save(saveFileName, 'GLbias','EVloss','subjectcoll', 'EVgain')
