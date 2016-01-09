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

% Task 1
taskId = '1';
minAlpha=0; stepAlpha=0.5; maxAlpha=10;
alphaValues = minAlpha:stepAlpha:maxAlpha;
connectivity = [4 , 8];
morphFunction = @applyMorphoTask1;
evaluateMorpho(seq, fileFormat, alphaValues, connectivity, morphFunction, colorIm, colorTransform, taskId);

% Task 2
taskId = '2';
minPixels = 1; stepPixels = 10; maxPixels = 100;
pixels = minPixels:stepPixels:maxPixels;
morphFunction = @applyMorphoTask2;
evaluateMorpho(seq, fileFormat, alphaValues, pixels, morphFunction, colorIm, colorTransform, taskId);
