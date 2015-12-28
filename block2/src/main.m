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
thresholdAlpha = minAlpha:stepAlpha:maxAlpha;
szMetrics = length(thresholdAlpha); count = 1;

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
plot(thresholdAlpha,tp1,'r'); hold on;
plot(thresholdAlpha,fp1,'g'); plot(thresholdAlpha,fn1,'b'); plot(thresholdAlpha,tn1,'y'); 
%Overwrite title and legend
title('Highway'); legend({'TP' , 'FP' , 'FN' , 'TN'}); hold off;

% Test 2
figure;
plot(thresholdAlpha,tp2,'r'); hold on;
plot(thresholdAlpha,fp2,'g'); plot(thresholdAlpha,fn2,'b'); plot(thresholdAlpha,tn2,'y'); 
%Overwrite title and legend
title('Fall'); legend({'TP' , 'FP' , 'FN' , 'TN'}); hold off;

% Test 3
figure;
plot(thresholdAlpha,tp3,'r'); hold on;
plot(thresholdAlpha,fp3,'g'); plot(thresholdAlpha,fn3,'b'); plot(thresholdAlpha,tn3,'y'); 
%Overwrite title and legend
title('Traffic'); legend({'TP' , 'FP' , 'FN' , 'TN'}); hold off;

% F1 score
figure;
plot(thresholdAlpha,f1score1,'r'); hold on;
plot(thresholdAlpha,f1score2,'g'); plot(thresholdAlpha,f1score3,'b'); 
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

% A) NON-RECURSIVE
[~, ind] = max(f1score1);
alpha1 = thresholdAlpha(ind);

[~, ind] = max(f1score2);
alpha2 = thresholdAlpha(ind);

[~, ind] = max(f1score3);
alpha3 = thresholdAlpha(ind);

offsetDesynch = 0; % offsetDesynch = 0 --> Synchronized

minRho = 0.1; stepRho = 0.1; maxRho = 1;
thresholdRho = minRho:stepRho:maxRho;
szMetricsRho = length(thresholdRho); countRho = 1;

% Setup variables
prec1 = zeros(szMetricsRho,1); rec1 = zeros(szMetricsRho,1); f1score1 = zeros(szMetricsRho,1);
tp1 = zeros(szMetricsRho,1); tn1 = zeros(szMetricsRho,1); fp1 = zeros(szMetricsRho,1); fn1 = zeros(szMetricsRho,1);

prec2 = zeros(szMetricsRho,1); rec2 = zeros(szMetricsRho,1); f1score2 = zeros(szMetricsRho,1);
tp2 = zeros(szMetricsRho,1); tn2 = zeros(szMetricsRho,1); fp2 = zeros(szMetricsRho,1); fn2 = zeros(szMetricsRho,1);

prec3 = zeros(szMetricsRho,1); rec3 = zeros(szMetricsRho,1); f1score3 = zeros(szMetricsRho,1);
tp3 = zeros(szMetricsRho,1); tn3 = zeros(szMetricsRho,1); fp3 = zeros(szMetricsRho,1); fn3 = zeros(szMetricsRho,1);

