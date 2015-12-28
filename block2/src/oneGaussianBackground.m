function [mu, sigma] = oneGaussianBackground( sequence , folderPath , fileFormat , pathResults , alpha , colorIm , colorTransform )
%ONEGAUSSIANBACKGROUND Summary of this function goes here
%   Detailed explanation goes here

    if ~exist('alpha', 'var')
        alpha = 2.5;
    end
    
    % check if we want to use colour
    if ~exist('colorTransform', 'var')
        colorTransform = @(x) x;
    end
    
    if ~exist('colorIm', 'var')
        colorIm = false;
    end
    
    % First 50% of the test sequence to model the background
    if colorIm
        cumpixel = cell(1,3);
    else
        cumpixel = cell(1,1);
    end
    
    for i = 1:floor(length(sequence)/2)
        imName = sprintf('%06d', sequence(i));
        fileName = [ folderPath , imName , fileFormat ];
        im = imread(fileName);
        if ~colorIm
            im = rgb2gray( im );
        else
            im = colorTransform( im );
        end
        im = double( im );
        for j = 1:size(im,3)
            cumpixel{j} = cat(3 , cumpixel{j} , im(:,:,j) );
        end
    end % for
    
    muAux = cellfun(@(x) mean(x,3), cumpixel, 'UniformOutput', false);
    sigmaAux = cellfun(@(x) std(x , 0 , 3), cumpixel, 'UniformOutput', false);
    
    mu = []; sigma = [];
    for i = 1:length(muAux)
        mu = cat(3 , mu , muAux{i} );
        sigma = cat(3 , sigma , sigmaAux{i} );
    end
    
    % Prevent low values of sigma
    sigma = sigma + 2;
    
    % Second 50% to segment the foreground
    for i = (floor(length(sequence)/2)+1):length(sequence)
        imName = sprintf('%06d', sequence(i));
        fileName = [ folderPath , imName , fileFormat ];
        im = imread(fileName);
        if ~colorIm
            im = rgb2gray( im );
        else
            im = colorTransform( im );
        end
        im = double( im );
        background = ~(prod(abs(im - mu),3) < prod(alpha*sigma,3));
        imwrite(background , [ pathResults , imName , '.png' ] )
    end % for
    
end % function

