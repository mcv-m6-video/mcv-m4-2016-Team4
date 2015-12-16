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
offsetDesynch = 0; % offsetDesynch = 0 --> Synchronized
% Test A
testIdA = 'test_A_';
[ tpA , fpA , fnA , tnA , totalForegroundA , totalBackgroundA ] =  ...
    segmentationEvaluation( pathHighwayGroundtruth , pathHighwayResults , testIdA , offsetDesynch , VERBOSE );

% Test B
testIdB = 'test_B_';
[ tpB , fpB , fnB , tnB , totalForegroundB , totalBackgroundB ] =  ...
    segmentationEvaluation( pathHighwayGroundtruth , pathHighwayResults , testIdB , offsetDesynch , VERBOSE );

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
%% Task 4 and 5
% Compute the mean magnitude error, MMEN, for all pixels in non-occluded areas.
% Calculate the percentage of erroneous pixels, PEPN, in non-occluded areas.

pathDataStereoGroundtruth = [ pathDataStereo filesep 'training' filesep 'flow_noc' ];
pathDataStereoResults = [ pathDataStereo filesep 'results' ];
testId = 'LKflow_';
pepnThresh = 3;

[ msen , pepn ] = opticalFlowEvaluation( pathDataStereoGroundtruth , pathDataStereoResults , testId , pepnThresh , VERBOSE );

%% Optionals
%% Task 6
% Desynchronized results for background substraction
offsetList = 0:25;

i=1;
for offsetDesynch=offsetList % offsetDesynch > 0 --> Desynchronized
    % Test A
    testIdA = 'test_A_';
    [tpA, fpA, fnA, tnA, ~, ~] =  ...
        segmentationEvaluation( pathHighwayGroundtruth , pathHighwayResults , testIdA , offsetDesynch , 0 );
    
    %Initialize F1 Score Test A
    if i==1
        f1scoreA = zeros(length(tpA),length(offsetList));
    end % if
    
    [~, ~, f1scoreA(:,i)] = getMetrics(tpA, fpA, fnA, tnA);
    % Test B
    
    %Initialize F1 Score Test A
    if i==1
        f1scoreB = zeros(length(tpB),length(offsetList));
    end % if
    
    testIdB = 'test_B_';
    [tpB, fpB, fnB, tnB, ~, ~] =  ...
        segmentationEvaluation( pathHighwayGroundtruth , pathHighwayResults , testIdB , offsetDesynch , 0 );
    [~, ~, f1scoreB(:,i)] = getMetrics(tpB, fpB, fnB, tnB);
    
    i = i + 1;
end %for

if VERBOSE
    %F1 Score evolution along desynchronization
    plotF1ScorePerFrame([mean(f1scoreA)' mean(f1scoreB)']);
    title('F1 Score evolution along desynchronization');
    xlabel('Desync frames');
    xlim([0 max(offsetList)]);
    
    %Only make this detailed plot if there are few lines (>6) to segment.
    %Otherwise, the plot will fail because there are not enough colors.
    if length(offsetList) < 6
        %More detailed F1 Score evolution plot
        % Create custom legend indicating the offset of each curve. 
        legendStr = cell(1,length(offsetList));
        for i=1:length(offsetList)
            legendStr{i} = sprintf('Offset=%d', offsetList(i));
        end %for

        %TEST A
        plotF1ScorePerFrame(f1scoreA);
        %Overwrite title and legend
        title('F1-Score vs #frame (Test A)');
        legend(legendStr);

        %TEST B
        plotF1ScorePerFrame(f1scoreB);
        %Overwrite title and legend
        title('F1-Score vs #frame (Test B)');
        legend(legendStr);
    end
    
end %if

%% Task 7
% Plot the optical flow
% flow_u = (double(im_test(:,:,1))-2^15)/64.0;
% flow_v = (double(im_test(:,:,2))-2^15)/64.0;
% quiver(flow_u,flow_v)
plotOpticalFlow(imreal, imtest, 10);

