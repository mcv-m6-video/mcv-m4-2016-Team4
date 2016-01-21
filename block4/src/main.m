%% Main Script
% M4. Video Analysis Project
% This script computes all the tasks that are done for the block 4 of the
% project.
% 

%% Setup
setup;

%% Task 1
taskId = 'B4_task1A';
%%%%%%% SpecialParameters applyOpticalFlowTask1
compensation = 'forward'; % 'backward'
blockSize = [16, 16];
areaSearch = blockSize(1)+blockSize(1)/2;
stepSlidingWindow = 1;
%%%%%%%
optFlowFunc = @(frames, outputPath, orderId) applyOpticalFlowTask1(frames, ...
    outputPath, orderId, compensation, areaSearch, blockSize, stepSlidingWindow);
outputPath = [ flow.resultsFolders taskId filesep];
if ~exist(outputPath, 'dir')
    mkdir(outputPath);
end
opticalFlowTest(optFlowFunc, flow, outputPath, pepnThresh, VERBOSE);
%%
taskId = 'B4_task1B';
%%%%%%% SpecialParameters applyOpticalFlowTask1
compensation = 'backward';
blockSize = [16, 16];
areaSearch = blockSize(1)+blockSize(1)/2;
stepSlidingWindow = 1;
%%%%%%%
optFlowFunc = @(frames, outputPath, orderId) applyOpticalFlowTask1(frames, ...
    outputPath, orderId, compensation, areaSearch, blockSize, stepSlidingWindow);
outputPath = [ flow.resultsFolders taskId filesep];
if ~exist(outputPath, 'dir')
    mkdir(outputPath);
end
opticalFlowTest(optFlowFunc, flow, outputPath, pepnThresh, VERBOSE);

%% Task 2
taskId = 'B4_task2';
%%%%%%% SpecialParameters applyOpticalFlowTask2
NoiseThreshold = 0.0039;
%%%%%%%
optFlowFunc = @(frames, outputPath, orderId) applyOpticalFlowTask2(frames, outputPath, orderId, NoiseThreshold, VERBOSE);
outputPath = [ flow.resultsFolders taskId filesep];
if ~exist(outputPath, 'dir')
    mkdir(outputPath);
end
opticalFlowTest(optFlowFunc, flow, outputPath, pepnThresh, VERBOSE);

%% Task 3
blockSize = [17 17];
areaSearch = [7, 7];

optFlowFunc = @(frames, outputPath, orderId) applyOpticalFlowTask3(frames, outputPath, orderId, blockSize, areaSearch, false);
task3(seq.inputFolders{3}, seq.framesInd{3}, seq.gtFolders{3}, optFlowFunc, fileFormat, folderFigures)

%% Task 4
task4;

%% Task 5

task5a(seq.inputFolders{3}, seq.framesInd{3}, seq.gtFolders{3}, fileFormat, folderFigures)
task5b(seq.inputFolders{3}, seq.framesInd{3}, seq.gtFolders{3}, fileFormat, folderFigures)

%% Task 6
