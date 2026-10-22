dbstop if error
warning off;
%select the folder for analysis
disp('Select the folder path for analysis');
selpath = uigetdir('/data2/BrainEPilot');

fileList = dir(fullfile(selpath, '*BrainE.xdf'));

% rawData = '/data2/AnalysisResults/Manuscript_I/VersionI_data/GI_healthy';
% files11 = pickfiles(rawData,{'BrainE.xdf'});
% files11p1 = pickfiles(rawData,{'braine.xdf'});
% files12 = pickfiles(rawData,{'BrainE2.xdf'});
%
%
% %symptomflag
% rawData = '/data2/AnalysisResults/Manuscript_I/VersionI_data/GII_symptomflag';
% files21 = pickfiles(rawData,{'BrainE.xdf'});
% files21p1 = pickfiles(rawData,{'braine.xdf'});
% files22 = pickfiles(rawData,{'BrainE2.xdf'});
%
% fileList = char(files11, files12, files11p1, files21, files22, files21p1);
%     nsubjects = size(fileList,1); %length(dir(selpath)) - 2; %to exclude DSstore, ., ..

if isempty(fileList) %when the main folder with all participant data is selected
    nsubjects = length(dir(selpath)) - 2; %to exclude DSstore, ., ..
else
    nsubjects = 1; %just do single subject analysis
end

flag_save = 0; %1 = save as figs, 2 = in a report, 0 = not save (risk of overwitten figures)
flag_beh_mini = 0;
flag_export_file = 1;
% flag_alignment.num = 3; %1 = trial onset, 2 = stim onset, 3 = response onset, 4 = feedback onset, 5 = net coin tally time (Lucky Door), 6 probe in the case of lost star
% flag_alignment.name = 'feedback'; 7, choice, lucky door
%%
behdatacol = struct;
% RTcol = [];
PerfReport = struct;

redcapfilename = '/data2/RedCap/Analysis/BrainE_RedCap_082919.xlsx';

% RedCap Table
redcaptable = readtable (redcapfilename,'Sheet',1);
rc = struct;
rc.age = redcaptable.age;
rc.pilotid = redcaptable.pilotid;
rc.pilotid = str2double(erase(string(rc.pilotid),"Pilot")); % Get only id number for comparison
rc.ADHD = redcaptable.totaliahiscore;
rc.Anxiety = redcaptable.anxietyscore;
rc.PTSD = redcaptable.totalsymptomseverityscore;
rc.Depression = redcaptable.depressionscore;
rc.Inattentive = redcaptable.iascore;
rc.Hyperactive = redcaptable.hiscore;

rc.resiliencescore = redcaptable.resiliencescore;
rc.mindfulnessscore = redcaptable.mindfulnessscore;
rc.emotionalsupportscore = redcaptable.emotionalsupportscore;
rc.wellbeing = redcaptable.wellbeing;


rc.gender = redcaptable.gender;
rc.race = redcaptable.race;
rc.sesscore = redcaptable.sesscore;
rc.exercisescore = redcaptable.exercisescore;
rc.education = redcaptable.education;
rc.sleep = redcaptable.promisscore;
rc.childevents = redcaptable.childhoodtraumatotal;

%%
for itersubject = 1:nsubjects
    %load the directory and the file for each subject
    
%     if nsubjects > 1
        selpathnext = dir(selpath);
        foldername = selpathnext(2+itersubject).name;
        fileList1 = dir(fullfile(selpath, foldername, '*BrainE.xdf'));
        fileList2 = dir(fullfile(selpath, foldername, '*braine.xdf'));
        fileList3 = dir(fullfile(selpath, foldername, '*BrainE2.xdf'));
        fileList =  [fileList1; fileList2; fileList3];
        behfileList = dir(fullfile(selpath, foldername, '*Behavior_Data.xlsx'));
        if isempty (behfileList)
            behfile = dir(fullfile(selpath, foldername, '*trial_summary.csv')); % Gets csv files if beh excel does not exist
        end
        %         cd(fullfile(selpath, foldername));
