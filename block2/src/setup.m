%% Setup enviroment

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

figuresFolder = ['..' filesep 'figures' filesep];
testId = '';

% Parameters to find
minAlpha = 0; stepAlpha = 0.5; maxAlpha = 10;
minRho = 0.1; stepRho = 0.1; maxRho = 1;