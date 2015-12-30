%% Main Script
% M4. Video Analysis Project
% This script computes all the tasks that are done for the block 2 of the
% project.
% 
%% Set up enviroment

setup;

%% Non-recursive Gaussian modeling
%% Task 1
% One gaussian distribution to model the background pixels.

% Threshold
alpha = 2.5;

task1;

%% Task 2 & 3
% Draw the curves F1 score, True Positive, True Negative, False Positive, False 
% Negative vs. threshold ? for the three proposed sequences (remember to convert 
% them to gray-scale).
% Draw the curve Precision vs. Recall depending of threshold ? for the three
% proposed sequences and comment the results.

task2_3;


%% Recursive Gaussian modeling
%% Task 4
% Implement the recursive function described above and discuss which is the best
% value of ? for the fall sequence.

task4;

%% Task 5
% Compute the F1 score (for the fixed value of ? computed in Task 4 and ? in Task
% 3) and compare with the non-recursive version for the three proposed sequences and
% comment the results.

%% Stauffer and Grimson
%% Task 6
% Use the S&G approach and compute the F1 score for the three provided sequences
% using a different number of gaussians (from 3 to 6). Find out the optimal number
% and comment the results obtained.

task6;

%% Task 7
% Compare your gaussian modeling of the Background pixels with S&G using the
% F1 score and comment which sequences benefit more from using more gaussians in
% the modeling.

%% Optionals
%% Task 8
% Update the single gaussian functions (recursive and non-recursive) to work with
% color images and use them to obtain the F1 score of the three proposed sequences.

task8_1;
task8_2;
