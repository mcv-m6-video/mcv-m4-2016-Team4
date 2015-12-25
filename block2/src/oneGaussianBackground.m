function [mu, sigma] = oneGaussianBackground( sequence , folderPath , fileFormat , pathResults , alpha , muPrev , sigmaPrev, rho )
%ONEGAUSSIANBACKGROUND Summary of this function goes here
%   Detailed explanation goes here

    if ~exist('alpha', 'var')
        alpha = 2.5;
    end
    
    if ~exist('rho', 'var')
        muPrev = 1;
        sigmaPrev = 1;
        rho = 1;
    end
    
    % First 50% of the test sequence to model the background
    cumpixel = [];
    for i = 1:floor(length(sequence)/2)
        imName = sprintf('%06d', sequence(i));
        fileName = [ folderPath , imName , fileFormat ];
        im = double( rgb2gray( imread(fileName) ) );
        cumpixel = cat(3 , cumpixel , im );
    end % for
    
    mu = rho*mean(cumpixel , 3) + (1-rho)*muPrev;
    sigmas_quare = rho*var(cumpixel , 0 , 3) + (1-rho)*(sigmaPrev*sigmaPrev);
    sigma = sqrt(sigmas_quare);
    
    % Prevent low values of sigma
    sigma = sigma + 2;
    % Second 50% to segment the foreground
    for i = (floor(length(sequence)/2)+1):length(sequence)
        imName = sprintf('%06d', sequence(i));
        fileName = [ folderPath , imName , fileFormat ];
        im = double( rgb2gray( imread(fileName) ) );
        background = ~(abs(im - mu) < (alpha*sigma));
        imwrite(background , [ pathResults , imName , '.png' ] )
    end % for
    
end % function

