%%% SETUP ENVIRONMENT %%%

%% General parameters
verbose = false;
addpath('../../src/backgroundSegmentation');
addpath('../../src/evaluation');

%% General configuration of the model (common for each sequence)
colorIm = true;
colorTransform = @rgb2lab;
%  Check if exist a matlab buildin function. If it does not exist, a matlab
%  exchange file is used
if ~exist('colorTransform', 'builtin')
    colorTransform = @(image) (applycform(im2double(image), makecform('srgb2lab')));
end
pathDatasets = ['..' filesep '..' filesep 'datasets' filesep];
folderInput = [ 'input' filesep 'in' ];
folderGroundtruth = [ 'groundtruth' filesep 'gt' ];
folderFigures = ['..' filesep 'figures' filesep];
% Resultng masks of B2 that will be taken as baseline to improve.
folderBaseResults = ['bestResultsB2' filesep];
fileFormat = '.jpg';

%% Specific configuration for every sequence
% Order followed: Highway, Fall, Traffic
seq.basePaths = {[pathDatasets 'highway' filesep];...
                 [pathDatasets 'fall' filesep]; ...
                 [pathDatasets 'traffic' filesep]};
seq.nSequences = size(seq.basePaths,1);
% Where the input raw images are stored.
seq.inputFolders = {[seq.basePaths{1} folderInput];...
                   [seq.basePaths{2} folderInput];...
                   [seq.basePaths{3} folderInput];};
% Where the groundtruth of those raw images is stored.
seq.gtFolders = {[seq.basePaths{1} folderGroundtruth];...
                 [seq.basePaths{2} folderGroundtruth];...
                 [seq.basePaths{3} folderGroundtruth];};
% Specific frame indexs that are going to be analyzed.
seq.framesInd = {1050:1350; 1460:1560; 950:1050};
% Best Rhos and Alphas for every sequence (1G Recursive)
seq.rhos = [0.2, 0.1, 0.2];
seq.alphas = [3, 3, 4];

VERBOSE = false;
testId = '';
offsetDesynch = 0;