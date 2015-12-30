%% Task 1
% One gaussian distribution to model the background pixels.

%% Results Folder
oneGaussianResultsFolder = 'resultsOneGaussian';

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

%% Estimate background
% Highway
oneGaussianBackground( highway , pathHighwayInput , fileFormat , pathHighwayResults , alpha);

% Fall
oneGaussianBackground( fall , pathFallInput , fileFormat , pathFallResults , alpha);

% Traffic
oneGaussianBackground( traffic , pathTrafficInput , fileFormat , pathTrafficResults , alpha);
