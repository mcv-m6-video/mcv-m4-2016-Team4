function [ flow, GTfiles ] = applyOpticalFlowTask1( frames, outputPath, orderId, compensation, areaSearch, blockSize, stepSlidingWindow, saveIm, VERBOSE )
%APPLYOPTICALFLOWTASK1 Block matching optical flow
    
    if ~exist('saveIm','var')
        saveIm = false;
    end
    
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
            iterator = 1:size(frames,3);
            direction = 1;
        case 'backward'
            % Backward compensation
            iterator = size(frames, 3):-1:1;
            direction = -1;
    end
    
    % The first frames is used as baseline
    %frame = frames(:,:,indFirst);

    
    % Apply the optical flow estimation to each frame
    for i = 1:(length(iterator)-1)
        frame = frames(:,:,iterator(i));
        framePlus = frames(:,:,iterator(i+1));
        
        % Block Matching
        results = BlockMatching(frame, framePlus, params);
        
        flow{i} = opticalFlow(results.imRelative(:,:,1)*direction, results.imRelative(:,:,2)*direction);
        
        % Get associated GT file name
        tmp = strsplit(outputPath, filesep);
        GTfiles{i} = [tmp{end} orderId(i,:) '.png'];
        
        
        if VERBOSE
            imshow(frame)
            hold on
            plot(flow{i},'DecimationFactor',[5 5],'ScaleFactor',10)
            hold off
        end
        
        if saveIm
            tmp = opticalFlow2GT(flow{i-1}.Vx, flow{i-1}.Vy, indicateValidPixels);
            imwrite([outputPath, orderId(i-1,:) '.png'], tmp)
        end
    end

end

