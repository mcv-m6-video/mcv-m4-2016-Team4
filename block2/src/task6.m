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

%% Plot the results
colorList = [ 'b', 'g', 'm'];
fig = figure('Visible','off', 'PaperUnits', 'centimeters', 'PaperPosition', [0 0 12.5 10.5]); 
hold on;
for i=1:size(f1Scores,2)
   plot(minGaussians:maxGaussians, f1Scores(:,i), colorList(i)); 
end
title('F1Score evolution along number of Gaussians', 'FontWeight', 'Bold');
xlabel('Number of Gaussians'); ylabel('F1-Score');
legend({'Highway', 'Fall', 'Traffic'});
print(fig,[ figuresFolder 'Task6_f1score' ],'-dpng')

% Plot one gaussian VS S&G (F1-Score) group of bars
bestF1ScoresSG = [max(f1Scores(:,1)); max(f1Scores(:,2)); max(f1Scores(:,3))];
fig = figure('Visible','off', 'PaperUnits', 'centimeters', 'PaperPosition', [0 0 12.5 10.5]); 
bar([bestF1Scores1G bestF1ScoresSG]);
title('One Gaussian VS Stauffer & Grimson');
labels = {'Highway', 'Fall', 'Traffic'};
set(gca, 'XTickLabel',labels, 'XTick',1:numel(labels));
ylabel('F1-Score'); 
legend({'One Gaussian', 'Stauffer&Grimson'});
print(fig,[ figuresFolder 'Task6_1GvsSG' ],'-dpng');