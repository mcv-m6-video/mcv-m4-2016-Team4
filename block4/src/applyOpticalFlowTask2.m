function [  ] = applyOpticalFlowTask2( frames, outputPath )
%APPLYOPTICALFLOWTASK2 Apply Lucas-Kanade
    
    if ~exist('VERBOSE','var')
        VERBOSE = 0;
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
        
        %     Optical flow maps are saved as 3-channel uint16 PNG images: The first channel
        %     contains the u-component, the second channel the v-component and the third
        %     channel denotes if a valid ground truth optical flow value exists for that
        %     pixel (1 if true, 0 otherwise). To convert the u-/v-flow into floating point
        %     values, convert the value to float, subtract 2^15 and divide the result by 64:
        % 
        %     flow_u(u,v) = ((float)I(u,v,1)-2^15)/64.0;
        %     flow_v(u,v) = ((float)I(u,v,2)-2^15)/64.0;
        %     valid(u,v)  = (bool)I(u,v,3);
        flow_im = uint16(zeros(size(flow.Vx,1),size(flow.Vx,2),3));
        flow_im(:,:,1) = (64*flow.Vx+2^15);
        flow_im(:,:,2) = (64*flow.Vy+2^15);
        flow_im(:,:,3) = ones(size(flow_im(:,:,3)));
        imwrite(flow_im, [outputPath, '_', num2str(i) '.png']);
    end

end