addpath('./../../evaluation')
for rho = minRho:stepRho:maxRho
    % Highway
    oneGaussianBackgroundAdaptive( highway , pathHighwayInput , fileFormat , pathHighwayResults , alpha1, rho);
    
    % Evaluate
    [ tpAux , fpAux , fnAux , tnAux , ~ , ~ ] =  ...
        segmentationEvaluation( pathHighwayGroundtruth , pathHighwayResults , testId , offsetDesynch , VERBOSE );
    tp1(countRho) = sum(tpAux); fp1(countRho) = sum(fpAux); fn1(countRho) = sum(fnAux); tn1(countRho) = sum(tnAux);
    [ precAux , recAux , f1Aux ] = getMetrics( tp1(countRho) , fp1(countRho) , fn1(countRho) , tn1(countRho) );
    prec1(countRho) = precAux; rec1(countRho) = recAux; f1score1(countRho) = f1Aux;
    
    % Fall
    oneGaussianBackgroundAdaptive( fall , pathFallInput , fileFormat , pathFallResults , alpha2, rho);

    % Evaluate
    [ tpAux , fpAux , fnAux , tnAux , ~ , ~ ] =  ...
        segmentationEvaluation( pathFallGroundtruth , pathFallResults , testId , offsetDesynch , VERBOSE );
    tp2(countRho) = sum(tpAux); fp2(countRho) = sum(fpAux); fn2(countRho) = sum(fnAux); tn2(countRho) = sum(tnAux);    
    [ precAux , recAux , f1Aux ] = getMetrics( tp2(countRho) , fp2(countRho) , fn2(countRho) , tn2(countRho) );
    prec2(countRho) = precAux; rec2(countRho) = recAux; f1score2(countRho) = f1Aux;
    
    % Traffic
    oneGaussianBackgroundAdaptive( traffic , pathTrafficInput , fileFormat , pathTrafficResults , alpha3, rho);
    
    % Evaluate
    [ tpAux , fpAux , fnAux , tnAux , ~ , ~ ] =  ...
        segmentationEvaluation( pathTrafficGroundtruth , pathTrafficResults , testId , offsetDesynch , VERBOSE );
    tp3(countRho) = sum(tpAux); fp3(countRho) = sum(fpAux); fn3(countRho) = sum(fnAux); tn3(countRho) = sum(tnAux);    
    [ precAux , recAux , f1Aux ] = getMetrics( tp3(countRho) , fp3(countRho) , fn3(countRho) , tn3(countRho) );
    prec3(countRho) = precAux; rec3(countRho) = recAux; f1score3(countRho) = f1Aux;
    
    countRho = countRho + 1;
    
    disp(sprintf('%f%%', 100*(countRho-1)/szMetricsRho))
end % for
rmpath('./../../evaluation')

% F1 score
figure;
plot(thresholdRho,f1score1,'r'); hold on;
plot(thresholdRho,f1score2,'g'); plot(thresholdRho,f1score3,'b'); 
%Overwrite title and legend
title('F1-Score vs threshold (RHO)'); legend({'Highway' , 'Fall' , 'Traffic'}); hold off;

% B) Alpha and Rho
offsetDesynch = 0; % offsetDesynch = 0 --> Synchronized

minRho = 0.1; stepRho = 0.1; maxRho = 1;
thresholdRho = minRho:stepRho:maxRho;
szMetricsRho = length(thresholdRho); countRho = 1;

minAlpha = 0; stepAlpha = 1; maxAlpha = 10;
thresholdAlpha = minAlpha:stepAlpha:maxAlpha;
szMetricsAlpha = length(thresholdAlpha); countAlpha = 1;

% Setup variables
prec1 = zeros(szMetricsAlpha, szMetricsRho); rec1 = zeros(szMetricsAlpha, szMetricsRho); f1score1 = zeros(szMetricsAlpha, szMetricsRho);
tp1 = zeros(szMetricsAlpha, szMetricsRho); tn1 = zeros(szMetricsAlpha, szMetricsRho); fp1 = zeros(szMetricsAlpha, szMetricsRho); fn1 = zeros(szMetricsAlpha, szMetricsRho);

prec2 = zeros(szMetricsAlpha, szMetricsRho); rec2 = zeros(szMetricsAlpha, szMetricsRho); f1score2 = zeros(szMetricsAlpha, szMetricsRho);
tp2 = zeros(szMetricsAlpha, szMetricsRho); tn2 = zeros(szMetricsAlpha, szMetricsRho); fp2 = zeros(szMetricsAlpha, szMetricsRho); fn2 = zeros(szMetricsAlpha, szMetricsRho);

prec3 = zeros(szMetricsAlpha, szMetricsRho); rec3 = zeros(szMetricsAlpha, szMetricsRho); f1score3 = zeros(szMetricsAlpha, szMetricsRho);
tp3 = zeros(szMetricsAlpha, szMetricsRho); tn3 = zeros(szMetricsAlpha, szMetricsRho); fp3 = zeros(szMetricsAlpha, szMetricsRho); fn3 = zeros(szMetricsAlpha, szMetricsRho);

