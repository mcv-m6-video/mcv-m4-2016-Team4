function staufferGrimsonMultipleGaussian( sequence , folderPath , fileFormat , pathResults , nGaussians , colorIm , colorTransform , verbose )
% staufferGrimsonMultipleGaussian: uses the Stauffer & Grimson Multiple
% Gaussian approach to segment a video frame between background and
% foreground.
    % check if we want to use colour
    if ~exist('colorTransform', 'var')
        colorTransform = @(x) x;
    end
    
    if ~exist('colorIm', 'var')
        colorIm = false;
    end
    
    if ~exist('verbose', 'var')
        verbose = false;
    end
    
    if verbose
        figure;
    end
    
    % First 50% of the test sequence to train the model
    detector = vision.ForegroundDetector('NumTrainingFrames',floor(length(sequence)/2), 'NumGaussians', nGaussians);
    
    % Second 50% to segment the foreground
    for i = (floor(length(sequence)/2)+1):length(sequence)
        % Read image
        imName = sprintf('%06d', sequence(i));
        fileName = [ folderPath , imName , fileFormat ];
        im = imread(fileName);
        
        % Segment between background and foreground
        % background --> 0      foreground --> 1
        foregroundMask = step(detector, im);
        
        if verbose
            imshow(foregroundMask, []);
            drawnow();
        end
        
        % Save image
        imwrite(foregroundMask , [ pathResults , imName , '.png' ] )
    end % for

end