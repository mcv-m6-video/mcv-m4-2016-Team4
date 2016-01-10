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
minAlpha=0; stepAlpha=0.5; maxAlpha=10;
alphaValues = minAlpha:stepAlpha:maxAlpha;
taskId = '1';
if ~exist(['savedResults' filesep 'dataTask1.mat'], 'file')
    connectivity = [4 , 8];
    morphFunction = @applyMorphoTask1;
    evaluateMorpho(seq, fileFormat, alphaValues, connectivity, morphFunction, colorIm, colorTransform, taskId);
else
   disp('Task 1 results found (savedResults/dataTask1.mat). Skipping Task 1...'); 
end

% Generate figures and calculate AUC
results = load(['savedResults' filesep 'dataTask1']);
legendStr = {'Baseline', 'Connectivity=4', 'Connectivity=8'};
[AUCs1B2, AUCs2T1] = calculateAUCs(seq, results, folderFigures, legendStr, taskId);

% Get best connectivity and metrics
[~, bestIndTask1] = max(mean(AUCs2T1));
task1BestResults.prec = results.prec2(:,:,bestIndTask1);
task1BestResults.rec = results.rec2(:,:,bestIndTask1);
task1BestResults.f1score = results.f1score2(:,:,bestIndTask1);
bestConnectivity = bestIndTask1*4;

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
[~ , AUCs2T2] = calculateAUCs(seq, results, folderFigures, legendStr, taskId);

plotAucCurve(seq, pixels, AUCs2T2, folderFigures, taskId);
