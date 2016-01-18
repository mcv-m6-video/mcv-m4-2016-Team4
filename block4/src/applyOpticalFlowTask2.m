function [ flow, GTfiles ] = applyOpticalFlowTask2( frames, outputPath, orderId, NoiseThreshold, saveIm, VERBOSE )
%APPLYOPTICALFLOWTASK2 Apply Lucas-Kanade
    
    if ~exist('VERBOSE','var')
        VERBOSE = 0;
    end
    
    if ~exist('NoiseThreshold','var')
        NoiseThreshold = 0.009;
    end
    
    if ~exist('save','var')
        saveIm = false;
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
        flow{i-1} = estimateFlow(opticFlow,frame);
        
        % Get associated GT file name
        tmp = strsplit(outputPath, filesep);
        GTfiles{i-1} = [tmp{end} orderId(i-1,:) '.png'];
        
        if VERBOSE
            imshow(frame);
            hold on;
            plot(flow,'DecimationFactor',[5 5],'ScaleFactor',10);
            hold off;
        end

        if saveIm
            tmp = opticalFlow2GT(flow{i-1}.Vx, flow{i-1}.Vy, indicateValidPixels);
            imwrite([outputPath, orderId(i-1,:) '.png'], tmp)
        end
        
    end

end

