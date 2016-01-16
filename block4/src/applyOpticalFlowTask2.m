function [  ] = applyOpticalFlowTask2( frames )
%APPLYOPTICALFLOWTASK2 Apply Lucas-Kanade
    
    if ~exist('VERBOSE','var')
        VERBOSE = 1;
    end
    
    if ~exist('NoiseThreshold','var')
        NoiseThreshold = 0.009;
    end
    
    % Create optical flow Lucas Kanade object
    opticFlow = opticalFlowLK('NoiseThreshold',NoiseThreshold);
    
    % Apply the optical flow estimation to each frame
    for i = 1:size(frames,4)
        frameRGB = frames(:,:,:,i);

        % Get and store estimation
        flow = estimateFlow(opticFlow,frameGray);

        if VERBOSE
            imshow(frameRGB)
            hold on
            plot(flow,'DecimationFactor',[5 5],'ScaleFactor',10)
            hold off
        end
    end

end

