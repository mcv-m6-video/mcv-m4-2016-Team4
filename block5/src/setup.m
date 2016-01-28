%%% SETUP ENVIRONMENT %%%

%% General parameters
VERBOSE = true;
addpath('../../src');
addpath('../../src/backgroundSegmentation');
addpath('../../src/evaluation');
addpath('../../src/GTOpticalFlowProcessing');
addpath('homography');
testId = '';
offsetDesynch = 0;
pepnThresh = 3;

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
                 [pathDatasets 'traffic' filesep]; ...
                 [pathDatasets 'speedEstimation' filesep 'croppedLowResolution' filesep]};
seq.nSequences = size(seq.basePaths,1);
% Where the input raw images are stored.
seq.inputFolders = {[seq.basePaths{1} folderInput];...
                   [seq.basePaths{2} folderInput];...
                   [seq.basePaths{3} folderInput];...
                   [seq.basePaths{4} 'v1_40kmh' filesep 'in'];...
                   [seq.basePaths{4} 'v2_40kmh' filesep 'in'];...
                   [seq.basePaths{4} 'v3_50kmh' filesep 'in'];...
                   [seq.basePaths{4} 'v4_50kmh' filesep 'in'];};
% Where the groundtruth of those raw images is stored.
seq.gtFolders = {[seq.basePaths{1} folderGroundtruth];...
                 [seq.basePaths{2} folderGroundtruth];...
                 [seq.basePaths{3} folderGroundtruth];};
% Specific frame indexs that are going to be analyzed.
seq.framesInd = {1050:1350; 1460:1560; 950:1050; 1:168; 1:262; 1:193;1:232};
% Best Rhos and Alphas for every sequence (1G Recursive)
seq.rhos = [0.2, 0.1, 0.2, 0.2, 0.2, 0.2, 0.2];
seq.alphas = [3, 3, 4, 3, 3, 3, 3];

%% Optical flow sequences
flow.basePaths = [ pathDatasets 'data_stereo_flow' filesep 'training' filesep 'image_0' ];
flow.nSequences = size(flow.basePaths,1);
flow.gtFolders = [ pathDatasets 'data_stereo_flow' filesep 'training' filesep 'flow_noc' ];
flow.resultsFolders = [ pathDatasets 'data_stereo_flow' filesep 'results' ];
flow.framesInd = [ 45 , 157 ];
flow.framesOrder = ['_10'; '_11'];

