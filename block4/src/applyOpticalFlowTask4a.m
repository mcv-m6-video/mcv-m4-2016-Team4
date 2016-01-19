function [ flow, GTfiles ] = applyOpticalFlowTask4a( frames, outputPath, orderId, saveIm, VERBOSE )
%APPLYOPTICALFLOWTASK2 Apply Lucas-Kanade
    
    if ~exist('VERBOSE','var')
        VERBOSE = 0;
    end
    
    if ~exist('saveIm','var')
        saveIm = false;
    end

    % Apply the optical flow estimation to each frame
    for i = 2:size(frames,3)
        uv = estimate_flow_interface(frames(:,:,i-1), frames(:,:,i), 'classic+nl-fast');
        flow{i-1} = opticalFlow(double(uv(:,:,1)), double(uv(:,:,2)));
        
        % Get associated GT file name
        tmp = strsplit(outputPath, filesep);
        GTfiles{i-1} = [tmp{end} orderId(i-1,:) '.png'];
        
        if VERBOSE
            imshow(frame);
            hold on;
            plot(flow{i-1},'DecimationFactor',[5 5],'ScaleFactor',10);
            hold off;
        end

        if saveIm
            tmp = opticalFlow2GT(flow{i-1}.Vx, flow{i-1}.Vy);
            imwrite(tmp , [outputPath, orderId(i-1,:) '.png'])
        end
        
    end

end