addpath('./../../evaluation')
k=0;
for alpha = minAlpha:stepAlpha:maxAlpha
    countRho = 1;
    for rho = minRho:stepRho:maxRho
        % Highway
        oneGaussianBackgroundAdaptive( highway , pathHighwayInput , fileFormat , pathHighwayResults , alpha, rho);

        % Evaluate
        [ tpAux , fpAux , fnAux , tnAux , ~ , ~ ] =  ...
            segmentationEvaluation( pathHighwayGroundtruth , pathHighwayResults , testId , offsetDesynch , VERBOSE );
        tp1(countAlpha, countRho) = sum(tpAux); fp1(countAlpha, countRho) = sum(fpAux); fn1(countAlpha, countRho) = sum(fnAux); tn1(countAlpha, countRho) = sum(tnAux);
        [ precAux , recAux , f1Aux ] = getMetrics( tp1(countAlpha, countRho) , fp1(countAlpha, countRho) , fn1(countAlpha, countRho) , tn1(countAlpha, countRho) );
        prec1(countAlpha, countRho) = precAux; rec1(countAlpha, countRho) = recAux; f1score1(countAlpha, countRho) = f1Aux;

        % Fall
        oneGaussianBackgroundAdaptive( fall , pathFallInput , fileFormat , pathFallResults , alpha, rho);

        % Evaluate
        [ tpAux , fpAux , fnAux , tnAux , ~ , ~ ] =  ...
            segmentationEvaluation( pathFallGroundtruth , pathFallResults , testId , offsetDesynch , VERBOSE );
        tp2(countAlpha, countRho) = sum(tpAux); fp2(countAlpha, countRho) = sum(fpAux); fn2(countAlpha, countRho) = sum(fnAux); tn2(countAlpha, countRho) = sum(tnAux);    
        [ precAux , recAux , f1Aux ] = getMetrics( tp2(countAlpha, countRho) , fp2(countAlpha, countRho) , fn2(countAlpha, countRho) , tn2(countAlpha, countRho) );
        prec2(countAlpha, countRho) = precAux; rec2(countAlpha, countRho) = recAux; f1score2(countAlpha, countRho) = f1Aux;

        % Traffic
        oneGaussianBackgroundAdaptive( traffic , pathTrafficInput , fileFormat , pathTrafficResults , alpha, rho);

        % Evaluate
        [ tpAux , fpAux , fnAux , tnAux , ~ , ~ ] =  ...
            segmentationEvaluation( pathTrafficGroundtruth , pathTrafficResults , testId , offsetDesynch , VERBOSE );
        tp3(countAlpha, countRho) = sum(tpAux); fp3(countAlpha, countRho) = sum(fpAux); fn3(countAlpha, countRho) = sum(fnAux); tn3(countAlpha, countRho) = sum(tnAux);    
        [ precAux , recAux , f1Aux ] = getMetrics( tp3(countAlpha, countRho) , fp3(countAlpha, countRho) , fn3(countAlpha, countRho) , tn3(countAlpha, countRho) );
        prec3(countAlpha, countRho) = precAux; rec3(countAlpha, countRho) = recAux; f1score3(countAlpha, countRho) = f1Aux;
        
        countRho = countRho + 1;
        k = k + 1;
        
        disp(sprintf('%f%%', 100*k/(szMetricsAlpha*szMetricsRho)))
    end % for
    countAlpha = countAlpha + 1;
end % for
rmpath('./../../evaluation')

% F1 score
[xt, yt] = meshgrid(thresholdRho, thresholdAlpha);
figure, h = surf(xt, yt, f1score1); xlabel('Rho'), ylabel('Alpha'), zlabel('F1-score'), set(h, 'edgecolor', 'none'); title('F1-Score Test 1');
figure, h = surf(xt, yt, f1score2); xlabel('Rho'), ylabel('Alpha'), zlabel('F1-score'), set(h, 'edgecolor', 'none'); title('F1-Score Test 2');
figure, h = surf(xt, yt, f1score3); xlabel('Rho'), ylabel('Alpha'), zlabel('F1-score'), set(h, 'edgecolor', 'none'); title('F1-Score Test 3');

