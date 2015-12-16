function plotOpticalFlow(realImage, annotationImage, subSample)
%PLOTOPTICALFLOW show the optical flow valids
%   Parameters:
%       * realImage: the realimage RGB
%       * annotationImage: the opticalFlow annotations
%       * subSample: Numbers of subsamples

    if ~exist('subSample', 'var')
        subSample=10;
    end

    figure;
    
    % Show the realImage
    imshow(realImage)
    hold on;
    
    % Valid pixels
    valids = annotationImage(:,:,3);
    
    % Creates the optical flow
    [x, y] = meshgrid(1:size(realImage, 2), 1:size(realImage, 1));
    
    u = annotationImage(:,:,1);
    v = annotationImage(:,:,2);
    
    % Apply the subsample to do a more simple representation
    % Delete the non valid pixels
    % And convert to double to avoid types problems...
    ind = mod(x, subSample)==0 & mod(y, subSample)==0 & valids;
    x = double(x(ind));
    y = double(y(ind));
    u = double(u(ind));
    v = double(v(ind));
    
    % Show the vectors
    quiver(x, y, u, v, 'r')
    xlim([1, size(realImage,2)])
    ylim([1, size(realImage,1)])
    
    hold off;
end
