%% Main Script
% M4. Video Analysis Project
% This script computes all the tasks that are done for the block 3 of the
% project.
% 

%% Initialize global parameters
setup;

%% Set up enviroment and get the best model from the block 2
if ~exist([seq.basePaths{1} folderBaseResults ], 'dir')
    obtainBestResultsB2(seq, folderBaseResults, fileFormat, colorIm, colorTransform);
end

% Task 1
connectivity = 4;
task1(connectivity, seq, folderBaseResults)

