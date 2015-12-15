%% Main Script
% M4. Video Analysis Project
% This script computes all the tasks that are done for the block 1 of the
% project.
% 
%% Set up enviroment

clear all; clc; close all;
pathDatasets = ['..' filesep '..' filesep 'datasets'];
pathHighway = [pathDatasets filesep 'highway'];
pathDataStereo = [pathDatasets filesep 'data_stereo_flow'];
VERBOSE = true;

%% Task 1
% Segmentation metrics (total).

% Get the needed files and split in test A and test B
pathHighwayGroundtruth = [pathHighway filesep 'groundtruth' filesep 'gt' ];
pathHighwayResults = [pathHighway filesep 'results' filesep ];

% Test A
testIdA = 'test_A_';
[ tpA , fpA , fnA , tnA , totalForegroundA , totalBackgroundA ] =  ...
    segmentationEvaluation( pathHighwayGroundtruth , pathHighwayResults , testIdA , VERBOSE );

% Test B
testIdB = 'test_B_';
[ tpB , fpB , fnB , tnB , totalForegroundB , totalBackgroundB ] =  ...
    segmentationEvaluation( pathHighwayGroundtruth , pathHighwayResults , testIdB , VERBOSE );

%% Task 2
% Test A segmentation has a higher recall because it misses less foreground pixels (true samples). 
% However, it misclassifies background pixels (false samples) as foreground (FP) and, consequently, 
% the precision lowers.
% On the other hand, Test B has a higher precision because most of the positive pixels (TP+FP) are 
% foreground (TP) at a cost of having foreground pixels incorrectly classified as background (FN), 
% which lowers the recall.

%% Task 3

% Obtain the metrics
[precisionA, recallA, f1scoreA] = getMetrics(tpA, fpA, fnA, tnA);
[precisionB, recallB, f1scoreB] = getMetrics(tpB, fpB, fnB, tnB);

if VERBOSE
    % .a
    plotF1ScorePerFrame([f1scoreA f1scoreB]);

    % .b
    plotTP_TF_PerFrame([tpA tpB], totalForegroundA);
end