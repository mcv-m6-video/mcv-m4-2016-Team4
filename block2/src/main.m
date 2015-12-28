%% Main Script
% M4. Video Analysis Project
% This script computes all the tasks that are done for the block 2 of the
% project.
% 
%% Set up enviroment

clear all; clc; close all;

pathDatasets = ['..' filesep '..' filesep 'datasets' filesep];
folderInput = [ 'input' filesep 'in' ];
folderGroundtruth = [ 'groundtruth' filesep 'gt' ];
fileFormat = '.jpg';

folderHighway = [ pathDatasets 'highway' filesep ];
folderFall = [ pathDatasets 'fall' filesep ];
folderTraffic = [ pathDatasets 'traffic' filesep ];
highway = 1050:1350;
fall = 1460:1560;
traffic = 950:1050;

VERBOSE = false;

pathHighwayInput = [ folderHighway folderInput ];
pathHighwayGroundtruth = [ folderHighway folderGroundtruth ];

pathFallInput = [ folderFall folderInput ];
pathFallGroundtruth = [ folderFall folderGroundtruth ];

pathTrafficInput = [ folderTraffic folderInput ];
pathTrafficGroundtruth = [ folderTraffic folderGroundtruth ];

testId = '';

%% Non-recursive Gaussian modeling
%% Task 1
% One gaussian distribution to model the background pixels.

% Threshold
alpha = 2.5;

% Results Folder
oneGaussianResultsFolder = 'resultsOneGaussian';

% Highway
pathHighwayResults = [ folderHighway oneGaussianResultsFolder filesep ];
if ~exist(pathHighwayResults , 'dir')
    mkdir( pathHighwayResults );
end % if
pathHighwayResults = [ pathHighwayResults testId ];

oneGaussianBackground( highway , pathHighwayInput , fileFormat , pathHighwayResults , alpha);

% Fall
pathFallResults = [ folderFall oneGaussianResultsFolder filesep ];
if ~exist(pathFallResults , 'dir')
    mkdir( pathFallResults );
end % if
pathFallResults = [ pathFallResults testId ];

oneGaussianBackground( fall , pathFallInput , fileFormat , pathFallResults , alpha);

% Traffic
pathTrafficResults = [ folderTraffic oneGaussianResultsFolder filesep ];
if ~exist(pathTrafficResults , 'dir')
    mkdir( pathTrafficResults );
end % if
pathTrafficResults = [ pathTrafficResults testId ];

oneGaussianBackground( traffic , pathTrafficInput , fileFormat , pathTrafficResults , alpha);

%% Task 2 & 3
% Draw the curves F1 score, True Positive, True Negative, False Positive, False 
% Negative vs. threshold ? for the three proposed sequences (remember to convert 
% them to gray-scale).
% Draw the curve Precision vs. Recall depending of threshold ? for the three
% proposed sequences and comment the results.

offsetDesynch = 0; % offsetDesynch = 0 --> Synchronized

minAlpha = 0; stepAlpha = 0.5; maxAlpha = 5;
threshold = minAlpha:stepAlpha:maxAlpha;
szMetrics = length(threshold); count = 1;

% Setup variables
prec1 = zeros(szMetrics,1); rec1 = zeros(szMetrics,1); f1score1 = zeros(szMetrics,1);
tp1 = zeros(szMetrics,1); tn1 = zeros(szMetrics,1); fp1 = zeros(szMetrics,1); fn1 = zeros(szMetrics,1);

prec2 = zeros(szMetrics,1); rec2 = zeros(szMetrics,1); f1score2 = zeros(szMetrics,1);
tp2 = zeros(szMetrics,1); tn2 = zeros(szMetrics,1); fp2 = zeros(szMetrics,1); fn2 = zeros(szMetrics,1);

prec3 = zeros(szMetrics,1); rec3 = zeros(szMetrics,1); f1score3 = zeros(szMetrics,1);
tp3 = zeros(szMetrics,1); tn3 = zeros(szMetrics,1); fp3 = zeros(szMetrics,1); fn3 = zeros(szMetrics,1);

