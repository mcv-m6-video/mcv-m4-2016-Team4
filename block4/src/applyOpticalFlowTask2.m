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
    
    % The first frames is used as baseline
    frame = frames(:,:,1);

    % Get and store estimation
    estimateFlow(opticFlow,frame);
    
    % Apply the optical flow estimation to each frame
    for i = 2:size(frames,3)
        frame = frames(:,:,i);

        % Get and store estimation
        flow = estimateFlow(opticFlow,frame);

        if VERBOSE
            imshow(frame)
            hold on
            plot(flow,'DecimationFactor',[5 5],'ScaleFactor',10)
            hold off
        end
    end

end

