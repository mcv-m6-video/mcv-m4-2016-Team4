%% Task 1
% One gaussian distribution to model the background pixels.

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