%     else %just a single subject
%         fileList1 = dir(fullfile(selpath, '*BrainE.xdf'));
%         fileList2 = dir(fullfile(selpath, '*braine.xdf'));
%         fileList3 = dir(fullfile(selpath, '*BrainE2.xdf'));
%         fileList =  [fileList1; fileList2; fileList3];
%         behfileList = dir(fullfile(selpath, '*Behdata_072219.xlsx'));
%         if isempty (behfileList)
%             behfile = dir(fullfile(selpath, '*trial_summary.csv'));
%             [~, foldername] = fileparts(behfile(1).folder);
%         else
%             [~, foldername] = fileparts(behfileList(1).folder);
%         end
%         cd(fullfile(selpath));
%     end
    
    [startIndex,endIndex] = regexp(foldername,'Pilot');
    
    subjectindex = str2num(foldername(endIndex+1:end));
    
    if isempty(subjectindex)
        subjectindex = (foldername(endIndex+1:end));
        disp(['Computing for Pilot ' (subjectindex)])
        [startIndex,endIndex] = regexp(foldername,'Pilotii');
        subjectindex = (200+str2num(foldername(endIndex+1:end)));
        if isempty(subjectindex)
            [startIndex,endIndex] = regexp(foldername,'pilotii');
            subjectindex = (200+str2num(foldername(endIndex+1:end)));
            disp(['Computing for Pilot ' (subjectindex)])
        end
    else
        disp(['Computing for Pilot ' num2str(subjectindex)])
    end
    %Run different BrainE task analysis
    PerfReport(itersubject).subjectID = subjectindex;
    %             %Go Green
    try
        close all;
        try
            if ~isempty(behfileList)
                tabledata = readtable(fullfile(behfileList(1).folder,behfileList(1).name),'Sheet',4);
            else
                if size(behfile,1) ~= 1
                    for n = 1:size(behfile,1)
                        behfile(n).behFilepath = fullfile(behfile(n).folder, behfile(n).name);
                    end
                    
                    behFileind=find(contains(cellstr(char(behfile.behFilepath)),'gogreen'));
                    if isempty(behFileind)
                        behFileind=find(contains(cellstr(char(behfile.behFilepath)),'gowait'));
                    end
                else
                    behFileind=1;
                end
                tabledata = readtable(fullfile(behfile(behFileind).folder,behfile(behFileind).name));
            end
        catch
            tabledata = [];
        end
        
        flag_task = 1; %go green
        if ~flag_beh_mini
            [behdata] = BrainEAnalysis_beh_MFch(tabledata, flag_task);
        else
            [behdata] = BrainEAnalysis_beh_mini(tabledata, flag_task);
            
        end
        behdatacol(itersubject).gogreen = behdata.values;
        PerfReport(itersubject).external_attention = behdata.values(7);
        PerfReport(itersubject).response_regulation = behdata.values(8);
        behdatacol(itersubject).gogreen(end+1) = subjectindex;
    catch ME
        keyboard
        ME.identifier
    end
    
    
    %middle fish
    try
        close all;
        
        try
            if ~isempty(behfileList)
                tabledata = readtable(fullfile(behfileList(1).folder,behfileList(1).name),'Sheet',1);
            else
                if size(behfile,1) ~= 1
                    for n = 1:size(behfile,1)
                        behfile(n).behFilepath = fullfile(behfile(n).folder, behfile(n).name);
                    end
                    behFileind=find(contains(cellstr(char(behfile.behFilepath)),'middlefish'));
                else
                    behFileind=1;
                end
                tabledata = readtable(fullfile(behfile(behFileind).folder,behfile(behFileind).name));
            end
        catch
            tabledata = [];
        end
        flag_task = 2; %middle fish
        if ~flag_beh_mini
            [behdata] = BrainEAnalysis_beh_MFch(tabledata, flag_task);
        else
            [behdata] = BrainEAnalysis_beh_mini(tabledata, flag_task);
            
        end
        behdatacol(itersubject).middlefish = behdata.values;
        PerfReport(itersubject).distractor_processing = behdata.values(4);
        behdatacol(itersubject).middlefish(end+1) = subjectindex;
        
    catch ME
        keyboard
        ME.identifier
    end
    
    
    %lost star
    try
        close all;
        
        try
            if ~isempty(behfileList)
                tabledata = readtable(fullfile(behfileList(1).folder,behfileList(1).name),'Sheet',2);
            else
                if size(behfile,1) ~= 1
                    for n = 1:size(behfile,1)
                        behfile(n).behFilepath = fullfile(behfile(n).folder, behfile(n).name);
                    end
                    behFileind=find(contains(cellstr(char(behfile.behFilepath)),'loststar'));
                else
                    behFileind=1;
                end
                tabledata = readtable(fullfile(behfile(behFileind).folder,behfile(behFileind).name));
            end
        catch
            tabledata = [];
        end
        flag_task = 3; %lost star
        if ~flag_beh_mini
            [behdata] = BrainEAnalysis_beh_MFch(tabledata, flag_task);
        else
            [behdata] = BrainEAnalysis_beh_mini(tabledata, flag_task);
            
        end
        behdatacol(itersubject).loststar = behdata.values;
        PerfReport(itersubject).working_memory = behdata.values(5);
        behdatacol(itersubject).loststar(end+1) = subjectindex;
        
    catch ME
        keyboard
        ME.identifier
        
    end
    
    
    %lucky door
    try
        close all;
        
        try
            if ~isempty(behfileList)
                tabledata = readtable(fullfile(behfileList(1).folder,behfileList(1).name),'Sheet',6);
            else
                if size(behfile,1) ~= 1
                    for n = 1:size(behfile,1)
                        behfile(n).behFilepath = fullfile(behfile(n).folder, behfile(n).name);
                    end
                    behFileind=find(contains(cellstr(char(behfile.behFilepath)),'luckydoor'));
                else
                    behFileind=1;
                end
                tabledata = readtable(fullfile(behfile(behFileind).folder,behfile(behFileind).name));
            end
        catch
            tabledata = [];
        end
        
        flag_task = 4; %lucky door
        if ~flag_beh_mini
            [behdata] = BrainEAnalysis_beh_MFch(tabledata, flag_task);
        else
            [behdata] = BrainEAnalysis_beh_mini(tabledata, flag_task);
        end
        behdatacol(itersubject).luckydoor = behdata.values;
        PerfReport(itersubject).reward_processing = behdata.values(11);
        behdatacol(itersubject).luckydoor(end+1) = subjectindex;
        
    catch ME
        keyboard
        ME.identifier
    end
    
    
    %face off
    try
        close all;
        
        try
            if ~isempty(behfileList)
                tabledata = readtable(fullfile(behfileList(1).folder,behfileList(1).name),'Sheet',5);
            else
                if size(behfile,1) ~= 1
                    for n = 1:size(behfile,1)
                        behfile(n).behFilepath = fullfile(behfile(n).folder, behfile(n).name);
                    end
                    behFileind=find(contains(cellstr(char(behfile.behFilepath)),'faceoff'));
                else
                    behFileind=1;
                end
                tabledata = readtable(fullfile(behfile(behFileind).folder,behfile(behFileind).name));
            end
        catch
            tabledata = [];
        end
        flag_task = 5; %face off
        if ~flag_beh_mini
            [behdata] = BrainEAnalysis_beh_MFch(tabledata, flag_task);
        else
            [behdata] = BrainEAnalysis_beh_mini(tabledata, flag_task);
            
        end
        behdatacol(itersubject).faceoff = behdata.values;
        PerfReport(itersubject).emotional_processing = behdata.values(13);
        behdatacol(itersubject).faceoff(end+1) = subjectindex;
        
    catch ME
        keyboard
        ME.identifier
    end
    
    
    % two tap
    try
        close all;
        
        try
            if ~isempty(behfileList)
                tabledata = readtable(fullfile(behfileList(1).folder,behfileList(1).name),'Sheet',3);
            else
                if size(behfile,1) ~= 1
                    for n = 1:size(behfile,1)
                        behfile(n).behFilepath = fullfile(behfile(n).folder, behfile(n).name);
                    end
                    behFileind=find(contains(cellstr(char(behfile.behFilepath)),'twotap'));
                else
                    behFileind=1;
                end
                tabledata = readtable(fullfile(behfile(behFileind).folder,behfile(behFileind).name));
            end
        catch
            tabledata = [];
        end
        
        flag_task = 6; %two tap
        if ~flag_beh_mini
            
            [behdata] = BrainEAnalysis_beh_MFch(tabledata, flag_task);
        else
            
            [behdata] = BrainEAnalysis_beh_mini(tabledata, flag_task);
        end
        behdatacol(itersubject).twotap = behdata.values;
        PerfReport(itersubject).internal_attention = behdata.values(2);
        behdatacol(itersubject).twotap(end+1) = subjectindex;
        
    catch ME
        keyboard
        ME.identifier
    end
    
