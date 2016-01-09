function [ segmentedMasks, maskNames ] = oneGaussianBackgroundAdaptive( sequence , folderPath , fileFormat , alpha , rho , colorIm , colorTransform , saveIm , pathResults)
%ONEGAUSSIANBACKGROUND Summary of this function goes here
%   Input: 
%       - saveIm: instead of returning the masks (segmentedMasks), they
%                 will be stored at 'pathResults'
%   Output: 
%       - segmentedMasks: NxMxK matrix, where N and M are the size of the
%         frames processed and K are the numbers of frames. For example, 
%         300x300x10 means that there are 10 frames of size 300x300.
%       - maskNames: K cell array containing the names of every mask, so it
%         can be later evaluated by relating the mask to a ground truth image.

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
    
    if ~exist('saveIm', 'var')
        saveIm = true;
    end
    
    % First 50% of the test sequence to model the background
    if colorIm
        cumpixel = cell(1,3);
    else
        cumpixel = cell(1,1);
    end
    
    segmentedMasks = [];
    maskNames = cell(0,0);
    
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
    
    if ~saveIm
        % Read image to know size of the masks
        segmentedMasks = false(size(im,1), size(im,2), floor(length(sequence)/2));
    end
    
    % Second 50% to segment the foreground
    count = 1;
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
        
        applyRho = repmat( (~background).*rho,[1,1,size(im,3)] );
        
        mu = (1-applyRho).*mu + applyRho.*im;
        sigma_square = (1-applyRho).*sigma_square + applyRho.*((im - mu).^2);
        if saveIm
            imwrite(background , [ pathResults , imName , '.png' ] );
        else
            segmentedMasks(:,:,count) = background;
            maskNames{count} = imName;
            count = count + 1;
        end
    end % for
    
end % function

