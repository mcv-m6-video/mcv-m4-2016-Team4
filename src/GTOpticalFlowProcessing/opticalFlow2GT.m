function flow_im = opticalFlow2GT(Vx, Vy, indicateValidPixels)
%     Optical flow maps are saved as 3-channel uint16 PNG images: The first channel
%     contains the u-component, the second channel the v-component and the third
%     channel denotes if a valid ground truth optical flow value exists for that
%     pixel (1 if true, 0 otherwise). To convert the u-/v-flow into floating point
%     values, convert the value to float, subtract 2^15 and divide the result by 64:
% 
%     flow_u(u,v) = ((float)I(u,v,1)-2^15)/64.0;
%     flow_v(u,v) = ((float)I(u,v,2)-2^15)/64.0;
%     valid(u,v)  = (bool)I(u,v,3);

    flow_im = uint16(zeros(size(Vx,1),size(Vx,2),3));
    flow_im(:,:,1) = (64*Vx+2^15);
    flow_im(:,:,2) = (64*Vy+2^15);
    if exist('indicateValidPixels', 'var')
        flow_im(:,:,3) = indicateValidPixels;
    else
        flow_im(:,:,3) = ones(size(flow_im(:,:,3)));
    end
            
end