[f1, ind] = max(f1score1(:)); [alphaB, rhoB] = ind2sub(size(f1score1), ind); disp(sprintf('Best alpha = %f and rho = %f for Test 1 (F1-score = %f)', thresholdAlpha(alphaB), thresholdRho(rhoB), f1))
[f1, ind] = max(f1score2(:)); [alphaB, rhoB] = ind2sub(size(f1score2), ind); disp(sprintf('Best alpha = %f and rho = %f for Test 2 (F1-score = %f)', thresholdAlpha(alphaB), thresholdRho(rhoB), f1))
[f1, ind] = max(f1score3(:)); [alphaB, rhoB] = ind2sub(size(f1score3), ind); disp(sprintf('Best alpha = %f and rho = %f for Test 3 (F1-score = %f)', thresholdAlpha(alphaB), thresholdRho(rhoB), f1))



%% Task 5
% Compute the F1 score (for the fixed value of ? computed in Task 4 and ? in Task
% 3) and compare with the non-recursive version for the three proposed sequences and
% comment the results.

%% Stauffer and Grimson
%% Task 6
% Use the S&G approach and compute the F1 score for the three provided sequences
% using a different number of gaussians (from 3 to 6). Find out the optimal number
% and comment the results obtained.
SGfolder = 'resultsSG';
pathHighwayResults = [ folderHighway SGfolder filesep ];
pathFallResults = [ folderFall SGfolder filesep ];
pathTrafficResults = [ folderTraffic SGfolder filesep ];
minGaussians = 3;
maxGaussians = 6;
f1Scores = zeros(length(minGaussians:maxGaussians), 3);
count = 1;
for nGaussians = minGaussians:maxGaussians
    
    % Highway
    staufferGrimsonMultipleGaussian( highway , pathHighwayInput , fileFormat , pathHighwayResults , nGaussians);
    
    % Evaluate
    [ tp , fp , fn , tn , ~ , ~ ] =  ...
        segmentationEvaluation( pathHighwayGroundtruth , pathHighwayResults , testId , 0 , VERBOSE );
    [ ~ , ~ , f1ScoreAux ] = getMetrics( tp , fp , fn , tn );
    f1Scores(count,1) = mean(f1ScoreAux);
    
    % Fall
    staufferGrimsonMultipleGaussian( fall , pathFallInput , fileFormat , pathFallResults , nGaussians);
    
    % Evaluate
    [ tp , fp , fn , tn , ~ , ~ ] =  ...
        segmentationEvaluation( pathFallGroundtruth , pathFallResults , testId , 0 , VERBOSE );
    
    [ ~ , ~ , f1ScoreAux ] = getMetrics( tp , fp , fn , tn );
    f1Scores(count,2) = mean(f1ScoreAux);
    
    % Traffic
    staufferGrimsonMultipleGaussian( traffic , pathTrafficInput , fileFormat , pathTrafficResults , nGaussians);
    
    % Evaluate
    [ tp , fp , fn , tn , ~ , ~ ] =  ...
        segmentationEvaluation( pathTrafficGroundtruth , pathTrafficResults , testId , 0 , VERBOSE );
    
    [ ~ , ~ , f1ScoreAux ] = getMetrics( tp , fp , fn , tn );
    f1Scores(count,3) = mean(f1ScoreAux);
    count = count + 1;
end % for

%Plot the results
colorList = [ 'b', 'g', 'm'];
figure; hold on;
for i=1:size(f1Scores,2)
   plot(minGaussians:maxGaussians, f1Scores(:,i), colorList(i)); 
end
title('F1Score evolution along number of Gaussians', 'FontWeight', 'Bold');
xlabel('Number of Gaussians'); ylabel('F1Score');
legend({'Highway', 'Fall', 'Traffic'});


%% Task 7
% Compare your gaussian modeling of the Background pixels with S&G using the
% F1 score and comment which sequences benefit more from using more gaussians in
% the modeling.

%% Optionals
%% Task 8
% Update the single gaussian functions (recursive and non-recursive) to work with
% color images and use them to obtain the F1 score of the three proposed sequences.

