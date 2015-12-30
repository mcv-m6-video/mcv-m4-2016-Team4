function [ ] = oneGaussianBackgroundAdaptive( sequence , folderPath , fileFormat , pathResults , alpha, rho , colorIm , colorTransform)
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
        im = imread( fileName );
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
    sigmaAux = cellfun(@(x) var(x , 0 , 3), cumpixel, 'UniformOutput', false);
    
    % Conversion from cell to matrix
    mu = []; sigma_square = [];
    for i = 1:length(muAux)
        mu = cat(3 , mu , muAux{i} );
        sigma_square = cat(3 , sigma_square , sigmaAux{i} );
    end
    
    % Second 50% to segment the foreground
    for i = (floor(length(sequence)/2)+1):length(sequence)
        % Adapt the mu and sigma
        sigma = sqrt(sigma_square);
        % Prevent low values of sigma
        sigma_plus2 = sigma + 2;
        
        
        imName = sprintf('%06d', sequence(i));
        fileName = [ folderPath , imName , fileFormat ];
        im = imread( fileName );
        if ~colorIm
            im = rgb2gray( im );
        else
            im = colorTransform( im );
        end
        im = double( im );
        % background --> 0      foreground --> 1
        background = ~(abs(im - mu) < (alpha*sigma_plus2));
                
        % In case of color images, if any dimension falls outside the
        % gaussian, it will be considered as foreground
        background = any(background,3);
        
        applyRho = repmat( (~background).*rho,1,1,size(im,3) );
        
        mu = (1-applyRho).*mu + applyRho.*im;
        sigma_square = (1-applyRho).*sigma_square + applyRho.*((im - mu).^2);
        
        imwrite(background , [ pathResults , imName , '.png' ] )
    end % for
    
end % function

