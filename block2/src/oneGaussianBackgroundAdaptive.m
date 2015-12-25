function [ ] = oneGaussianBackgroundAdaptive( sequence , folderPath , fileFormat , pathResults , alpha, rho)
%ONEGAUSSIANBACKGROUND Summary of this function goes here
%   Detailed explanation goes here

    if ~exist('alpha', 'var')
        alpha = 2.5;
    end
    
    % First 50% of the test sequence to model the background
    cumpixel = [];
    for i = 1:floor(length(sequence)/2)
        imName = sprintf('%06d', sequence(i));
        fileName = [ folderPath , imName , fileFormat ];
        im = double( rgb2gray( imread(fileName) ) );
        cumpixel = cat(3 , cumpixel , im );
    end % for
    
    % Prevent low values of sigma
    mu = mean(cumpixel , 3);
    sigma_square = var(cumpixel , 0 , 3);
    % Second 50% to segment the foreground
    for i = (floor(length(sequence)/2)+1):length(sequence)
        % Adapt the mu and sigma
        sigma = sqrt(sigma_square); 
        sigma_plus2 = sigma + 2;
        
        
        imName = sprintf('%06d', sequence(i));
        fileName = [ folderPath , imName , fileFormat ];
        im = double( rgb2gray( imread(fileName) ) );
        background = ~(abs(im - mu) < (alpha*sigma_plus2));
              
        applyRho = (~background).*rho;
        
        sigma_square = (1-applyRho).*sigma_square + applyRho.*((im - mu).^2);
        mu = (1-applyRho).*mu + applyRho.*im;
        
        imwrite(background , [ pathResults , imName , '.png' ] )
    end % for
    
end % function

