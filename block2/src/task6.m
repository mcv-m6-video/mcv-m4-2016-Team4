%% Task 6
% Use the S&G approach and compute the F1 score for the three provided sequences
% using a different number of gaussians (from 3 to 6). Find out the optimal number
% and comment the results obtained.

SGfolder = 'resultsSG';
pathHighwayResults = [ folderHighway SGfolder filesep ];
if ~exist(pathHighwayResults , 'dir')
    mkdir( pathHighwayResults );
end % if
pathFallResults = [ folderFall SGfolder filesep ];
if ~exist(pathFallResults , 'dir')
    mkdir( pathFallResults );
end % if
pathTrafficResults = [ folderTraffic SGfolder filesep ];
if ~exist(pathTrafficResults , 'dir')
    mkdir( pathTrafficResults );
end % if
minGaussians = 3;
maxGaussians = 6;
f1Scores = zeros(length(minGaussians:maxGaussians), 3);
count = 1;
addpath('../../evaluation');
nGaussians = 3;
minTh = 3; stepTh = 1; maxTh = 6;
thList = minTh:stepTh:maxTh;
for th = thList
    
    % Highway
    bkgRatio = 0.5;
    lrRate = 0.008;
    staufferGrimsonMultipleGaussian( highway , pathHighwayInput , fileFormat , pathHighwayResults , th , bkgRatio, lrRate);
    
    % Evaluate
    [ tp , fp , fn , tn , ~ , ~ ] =  ...
        segmentationEvaluation( pathHighwayGroundtruth , pathHighwayResults , testId , 0 , VERBOSE );
    [ ~ , ~ , f1ScoreAux ] = getMetrics( sum(tp) , sum(fp) , sum(fn) , sum(tn) );
    f1Scores(count,1) = f1ScoreAux;
    
    % Fall
    bkgRatio = 0.8;
    lrRate = 0.012;
    staufferGrimsonMultipleGaussian( fall , pathFallInput , fileFormat , pathFallResults , th , bkgRatio, lrRate);
    
    % Evaluate
    [ tp , fp , fn , tn , ~ , ~ ] =  ...
        segmentationEvaluation( pathFallGroundtruth , pathFallResults , testId , 0 , VERBOSE );
    
    [ ~ , ~ , f1ScoreAux ] = getMetrics( sum(tp) , sum(fp) , sum(fn) , sum(tn) );
    f1Scores(count,2) = f1ScoreAux;
    
    % Traffic
    bkgRatio = 0.7;
    lrRate = 0.016;
    staufferGrimsonMultipleGaussian( traffic , pathTrafficInput , fileFormat , pathTrafficResults , th , bkgRatio, lrRate);
    
    % Evaluate
    [ tp , fp , fn , tn , ~ , ~ ] =  ...
        segmentationEvaluation( pathTrafficGroundtruth , pathTrafficResults , testId , 0 , VERBOSE );
    
    [ ~ , ~ , f1ScoreAux ] = getMetrics( sum(tp) , sum(fp) , sum(fn) , sum(tn) );
    f1Scores(count,3) = f1ScoreAux;
    count = count + 1;
end % for

%% Plot the results
colorList = [ 'b', 'g', 'm'];
fig = figure('Visible','off', 'PaperUnits', 'centimeters', 'PaperPosition', [0 0 12.5 10.5]); 
hold on;
for i=1:size(f1Scores,2)
   plot(minTh:stepTh:maxTh, f1Scores(:,i), colorList(i)); 
end
title('F1Score evolution along number of Gaussians', 'FontWeight', 'Bold');
xlabel('Number of Gaussians'); ylabel('F1-Score');
legend({'Highway', 'Fall', 'Traffic'});
print(fig,[ figuresFolder 'Task6_f1score' ],'-dpng')

[f1, ind] = max(f1Scores(:,1)); bestTh = thList(ind); 
fprintf('Best Number of Gaussians = %f for Highway (F1-score = %f)\n', bestTh, f1);
[f1, ind] = max(f1Scores(:,2)); bestTh = thList(ind); 
fprintf('Best Number of Gaussians = %f for Fall (F1-score = %f)\n', bestTh, f1);
[f1, ind] = max(f1Scores(:,3)); bestTh = thList(ind); 
fprintf('Best Number of Gaussians = %f for Traffic (F1-score = %f)\n', bestTh, f1);

% Plot one gaussian VS S&G (F1-Score) group of bars
bestF1ScoresSG = [max(f1Scores(:,1)); max(f1Scores(:,2)); max(f1Scores(:,3))];
save([savedResultsFolder 'bestF1ScoresSG.mat'], 'bestF1ScoresSG' ); %Save in case it's needed later
load([savedResultsFolder 'bestF1Scores1G_NR_grey.mat']);
load([savedResultsFolder 'bestF1Scores1G_R_grey.mat']);
fig = figure('Visible','off', 'PaperUnits', 'centimeters', 'PaperPosition', [0 0 12.5 10.5]); 
bar([bestF1Scores1G_NR_grey(:,1) bestF1Scores1G_R_grey(1,:)' bestF1ScoresSG ]);
title('1G Non Recursive VS 1G Recursive VS Stauffer & Grimson');
labels = {'Highway', 'Fall', 'Traffic'};
set(gca, 'XTickLabel',labels, 'XTick',1:numel(labels));
ylabel('F1-Score'); 
legend({'One Gaussian (Non Recursive)', 'One Gaussian (Recursive)', 'Stauffer&Grimson'});
print(fig,[ figuresFolder 'Task6_1GvsSG' ],'-dpng');