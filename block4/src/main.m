%% Main Script
% M4. Video Analysis Project
% This script computes all the tasks that are done for the block 4 of the
% project.
% 

%% Setup
setup;

%% Task 1
taskId = 'B4_task2';
%%%%%%% SpecialParameters applyOpticalFlowTask1
compensation = 'forward'; % 'backward'
areaSearch = 200;
blockSize = 50;
StepSlidingWindow = 20;
%%%%%%%
optFlowFunc = @(frames, outputPath, orderId) applyOpticalFlowTask1(frames, ...
    outputPath, orderId, compensation, areaSearch, blockSize, StepSlidingWindow);
outputPath = [ flow.resultsFolders taskId filesep];
if ~exist(outputPath, 'dir')
    mkdir(outputPath);
end
opticalFlowTest(optFlowFunc, flow, outputPath, pepnThresh, VERBOSE);

%% Task 2
taskId = 'B4_task2';
%%%%%%% SpecialParameters applyOpticalFlowTask2
NoiseThreshold = 0.009;
%%%%%%%
optFlowFunc = @(frames, outputPath, orderId) applyOpticalFlowTask2(frames, outputPath, orderId, NoiseThreshold);
optFlowFunc = @(frames, outputPath, orderId) applyOpticalFlowTask2(frames, outputPath, orderId, NoiseThreshold, VERBOSE);
outputPath = [ flow.resultsFolders taskId filesep];
if ~exist(outputPath, 'dir')
    mkdir(outputPath);
end
opticalFlowTest(optFlowFunc, flow, outputPath, pepnThresh, VERBOSE);

%% Task 3

%% Task 4

%% Task 5

%% Task 6
