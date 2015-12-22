%% Main Script
% M4. Video Analysis Project
% This script computes all the tasks that are done for the block 2 of the
% project.
% 
%% Set up enviroment

clear all; clc; close all;

pathDatasets = ['..' filesep '..' filesep 'datasets' filesep 'highway' filesep];
pathInput = [ pathDatasets 'input' filesep 'in' ];
pathGroundtruth = [ pathDatasets 'groundtryth' filesep ];
fileFormat = '.jpg';

highway = 1050:1350;
fall = 1460:1560;
traffic = 950:1050;

testId1 = 'test_1_';
testId2 = 'test_2_';
testId3 = 'test_3_';

VERBOSE = false;

%% Non-recursive Gaussian modeling
%% Task 1
% One gaussian distribution to model the background pixels.

% Threshold
alpha = 5;

testId1 = 'test_1_';
pathResults = [ pathDatasets 'results' filesep testId1 ];
oneGaussianBackground( highway , pathInput , fileFormat , pathResults , alpha);

testId2 = 'test_2_';
pathResults = [ pathDatasets 'results' filesep testId2 ];
oneGaussianBackground( fall , pathInput , fileFormat , pathResults , alpha);

testId3 = 'test_3_';
pathResults = [ pathDatasets 'results' filesep testId3 ];
oneGaussianBackground( traffic , pathInput , fileFormat , pathResults , alpha);

%% Task 2 & 3
% Draw the curves F1 score, True Positive, True Negative, False Positive, False 
% Negative vs. threshold ? for the three proposed sequences (remember to convert 
% them to gray-scale).
% Draw the curve Precision vs. Recall depending of threshold ? for the three
% proposed sequences and comment the results.

pathHighwayGroundtruth = [ pathDatasets 'groundtruth' filesep 'gt' ];
pathHighwayResults = [ pathDatasets 'results' filesep ];
offsetDesynch = 0; % offsetDesynch = 0 --> Synchronized

minAlpha = 0; stepAlpha = 1; maxAlpha = 10;
szMetrics = floor((maxAlpha-minAlpha)/stepAlpha); count = 1;
threshold = minAlpha:stepAlpha:maxAlpha;

% Setup variables
prec1 = zeros(szMetrics,1); rec1 = zeros(szMetrics,1); f1score1 = zeros(szMetrics,1);
tp1 = zeros(szMetrics,1); tn1 = zeros(szMetrics,1); fp1 = zeros(szMetrics,1); fn1 = zeros(szMetrics,1);

prec2 = zeros(szMetrics,1); rec2 = zeros(szMetrics,1); f1score2 = zeros(szMetrics,1);
tp2 = zeros(szMetrics,1); tn2 = zeros(szMetrics,1); fp2 = zeros(szMetrics,1); fn2 = zeros(szMetrics,1);

prec3 = zeros(szMetrics,1); rec3 = zeros(szMetrics,1); f1score3 = zeros(szMetrics,1);
tp3 = zeros(szMetrics,1); tn3 = zeros(szMetrics,1); fp3 = zeros(szMetrics,1); fn3 = zeros(szMetrics,1);

addpath('./../../evaluation')
for alpha = minAlpha:stepAlpha:maxAlpha

    
    pathResults = [ pathDatasets 'results' filesep testId1 ];
    oneGaussianBackground( highway , pathInput , fileFormat , pathResults , alpha);

    pathResults = [ pathDatasets 'results' filesep testId2 ];
    oneGaussianBackground( fall , pathInput , fileFormat , pathResults , alpha);

    pathResults = [ pathDatasets 'results' filesep testId3 ];
    oneGaussianBackground( traffic , pathInput , fileFormat , pathResults , alpha);
    
    % Test 1
    [ tpAux , fpAux , fnAux , tnAux , ~ , ~ ] =  ...
        segmentationEvaluation( pathHighwayGroundtruth , pathHighwayResults , testId1 , offsetDesynch , VERBOSE );
    tp1(count) = sum(tpAux); fp1(count) = sum(fpAux); fn1(count) = sum(fnAux); tn1(count) = sum(tnAux);
    [ precAux , recAux , f1Aux ] = getMetrics( tp1(count) , fp1(count) , fn1(count) , tn1(count) );
    prec1(count) = precAux; rec1(count) = recAux; f1score1(count) = f1Aux;
    
    % Test 2
    [ tpAux , fpAux , fnAux , tnAux , ~ , ~ ] =  ...
        segmentationEvaluation( pathHighwayGroundtruth , pathHighwayResults , testId2 , offsetDesynch , VERBOSE );
    tp2(count) = sum(tpAux); fp2(count) = sum(fpAux); fn2(count) = sum(fnAux); tn2(count) = sum(tnAux);    
    [ precAux , recAux , f1Aux ] = getMetrics( tp2(count) , fp2(count) , fn2(count) , tn2(count) );
    prec2(count) = precAux; rec2(count) = recAux; f1score2(count) = f1Aux;

    % Test 3
    [ tpAux , fpAux , fnAux , tnAux , ~ , ~ ] =  ...
        segmentationEvaluation( pathHighwayGroundtruth , pathHighwayResults , testId3 , offsetDesynch , VERBOSE );
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
title('Test 1'); legend({'TP' , 'FP' , 'FN' , 'TN'}); hold off;

% Test 2
figure;
plot(threshold,tp2,'r'); hold on;
plot(threshold,fp2,'g'); plot(threshold,fn2,'b'); plot(threshold,tn2,'y'); 
%Overwrite title and legend
title('Test 2'); legend({'TP' , 'FP' , 'FN' , 'TN'}); hold off;

% Test 3
figure;
plot(threshold,tp3,'r'); hold on;
plot(threshold,fp3,'g'); plot(threshold,fn3,'b'); plot(threshold,tn3,'y'); 
%Overwrite title and legend
title('Test 3'); legend({'TP' , 'FP' , 'FN' , 'TN'}); hold off;

% F1 score
figure;
plot(threshold,f1score1,'r'); hold on;
plot(threshold,f1score2,'g'); plot(threshold,f1score3,'b'); 
%Overwrite title and legend
title('F1-Score vs threshold'); legend({'test1' , 'test2' , 'test3'}); hold off;

% Precision Recall Test 1
figure;
plot(rec1, prec1);
title('Precision Recall Test1');

% Precision Recall Test 2
figure;
plot(rec2, prec2);
title('Precision Recall Test1');

% Precision Recall Test 3
figure;
plot(rec3, prec3);
title('Precision Recall Test1');

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

