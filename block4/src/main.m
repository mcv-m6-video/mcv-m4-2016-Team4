%% Main Script
% M4. Video Analysis Project
% This script computes all the tasks that are done for the block 4 of the
% project.
% 

%% Setup
setup;

%% Task 1
optFlowFunc = @applyOpticalFlowTask1;
opticalFlowTest(optFlowFunc, flow, pepnThresh, VERBOSE);
%% Task 2
taskId = 'B4_task2';
optFlowFunc = @applyOpticalFlowTask2;
outputPath = [ flow.resultsFolders taskId filesep];
if ~exist(outputPath, 'dir')
    mkdir(outputPath);
end
opticalFlowTest(optFlowFunc, flow, outputPath, pepnThresh, VERBOSE);
%% Task 3

%% Task 4

%% Task 5

%% Task 6
