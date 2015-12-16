function plotOpticalFlow(realImage, annotationImage, subSample)
%PLOTOPTICALFLOW show the optical flow valids
%   Parameters:
%       * realImage: the realimage RGB
%       * annotationImage: the opticalFlow annotations
%       * subSample: Numbers of subsamples

    if ~exist('subSample', 'var')
        subSample=9;
    end
    
    % Convert to a impar value (It is necessary for the padding conditions)
    subSample = floor(subSample/2)*2 + 1;

    % Create the figure
    figure;
    
    % Show the realImage
    imshow(rgb2gray(realImage))
    hold on;
    
    % Valid pixels
    valids = annotationImage(:,:,3)==1;
    
    % Creates the optical flow
    [x, y] = meshgrid(1:size(realImage, 2), 1:size(realImage, 1));
    
    u = annotationImage(:,:,1);
    v = annotationImage(:,:,2);
    
    % Calculate the mean of each point between the number of subSample neighboors, to
    % avoid the zero-padding we apply the mirroring padarray
    marginSubSample = floor(subSample/2);
    u = padarray(u, [marginSubSample, marginSubSample], 'replicate');
    u = conv2(u, (1/(subSample^2))*ones(subSample), 'valid');
    
    v = padarray(v, [marginSubSample, marginSubSample], 'replicate');
    v = conv2(v, (1/(subSample^2))*ones(subSample), 'valid');
    
    % Apply the subsample to do a more simple representation
    % Delete the non valid pixels
    % And convert to double to avoid types problems...
    ind = mod(x, subSample)==0 & mod(y, subSample)==0 & valids;
    x = double(x(ind));
    y = double(y(ind));
    u = double(u(ind));
    v = double(v(ind));
    
    % Show the vectors
    quiver(x, y, u, v, 1.5, 'r', 'LineWidth', 1.2)
    xlim([1, size(realImage,2)])
    ylim([1, size(realImage,1)])
    
    hold off;
end
