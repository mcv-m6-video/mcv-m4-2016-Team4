%% Main Script
% M4. Video Analysis Project
% This script computes all the tasks that are done for the block 3 of the
% project.
% 

%% Initialize global parameters
setup;

%% Set up enviroment and get the best model from the block 2
if ~exist([seq.basePaths{1} folderBaseResults ], 'dir')
    allSequencesSegmentation(seq, folderBaseResults, fileFormat, colorIm, colorTransform);
end

%% Task 1
% Generate precision and recall
minAlpha=0; stepAlpha=1; maxAlpha=25;
alphaValues = minAlpha:stepAlpha:maxAlpha;
taskId = '1';
connectivity = [4 , 8];
if ~exist(['savedResults' filesep 'dataTask1.mat'], 'file')
    morphFunction = @applyMorphoTask1;
    evaluateMorpho(seq, fileFormat, alphaValues, connectivity, morphFunction, colorIm, colorTransform, taskId);
else
   disp('Task 1 results found (savedResults/dataTask1.mat). Skipping Task 1...'); 
end

% Generate figures and calculate AUC
results = load(['savedResults' filesep 'dataTask1']);
legendStr = {'Baseline', 'Connectivity=4', 'Connectivity=8'};
[AUCsB2, AUCsT1] = calculateAUCs(seq, results, folderFigures, legendStr, taskId);

% Get best connectivity and metrics
[maxAUCT1, bestIndTask1] = max(mean(AUCsT1));
task1BestResults.prec = results.prec2(:,:,bestIndTask1);
task1BestResults.rec = results.rec2(:,:,bestIndTask1);
task1BestResults.f1score = results.f1score2(:,:,bestIndTask1);
bestConnectivity = connectivity(bestIndTask1);

disp(['Task 1 best connectivity is ' num2str(bestConnectivity)]); 
%% Task 2
taskId = '2';
minPixels = 1; stepPixels = 10; maxPixels = 100;
pixels = minPixels:stepPixels:maxPixels;
if ~exist(['savedResults' filesep 'dataTask2.mat'], 'file')
    morphFunction = @(masks,p) applyMorphoTask2(masks, p, bestConnectivity);
    evaluateMorpho(seq, fileFormat, alphaValues, pixels, morphFunction, colorIm, colorTransform, taskId);
else
   disp('Task 2 results found (savedResults/dataTask2.mat). Skipping Task 2...');  
end

% Generate figures and calculate AUC
% To compare with task one best result we have to change the baseline
results = load(['savedResults' filesep 'dataTask2']);
results.prec1 = task1BestResults.prec;
results.rec1 = task1BestResults.rec;
results.f1score1 = task1BestResults.f1score;

legendStr = {'Baseline Task1'};
% The pixels will change depending on the parameters
for p = pixels
    legendStr{end+1} = sprintf('Pixels=%d',p);
end
[~ , AUCsT2] = calculateAUCs(seq, results, folderFigures, legendStr, taskId);

plotAucCurve(seq, pixels, AUCsT2, folderFigures, taskId);

% Get best number of pixels and metrics
[maxAUCT2, bestIndTask2] = max(mean(AUCsT2));
bestPixels = pixels(bestIndTask2);

disp(['Task 2 best number of pixels is ' num2str(bestPixels)]);

%% Task 3
taskId = '3';
legendStr = {'Baseline'};
if maxAUCT2>maxAUCT1
    results = load(['savedResults' filesep 'dataTask2']);
    legendStr{end+1} = 'Task2';
    bestInd = bestIndTask2;
else
    results = load(['savedResults' filesep 'dataTask1']);
    legendStr{end+1} = 'Task1';
    bestInd = bestIndTask1;
end
results.prec2 = results.prec2(:,:,bestInd);
results.rec2 = results.rec2(:,:,bestInd);
results.f1score2 = results.f1score2(:,:,bestInd);

calculateAUCs(seq, results, folderFigures, legendStr, taskId);

disp(['The best result is obtained with ' num2str(legendStr{2})]);