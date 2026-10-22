clear all;close all;clc

saveLDFileName = 'LDProject.mat'; % save File name
load('LD_params.mat')
LDproject=struct();
% Each variable loaded is 4D matrix size freq x chan/roi x time x sub
% Scalp Data
load(LUCKYDOOR_SCALP_PRE_DATA) % fill this out
LDproject.scalpData.Pre.groupname='Pre';
LDproject.scalpData.Pre.EVgain=EVgain;
LDproject.scalpData.Pre.EVloss=EVloss;
LDproject.scalpData.Pre.GLbias=GLbias;
LDproject.scalpData.Pre.subList=subjectcoll; % make sure this is the same as post (sub###, not subpre###)
load(LUCKYDOOR_SCALP_POST_DATA) % fill this out
LDproject.scalpData.Post.groupname='Post';
LDproject.scalpData.Post.EVgain=EVgain;
LDproject.scalpData.Post.EVloss=EVloss;
LDproject.scalpData.Post.GLbias=GLbias;
LDproject.scalpData.Post.subList=subjectcoll; % make sure this is the same as pre (sub###, not subpost###)

% source Data
load(LUCKYDOOR_SOURCE_PRE_DATA) % fill this out
LDproject.sourceData.Pre.groupname='Pre';
LDproject.sourceData.Pre.EVgain=EVgain;
LDproject.sourceData.Pre.EVloss=EVloss;
LDproject.sourceData.Pre.GLbias=GLbias;
LDproject.sourceData.Pre.subList=subjectcoll; % make sure this is the same as post (sub###, not subpre###)
load(LUCKYDOOR_SOURCE_POST_DATA) % fill this out
LDproject.sourceData.Post.groupname='Post';
LDproject.sourceData.Post.EVgain=EVgain;
LDproject.sourceData.Post.EVloss=EVloss;
LDproject.sourceData.Post.GLbias=GLbias;
LDproject.sourceData.Post.subList=subjectcoll; % make sure this is the same as pre (sub###, not subpost###)

load('LD_params.mat')
LDproject.info.freq_list=freq_list;
LDproject.info.timeAxis=timeAxis;
LDproject.info.groupNames=fieldnames(LDproject.scalpData);
LDproject.info.variables=setdiff(fieldnames(LDproject.scalpData.Pre),{'groupname','subList'});
% General information
LDproject.info.chanlocs=chanlocs_str;
LDproject.info.roi=roi;
save(saveLDFileName,'LDproject')



