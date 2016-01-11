function [ shadowMask ] = shadowRemoval( imOrig, mask, background, alpha, beta, threshS, threshH )
%shadowRemoval Shadow removal alogrithm
%   Following the paper:
%       Detecting Moving Objects, Ghosts, and Shadows in Video Streams
%   by Rita Cucchiara
%   Reported as the best algorithm in the paper:
%       Shadow detection: A survey and comparative evaluation of recent methods.
%   by Sanin
%   Continues the idea of the paper from the same author:
%       Improving shadow suppression in moving object detection with HSV color information.

    % Parameters that will be needed
    % Following the parameters used in:
    %       Improving shadow suppression in moving object detection with HSV color information.

    if ~exist('alpha', 'var')
        alpha = 0.4; % [0..1]
    end
    if ~exist('beta', 'var')
        beta = 0.6; % [0..1]
    end
    if ~exist('threshS', 'var')
        threshS = 0.5;
    end
    if ~exist('threshH', 'var')
        threshH = 0.1;
    end
    
    % Work in HSV colorspace
    im = rgb2hsv( imOrig );
    H = im(:,:,1); S = im(:,:,2); V = im(:,:,3);        
    B = rgb2hsv(lab2rgb(background));
    
    % Three conditions to be background
    Cond1_value = (V)./(B(:,:,3)); % Value
    Cond1_value(B(:,:,3)==0) = -1; % Don't care for NaN
    Cond2_value = abs(S-B(:,:,2));% Saturation
    Cond3_value = min(abs(H-B(:,:,1)), 360-abs(H-B(:,:,1))); % Hue

    Cond1 = (Cond1_value>=alpha) .* (Cond1_value<=beta);
    Cond2 = (Cond2_value<=threshS);
    Cond3 = (Cond3_value<=threshH);

    % Apply all the conditions and restringe it to the mask 
    shadowMask = Cond1.*Cond2.*Cond3.*mask;
end

