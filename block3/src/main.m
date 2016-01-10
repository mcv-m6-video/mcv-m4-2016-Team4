%% Main Script
% M4. Video Analysis Project
% This script computes all the tasks that are done for the block 3 of the
% project.
% 

%% Initialize global parameters
setup;

%% Set up enviroment and get the best model from the block 2
if ~exist([seq.basePaths{1} folderBaseResults ], 'dir')
    allSequencesSegmentation(seq, folderBaseResults, fileFormat, colorIm, colorTransform);
end

%% Task 1
% Generate precision and recall
minAlpha=0; stepAlpha=0.5; maxAlpha=10;
alphaValues = minAlpha:stepAlpha:maxAlpha;
taskId = '1';
if ~exist(['savedResults' filesep 'dataTask1.mat'], 'file')
    connectivity = [4 , 8];
    morphFunction = @applyMorphoTask1;
    evaluateMorpho(seq, fileFormat, alphaValues, connectivity, morphFunction, colorIm, colorTransform, taskId);
else
   disp('Task 1 results found (savedResults/dataTask1.mat). Skipping Task 1...'); 
end

% Generate figures and calculate AUC
results = load(['savedResults' filesep 'dataTask1']);
legendStr = {'Baseline', 'Connectivity=4', 'Connectivity=8'};
[AUCs1, AUCs2] = calculateAUCs(seq, results, folderFigures, legendStr, taskId);

%% Task 2
if ~exist(['savedResults' filesep 'dataTask2.mat'], 'file')
    taskId = '2';
    minPixels = 1; stepPixels = 10; maxPixels = 100;
    pixels = minPixels:stepPixels:maxPixels;
    morphFunction = @applyMorphoTask2;
    evaluateMorpho(seq, fileFormat, alphaValues, pixels, morphFunction, colorIm, colorTransform, taskId);
else
   disp('Task 2 results found (savedResults/dataTask2.mat). Skipping Task 2...');  
end

% Generate figures and calculate AUC
results = load(['savedResults' filesep 'dataTask2']);
AUCs = calculateAUCs(seq, results);