%% Neatlabs base EEG processing: epoching + PEB+ artifact cleaning
% Cleaned-up version. Every change is marked with a tag like [CHG-3];
% the numbers match the change list that came with this file.
% Requires MATLAB R2016b or newer (local functions at the end of a script).
clear; clc; close all

%% ===================== USER SETTINGS (edit here) =====================
eeglabPath  = '/eeglab';                                   % folder containing eeglab.m
rawData     = RAW_DATA_FOLDERPATH;
resultsDir  = RESULTS_FOLDERPATH;
filePattern = 'mycog.xdf';        % template for your .xdf files
subjectIdx  = [];                 % [] = all subjects, or e.g. 1:3

% PEB+ parameters
templatefile = "headModel_templateFile_newPEBplus.mat"; % if you have a template file, specify here
%templatefile = headModel.getDefaultTemplateFilename(); %Otherwise use this
conductivity         = [0.33, 0.022, 0.33];
orientation          = false;
saveFull             = false;
account4artifacts    = true;
src2roiReductionType = 'm2power';

%% ===================== TASK TABLE ===================
%   Modify here for changes to task
%   name    : task folder / file-name label
%   preproc : preprocessing function for that task
%   behKey  : text that identifies the task's behavioural file
%   tag     : prefix inserted in file names ('nogo1_' for task 1, 'ch_' for task 4)
tasks = struct( ...
    'name',    {'go_green', 'middle_fish', 'lost_star', 'lucky_door', 'face_off', 'two_tap'}, ...
    'preproc', {@go_wait.preProcessing, @middle_fish.preProcessing, @lost_star.preProcessing, ...
                @lucky_door.preProcessing, @face_off.preProcessing, @two_tap.preProcessing}, ...
    'behKey',  {'gowait', 'middlefish', 'loststar', 'luckydoor', 'faceoff', 'twotap'}, ...
    'tag',     {'nogo1_', '', '', 'ch_', '', ''});

%% ===================== SETUP =====================
addpath(eeglabPath);
eeglab;

eeglabRoot   = fileparts(which('eeglab'));
templateFile = fullfile(eeglabRoot, 'plugins', 'BrainEAnalysis', templatefile);

if ~exist(resultsDir, 'dir'), mkdir(resultsDir); end

fid = fopen(fullfile(resultsDir, 'errors.log'), 'a');
closeLog = onCleanup(@() fclose(fid));

files = pickList(rawData, {filePattern});
if isempty(subjectIdx), subjectIdx = 1:numel(files); end
files = files(subjectIdx);

%% ===================== RUN PIPELINE =====================
for s = 1:numel(files)
    rawFile = files{s};
    [pathName, rawFileName] = fileparts(rawFile);
    fprintf('Processing subject %s (%d/%d)\n', rawFileName, s, numel(files));  

    for t = 1:numel(tasks)
        task = tasks(t);
        fprintf('  Task %d: %s\n', t, task.name);                               
        try
            taskFolder = fullfile(resultsDir, rawFileName, task.name);
            if ~exist(taskFolder, 'dir'), mkdir(taskFolder); end

            runEpoching(rawFile, pathName, rawFileName, task, taskFolder);
            runPEB(task, taskFolder, templateFile, conductivity, orientation, ...
                   saveFull, account4artifacts, src2roiReductionType);
        catch ME
            msg = sprintf('%s\t%s\t%s', rawFileName, task.name, strrep(ME.message, newline, ' '));
            fprintf(2, '  ERROR: %s\n', msg);
            fprintf(fid, '%s\n', msg);
        end
    end
end

%% ===================== LOCAL FUNCTIONS =====================

function runEpoching(rawFile, pathName, rawFileName, task, taskFolder)
    disp('  Epoching');
    % Skip if this task was already epoched
    if ~isempty(pickList(taskFolder, {['processvars_' task.tag], '.mat'}))
        return
    end

    behFile = findBehFile(pathName, task.behKey);
    preproc = task.preproc;
    [EEGset, ProcessVars] = preproc(rawFile, behFile);

    for k = 1:numel(EEGset)
        pipelineSettings = ProcessVars(k);
        stem         = [task.tag task.name '_' rawFileName '_' EEGset{k}.setname];
        settingsFile = fullfile(taskFolder, ['processvars_' stem '.mat']);

        EEGset{k}.etc.pipelineSettingsFile = settingsFile;
        pop_saveset(EEGset{k}, 'filepath', taskFolder, ...
                    'filename', ['epoch_' stem], 'savemode', 'onefile');
        save(settingsFile, 'pipelineSettings');
    end
end

function behFile = findBehFile(pathName, key)
    candidates = pickList(pathName, {'.xlsx'}, {'.xlsx'}, {'lock'});
    if isempty(candidates)
        candidates = pickList(pathName, 'trial_summary.csv');
    end
    if isempty(candidates)
        error('No behavioural file found in %s', pathName);
    end

    if numel(candidates) == 1
        behFile = candidates{1};
    else
        hit = find(contains(candidates, key), 1);
        if isempty(hit)
            error('No behavioural file matching "%s" in %s', key, pathName);
        end
        behFile = candidates{hit};
    end
end

function runPEB(task, taskFolder, templateFile, conductivity, orientation, ...
                saveFull, account4artifacts, reductionType)
    disp('  PEB+');
    epochFiles = pickList(taskFolder, {['epoch_' task.tag], '.set'}, ...
                                      {['epoch_' task.tag], '.set'}, {'peb'});

    for k = 1:numel(epochFiles)
        [~, fileName] = fileparts(epochFiles{k});
        outName = ['peb_cleaned_' task.tag fileName];   % same name as before
        if exist(fullfile(taskFolder, [outName '.set']), 'file')
            continue
        end

        EEG = pop_loadset(epochFiles{k});
        EEG = pop_forwardModel(EEG, templateFile, conductivity, orientation);
        EEG = pop_pebp(EEG, saveFull, account4artifacts, reductionType);
        pop_saveset(EEG, 'filepath', taskFolder, 'filename', outName, 'savemode', 'onefile');
    end
end

function list = pickList(varargin)
    f = pickfiles(varargin{:});
    if isempty(f), list = {}; else, list = cellstr(f); end
end
