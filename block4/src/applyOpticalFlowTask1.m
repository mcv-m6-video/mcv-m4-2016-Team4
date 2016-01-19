function [ flow, GTfiles ] = applyOpticalFlowTask1( frames, outputPath, orderId, compensation, areaSearch, blockSize, stepSlidingWindow )
%APPLYOPTICALFLOWTASK1 Block matching optical flow
    
    if ~exist('VERBOSE','var')
        VERBOSE = 0;
    end
    if ~exist('compensation','var')
        compensation = 'forward';
    end    % Typical setup
    if ~exist('blockSize','var')
        blockSize = [16, 16];
    end
    if ~exist('areaSearch','var')
        areaSearch = blockSize(1)+blockSize(1)/2;
    end
    
    if ~exist('stepSlidingWindow','var')
        stepSlidingWindow = 20;
    end
    
    % BlockMatching params
    params.blockSize = blockSize;
    params.radiousSearch = areaSearch;
    params.stepSlidingWindow = stepSlidingWindow;
    
    switch(compensation)
        case 'forward'
            % Forward compensation
            %iterator = 2:size(frames,3);
            %indFirst = 1;
            iterator = 1:size(frames,3);
        case 'backward'
            % Backward compensation
            %iterator = size(frames,3)-1:1;
            %indFirst = size(frames,3);
            iterator = size(frames, 3):-1:1;
    end
    
    % The first frames is used as baseline
    %frame = frames(:,:,indFirst);

    
    % Apply the optical flow estimation to each frame
    for i = 1:(length(iterator)-1)
        frame = frames(:,:,iterator(i));
        framePlus = frames(:,:,iterator(i+1));
        
        % Block Matching
        results = BlockMatching(frame, framePlus, params);
        
        flow{i} = opticalFlow(results.imRelative(:,:,1), results.imRelative(:,:,2));
        
        % Get associated GT file name
        tmp = strsplit(outputPath, filesep);
        GTfiles{i} = [tmp{end} orderId(i,:) '.png'];
        
        
        if VERBOSE
            imshow(frame)
            hold on
            plot(flow{i},'DecimationFactor',[5 5],'ScaleFactor',10)
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
%         flow_im = uint16(zeros(size(flow.Vx,1),size(flow.Vx,2),3));
%         flow_im(:,:,1) = (64*flow.Vx+2^15);
%         flow_im(:,:,2) = (64*flow.Vy+2^15);
%         flow_im(:,:,3) = ones(size(flow_im(:,:,3)));
        %imwrite(flow_im, [outputPath, orderId(i-1,:) '.png']);
    end

end

