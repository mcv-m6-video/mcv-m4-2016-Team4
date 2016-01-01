%% Task 8_2
% Update the single gaussian functions (recursive) to work with
% color images and use them to obtain the F1 score of the three proposed sequences.

%% Results Folder
adaptiveGaussianResultsFolder = 'resultsAdaptiveGaussianColor';

% Highway
pathHighwayResults = [ folderHighway adaptiveGaussianResultsFolder filesep ];
if ~exist(pathHighwayResults , 'dir')
    mkdir( pathHighwayResults );
end % if
pathHighwayResults = [ pathHighwayResults testId ];

% Fall
pathFallResults = [ folderFall adaptiveGaussianResultsFolder filesep ];
if ~exist(pathFallResults , 'dir')
    mkdir( pathFallResults );
end % if
pathFallResults = [ pathFallResults testId ];

% Traffic
pathTrafficResults = [ folderTraffic adaptiveGaussianResultsFolder filesep ];
if ~exist(pathTrafficResults , 'dir')
    mkdir( pathTrafficResults );
end % if
pathTrafficResults = [ pathTrafficResults testId ];

%% Evaluation

colorIm = true;
colorTransform = @rgb2lab;
colorSpace = 'lab'; % Change this variable along colorTransform, so the F1Scores
                    % saved have a filename that identifies the color space used
offsetDesynch = 0; % offsetDesynch = 0 --> Synchronized

%% B) Alpha and Rho
offsetDesynch = 0; % offsetDesynch = 0 --> Synchronized

thresholdRho = minRho:stepRho:maxRho;
szMetricsRho = length(thresholdRho); countRho = 1;

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
        oneGaussianBackgroundAdaptive( highway , pathHighwayInput , fileFormat , pathHighwayResults , alpha, rho , colorIm , colorTransform );

        % Evaluate
        [ tpAux , fpAux , fnAux , tnAux , ~ , ~ ] =  ...
            segmentationEvaluation( pathHighwayGroundtruth , pathHighwayResults , testId , offsetDesynch , VERBOSE );
        tp1(countAlpha, countRho) = sum(tpAux); fp1(countAlpha, countRho) = sum(fpAux); fn1(countAlpha, countRho) = sum(fnAux); tn1(countAlpha, countRho) = sum(tnAux);
        [ precAux , recAux , f1Aux ] = getMetrics( tp1(countAlpha, countRho) , fp1(countAlpha, countRho) , fn1(countAlpha, countRho) , tn1(countAlpha, countRho) );
        prec1(countAlpha, countRho) = precAux; rec1(countAlpha, countRho) = recAux; f1score1(countAlpha, countRho) = f1Aux;

        % Fall
        oneGaussianBackgroundAdaptive( fall , pathFallInput , fileFormat , pathFallResults , alpha, rho , colorIm , colorTransform );

        % Evaluate
        [ tpAux , fpAux , fnAux , tnAux , ~ , ~ ] =  ...
            segmentationEvaluation( pathFallGroundtruth , pathFallResults , testId , offsetDesynch , VERBOSE );
        tp2(countAlpha, countRho) = sum(tpAux); fp2(countAlpha, countRho) = sum(fpAux); fn2(countAlpha, countRho) = sum(fnAux); tn2(countAlpha, countRho) = sum(tnAux);    
        [ precAux , recAux , f1Aux ] = getMetrics( tp2(countAlpha, countRho) , fp2(countAlpha, countRho) , fn2(countAlpha, countRho) , tn2(countAlpha, countRho) );
        prec2(countAlpha, countRho) = precAux; rec2(countAlpha, countRho) = recAux; f1score2(countAlpha, countRho) = f1Aux;

        % Traffic
        oneGaussianBackgroundAdaptive( traffic , pathTrafficInput , fileFormat , pathTrafficResults , alpha, rho , colorIm , colorTransform );

        % Evaluate
        [ tpAux , fpAux , fnAux , tnAux , ~ , ~ ] =  ...
            segmentationEvaluation( pathTrafficGroundtruth , pathTrafficResults , testId , offsetDesynch , VERBOSE );
        tp3(countAlpha, countRho) = sum(tpAux); fp3(countAlpha, countRho) = sum(fpAux); fn3(countAlpha, countRho) = sum(fnAux); tn3(countAlpha, countRho) = sum(tnAux);    
        [ precAux , recAux , f1Aux ] = getMetrics( tp3(countAlpha, countRho) , fp3(countAlpha, countRho) , fn3(countAlpha, countRho) , tn3(countAlpha, countRho) );
        prec3(countAlpha, countRho) = precAux; rec3(countAlpha, countRho) = recAux; f1score3(countAlpha, countRho) = f1Aux;
        
        countRho = countRho + 1;
        k = k + 1;
        
        fprintf('%f%%\n', 100*k/(szMetricsAlpha*szMetricsRho));
    end % for
    countAlpha = countAlpha + 1;
end % for
rmpath('./../../evaluation')

%% Plot the results
% F1 score
[xt, yt] = meshgrid(thresholdRho, thresholdAlpha);
fig = figure('Visible','off'); hold on;
title('F1-Score Highway depending on \alpha and \rho');
xlabel('\rho'), ylabel('\alpha'), zlabel('F1-score');
h = surf(xt, yt, f1score1);  set(h, 'edgecolor', 'none');
print(fig,[ figuresFolder 'Task4_f1score_highway_rho_alpha' ],'-dpng')

fig = figure('Visible','off'); hold on;
title('F1-Score Fall depending on \alpha and \rho');
h = surf(xt, yt, f1score2); set(h, 'edgecolor', 'none'); 
xlabel('\rho'), ylabel('\alpha'), zlabel('F1-score'); 
print(fig,[ figuresFolder 'Task4_f1score_fall_rho_alpha' ],'-dpng')

fig = figure('Visible','off'); hold on;
title('F1-Score Traffic depending on \rho and \alpha');
xlabel('\rho'), ylabel('\alpha'), zlabel('F1-score');
h = surf(xt, yt, f1score3); set(h, 'edgecolor', 'none');
print(fig,[ figuresFolder 'Task4_f1score_traffic_rho_alpha' ],'-dpng')

[f1, ind] = max(f1score1(:)); [alphaB, rhoB] = ind2sub(size(f1score1), ind); 
bestF1Scores1G_R(:,1) = [f1 alphaB rhoB];
fprintf('Best alpha = %f and rho = %f for Test 1 (F1-score = %f)\n', thresholdAlpha(alphaB), thresholdRho(rhoB), f1);
[f1, ind] = max(f1score2(:)); [alphaB, rhoB] = ind2sub(size(f1score2), ind); 
bestF1Scores1G_R(:,2) = [f1 alphaB rhoB];
fprintf('Best alpha = %f and rho = %f for Test 2 (F1-score = %f)\n', thresholdAlpha(alphaB), thresholdRho(rhoB), f1);
[f1, ind] = max(f1score3(:)); [alphaB, rhoB] = ind2sub(size(f1score3), ind); 
bestF1Scores1G_R(:,3) = [f1 alphaB rhoB];
fprintf('Best alpha = %f and rho = %f for Test 3 (F1-score = %f)\n', thresholdAlpha(alphaB), thresholdRho(rhoB), f1);
eval(['bestF1Scores1G_R_' colorSpace '=bestF1Scores1G_R;']);
save([savedResultsFolder 'bestF1Scores1G_R_' colorSpace '.mat'], ['bestF1Scores1G_R_' colorSpace]);
