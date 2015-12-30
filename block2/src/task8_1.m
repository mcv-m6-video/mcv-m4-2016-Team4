%% Task 8_1
% Update the single gaussian functions (non-recursive) to work with
% color images and use them to obtain the F1 score of the three proposed sequences.

%% Results Folder
oneGaussianResultsFolder = 'resultsOneGaussianColor';

% Highway
pathHighwayResults = [ folderHighway oneGaussianResultsFolder filesep ];
if ~exist(pathHighwayResults , 'dir')
    mkdir( pathHighwayResults );
end % if
pathHighwayResults = [ pathHighwayResults testId ];

% Fall
pathFallResults = [ folderFall oneGaussianResultsFolder filesep ];
if ~exist(pathFallResults , 'dir')
    mkdir( pathFallResults );
end % if
pathFallResults = [ pathFallResults testId ];

% Traffic
pathTrafficResults = [ folderTraffic oneGaussianResultsFolder filesep ];
if ~exist(pathTrafficResults , 'dir')
    mkdir( pathTrafficResults );
end % if
pathTrafficResults = [ pathTrafficResults testId ];

%% Evaluation
colorIm = true;
colorTransform = @rgb2yuv;
 
offsetDesynch = 0; % offsetDesynch = 0 --> Synchronized

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
    oneGaussianBackground( highway , pathHighwayInput , fileFormat , pathHighwayResults , alpha , colorIm , colorTransform );
    
    % Evaluate
    [ tpAux , fpAux , fnAux , tnAux , ~ , ~ ] =  ...
        segmentationEvaluation( pathHighwayGroundtruth , pathHighwayResults , testId , offsetDesynch , VERBOSE );
    tp1(count) = sum(tpAux); fp1(count) = sum(fpAux); fn1(count) = sum(fnAux); tn1(count) = sum(tnAux);
    [ precAux , recAux , f1Aux ] = getMetrics( tp1(count) , fp1(count) , fn1(count) , tn1(count) );
    prec1(count) = precAux; rec1(count) = recAux; f1score1(count) = f1Aux;
    
    % Fall
    oneGaussianBackground( fall , pathFallInput , fileFormat , pathFallResults , alpha , colorIm , colorTransform );

    % Evaluate
    [ tpAux , fpAux , fnAux , tnAux , ~ , ~ ] =  ...
        segmentationEvaluation( pathFallGroundtruth , pathFallResults , testId , offsetDesynch , VERBOSE );
    tp2(count) = sum(tpAux); fp2(count) = sum(fpAux); fn2(count) = sum(fnAux); tn2(count) = sum(tnAux);    
    [ precAux , recAux , f1Aux ] = getMetrics( tp2(count) , fp2(count) , fn2(count) , tn2(count) );
    prec2(count) = precAux; rec2(count) = recAux; f1score2(count) = f1Aux;
    
    % Traffic
    oneGaussianBackground( traffic , pathTrafficInput , fileFormat , pathTrafficResults , alpha , colorIm , colorTransform );
    
    % Evaluate
    [ tpAux , fpAux , fnAux , tnAux , ~ , ~ ] =  ...
        segmentationEvaluation( pathTrafficGroundtruth , pathTrafficResults , testId , offsetDesynch , VERBOSE );
    tp3(count) = sum(tpAux); fp3(count) = sum(fpAux); fn3(count) = sum(fnAux); tn3(count) = sum(tnAux);    
    [ precAux , recAux , f1Aux ] = getMetrics( tp3(count) , fp3(count) , fn3(count) , tn3(count) );
    prec3(count) = precAux; rec3(count) = recAux; f1score3(count) = f1Aux;
    
    count = count + 1;
end % for
rmpath('./../../evaluation')

%% Plot metrics

% Test 1
fig = figure('Visible','off','PaperUnits','centimeters','PaperPosition',[0 0 12.5 10.5]);
plot(thresholdAlpha,tp1,'r'); hold on;
plot(thresholdAlpha,fp1,'g'); plot(thresholdAlpha,fn1,'b'); plot(thresholdAlpha,tn1,'m'); 
%Overwrite title and legend
title('Highway: TP FN TN FP for one gaussian with color'); xlabel('Threshold (\alpha)'); ylabel('Number of pixels');
legend({'TP' , 'FP' , 'FN' , 'TN'}); hold off;
print(fig,[ figuresFolder 'Task8_1_highway' ],'-dpng')

% Test 2
fig = figure('Visible','off','PaperUnits','centimeters','PaperPosition',[0 0 12.5 10.5]);
plot(thresholdAlpha,tp2,'r'); hold on;
plot(thresholdAlpha,fp2,'g'); plot(thresholdAlpha,fn2,'b'); plot(thresholdAlpha,tn2,'m'); 
%Overwrite title and legend
title('Fall: TP FN TN FP for one gaussian with color');  xlabel('Threshold (\alpha)'); ylabel('Number of pixels');
legend({'TP' , 'FP' , 'FN' , 'TN'}); hold off;
print(fig,[ figuresFolder 'Task8_1_fall' ],'-dpng')

% Test 3
fig = figure('Visible','off','PaperUnits','centimeters','PaperPosition',[0 0 12.5 10.5]);
plot(thresholdAlpha,tp3,'r'); hold on;
plot(thresholdAlpha,fp3,'g'); plot(thresholdAlpha,fn3,'b'); plot(thresholdAlpha,tn3,'m'); 
%Overwrite title and legend
title('Traffic: TP FN TN FP for one gaussian with color');  xlabel('Threshold (\alpha)'); ylabel('Number of pixels');
legend({'TP' , 'FP' , 'FN' , 'TN'}); hold off;
print(fig,[ figuresFolder 'Task8_1_traffic' ],'-dpng')

% F1 score
fig = figure('Visible','off','PaperUnits','centimeters','PaperPosition',[0 0 12.5 10.5]);
plot(thresholdAlpha,f1score1,'r'); hold on;
plot(thresholdAlpha,f1score2,'g'); plot(thresholdAlpha,f1score3,'b'); 
%Overwrite title and legend
title('F1-Score depending on threshold (\alpha) with color'); 
xlabel('Threshold (\alpha)'); ylabel('F1-Score');
legend({'Highway' , 'Fall' , 'Traffic'}); hold off;
print(fig,[ figuresFolder 'Task8_1_f1score' ],'-dpng')

% Store the bests F1Scores (they'll be needed for Task 6)
bestF1Scores1G = [max(f1score1); max(f1score2); max(f1score3)];

% Precision Recall Test 1
fig = figure('Visible','off','PaperUnits','centimeters','PaperPosition',[0 0 12.5 10.5]);
hold on;
plot(rec1, prec1, 'r'); % Highway
plot(rec2, prec2, 'g'); % Fall
plot(rec3, prec3, 'b'); % Traffic
xlim([0 1]); ylim([0 1]);
xlabel('Recall'); ylabel('Precision');
title(sprintf('Precision Recall curve with color.'));
legendStr{1} = sprintf('Highway (AUC: %.2f)', trapz(prec1));
legendStr{2} = sprintf('Fall (AUC: %.2f)', trapz(prec2));
legendStr{3} = sprintf('Traffic (AUC: %.2f)', trapz(prec3));
legend(legendStr); hold off;
print(fig,[ figuresFolder 'Task8_1_precision_recall' ],'-dpng')