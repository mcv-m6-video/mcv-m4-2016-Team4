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
alphaValues = 0:0.5:10;
connectivity = [4 , 8];
morphFunction = @applyMorphoTask1;
evaluateMorpho(seq, fileFormat, alphaValues, connectivity, morphFunction, colorIm, colorTransform);

% Task 2
folderBestResultsT1 = 'resultsImFill_4/';
minPixels = 1; stepPixels = 10; maxPixels = 100;
pixels = minPixels:stepPixels:maxPixels;
task2(pixels , seq , folderBestResultsT1);