addpath('./../../evaluation')
for alpha = minAlpha:stepAlpha:maxAlpha
    
    % Highway
    oneGaussianBackground( highway , pathHighwayInput , fileFormat , pathHighwayResults , alpha);
    
    % Evaluate
    [ tpAux , fpAux , fnAux , tnAux , ~ , ~ ] =  ...
        segmentationEvaluation( pathHighwayGroundtruth , pathHighwayResults , testId , offsetDesynch , VERBOSE );
    tp1(count) = sum(tpAux); fp1(count) = sum(fpAux); fn1(count) = sum(fnAux); tn1(count) = sum(tnAux);
    [ precAux , recAux , f1Aux ] = getMetrics( tp1(count) , fp1(count) , fn1(count) , tn1(count) );
    prec1(count) = precAux; rec1(count) = recAux; f1score1(count) = f1Aux;
    
    % Fall
    oneGaussianBackground( fall , pathFallInput , fileFormat , pathFallResults , alpha);

    % Evaluate
    [ tpAux , fpAux , fnAux , tnAux , ~ , ~ ] =  ...
        segmentationEvaluation( pathFallGroundtruth , pathFallResults , testId , offsetDesynch , VERBOSE );
    tp2(count) = sum(tpAux); fp2(count) = sum(fpAux); fn2(count) = sum(fnAux); tn2(count) = sum(tnAux);    
    [ precAux , recAux , f1Aux ] = getMetrics( tp2(count) , fp2(count) , fn2(count) , tn2(count) );
    prec2(count) = precAux; rec2(count) = recAux; f1score2(count) = f1Aux;
    
    % Traffic
    oneGaussianBackground( traffic , pathTrafficInput , fileFormat , pathTrafficResults , alpha);
    
    % Evaluate
    [ tpAux , fpAux , fnAux , tnAux , ~ , ~ ] =  ...
        segmentationEvaluation( pathTrafficGroundtruth , pathTrafficResults , testId , offsetDesynch , VERBOSE );
    tp3(count) = sum(tpAux); fp3(count) = sum(fpAux); fn3(count) = sum(fnAux); tn3(count) = sum(tnAux);    
    [ precAux , recAux , f1Aux ] = getMetrics( tp3(count) , fp3(count) , fn3(count) , tn3(count) );
    prec3(count) = precAux; rec3(count) = recAux; f1score3(count) = f1Aux;
    
    count = count + 1;
end % for
rmpath('./../../evaluation')

% Test 1
figure;
plot(threshold,tp1,'r'); hold on;
plot(threshold,fp1,'g'); plot(threshold,fn1,'b'); plot(threshold,tn1,'y'); 
%Overwrite title and legend
title('Highway'); legend({'TP' , 'FP' , 'FN' , 'TN'}); hold off;

% Test 2
figure;
plot(threshold,tp2,'r'); hold on;
plot(threshold,fp2,'g'); plot(threshold,fn2,'b'); plot(threshold,tn2,'y'); 
%Overwrite title and legend
title('Fall'); legend({'TP' , 'FP' , 'FN' , 'TN'}); hold off;

% Test 3
figure;
plot(threshold,tp3,'r'); hold on;
plot(threshold,fp3,'g'); plot(threshold,fn3,'b'); plot(threshold,tn3,'y'); 
%Overwrite title and legend
title('Traffic'); legend({'TP' , 'FP' , 'FN' , 'TN'}); hold off;

% F1 score
figure;
plot(threshold,f1score1,'r'); hold on;
plot(threshold,f1score2,'g'); plot(threshold,f1score3,'b'); 
%Overwrite title and legend
title('F1-Score vs threshold'); legend({'Highway' , 'Fall' , 'Traffic'}); hold off;

% Precision Recall Test 1
figure;
plot(rec1, prec1);
xlim([0 1]); ylim([0 1]);
xlabel('Recall'); ylabel('Precision');
title(sprintf('Precision Recall (Highway). AUC: %.2f', trapz(prec1)));

% Precision Recall Test 2
figure;
plot(rec2, prec2);
xlim([0 1]); ylim([0 1]);
xlabel('Recall'); ylabel('Precision');
title(sprintf('Precision Recall (Fall).  AUC: %.2f', trapz(prec2)));

% Precision Recall Test 3
figure;
plot(rec3, prec3);
xlim([0 1]); ylim([0 1]);
xlabel('Recall'); ylabel('Precision');
title(sprintf('Precision Recall (Traffic). AUC: %.2f', trapz(prec3)));

%% Recursive Gaussian modeling
%% Task 4
% Implement the recursive function described above and discuss which is the best
% value of ? for the fall sequence.

%% Task 5
% Compute the F1 score (for the fixed value of ? computed in Task 4 and ? in Task
% 3) and compare with the non-recursive version for the three proposed sequences and
% comment the results.

%% Stauffer and Grimson
%% Task 6
% Use the S&G approach and compute the F1 score for the three provided sequences
% using a different number of gaussians (from 3 to 6). Find out the optimal number
% and comment the results obtained.

%% Task 7
% Compare your gaussian modeling of the Background pixels with S&G using the
% F1 score and comment which sequences benefit more from using more gaussians in
% the modeling.

%% Optionals
%% Task 8
% Update the single gaussian functions (recursive and non-recursive) to work with
% color images and use them to obtain the F1 score of the three proposed sequences.

