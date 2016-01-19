function video = readVideo(framesPath, framesInd, imageFormat)
% Given a path that contains images, it reads the images specified by
% framesInd.
% Output: - video: NxMxK matrix where NxM is the size of the frames and K
%                  is the total amount of frames

    % First iteration is done before so we can initialize the video
    % sequence matrix
    frameName = sprintf('%06d', framesInd(1));
    framePath = [ framesPath , frameName , imageFormat ];
    frame = imread(framePath);
    if size(frame,3) == 3
       frame = rgb2gray(frame) ;
    end
    
    % video is an NxMxK matrix, where NxM is the size of the frames and
    % K is the total number of frames.
    video = zeros(size(frame,1), size(frame,2), length(framesInd), 'like', frame);
    video(:,:,1) = frame;
    
    % For every indicated frame in the sequence
    for i=2:length(framesInd)
        % Read the frame of the sequence
        frameName = sprintf('%06d', framesInd(i));
        framePath = [ framesPath , frameName , imageFormat ];
        frame = imread(framePath);
        if size(frame,3) == 3
            frame = rgb2gray(frame) ;
        end
        % Accumulate it on the video
        video(:,:,i) = frame;
    end
end