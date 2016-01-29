clear, close all;

% Load two sample images
datasetPath = ['..' filesep '..' filesep '..' filesep 'datasets' filesep];
im = imread([datasetPath 'highway' filesep 'input' filesep 'in000001.jpg']);
im2 = imread([datasetPath 'highway' filesep 'input' filesep 'in000030.jpg']);

% Bounding box that contains the object that we want to track
% Format: [xmin, ymin, width, height]
p = [203 2 27 23];

% Initialize tracker for the specific object
sda = SDAFilter(im, p);

% Estimate the position of the object in a given frame
[sda, bb, ~, ~] = sda.estimatePosition(im2);

% See the results
figure(1),imshow(im)
hold on;
rectangle('Position', p, 'EdgeColor','r','LineWidth',2)

figure(2),imshow(im2)
hold on;
rectangle('Position', bb, 'EdgeColor','r','LineWidth',2)