%     redcap performance
%     Combination of both
%     
%     
%    index = find(rc.pilotid == subjectindex);
%     if  ~isempty (index)
%        behdatacol(itersubject).redcap(1) = str2double(char(rc.age(index)));
%      behdatacol(itersubject).redcap(10) = str2double(char(rc.emotionalsupportscore(index)));
%        behdatacol(itersubject).redcap(11) = str2double(char(rc.wellbeing(index)));
%        
%         behdatacol(itersubject).redcap(12) = str2double(char(rc.gender(index)));
%         behdatacol(itersubject).redcap(13) = str2double(char(rc.race(index)));
%        behdatacol(itersubject).redcap(14) = str2double(char(rc.sesscore(index)));
%        behdatacol(itersubject).redcap(15) = str2double(char(rc.exercisescore(index)));
%         behdatacol(itersubject).redcap(16) = str2double(char(rc.education(index)));
%        behdatacol(itersubject).redcap(17) = str2double(char(rc.sleep(index)));
%        behdatacol(itersubject).redcap(18) = str2double(char(rc.childevents(index)));
%         
%        behdatacol(itersubject).redcap(19) = (rc.pilotid(index)); %{num2str
%        
%        behdatacol(itersubject).redcap(20) = (subjectindex);
%    else
%        behdatacol(itersubject).redcap(1) = nan;
%        behdatacol(itersubject).redcap(2) = nan;
%        behdatacol(itersubject).redcap(3) = nan;
%        behdatacol(itersubject).redcap(4) = nan;
%        behdatacol(itersubject).redcap(5) = nan;
%     %   behdatacol(itersubject).redcap(7) = nan;
%         
%        behdatacol(itersubject).redcap(8) = nan;
%         behdatacol(itersubject).redcap(9) = nan;
%         behdatacol(itersubject).redcap(10) = nan;
%         behdatacol(itersubject).redcap(11) = nan;
%         
%         behdatacol(itersubject).redcap(12) = nan;
%         behdatacol(itersubject).redcap(13) = nan;
%         behdatacol(itersubject).redcap(14) = nan;
%         behdatacol(itersubject).redcap(15) = nan;
%         behdatacol(itersubject).redcap(16) = nan;
%         behdatacol(itersubject).redcap(17) = nan;
%         behdatacol(itersubject).redcap(18) = nan;
%         behdatacol(itersubject).redcap(19) = nan;
%         behdatacol(itersubject).redcap(20) = subjectindex;
%     end
%     
%     
%     
%     %Overall performance
%     try
%         PerfReport(itersubject).overall_performance = mean([PerfReport(itersubject).external_attention; PerfReport(itersubject).response_regulation; PerfReport(itersubject).distractor_processing; PerfReport(itersubject).working_memory; PerfReport(itersubject).reward_processing; PerfReport(itersubject).emotional_processing; PerfReport(itersubject).internal_attention]);
%         %structfun(@mean, PerfReport(itersubject), 'uniform', 0);
%         PerfReport(itersubject).overall_accuracy = mean([behdatacol(itersubject).gogreen([1:2])'; 1-abs(behdatacol(itersubject).middlefish(1)); behdatacol(itersubject).loststar(2); mean(behdatacol(itersubject).faceoff([1:4]))]);
%         PerfReport(itersubject).overall_consistency = mean([behdatacol(itersubject).gogreen([3:4])'; 1-abs(behdatacol(itersubject).middlefish(2)); behdatacol(itersubject).loststar(3); mean(behdatacol(itersubject).faceoff([5:8])); behdatacol(itersubject).twotap(2)]);
%         PerfReport(itersubject).overall_speed = mean([behdatacol(itersubject).gogreen([5:6])'; 1-abs(behdatacol(itersubject).middlefish(3)); behdatacol(itersubject).loststar(4); mean(behdatacol(itersubject).faceoff([9:12]))]);
%         %         % generate report card
%         %         reportFile = '/data2/Aus/MtGravattReportCards/Tafe_Comparisons/Perfreport_tafe';
%         %         createReportCard(reportFile,cell2mat(struct2cell(PerfReport(itersubject))));
%         
%         
%     end
%     
end



%%
%exporting
if flag_export_file
    
    % select the folder for exportation
    disp('Select the folder path for exportation');
    resultpath = uigetdir('/data2/AnalysisResults');
    filename = [resultpath '/BrainE_behdata_pilot_MFch3_14Aug2019_age_MLmodel.xlsx'];
    
    temp = array2table(cell2mat({behdatacol.gogreen}'),'VariableNames',{'dprime_acc_block1', 'dprime_acc_block2', 'consistency_block1', 'consistency_block2', 'speed_block1', 'speed_block2', 'CumPerf_block1', 'CumPerf_block2','dprime_cost_block1','dprime_cost_block2','consistency_cost_block1','consistency_cost_block2', 'speed_cost_block1','speed_cost_block2','SubjectIndex'});
    writetable(temp,filename,'Sheet','GoGreen');
    
    temp = array2table(cell2mat({behdatacol.middlefish}'),'VariableNames',{'dprime_acc', 'consistency', 'speed', 'CumPerf','dprime_cost','consistency_cost','speed_cost','SubjectIndex'});
    writetable(temp,filename,'Sheet','MiddleFish');
    
    temp = array2table(cell2mat({behdatacol.loststar}'),'VariableNames',{'level', 'dprime_acc', 'consistency', 'speed', 'CumPerf','SubjectIndex'});
    writetable(temp,filename,'Sheet','LostStar');
    
    temp = array2table(cell2mat({behdatacol.luckydoor}'),'VariableNames',{'Choose_RareG_Block1_Q1','Choose_RareG_Block1_Q2', 'Choose_RareG_Block1_Q3', 'Choose_RareG_Block1_Q4', 'Choose_RareG_Block1', 'Choose_RareG_Block2_Q1', 'Choose_RareG_Block2_Q2', 'Choose_RareG_Block2_Q3', 'Choose_RareG_Block2_Q4', 'Choose_RareG_Block2', 'CumPerf','StimOrder','SubjectIndex'});
    writetable(temp,filename,'Sheet','LuckyDoor');
    
    temp = array2table(cell2mat({behdatacol.faceoff}'),'VariableNames',{'dprime_acc_neutral', 'dprime_acc_happy', 'dprime_acc_angry', 'dprime_acc_sad', 'consistency_neutral', 'consistency_happy', 'consistency_angry', 'consistency_sad', 'speed_neutral', 'speed_happy', 'speed_angry', 'speed_sad', 'CumPerf','perf_happy','perf_angry','perf_sad', 'dprime_all', 'consistency_all', 'speed_all', 'dprime_cost_happy', 'dprime_cost_angry', 'dprime_cost_sad', 'consistency_happy_cost', 'consistency_sad_cost', 'consistency_angry_cost',...
        'speed_happy_cost', 'speed_angry_cost', 'speed_sad_cost', 'SubjectIndex'});
    writetable(temp,filename,'Sheet','FaceOff');
    
    temp = array2table(cell2mat({behdatacol.twotap}'),'VariableNames',{'MeanBreathingTime', 'Consistency_TT', 'Speed_TT', 'SubjectIndex'});
    writetable(temp,filename,'Sheet','TwoTap');
    
%     temp = array2table(cell2mat({behdatacol.redcap}'),'VariableNames',{'age', 'ADHD', 'Anxiety', 'PTSD', 'Depression','Inattentiveness','Hyperactivity','resiliencescore','mindfulnessscore','emotionalsupportscore','wellbeing','gender','race','sesscore','exercisescore','education','sleep','childevents','Pilotid','SubjectIndex'});
%     writetable(temp,filename,'Sheet','Redcap');
    
end

if flag_save
    save behdata_mini_32 behdatacol
end



% %% plotting the beh data
% 
% %relating various redcap scores
% temp = cell2mat({behdatacol.redcap}');
% 
% anx = temp(:,3);
% dep = temp(:,5);
% inatt = temp(:,6);
% hyper = temp(:,7);
% 
% res = temp(:,8);
% mindful = temp(:,9);
% emotsup = temp(:,10);
% wellbeing = temp(:,11);
% 
% %%
% [r,p] = corr(dep,res,'rows','complete')
% 
% %%
% 
% flag_plot = 0
% if flag_plot
%     
%     %go green
%     temp = cell2mat({behdatacol.gogreen}');
%     
%     data_modif1 = [temp(:,1) temp(:,7) temp(:,2) temp(:,8)];
%     %Doing a ranova model
%     data_modif = [[temp(:,1);temp(:,7)],[temp(:,2);temp(:,8)]]; %dprime and RT in rows, block 1 and 2 in cols
%     
%     figure
%     subplot(1,4,1)
%     distributionPlot(temp(:,[1 2]),'showMM',4,'color',{'b','m'},'histOpt',2);
%     
%     legend('Block 1','Block 2');
%     title('dprime-Accuracy');
%     ylim([-0.5 1.5]);
%     xticks([])
%     set(gca,'fontsize',12,'fontweight','bold');
%     
%     subplot(1,4,2)
%     distributionPlot(temp(:,[3 4]),'showMM',4,'color',{'b','m'},'histOpt',2);
%     
%     legend('Block 1','Block 2');
%     title('Consistency');
%     
%     ylim([-0.5 1.5]);
%     xticks([])
%     set(gca,'fontsize',12,'fontweight','bold');
%     
%     subplot(1,4,3)
%     distributionPlot(temp(:,[5,6]),'showMM',4,'color',{'b','m'},'histOpt',2);
%     
%     legend('Block 1','Block 2');
%     title('Speed');
%     
%     ylim([-0.5 1.5]);
%     xticks([])
%     set(gca,'fontsize',12,'fontweight','bold');
%     
%     subplot(1,4,4)
%     %overall
%     meantemp = [mean(temp(:,[1 3 5]),2) mean(temp(:,[2 4 6]),2)];
%     distributionPlot(meantemp,'showMM',4,'color',{'b','m'},'histOpt',2);
%     
%     legend('Block 1','Block 2');
%     title('Overall Scores');
%     
%     ylim([-0.5 1.5]);
%     xticks([])
%     set(gca,'fontsize',12,'fontweight','bold');
%     
%     % saveas(gcf,'gogreen_v2','png');
%     
%     
%     figure
%     % subplot(2,1,1)
%     scatter(temp(:,7),temp(:,1))
%     xlabel('RT')
%     ylabel('dprime');
%     title('Block 1');
%     
%     figure
%     % subplot(2,1,2)
%     % scatter(temp(:%obtain behdatacol variable
%     histogram(RTcol(RTcol > 0),5,'FaceColor','g')
%     hold on
%     histogram(RTcol(RTcol < 0),5,'FaceColor','r')
%     histogram(RTcol1(RTcol < 0),5,'FaceColor','m')
%     hold off
%     xlabel('RT')
%     ylabel('dprime');
%     title('Block 2');
%     
%     % [p,s] = polyfit(xnow,ynow,1);
%     % hold on
%     % [yfit,dy] = polyconf(p,xnow,s,'predopt','curve');
%     % line(xnow,yfit,'color',[.1,.1,.61])
%     % line(xnow,yfit-dy,'color',[.1,.1,.61],'linestyle',':')
%     % line(xnow,yfit+dy,'color',[.1,.1,.61],'linestyle',':')
%     % hold off
%     
%     %obtain behdatacol variable
%     histogram(RTcol(RTcol > 0),5,'FaceColor','g')
%     hold on
%     histogram(RTcol(RTcol < 0),5,'FaceColor','r')
%     histogram(RTcol1(RTcol < 0),5,'FaceColor','m')
%     hold off
%     
%     %stats for the task variables
%     [p,tbl,stats] = anova2(data_modif,20); %20 replications
%     
%     c = multcompare(stats)
%     c = multcompare(stats,'Estimate','row')
%     
%     % data = temp(:,[1 2 7 8]);
%     
%     % t = table(data(:,1),data(:,2),data(:,3),data(:,4),...%Table of the data dprime: block
%     %     'VariableNames',{'y1','y2','y3','y4'});
%     % within = table({'dprimeB1','dprimeB2','RTB1','RTB2'}',...
%     %     'VariableNames',{'TaskFactors'});
%     % rm = fitrm(t,'y1-y4~1','WithinDesign',within)
%     %
%     % ranovatbl = ranova(rm)
%     
%     
%     
%     
%     %middle fish
%     temp = cell2mat({behdatacol.middlefish}');
%     
%     figure
%     %accuracy
%     subplot(1,4,1)
%     distributionPlot(temp(:,1),'showMM',4,'color','b','histOpt',2);
%     
%     % legend('Accuracy');
%     title('dprime Accuracy');
%     
%     ylim([-1.5 1.5]);
%     xticks([])
%     set(gca,'fontsize',12,'fontweight','bold');
%     
%     
%     subplot(1,4,2)
%     distributionPlot(temp(:,2),'showMM',4,'color','g','histOpt',2);
%     
%     % legend('Consistency');
%     title('Consistency');
%     
%     ylim([-1.5 1.5]);
%     xticks([])
%     set(gca,'fontsize',12,'fontweight','bold');
%     
%     subplot(1,4,3)
%     distributionPlot(temp(:,3),'showMM',4,'color',{'m'},'histOpt',2);
%     
%     title('Speed');
%     
%     ylim([-1.5 1.5]);
%     xticks([])
%     set(gca,'fontsize',12,'fontweight','bold');
%     
%     subplot(1,4,4)
%     %overall
%     distributionPlot(mean(temp,2),'showMM',4,'color',{'y'},'histOpt',2);
%     
%     title('Overall Scores');
%     
%     ylim([-1.5 1.5]);
%     xticks([])
%     set(gca,'fontsize',12,'fontweight','bold');
%     
%     % saveas(gcf,'middlefish_v2','png');
%     
%     
%     
%     
%     
%     
%     %lost star
%     temp = cell2mat({behdatacol.loststar}');
%     figure
%     %memory level
%     %memory accuracy
%     %memory consistency
%     subplot(1,5,1)
%     distributionPlot(temp(:,1),'showMM',4,'color',{'g'},'histOpt',2);
%     title('Memory level');
%     % title('[1 8]');
%     ylim([-0.5 1.5]);
%     xticks([])
%     set(gca,'fontsize',12,'fontweight','bold');
%     
%     subplot(1,5,2)
%     distributionPlot(temp(:,2),'showMM',4,'color',{'b',},'histOpt',2);
%     title('Memory Accuracy');
%     % title('[0 4.65]');
%     ylim([-0.5 1.5]);
%     xticks([])
%     set(gca,'fontsize',12,'fontweight','bold');
%     
%     subplot(1,5,3)
%     distributionPlot(temp(:,3),'showMM',4,'color',{'m'},'histOpt',2);
%     title('Memory Consistency');
%     % title('[0 100]');
%     ylim([-0.5 1.5]);
%     xticks([])
%     set(gca,'fontsize',12,'fontweight','bold');
%     
%     subplot(1,5,4)
%     distributionPlot(temp(:,4),'showMM',4,'color',{'y'},'histOpt',2);
%     title('Speed');
%     ylim([-0.5 1.5]);
%     xticks([])
%     set(gca,'fontsize',12,'fontweight','bold');
%     
%     subplot(1,5,5)
%     %overall
%     distributionPlot(mean(temp,2),'showMM',4,'color',{'k'},'histOpt',2);
%     title('Overall Scores');
%     ylim([-0.5 1.5]);
%     xticks([])
%     set(gca,'fontsize',12,'fontweight','bold');
%     
%     % saveas(gcf,'loststar_v2','png');
%     
%     
%     
%     %%
%     % tempindsub = ...
%     % [0    1;
%     % 0	1;
%     % 0	nan;
%     % 0   1;
%     % 0	1;
%     % 0	1;
%     % 0	1;
%     % 0	1;
%     % 0	1;
%     % 0	nan;
%     % 0   nan;
%     % 0	nan;
%     % 0	1;
%     % 0	1;
%     % 0	nan;
%     % 0	1;
%     % 0	nan;
%     % 0	1;
%     % 0	1;
%     % 0	1;
%     % 0	1;
%     % 0	1;
%     % 0	1;
%     % 0	1;
%     % 0	1;
%     % 0	1;
%     % 1	0;
%     % 1	0;
%     % 1	0;
%     % 1	0;
%     % nan 0;
%     % 1	0;
%     % 1	0;
%     % 1	0;
%     % nan 0;
%     % nan 0;
%     % 1	0;
%     % 1	0;
%     % 0	nan
%     % nan 0;
%     % 0	nan;
%     % 1	0;
%     % 1	0;
%     % 1	0;
%     % 1	0;
%     % nan 0;
%     % nan 0;
%     % nan 0;
%     % nan 0;
%     % 1	0;
%     % 1	0;
%     % 1	0;
%     % 0   1;
%     % nan 0;
%     % 1	0;
%     % nan 0;
%     % 0	1
%     % 1	0;
%     % 1	0;
%     % 0	1
%     % nan 0;
%     % 1	0;
%     % 1	0;
%     % 1	0;
%     % 1	0;
%     % 1	0;
%     % 1	0;
%     % 1	0;
%     % 0	1
%     % 0	1
%     % nan 0;
%     % nan	0;
%     % 1	0;
%     % 0	1
%     % 1	0;
%     % nan 0;
%     % 0	1
%     % 1	0;
%     % 1	0;
%     % 1	0;
%     % 0	1
%     % 1	0;
%     % 0	1
%     % 1	0;
%     % 0	1
%     % 0	1
%     % 1	0;
%     % nan 0;
%     % 0	1
%     % 1	0;
%     % 1	0;
%     % 0	1
%     % 1	0;
%     % 0	1
%     % 0	1
%     % 1	0;
%     % 1	0;
%     % 0	1
%     % 1	0;
%     % 0	1]
%     %From the neurotracking sheet.. look at tempindsub.m
%     
%     
%     
%     
%     
    
    %% tempstr = {behdatacol.luckydoor};
    % indhere = find(cell2mat(cellfun(@(x) ~isempty(x),tempstr,'UniformOutput',false)));
    %lucky door
    %     subint = find(tempindsub(:,2) ==1); %[27:52 54:56 58:59 61:70];
    
    %     subint = find(tempindsub(:,3) ==1); %[1:26]; %
    
    temp = cell2mat({behdatacol.luckydoor}');
    
    subint = temp(temp(:,end-1)==1,end);
    
    %     [~,tempind,~] = intersect(temp(:,end),tempindsub(subint,1));
    [~,tempind,~] = intersect(temp(:,end),subint);
    temp = temp(tempind,:);
    
        titlename = ['LD: Baseline first, N ' num2str(length(tempind))];
%     titlename = ['LD: Baseline second, N ' num2str(length(tempind))];
    
    
    
    %%
    %cumulative choice frequency
    % subplot(2,1,1)
    %
    % tempdist = cell2mat(cellfun(@(x) mean(x.csumpool1(:,end),2),tempstr(indhere),'UniformOutput',false)); %get the rareL and the rareG in order 1 and 2
    % distributionPlot(tempdist','showMM',4,'color',{'b','g'},'histOpt',2);
    %
    % legend('RareL','Rare G');
    % title('Cumulative Choice Frequency');
    % xticks([])
    % set(gca,'fontsize',12,'fontweight','bold');
    %
    %
    % subplot(2,1,2)
    %
    % tempdist = cell2mat(cellfun(@(x) mean(x.csumpool2(:,end),2),tempstr(indhere),'UniformOutput',false)); %get the rareL and the rareG in order 1 and 2
    % distributionPlot(tempdist','showMM',4,'color',{'b','g'},'histOpt',2);
    %
    % legend('RareL','Rare G');
    % title('Cumulative Choice Frequency- Block 2');
    % xticks([])
    % set(gca,'fontsize',12,'fontweight','bold');
    % indhere = find(cell2mat(cellfun(@(x) ~isempty(x),tempstr,'UniformOutput',false)));
    %lucky door
    figure
    
    %cumulative choice frequency
    % subplot(2,1,1)
    %
    % tempdist
    subplot(1,3,1)
    % distributionPlot(temp(:,1:4),'showMM',4,'color',{'g','b','m','y'},'histOpt',2);
    errorbar(mean(temp(:,1:4),1), std(temp(:,1:4),[],1),'linewidth',2); %,'showMM',4,'color',{'g','b','m','y'},'histOpt',2);
    % title('RareG- Block 1');
    % title('[1 8]');
    % ylim([-0.5 1.5]);
    % xticks([])
    % xlabel('final quartiles: CumAvg');
    % set(gca,'fontsize',12,'fontweight','bold');
    
    hold on
    % distributionPlot(temp(:,5:8),'showMM',4,'color',{'g','b','m','y'},'histOpt',2);
    errorbar(mean(temp(:,6:9),1), std(temp(:,6:9),[],1),'linewidth',2); %,'showMM',4,'color',{'g','b','m','y'},'histOpt',2);
    title('RareG: Cumulative preference');
    % title('[1 8]');
    ylim([-0.5 1.5]);
    % xticks = 1:4;
    xlabel('quartiles');
    hold off
    legend('Block 1','Block 2');
    set(gca,'fontsize',12,'fontweight','bold');
    
    % subplot(1,4,2)
    % distributionPlot(temp(:,9:10),'showMM',4,'color',{'g','b'},'histOpt',2);
    % title('Consistency');
    % % title('[0 100]');
    % ylim([-1 1.5]);
    % xticks([])
    % legend('Block 1','Block 2');
    % set(gca,'fontsize',12,'fontweight','bold');
    %
    % subplot(1,4,3)
    % distributionPlot(temp(:,11:12),'showMM',4,'color',{'g','b'},'histOpt',2);
    % title('Speed');
    % ylim([-0.5 1.5]);
    % xticks([])
    % legend('Block 1','Block 2');
    % set(gca,'fontsize',12,'fontweight','bold');
    
%     subplot(1,3,2)
%     %Final quartile scores
%     distributionPlot(temp(:,[4,9]),'showMM',4,'color',{'g','b'},'histOpt',2);
%     title('Cumulative Performance');
%     ylim([-0.5 1.5]);
%     xticks([])
%     xlabel('Final Quartile');
%     legend('Block 1','Block 2');
%     set(gca,'fontsize',12,'fontweight','bold');
    
%     subplot(1,3,3)
%     %Overall scores
%     distributionPlot(temp(:,[5,10]),'showMM',4,'color',{'g','b'},'histOpt',2);
%     title('Cumulative Performance');
%     ylim([-0.5 1.5]);
%     xticks([])
%     xlabel('Overall');
%     legend('Block 1','Block 2');
%     set(gca,'fontsize',12,'fontweight','bold');
%     
%     % saveas(gcf,'luckydoor_v2','png');
%     
%     suptitle(titlename);
%     
    
%     %% anova analysis for the above
%     
%     %repeated measures ANOVA for cumulative performance with two within-subject factors of quartile & EV (equal vs unequal) as a repeated measure, and also a between-subject factor of block order 1 vs 2
%     
%     % subint = find(tempindsub(:,2) ==1); %1 26
%     
%     temp = cell2mat({behdatacol.luckydoor}');
%     subint = temp(temp(:,end-1)==1,end);
%     
%     [~,tempind,~] = intersect(temp(:,end),subint);
%     temp1 = temp(tempind,:);
%     
%     
%     % subint = find(tempindsub(:,3) ==1); %[27:52 54:56 58:59 61:70];
%     
%     temp = cell2mat({behdatacol.luckydoor}');
%     
%     subint = temp(temp(:,end-1)==2,end);
%     
%     [~,tempind,~] = intersect(temp(:,end),subint);
%     temp2 = temp(tempind,:);
%     
%     grp = [ones(size(temp1,1),1); 2*ones(size(temp2,1),1)]; %group
%     test = [grp, [temp1(:,[6:9 1:4]);temp2(:,[1:4 6:9])]]; %the dataset with the group as the first column
%     % test = [temp1(:,[6:9 1:4]);temp2(:,[1:4 6:9])]; %the dataset with the group as the first column
%     % test = [grp, [temp1(:,[4 9]);temp2(:,[4 9])]]; %the dataset with the group as the first column
%     
%     varNames = {'group','ExptQ1','ExptQ2','ExptQ3','ExptQ4','BaseQ1','BaseQ2','BaseQ3','BaseQ4'};
%     % varNames = {'group','Bl1Q4','Bl2Q4'};
%     %array2table
%     t = array2table(test,'VariableNames',varNames);
%     % Create a table reflecting the within subject factors 'Block', 'Performance', and their levels
%     factorNames = {'Quartile','Block'};
%     % factorNames = {'Quartile'};
%     within = table({'Q1';'Q2';'Q3';'Q4';'Q1';'Q2';'Q3';'Q4'},{'Expt';'Expt';'Expt';'Expt';'Base';'Base';'Base';'Base'},'VariableNames',factorNames);
%     % within = table({'Q4';'Q4'},'VariableNames',factorNames);
%     
%     % fit the repeated measures model
%     rm = fitrm(t,'ExptQ1-BaseQ4~group','WithinDesign',within) %,'WithinModel','orthogonalcontrasts')
%     % run my repeated measures anova here
%     [ranovatbl] = ranova(rm, 'WithinModel','Quartile*Block')
%     % [ranovatbl] = ranova(rm, 'WithinModel','Quartile');
%     
%     %%
%     filename = 'LD_exptFirst_group2_88subs';
%     saveas(gcf,filename,'png');
%     
    
%     %% face off
%     temp = cell2mat({behdatacol.faceoff}');
%     figure
%     %accuracy
%     subplot(1,4,1)
%     distributionPlot(temp(:,[1:4]),'showMM',4,'color',{'b','g','m','y'},'histOpt',2);
%     legend('neutral','happy','angry','sad');
%     title('Accuracy');
%     ylim([-0.5 1.5]);
%     xticks([])
%     set(gca,'fontsize',12,'fontweight','bold');
%     
%     
%     %consistency
%     subplot(1,4,2)
%     distributionPlot(temp(:,[5:8]),'showMM',4,'color',{'b','g','m','y'},'histOpt',2);
%     legend('neutral','happy','angry','sad');
%     title('Consistency');
%     ylim([-0.5 1.5]);
%     xticks([])
%     set(gca,'fontsize',12,'fontweight','bold');
%     
%     %Speed
%     subplot(1,4,3)
%     distributionPlot(temp(:,[9:12]),'showMM',4,'color',{'b','g','m','y'},'histOpt',2);
%     legend('neutral','happy','angry','sad');
%     title('Speed');
%     ylim([-0.5 1.5]);
%     xticks([])
%     set(gca,'fontsize',12,'fontweight','bold');
%     
%     %Overall
%     subplot(1,4,4)
%     meantemp = [mean(temp(:,[1 5 9]),2) mean(temp(:,[2 6 10]),2) mean(temp(:,[3 7 11]),2) mean(temp(:,[4 8 12]),2)];
%     meantemp = [meantemp mean(meantemp,2)];
%     distributionPlot(meantemp,'showMM',4,'color',{'b','g','m','y','k'},'histOpt',2);
%     legend('neutral','happy','angry','sad','GrandAvg');
%     title('Overall Scores');
%     ylim([-0.5 1.5]);
%     xticks([])
%     set(gca,'fontsize',12,'fontweight','bold');
%     
%     % saveas(gcf,'faceoff_v2','png');
%     
%     %Two tap
%     temp = cell2mat({behdatacol.twotap}');
%     figure
%     %consistency
%     distributionPlot(temp(:,1),'showMM',4,'color',{'g'},'histOpt',2);
%     title('Consistency');
%     % title('[1 8]');
%     ylim([-0.5 1.5]);
%     xticks([])
%     set(gca,'fontsize',12,'fontweight','bold');
    
    %%
%     temp = cell2mat({behdatacol.gogreen}');
%     dprime = [temp(:,1);temp(:,2)];
%     con = [temp(:,3);temp(:,4)];
%     speed = [temp(:,5);temp(:,6)];
%     [r p] = corr(speed,dprime)%.3
%     [r p] = corr(con,dprime)%.9
%     [r p] = corr(con,speed)%.3
%     
%     temp = cell2mat({behdatacol.middlefish}');
%     dprime = [temp(:,1)];
%     con = [temp(:,2)];
%     speed = [temp(:,3)];
%     %%%%%%%%%%%%.00
%     [r p] = corr(speed,dprime)
%     %%%%%%%%%%%%%%%.00
%     [r p] = corr(con,dprime)
%     %%%%.5
%     [r p] = corr(con,speed)
%     
%     
%     temp = cell2mat({behdatacol.loststar}');
%     dprime = [temp(:,2)];
%     con = [temp(:,3)];
%     speed = [temp(:,4)];
%     %%%%%%%%%%%%.000
%     [r p] = corr(speed,dprime)
%     %%%%%%%%%%%%%%%.00
%     [r p] = corr(con,dprime)
%     %%%%.00
%     [r p] = corr(con,speed)
%     
%     
%     temp = cell2mat({behdatacol.faceoff}');
%     dprime = [temp(:,1);temp(:,2);temp(:,3);temp(:,4)];
%     con = [temp(:,5);temp(:,6);temp(:,7);temp(:,8)];
%     speed = [temp(:,9);temp(:,10);temp(:,11);temp(:,12)];
%     [r p] = corr(speed,dprime)%.4
%     [r p] = corr(con,dprime)%00
%     [r p] = corr(con,speed)%00
    
    %% lucky door
    
    temp = cell2mat({behdatacol.luckydoor}');
    
    tempnow = [temp(:,[4 9])];
    
    figure
    hold on
    for iternow = 1:size(tempnow,1)
        ylim([0 1]);
        plot(tempnow(iternow,:),'o-');
        pause
    end
    
    
    temp = cell2mat({behdatacol.luckydoor}');
    
    tempnow = [temp(:,[5 10])];
    
    figure
    hold on
    for iternow = 1:size(tempnow,1)
        ylim([0 1]);
        plot(tempnow(iternow,:),'o-');
        pause
    end
    
    
    %% ttests for the mini and the main behanalysis files
    %main one stored in behdatacol and the mini one is on behdatacol_mini
    clc
%     %go green
%     disp('GoGreen')
%     temp = cell2mat({behdatacol.gogreen}');
%     tempmini = cell2mat({behdatacol_mini.gogreen}');
%     disp('Block 1');
%     disp('dprime')
%     [h, p] = ttest(temp(:,1),tempmini(:,1)); [h p]
%     disp('consistency')
%     [h, p] = ttest(temp(:,3),tempmini(:,3)); [h, p]
%     disp('speed')
%     [h, p] = ttest(temp(:,5),tempmini(:,5)); [h, p]
%     
%     disp('Block 2');
%     disp('dprime')
%     [h, p] = ttest(temp(:,2),tempmini(:,2)); [h, p]
%     disp('consistency')
%     [h, p] = ttest(temp(:,4),tempmini(:,4)); [h, p]
%     disp('speed')
%     [h, p] = ttest(temp(:,6),tempmini(:,6)); [h, p]
%     
%     
%     %MiddleFish
%     disp('MiddleFish')
%     temp = cell2mat({behdatacol.middlefish}');
%     tempmini = cell2mat({behdatacol_mini.middlefish}');
%     disp('dprime')
%     [h, p] = ttest(temp(:,1),tempmini(:,1)); [h, p]
%     disp('consistency')
%     [h, p] = ttest(temp(:,2),tempmini(:,2)); [h, p]
%     disp('speed')
%     [h, p] = ttest(temp(:,3),tempmini(:,3)); [h, p]
%     
%     
%     %LostStar
%     disp('LostStar')
%     temp = cell2mat({behdatacol.loststar}');
%     tempmini = cell2mat({behdatacol_mini.loststar}');
%     disp('accuracy')
%     [h, p] = ttest(temp(:,2),tempmini(:,2)); [h, p]
%     disp('consistency')
%     [h, p] = ttest(temp(:,3),tempmini(:,3)); [h, p]
%     disp('speed')
%     [h, p] = ttest(temp(:,4),tempmini(:,4)); [h, p]
%     
%     
%     %FaceOff
%     disp('FaceOff')
%     temp = cell2mat({behdatacol.faceoff}');
%     tempmini = cell2mat({behdatacol_mini.faceoff}');
%     disp('Neutral')
%     disp('accuracy')
%     [h, p] = ttest(temp(:,1),tempmini(:,1)); [h, p]
%     disp('consistency')
%     [h, p] = ttest(temp(:,5),tempmini(:,5)); [h, p]
%     disp('speed')
%     [h, p] = ttest(temp(:,9),tempmini(:,9)); [h, p]
%     
%     disp('Happy')
%     disp('accuracy')
%     [h, p] = ttest(temp(:,2),tempmini(:,2)); [h, p]
%     disp('consistency')
%     [h, p] = ttest(temp(:,6),tempmini(:,6)); [h, p]
%     disp('speed')
%     [h, p] = ttest(temp(:,10),tempmini(:,10)); [h, p]
%     
%     disp('Angry')
%     disp('accuracy')
%     [h, p] = ttest(temp(:,3),tempmini(:,3)); [h, p]
%     disp('consistency')
%     [h, p] = ttest(temp(:,7),tempmini(:,7)); [h, p]
%     disp('speed')
%     [h, p] = ttest(temp(:,11),tempmini(:,11)); [h, p]
%     
%     disp('Sad')
%     disp('accuracy')
%     [h, p] = ttest(temp(:,4),tempmini(:,4)); [h, p]
%     disp('consistency')
%     [h, p] = ttest(temp(:,8),tempmini(:,8)); [h, p]
%     disp('speed')
%     [h, p] = ttest(temp(:,12),tempmini(:,12)); [h, p]
%     
    
    %LuckyDoor
    disp('LuckyDoor')
    temp = cell2mat({behdatacol.luckydoor}');
    tempmini = cell2mat({behdatacol_mini.luckydoor}');
    disp('Block 1');
    disp('FinalQuartile')
    [h, p] = ttest(temp(:,4),tempmini(:,4)); [h, p]
    disp('Overall')
    [h, p] = ttest(temp(:,5),tempmini(:,5)); [h, p]
    disp('Block 2');
    disp('FinalQuartile')
    [h, p] = ttest(temp(:,9),tempmini(:,9)); [h, p]
    disp('Overall')
    [h, p] = ttest(temp(:,10),tempmini(:,10)); [h, p]
    
    
%     %TwoTap
%     disp('TwoTap')
%     temp = cell2mat({behdatacol.twotap}');
%     tempmini = cell2mat({behdatacol_mini.twotap}');
%     disp('Block 0');
%     [h, p] = ttest(temp(:,1),tempmini(:,1)); [h, p]
%     
    
%end
