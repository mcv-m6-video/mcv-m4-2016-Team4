%% Main Script
% M4. Video Analysis Project
% This script computes all the tasks that are done for the block 1 of the
% project.
% 
%% Set up enviroment

%clear all; clc; close all;

pathDatasets = ['..' filesep '..' filesep 'datasets'];
pathHighway = [pathDatasets filesep 'highway'];
pathDataStereo = [pathDatasets filesep 'data_stereo_flow'];
VERBOSE = true;

%% Foreground Estimation Metrics
%% Task 1
% Segmentation metrics (total).

% Get the needed files and split in test A and test B
pathHighwayGroundtruth = [pathHighway filesep 'groundtruth' filesep 'gt' ];
pathHighwayResults = [pathHighway filesep 'results' filesep ];
forward = 1; % Synchronized
% Test A
testIdA = 'test_A_';
[ tpA , fpA , fnA , tnA , totalForegroundA , totalBackgroundA ] =  ...
    segmentationEvaluation( pathHighwayGroundtruth , pathHighwayResults , testIdA , forward , VERBOSE );

% Test B
testIdB = 'test_B_';
[ tpB , fpB , fnB , tnB , totalForegroundB , totalBackgroundB ] =  ...
    segmentationEvaluation( pathHighwayGroundtruth , pathHighwayResults , testIdB , forward , VERBOSE );

%% Task 2
% Test A segmentation has a higher recall because it misses less foreground pixels (true samples). 
% However, it misclassifies background pixels (false samples) as foreground (FP) and, consequently, 
% the precision lowers.
% On the other hand, Test B has a higher precision because most of the positive pixels (TP+FP) are 
% foreground (TP) at a cost of having foreground pixels incorrectly classified as background (FN), 
% which lowers the recall.

%% Task 3
% Temporal analysis of the results

% Test A
% Obtain the metrics
[precisionA, recallA, f1scoreA] = getMetrics(tpA, fpA, fnA, tnA);

% Test B
% Obtain the metrics
[precisionB, recallB, f1scoreB] = getMetrics(tpB, fpB, fnB, tnB);

if VERBOSE
    % Graph 1. F1-Score vd # frame
    plotF1ScorePerFrame([f1scoreA f1scoreB]);

    % Graph 2. True Positive & Total Foreground pixels vs # frame
    plotTP_TF_PerFrame([tpA tpB], totalForegroundA);
end % if

%% Motion Estimation Metrics
%% Task 4
% Compute the mean magnitude error, MMEN, for all pixels in non-occluded areas.

pathDataStereoGroundtruth = [ pathDataStereo filesep 'training' filesep 'flow_noc' ];
pathDataStereoResults = [ pathDataStereo filesep 'results' ];
testId = 'LKflow_';
pepnThresh = 3;

[ msen , pepn ] = opticalFlowEvaluation( pathDataStereoGroundtruth , pathDataStereoResults , testId , pepnThresh , VERBOSE );

%% Task 5
% Calculate the percentage of erroneous pixels, PEPN, in non-occluded
% areas.

%% Optionals
%% Task 6
% De-synchronized results for background substraction

forward = 1; % Synchronized
% Test A
testIdA = 'test_A_';
[ tpA , fpA , fnA , tnA , totalForegroundA , totalBackgroundA ] =  ...
    segmentationEvaluation( pathHighwayGroundtruth , pathHighwayResults , testIdA , forward , VERBOSE );

% Test B
testIdB = 'test_B_';
[ tpB , fpB , fnB , tnB , totalForegroundB , totalBackgroundB ] =  ...
    segmentationEvaluation( pathHighwayGroundtruth , pathHighwayResults , testIdB , forward , VERBOSE );


%% Task 7
% Plot the optical flow
% flow_u = (double(im_test(:,:,1))-2^15)/64.0;
% flow_v = (double(im_test(:,:,2))-2^15)/64.0;
% quiver(flow_u,flow_v)
