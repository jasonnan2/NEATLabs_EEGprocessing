%% Formatting Data
% Run this after you have all the 'neural_task_data_outlierrm_post' and '..pre' files
clear all;close all;clc
%%
saveFileName = 'formattedProject.mat'
baseFolder = './sourceData/';
freq_list = {'theta','alpha','beta'}; % enter the freq (folders you have under sourceData

postGW =[];postMF=[];postLS=[];postFO=[]; preGW=[];preMF=[];preLS=[];preFO=[];
for f=1:length(freq_list)
    freq = string(freq_list{f});
    load(fullfile(baseFolder, freq, 'neural_task_data_outlierrm_post.mat'))
    postSubCol = subjectcoll;
    load(fullfile(baseFolder, freq, 'neural_task_data_outlierrm_pre.mat'))
    preSubCol = subjectcoll;

    postTrials = cat(2,all_task_post, accurate_post_resp,accurate_post_fdbk);
    postGW(f,:,:,:) = squeeze(postTrials(:,:,1,:));
    postMF(f,:,:,:) = squeeze(postTrials(:,:,2,:));
    postLS(f,:,:,:) = squeeze(postTrials(:,:,3,:));
    postFO(f,:,:,:) = squeeze(postTrials(:,:,5,:));
    
    preTrials = cat(2,all_task_pre, accurate_pre_resp,accurate_pre_fdbk);
    preGW(f,:,:,:) = squeeze(preTrials(:,:,1,:));
    preMF(f,:,:,:) = squeeze(preTrials(:,:,2,:));
    preLS(f,:,:,:)= squeeze(preTrials(:,:,3,:));
    preFO(f,:,:,:) = squeeze(preTrials(:,:,5,:));

end

project.sourceData.Pre.groupname='Pre';
project.sourceData.Pre.GoWait=preGW;
project.sourceData.Pre.MiddleFish=preMF;
project.sourceData.Pre.LostStar=preLS;
project.sourceData.Pre.FaceOff=preFO;
project.sourceData.Pre.subList=preSubCol;

project.sourceData.Post.groupname='Post';
project.sourceData.Post.GoWait=postGW;
project.sourceData.Post.MiddleFish=postMF;
project.sourceData.Post.LostStar=postLS;
project.sourceData.Post.FaceOff=postFO;
project.sourceData.Post.subList=postSubCol;

timeAxis=[-996:4:2996]; % [-996 1000] relative to stim onset | [1000 2000] relative to response, 1500 is response onset | [2000 2996] relative to feedback, 2500 is feedback onset.
project.info.freq_list=freq_list;
project.info.timeAxis=timeAxis;
project.info.groupNames=fieldnames(project.sourceData);
project.info.variables=setdiff(fieldnames(project.sourceData.Pre),{'groupname','subList'});
% General information
load('68roi.mat')
project.info.roi=roi;

save(saveFileName, 'project')
